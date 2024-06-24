import UIKit

final class MovieQuizViewController: UIViewController,
                                     MovieQuizViewControllerProtocol,
                                     AlertPresenterDelegate {
    
    // MARK: - IBOutlets
    
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var noButton: UIButton!
    @IBOutlet private var yesButton: UIButton!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Properties
    
    private var presenter: MovieQuizPresenter!
    
    private var resultAlertPresenter: AlertPresenterProtocol?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.presenter = MovieQuizPresenter(viewController: self)
        
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 20
        
        noMultipleTouchForButton(isExclusive: true)
        
        
        showLoadingIndicator()
        resetStateForIndicator()
    }
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
    }
    
    
    // MARK: - ActivityIndicator
    
    private func resetStateForIndicator() {
        activityIndicator.hidesWhenStopped = true
    }
    
    func showLoadingIndicator() {
        activityIndicator.startAnimating()
    }
    
    func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
    }
    
    // MARK: - AlertPresenterDelegate
    
    func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let model = AlertModel(title: "Ошибка",
                               message: message,
                               buttonText: "Попробовать еще раз") { [weak self] in
            guard let self else { return }
            
            self.presenter.restartGame()
        }
        
        let resultAlertPresenter = ResultAlertPresenter()
        resultAlertPresenter.setup(delegate: self)
        self.resultAlertPresenter = resultAlertPresenter
        resultAlertPresenter.showAlert(alertData: model)
    }
    
    func show(quiz result: QuizResultsViewModel) {
        let message = self.presenter.makeResultsMessage()
        
        let completion = {
            self.presenter.restartGame()
        }
        
        let alertData = AlertModel(
            title: result.title,
            message: message,
            buttonText: result.buttonText,
            completion: completion
        )
        
        let resultAlertPresenter = ResultAlertPresenter()
        resultAlertPresenter.setup(delegate: self)
        self.resultAlertPresenter = resultAlertPresenter
        resultAlertPresenter.showAlert(alertData: alertData)
    }
    
    // MARK: - Actions
    
    func show(quiz step: QuizStepViewModel) {
        showLoadingIndicator()
        imageView.layer.borderColor = UIColor.clear.cgColor
        counterLabel.text = step.questionNumber
        textLabel.text = step.question
        imageView.image = step.image
        changeStateButton(isEnabled: true)
        hideLoadingIndicator()
    }
    
    // MARK: - Actions For Buttons
    
    func changeStateButton(isEnabled: Bool) {
        noButton.isEnabled = isEnabled
        yesButton.isEnabled = isEnabled
    }
    
    private func noMultipleTouchForButton(isExclusive: Bool) {
        noButton.isExclusiveTouch = isExclusive
        yesButton.isExclusiveTouch = isExclusive
    }
    
    @IBAction private func noButtonClick(_ sender: UIButton) {
        if noButton.isEnabled {
            self.presenter.noButtonClick()
            changeStateButton(isEnabled: false)
        }
    }
    
    @IBAction private func yesButtonClick(_ sender: UIButton) {
        if yesButton.isEnabled {
            self.presenter.yesButtonClick()
            changeStateButton(isEnabled: false)
        }
    }
}
