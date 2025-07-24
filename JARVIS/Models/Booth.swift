//
//  Booth.swift
//  JARVIS
//
//  Created by Jerry Febriano on 22/07/25.
//

enum BoothType: String {
    case experience
    case booth
}

struct Booth {
    let name: String
    let location: String
    let boothType: BoothType
}
