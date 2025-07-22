//
//
//  MapViewController.swift
//  MapKit-GeoJSON
//
//  Created by Abimanyu Damarjati on 16/07/25.
//

import CoreLocation
import GameplayKit
import MapKit
import SwiftUI
import simd

extension CLLocationCoordinate2D {
    static let ada: Self = .init(
        latitude: -6.302015537374438,
        longitude: 106.65234872520136
    )
}

class MapViewController: UIViewController {
    // MARK: Properties - Map and Location
    private let locationManager = CLLocationManager()
    private var mapOverlays: [MKOverlay] = []
    private var obstacles: [GeoJSONPolygon] = []
    private var allObjects: [GeoJSONPolygon] = []
    private var graph: GKObstacleGraph? = nil

    // MARK: Pathfinding Properties
    private var startAnnotation: CustomPointAnnotation?
    private var endAnnotation: CustomPointAnnotation?
    private var routeOverlay: MKPolyline?

    private lazy var mapView: MKMapView = {
        let map = MKMapView()
        map.delegate = self
        map.translatesAutoresizingMaskIntoConstraints = false
        map.isRotateEnabled = false
        map.pointOfInterestFilter = .excludingAll

        let cameraBoundary = MKCoordinateRegion(center: .ada, latitudinalMeters: 50, longitudinalMeters: 50)
        map.cameraBoundary = MKMapView.CameraBoundary(coordinateRegion: cameraBoundary)
        map.cameraZoomRange = MKMapView.CameraZoomRange(
            minCenterCoordinateDistance: 50,
            maxCenterCoordinateDistance: 200
        )
        return map
    }()

    private func setupUI() {
        view.addSubview(mapView)
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupLocationManager()
        loadGeoJSON()
        setupGraph()
    }

    private func setupLocationManager() {
        locationManager.delegate = self

        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            mapView.showsUserLocation = true
            locationManager.startUpdatingLocation()
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            // Handle denied or restricted access
            print("Location access denied or restricted.")
            break
        @unknown default:
            fatalError("Unknown location authorization status.")
        }
    }

    private func focusMapOn(
        _ annotations: [MKAnnotation],
        _ overlays: [MKOverlay]
    ) {
        guard !overlays.isEmpty || !annotations.isEmpty else { return }

        var mapRect = MKMapRect.null

        for overlay in overlays {
            mapRect = mapRect.union(overlay.boundingMapRect)
        }

        for annotation in annotations {
            let pointRect = MKMapRect(
                origin: MKMapPoint(annotation.coordinate),
                size: MKMapSize(width: 0.1, height: 0.1)
            )
            mapRect = mapRect.union(pointRect)
        }

        mapView.cameraZoomRange = MKMapView.CameraZoomRange(
            minCenterCoordinateDistance: 50,
            maxCenterCoordinateDistance: 300
        )
        mapView
            .setVisibleMapRect(
                mapRect,
                edgePadding: UIEdgeInsets(
                    top: 20,
                    left: 20,
                    bottom: 20,
                    right: 20
                ),
                animated: true
            )
    }

    func loadGeoJSON() {
        guard
            let url = Bundle.main.url(
                forResource: "map-9",
                withExtension: "geojson"
            )
        else {
            fatalError("Failed to find GeoJSON file in the Bundle.")
        }

        do {
            let data = try Data(contentsOf: url)
            let geoJSONObjects = try MKGeoJSONDecoder().decode(data)

            let (parsedAnnotations, parsedOverlays) = parseGeoJSONFeatures(
                geoJSONObjects
            )
            mapOverlays = parsedOverlays

            mapView.addOverlays(parsedOverlays)
            mapView.addAnnotations(parsedAnnotations)

            focusMapOn(parsedAnnotations, parsedOverlays)

        } catch {
            print("Error loading GeoJSON data: \(error.localizedDescription)")
        }
    }

    private func parseGeoJSONFeatures(_ features: [MKGeoJSONObject]) -> (
        annotations: [MKAnnotation], overlays: [MKOverlay]
    ) {
        var overlays: [MKOverlay] = []
        var annotations: [MKAnnotation] = []

        for object in features {
            guard let feature = object as? MKGeoJSONFeature else { continue }

            var featureProperties: FeatureProperties?
            if let propertiesData = feature.properties {
                do {
                    featureProperties = try JSONDecoder()
                        .decode(FeatureProperties.self, from: propertiesData)
                } catch {
                    print(
                        "Error decoding feature properties: \(error.localizedDescription)"
                    )
                }
            }

            for geometry in feature.geometry {
                if let polygon = geometry as? MKPolygon {
                    let customPolygon = CustomPolygon(
                        points: polygon.points(),
                        count: polygon.pointCount,
                    )
                    customPolygon.properties = featureProperties
                    overlays.append(customPolygon)

                    let geoJsonPolygon = GeoJSONPolygon(from: polygon)

                    if !(featureProperties?.name == "Building") {
                        obstacles.append(geoJsonPolygon)
                    }

                    allObjects.append(geoJsonPolygon)
                } else if let polyline = geometry as? MKPolyline {
                    let customPolyline = CustomPolyline(
                        points: polyline.points(),
                        count: polyline.pointCount
                    )
                    customPolyline.properties = featureProperties
                    overlays.append(customPolyline)
                } else if let point = geometry as? MKPointAnnotation {
                    let customAnnotation = CustomPointAnnotation()
                    customAnnotation.coordinate = point.coordinate
                    customAnnotation.properties = featureProperties
                    customAnnotation.title = featureProperties?.name
                    annotations.append(customAnnotation)
                }
            }
        }

        return (annotations, overlays)
    }
}

extension MapViewController: MKMapViewDelegate {
    /// This delegate method is called for each overlay that is added to the map view.
    /// It allows us to customize the appearance of the overlay using a refined color palette.
    func mapView(_ mapView: MKMapView, rendererFor overlay: any MKOverlay)
        -> MKOverlayRenderer
    {
        // Style for Polygons (Buildings, Rooms, Walls, etc.)
        if let polygon = overlay as? CustomPolygon {
            let renderer = MKPolygonRenderer(polygon: polygon)
            let objectType = polygon.properties?.object_type

            switch objectType {
            // Base structure
            case "building":
                renderer.fillColor = UIColor.systemGray5.withAlphaComponent(0.6)
                renderer.strokeColor = UIColor.systemGray3
                renderer.lineWidth = 1.0

            // Important interior spaces
            case "room":
                renderer.fillColor = UIColor.systemBlue.withAlphaComponent(0.2)
                renderer.strokeColor = UIColor.systemBlue.withAlphaComponent(
                    0.8
                )
                renderer.lineWidth = 1.0

            // Structural elements
            case "wall", "pillar":
                renderer.fillColor = UIColor.systemGray3.withAlphaComponent(0.8)
                renderer.strokeColor = UIColor.systemGray2
                renderer.lineWidth = 0.5

            // Furniture and other interior objects
            case "table", "obstacle":
                renderer.fillColor = UIColor.systemGray4.withAlphaComponent(0.7)
                renderer.strokeColor = UIColor.systemGray3
                renderer.lineWidth = 0.5

            // Special designated areas
            case "locker":
                renderer.fillColor = UIColor.systemYellow.withAlphaComponent(
                    0.2
                )
                renderer.strokeColor = UIColor.systemYellow
                renderer.lineWidth = 1.0

            // Default for any unknown types
            default:
                renderer.fillColor = UIColor.systemGray.withAlphaComponent(0.3)
                renderer.strokeColor = UIColor.systemGray
                renderer.lineWidth = 1.0
            }

            return renderer
        }

        // Style for Polylines (e.g., navigation routes)
        if let polyline = overlay as? CustomPolyline {
            let renderer = MKPolylineRenderer(polyline: polyline)
            renderer.strokeColor = UIColor.systemIndigo
            renderer.lineWidth = 3.0
            renderer.lineCap = .round
            return renderer
        }

        // A* pathfinding routes
        if let routePolyline = overlay as? MKPolyline,
           !(overlay is CustomPolyline)
        {
            let renderer = MKPolylineRenderer(polyline: routePolyline)
            renderer.strokeColor = .systemRed
            renderer.lineWidth = 4.0
            renderer.lineDashPattern = [2, 5] // Dashed line for the route
            renderer.lineCap = .round
            return renderer
        }

        return MKOverlayRenderer(overlay: overlay)
    }

    /// This delegate method is called for each annotation that is added to the map view.
    /// It allows us to customize the appearance of the annotation view with semantic colors and icons.
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation)
        -> MKAnnotationView?
    {
        guard let customAnnotation = annotation as? CustomPointAnnotation else {
            return nil
        }

        let identifier = "CustomAnnotation"
        var view: MKMarkerAnnotationView

        if let dequeuedView = mapView.dequeueReusableAnnotationView(
            withIdentifier: identifier
        ) as? MKMarkerAnnotationView {
            dequeuedView.annotation = customAnnotation
            view = dequeuedView
        } else {
            view = MKMarkerAnnotationView(
                annotation: customAnnotation,
                reuseIdentifier: identifier
            )
            view.canShowCallout = true
            view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }

        // Default style
        view.markerTintColor = UIColor.systemBlue
        view.glyphImage = UIImage(systemName: "mappin.circle.fill")

        // Customize based on annotation name
        if let name = customAnnotation.properties?.name.lowercased() {
            if name.contains("lab") {
                view.markerTintColor = UIColor.systemOrange
                view.glyphImage = UIImage(systemName: "desktopcomputer") // More specific than a table
            } else if name.contains("pantry") || name.contains("kitchen") {
                view.markerTintColor = UIColor.systemGreen
                view.glyphImage = UIImage(systemName: "cup.and.saucer.fill")
            } else if name.contains("board") || name.contains("collab") {
                view.markerTintColor = UIColor.systemIndigo // Great for collaborative spaces
                view.glyphImage = UIImage(systemName: "person.2.fill")
            } else if name.contains("locker") {
                view.markerTintColor = UIColor.systemGray
                view.glyphImage = UIImage(systemName: "lock.fill")
            }
        }

        return view
    }

    func mapView(
        _ mapView: MKMapView,
        annotationView view: MKAnnotationView,
        calloutAccessoryControlTapped control: UIControl
    ) {
        guard let annotation = view.annotation as? CustomPointAnnotation else {
            return
        }

        if startAnnotation == nil {
            startAnnotation = annotation
            print(
                "Start point set: \(annotation.properties?.name ?? "Unknown")"
            )
        } else if endAnnotation == nil {
            endAnnotation = annotation
            print("End point set: \(annotation.properties?.name ?? "Unknown")")
            findAndDisplayRoute()
        } else {
            clearRoute()
            startAnnotation = annotation
            endAnnotation = nil
            print(
                "Start point reset: \(annotation.properties?.name ?? "Unknown")"
            )
        }
    }

    private func findAndDisplayRoute() {
        guard let start = startAnnotation, let end = endAnnotation else {
            return
        }

        guard let graph = graph else { return }

        let startNode = GKGraphNode2D(point: [Float(start.coordinate.latitude), Float(start.coordinate.longitude)])
        let endNode = GKGraphNode2D(point: [Float(end.coordinate.latitude), Float(end.coordinate.longitude)])

        graph.add([startNode, endNode])
        graph.connectUsingObstacles(node: startNode)
        graph.connectUsingObstacles(node: endNode)

        // 3. Find the path! This returns an array of GKGraphNode objects.
        let pathNodes = graph.findPath(from: startNode, to: endNode) as! [GKGraphNode2D]

        // 4. Convert the path nodes to a simple array of coordinates
        let pathCoordinates = pathNodes.map { $0.position }

        drawRoute(pathCoordinates)

        graph.remove([startNode, endNode])
    }

    private func drawRoute(_ path: [vector_float2]) {
        clearRoute()
        let coordinates = path.map { simd_float2 in
            CLLocationCoordinate2D(
                latitude: Double(simd_float2.x),
                longitude: Double(simd_float2.y)
            )
        }
        routeOverlay = MKPolyline(
            coordinates: coordinates,
            count: coordinates.count
        )
        if let routeOverlay = routeOverlay {
            mapView.addOverlay(routeOverlay)
            mapView.setVisibleMapRect(
                routeOverlay.boundingMapRect,
                edgePadding: UIEdgeInsets(
                    top: 20,
                    left: 20,
                    bottom: 20,
                    right: 20
                ),
                animated: true
            )
        }
    }

    private func clearRoute() {
        if let routeOverlay = routeOverlay {
            mapView.removeOverlay(routeOverlay)
        }
        routeOverlay = nil
    }
}

extension MapViewController: CLLocationManagerDelegate {
    func locationManager(
        _ manager: CLLocationManager,
        didChangeAuthorization status: CLAuthorizationStatus
    ) {
        setupLocationManager()
    }
}

typealias Coordinate = [Double]
struct GeoJSONPolygon: Codable {
    let coordinates: [[Coordinate]] // A Coordinate is [Double]

    init(from mkPolygon: MKPolygon) {
        // Helper function to convert an array of MKMapPoint to a GeoJSON
        func ring(from points: UnsafePointer<MKMapPoint>, count: Int) -> [Coordinate] {
            let buffer = UnsafeBufferPointer(start: points, count: count)
            return buffer.map { mapPoint -> Coordinate in
                let coord = mapPoint.coordinate
                return [coord.longitude, coord.latitude]
            }
        }

        let exteriorRing = ring(from: mkPolygon.points(), count: mkPolygon.pointCount)

        self.coordinates = [exteriorRing]
    }

    func toVectors() -> [vector_float2] {
        guard let exteriorRing = coordinates.first else {
            return []
        }

        return exteriorRing.map { coordinatePoint in
            // coordinatePoint[0] is x or longitude
            // coordinatePoint[1] is y or latitude
            vector_float2(Float(coordinatePoint[0]), Float(coordinatePoint[1]))
        }
    }
}

extension MapViewController {
    func setupGraph() {
        let obstacles: [GKPolygonObstacle] = obstacles.compactMap { (geoJsonPolygon: GeoJSONPolygon) -> GKPolygonObstacle? in

            let points: [vector_float2] = geoJsonPolygon.toVectors()
            guard !points.isEmpty, points.count > 1 else { return nil }

            return GKPolygonObstacle(points: points)
        }

        graph = GKObstacleGraph(
            obstacles: obstacles,
//            bufferRadius: 237.31317901611300, // Padding around obstacles
            bufferRadius: 200
        )
    }
}

/// Codable is being used to parse the GeoJSON data.
/// This is far better than using JSONSerialization, as it provides type safety and is easier to work with in Swift.
struct FeatureProperties: Codable {
    let name: String
    let object_type: String?
}

/// Custom MKPolygon subclass to hold additional properties.
/// This allows us to associate properties with the polygon, such as the state name.
class CustomPolygon: MKPolygon {
    var properties: FeatureProperties?
}

class CustomPolyline: MKPolyline {
    var properties: FeatureProperties?
}

class CustomPointAnnotation: MKPointAnnotation {
    var properties: FeatureProperties?
}

struct MapView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> MapViewController {
        return MapViewController()
    }

    func updateUIViewController(
        _ uiViewController: MapViewController,
        context: Context
    ) {
    }
}
