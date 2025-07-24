//
//  MapViewModel.swift
//  JARVIS
//
//  Created by Jerry Febriano on 23/07/25.
//

import Combine
import Foundation
import MapKit

class MapViewModel: ObservableObject {
    @Published var locations: [CustomPointAnnotation] = []
    @Published var boothLocations: [CustomPointAnnotation] = []
    @Published var selectedCurrentLocation: CustomPointAnnotation?
    @Published var selectedDestinationLocation: CustomPointAnnotation?

    init() {
        loadLocations()
    }

    private func loadLocations() {
        guard
            let url = Bundle.main.url(
                forResource: "map-9",
                withExtension: "geojson"
            )
        else {
            fatalError("Failed to find GeoJSON file in the bundle")
        }

        do {
            let data = try Data(contentsOf: url)
            let geoJSONObjects = try MKGeoJSONDecoder().decode(data)
            let (parsedAnnotations, _) = parseGeoJSONFeatures(geoJSONObjects)
            self.locations = parsedAnnotations
            
            self.boothLocations = parsedAnnotations.filter {
                $0.properties?.object_type == "point" && $0.properties?.booth_type != nil
            }

        } catch {
            print("Error loading GeoJSON: \(error.localizedDescription)")
        }
    }

    private func parseGeoJSONFeatures(_ features: [MKGeoJSONObject]) -> (
        annotations: [CustomPointAnnotation], overlay: [MKOverlay]
    ) {
        var annotations: [CustomPointAnnotation] = []
        let overlay: [MKOverlay] = []

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
                if geometry is MKPointAnnotation {
                    let customAnnotation = CustomPointAnnotation()
                    customAnnotation.coordinate = geometry.coordinate
                    customAnnotation.properties = featureProperties
                    customAnnotation.title = featureProperties?.name
                    annotations.append(customAnnotation)
                }
            }
        }

        return (annotations, overlay)
    }
}
