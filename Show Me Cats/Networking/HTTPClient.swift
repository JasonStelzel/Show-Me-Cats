//
//  HTTPClient.swift
//  Show Me Cats
//
//  Created by Jason Stelzel on 12/5/22.
//

import Foundation

public enum HTTPClientResult {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}


public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}
