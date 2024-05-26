//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Aliaksandr Charnyshou on 25.05.2024.
//

import Foundation
import UIKit

class ResultAlertPresenter: AlertPresenterProtocol {
    weak var delegate: AlertPresenterDelegate?
    
    func setup(delegate: AlertPresenterDelegate) {
        self.delegate = delegate
    }
    
    func showAlert(alertData: AlertModel) {
        let alert = UIAlertController(title: alertData.title,
                                      message: alertData.message,
                                      preferredStyle: .alert)
        let action = UIAlertAction(title: alertData.buttonText, style: .default) { [weak self] _ in
            guard self != nil else { return }
            
            alertData.completion()
        }
        
        alert.addAction(action)
        
        self.delegate?.present(alert, animated: true, completion: nil)
    }
}
