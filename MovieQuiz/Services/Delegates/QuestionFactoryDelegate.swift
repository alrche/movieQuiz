//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Aliaksandr Charnyshou on 25.05.2024.
//

import Foundation

protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)
}
