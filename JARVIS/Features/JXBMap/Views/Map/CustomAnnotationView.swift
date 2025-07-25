//
//  CustomAnnotationView.swift
//  JARVIS
//
//  Created by Jerry Febriano on 25/07/25.
//

import MapKit
import SwiftUI

class CustomAnnotationView: MKAnnotationView {
    var onNavigateTapped: (() -> Void)?
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    private func setupView() {
        canShowCallout = false
        centerOffset = CGPoint(x: 0, y: -frame.height / 2)
    }
    
    override var annotation: MKAnnotation? {
        didSet {
            configure()
        }
    }
    
    private func configure() {
        guard let customAnnotation = annotation as? CustomPointAnnotation else { return }
        
        let booth = Booth(
            name: customAnnotation.properties?.name ?? "Unknown",
            location: customAnnotation.properties?.location ?? "Unknown",
            boothType: BoothType(rawValue: customAnnotation.properties?.booth_type ?? "") ?? .booth
        )
        
        let swiftUIView = CustomAnnotationContentView(
            booth: booth,
            onNavigateTapped: { [weak self] in
                self?.onNavigateTapped?()
            }
        )
        
        let hostingController = UIHostingController(rootView: swiftUIView)
        hostingController.view.backgroundColor = .clear
        
        // Remove any existing subviews
        subviews.forEach { $0.removeFromSuperview() }
        
        // Add the SwiftUI view
        addSubview(hostingController.view)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: bottomAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        
        // Update frame size
        let size = hostingController.view.intrinsicContentSize
        frame.size = size
        centerOffset = CGPoint(x: 0, y: -size.height / 2)
    }
}
