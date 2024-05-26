//
//  StatisticService.swift
//  MovieQuiz
//
//  Created by Aliaksandr Charnyshou on 25.05.2024.
//

import Foundation

internal class StatisticServiceImplementation: StatisticServiceProtocol {
    private let userDefaults = UserDefaults.standard

    private enum Keys: String {
        case correct
        case total
        case bestGame
        case gamesCount
    }

    var totalAccuracy: Double {
        let correct = userDefaults.integer(forKey: Keys.correct.rawValue)
        let total = userDefaults.integer(forKey: Keys.total.rawValue)
        return total > 0 ? Double(correct) / Double(total) : 0
    }

    var gamesCount: Int {
        get {
            let gamesCount = userDefaults.integer(forKey: Keys.gamesCount.rawValue)
            return gamesCount
        }

        set {
            userDefaults.set(newValue, forKey: Keys.gamesCount.rawValue)
            return
        }

    }

    var bestGame: GameResult {
        get {
            guard let data = userDefaults.data(forKey: Keys.bestGame.rawValue),
                  let record = try? JSONDecoder().decode(GameResult.self, from: data) else {
                return .init(correct: 0, total: 0, date: Date())
            }
            return record
        }
        set {
            guard let data = try? JSONEncoder().encode(newValue) else {
                print("Невозможно сохранить результат")
                return
            }
            userDefaults.set(data, forKey: Keys.bestGame.rawValue)
        }
    }

    func store(correct count: Int, total amount: Int) {
        let newGame = GameResult(correct: count, total: amount, date: Date())
        if newGame.isBetterThan(bestGame) {
            bestGame = newGame
        }
        var correctQuestions = userDefaults.integer(forKey: Keys.correct.rawValue)
        var totalQuestions = userDefaults.integer(forKey: Keys.total.rawValue)

        correctQuestions += count
        totalQuestions += amount

        userDefaults.set(correctQuestions, forKey: Keys.correct.rawValue)
        userDefaults.set(totalQuestions, forKey: Keys.total.rawValue)
    }

    func getGamesStatistic(correct count: Int, total amount: Int) -> String {
        let score = "Ваш результат: \(count)/\(amount)"
        let gameCount = "Количество сыграных квизов: \(gamesCount)"
        let record = "Рекорд: \(bestGame.correct)/\(bestGame.total) (\(bestGame.date.dateTimeString))"
        let averageAccuracy = "Средняя точность: \(String(format: "%.2f", totalAccuracy * 100))%"
        return  [score, gameCount, record, averageAccuracy].joined(separator: "\n")
    }
}
