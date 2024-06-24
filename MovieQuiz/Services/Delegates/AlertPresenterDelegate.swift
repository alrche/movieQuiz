//
//  AlertPresenterDelegate.swift
//  MovieQuiz
//
//  Created by Aliaksandr Charnyshou on 22.06.2024.
//

import Foundation
import UIKit

protocol AlertPresenterDelegate: AnyObject {
    func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)?)
}
