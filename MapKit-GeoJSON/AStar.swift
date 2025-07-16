//
//  AStar.swift
//  MapKit-GeoJSON
//
//  Created by Jerry Febriano on 16/07/25.
//

import Foundation
import MapKit

fileprivate class Node {
    let annotation: CustomPointAnnotation
    var parent: Node?
    var gCost: Double = 0 // Cost from start to this node
    var hCost: Double = 0 // Heuristic cost to end node
    var fCost: Double { gCost + hCost } // Total cost
    
    init(annotation: CustomPointAnnotation) {
        self.annotation = annotation
    }
}

extension Node: Hashable {
    static func == (lhs: Node, rhs: Node) -> Bool {
        return lhs.annotation === rhs.annotation
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(annotation))
    }
}


/// Finds the shortest path between two points using the A* algorithm.
/// - Parameters:
///  - start: The starting point as a `CustomPointAnnotation`.
///  - end: The ending point as a `CustomPointAnnotation`.
///  - nodes: All possible annotations as `CustomPointAnnotation` objects.
///  - obstacles: Polygon overlays that block movement.
/// - Returns: An array of `CustomPointAnnotation` representing the shortest path, or nil if no path is found.
func findPath(from start: CustomPointAnnotation, to end: CustomPointAnnotation, nodes: [CustomPointAnnotation], obstacles: [MKPolygon]) -> [CustomPointAnnotation]? {
    let startNode = Node(annotation: start)
    let endNode = Node(annotation: end)

    var openList = [startNode]
    var closedList = Set<Node>()

    while !openList.isEmpty {
        // Find the node with the lowest F cost in the open list
        openList.sort { $0.fCost < $1.fCost }
        let currentNode = openList.removeFirst()
        closedList.insert(currentNode)

        // Path found
        if currentNode == endNode {
            var path: [CustomPointAnnotation] = []
            var current: Node? = currentNode
            while let node = current {
                path.append(node.annotation)
                current = node.parent
            }
            return path.reversed()
        }

        // Check neighbors
        for otherAnnotation in nodes where otherAnnotation !== currentNode.annotation {
            let neighborNode = Node(annotation: otherAnnotation)
            if closedList.contains(neighborNode) {
                continue
            }

            // Check if the path to the neighbor is blocked by a wall
            if isPathObstructed(from: currentNode.annotation.coordinate, to: neighborNode.annotation.coordinate, by: obstacles) {
                continue
            }

            let moveCost = distance(from: currentNode.annotation.coordinate, to: neighborNode.annotation.coordinate)
            let newGCost = currentNode.gCost + moveCost

            if newGCost < neighborNode.gCost || !openList.contains(neighborNode) {
                neighborNode.gCost = newGCost
                neighborNode.hCost = distance(from: neighborNode.annotation.coordinate, to: endNode.annotation.coordinate)
                neighborNode.parent = currentNode

                if !openList.contains(neighborNode) {
                    openList.append(neighborNode)
                }
            }
        }
    }

    return nil // No path found
}

// MARK: - Helper Functions

/// Calculates the straight-line distance between two coordinates.
private func distance(from start: CLLocationCoordinate2D, to end: CLLocationCoordinate2D) -> Double {
    return MKMapPoint(start).distance(to: MKMapPoint(end))
}

/// Checks if the path between two coordinates is obstructed by any polygon overlays.
private func isPathObstructed(from start: CLLocationCoordinate2D, to end: CLLocationCoordinate2D, by obstacles: [MKPolygon]) -> Bool {
    let pathLine = MKPolyline(coordinates: [start, end], count: 2)
    let pathRect = pathLine.boundingMapRect
    
    for obstacle in obstacles {
        if !obstacle.boundingMapRect.intersects(pathRect) {
            continue
        }
        
        // A more precise (but more complex) check would be to test for line-polygon intersection.
        // For simplicity, we can check if the midpoint of the path is inside an obstacle.
        let midPoint = MKMapPoint(CLLocationCoordinate2D(
            latitude: (start.latitude + end.latitude) / 2,
            longitude: (start.longitude + end.longitude) / 2
        ))
        
        let renderer = MKPolygonRenderer(polygon: obstacle)
        let pointInPath = renderer.path.contains(renderer.point(for: midPoint))
        
        if pointInPath {
            return true // Path is obstructed
        }
    }
    
    return false
}
