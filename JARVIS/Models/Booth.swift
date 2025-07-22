//
//  Booth.swift
//  JARVIS
//
//  Created by Jerry Febriano on 22/07/25.
//

enum BoothType {
    case experience
    case booth
}

struct Booth {
    let name: String
    let location: String
    let boothType: BoothType
    
    static let examples: [Booth] = [
        Booth(name: "Emina Experience", location: "Hall Cendrawasih", boothType: .experience),
        Booth(name: "Wardah Cosmetics", location: "Hall A", boothType: .booth),
        Booth(name: "Wardah Experience", location: "Hall Cendrawasih", boothType: .experience),
        Booth(name: "Vaseline Lip Care", location: "Hall A", boothType: .booth),
        Booth(name: "Vaseline Experience", location: "Hall Cendrawasih", boothType: .experience),
        Booth(name: "BLACKSTAG", location: "Hall Cendrawasih", boothType: .booth)
    ]
}
