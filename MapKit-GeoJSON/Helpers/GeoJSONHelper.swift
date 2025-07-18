//
//  GeoJSONHelper.swift
//  MapKit-GeoJSON
//
//  Created by Abimanyu Damarjati on 17/07/25.
//

import simd

struct MapBoundary {
    let minX: Double
    let maxX: Double
    let minY: Double
    let maxY: Double
}

struct GeoJSONHelper {
    let rect: MapBoundary

    // TODO: Coba untuk ubah ke local coordinate space untuk GameplayKit pakai MapBoundary
    func toLocalCoordinateSpace(_ coordinate: vector_float2) {}

    func toGlobalCoordinateSpace(_ localCoordinates: vector_float2) {}
}
