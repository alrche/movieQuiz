//
//  Network Routing.swift
//  MovieQuiz
//
//  Created by Aliaksandr Charnyshou on 22.06.2024.
//

import Foundation

protocol NetworkRouting {
    func fetch(url: URL, handler: @escaping (Result<Data, Error>) -> Void)
}
