//
//  MockURLProtocol.swift
//  rick_morty
//
//  Created by Alessandra Souza da Silva on 18/03/26.
//


import Foundation

final class MockURLProtocol: URLProtocol {
    static var stubData: Data?
    static var stubResponse: URLResponse?
    static var stubError: Error?
    
    override class func canInit(with request: URLRequest) -> Bool {
        true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }
    
    override func startLoading() {
        if let error = Self.stubError {
            client?.urlProtocol(self, didFailWithError: error)
            return
        }
        
        if let response = Self.stubResponse {
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        }
        
        if let data = Self.stubData {
            client?.urlProtocol(self, didLoad: data)
        }
        
        client?.urlProtocolDidFinishLoading(self)
    }
    
    override func stopLoading() {}
}

func makeMockSession(
    data: Data,
    statusCode: Int,
    url: URL = URL(string: "https://rickandmortyapi.com/api/character")!
) -> URLSession {
    MockURLProtocol.stubData = data
    MockURLProtocol.stubResponse = HTTPURLResponse(
        url: url,
        statusCode: statusCode,
        httpVersion: nil,
        headerFields: nil
    )
    MockURLProtocol.stubError = nil

    let configuration = URLSessionConfiguration.ephemeral
    configuration.protocolClasses = [MockURLProtocol.self]

    return URLSession(configuration: configuration)
}
