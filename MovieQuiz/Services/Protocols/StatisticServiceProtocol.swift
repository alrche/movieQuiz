//
//  StatisticServiceProtocol.swift
//  MovieQuiz
//
//  Created by Aliaksandr Charnyshou on 25.05.2024.
//

import Foundation

protocol StatisticServiceProtocol {
    var totalAccuracy: Double { get }
    var gamesCount: Int { get }
    var bestGame: GameResult { get }
    
    func store(correct count: Int, total amount: Int)
    
    func getGamesStatistic(correct count: Int, total amount: Int) -> String
}
