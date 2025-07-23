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
                        count: polygon.pointCount
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
    
    public func updateRoute(from start: CustomPointAnnotation?, to end: CustomPointAnnotation?) {
        clearRoute()
        
        guard let start = start, let end = end else {
            return
        }
        
        findAndDisplayRoute(from: start, to: end)
    }

    private func findAndDisplayRoute(from start: CustomPointAnnotation, to end: CustomPointAnnotation) {
        guard let graph = graph else { return }

        let startNode = GKGraphNode2D(point: [Float(start.coordinate.latitude), Float(start.coordinate.longitude)])
        let endNode = GKGraphNode2D(point: [Float(end.coordinate.latitude), Float(end.coordinate.longitude)])

        graph.add([startNode, endNode])
        graph.connectUsingObstacles(node: startNode)
        graph.connectUsingObstacles(node: endNode)

        let pathNodes = graph.findPath(from: startNode, to: endNode) as! [GKGraphNode2D]
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
                    top: 40,
                    left: 40,
                    bottom: 40,
                    right: 40
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

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: any MKOverlay)
        -> MKOverlayRenderer
    {
        if let polygon = overlay as? CustomPolygon {
            let renderer = MKPolygonRenderer(polygon: polygon)
            let objectType = polygon.properties?.object_type

            switch objectType {
            case "building":
                renderer.fillColor = UIColor.systemGray5.withAlphaComponent(0.6)
                renderer.strokeColor = UIColor.systemGray3
                renderer.lineWidth = 1.0
            case "room":
                renderer.fillColor = UIColor.systemBlue.withAlphaComponent(0.2)
                renderer.strokeColor = UIColor.systemBlue.withAlphaComponent(0.8)
                renderer.lineWidth = 1.0
            case "wall", "pillar":
                renderer.fillColor = UIColor.systemGray3.withAlphaComponent(0.8)
                renderer.strokeColor = UIColor.systemGray2
                renderer.lineWidth = 0.5
            case "table", "obstacle":
                renderer.fillColor = UIColor.systemGray4.withAlphaComponent(0.7)
                renderer.strokeColor = UIColor.systemGray3
                renderer.lineWidth = 0.5
            case "locker":
                renderer.fillColor = UIColor.systemYellow.withAlphaComponent(0.2)
                renderer.strokeColor = UIColor.systemYellow
                renderer.lineWidth = 1.0
            default:
                renderer.fillColor = UIColor.systemGray.withAlphaComponent(0.3)
                renderer.strokeColor = UIColor.systemGray
                renderer.lineWidth = 1.0
            }
            return renderer
        }

        if let polyline = overlay as? CustomPolyline {
            let renderer = MKPolylineRenderer(polyline: polyline)
            renderer.strokeColor = UIColor.systemIndigo
            renderer.lineWidth = 3.0
            renderer.lineCap = .round
            return renderer
        }

        if let routePolyline = overlay as? MKPolyline, !(overlay is CustomPolyline) {
            let renderer = MKPolylineRenderer(polyline: routePolyline)
            renderer.strokeColor = .systemRed
            renderer.lineWidth = 4.0
            renderer.lineDashPattern = [2, 5]
            renderer.lineCap = .round
            return renderer
        }

        return MKOverlayRenderer(overlay: overlay)
    }

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
        }

        view.markerTintColor = UIColor.systemBlue
        view.glyphImage = UIImage(systemName: "mappin.circle.fill")

        if let name = customAnnotation.properties?.name.lowercased() {
            if name.contains("lab") {
                view.markerTintColor = UIColor.systemOrange
                view.glyphImage = UIImage(systemName: "desktopcomputer")
            } else if name.contains("pantry") || name.contains("kitchen") {
                view.markerTintColor = UIColor.systemGreen
                view.glyphImage = UIImage(systemName: "cup.and.saucer.fill")
            } else if name.contains("board") || name.contains("collab") {
                view.markerTintColor = UIColor.systemIndigo
                view.glyphImage = UIImage(systemName: "person.2.fill")
            } else if name.contains("locker") {
                view.markerTintColor = UIColor.systemGray
                view.glyphImage = UIImage(systemName: "lock.fill")
            }
        }
        return view
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
    let coordinates: [[Coordinate]]

    init(from mkPolygon: MKPolygon) {
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
            vector_float2(Float(coordinatePoint[0]), Float(coordinatePoint[1]))
        }
    }
}

extension MapViewController {
    func setupGraph() {
        let obstacles: [GKPolygonObstacle] = obstacles.compactMap { (geoJsonPolygon: GeoJSONPolygon) -> GKPolygonObstacle? in

            let points: [vector_float2] = geoJsonPolygon.toVectors()
            guard !points.isEmpty, points.count > 1 else { return nil }

            let mutablePoints = UnsafeMutablePointer<vector_float2>.allocate(capacity: points.count)
            mutablePoints.initialize(from: points, count: points.count)
            
            return GKPolygonObstacle(__points: mutablePoints, count: points.count)
        }

        graph = GKObstacleGraph(
            obstacles: obstacles,
            bufferRadius: 0.00001
        )
    }
}

struct FeatureProperties: Codable {
    let name: String
    let object_type: String?
}

class CustomPolygon: MKPolygon {
    var properties: FeatureProperties?
}

class CustomPolyline: MKPolyline {
    var properties: FeatureProperties?
}

class CustomPointAnnotation: MKPointAnnotation, Identifiable {
    var properties: FeatureProperties?
}
