//
//  AlertPresenterProtocol.swift
//  MovieQuiz
//
//  Created by Aliaksandr Charnyshou on 25.05.2024.
//

import Foundation
import UIKit

internal protocol AlertPresenterProtocol {
    func setup(delegate: AlertPresenterDelegate)
    func showAlert(alertData: AlertModel)
}
