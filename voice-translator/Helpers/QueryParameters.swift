//
//  QueryParameters.swift
//  voice-translator
//
//  Created by Hima Devisetti on 10/6/20.
//  Copyright © 2020 Hima Bindu Devisetti. All rights reserved.
//

import Foundation

extension URL {
    var queryParameters: QueryParameters { return QueryParameters(url: self) }
}

class QueryParameters {
    let queryItems: [URLQueryItem]
    init(url: URL?) {
        queryItems = URLComponents(string: url?.absoluteString ?? "")?.queryItems ?? []
    }
    subscript(name: String) -> String? {
        return queryItems.first(where: { $0.name == name })?.value
    }
}
