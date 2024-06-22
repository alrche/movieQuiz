import UIKit

final class MovieQuizViewController: UIViewController,
                                        QuestionFactoryDelegate,
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

    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol?

    private var resultAlertPresenter: AlertPresenterProtocol?

    private var statisticService: StatisticServiceProtocol!

    private var currentQuestion: QuizQuestion?
    private var currentQuestionIndex: Int = 0
    private var correctAnswers: Int = 0

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 20

        noMultipleTouchForButton(isExclusive: true)

        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        statisticService = StatisticServiceImplementation()

        showLoadingIndicator()
        questionFactory?.loadData()
        resetStateForIndicator()

        self.questionFactory?.requestNextQuestion()
    }

    // MARK: - ActivityIndicator

    private func resetStateForIndicator() {
        activityIndicator.hidesWhenStopped = true
    }

    private func showLoadingIndicator() {
        activityIndicator.startAnimating()
    }

    private func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
    }

    private func showNetworkError(message: String) {
        hideLoadingIndicator()

        let model = AlertModel(title: "Ошибка",
                               message: message,
                               buttonText: "Попробовать еще раз") { [weak self] in
            guard let self = self else { return }

            self.currentQuestionIndex = 0
            self.correctAnswers = 0

            self.questionFactory?.requestNextQuestion()
        }

        let resultAlertPresenter = ResultAlertPresenter()
        resultAlertPresenter.setup(delegate: self)
        self.resultAlertPresenter = resultAlertPresenter
        resultAlertPresenter.showAlert(alertData: model)
    }

    // MARK: - QuestionFactoryDelegate

    func didReceiveNextQuestion(question: QuizQuestion?) {
        hideLoadingIndicator()
        guard let question = question else {
            return
        }

        currentQuestion = question
        let viewModel = convert(model: question)

        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }

    func didLoadDataFromServer() {
        hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }

    func didFailToLoadData(with error: Error) {
        hideLoadingIndicator()
        showNetworkError(message: error.localizedDescription)
    }

    // MARK: - StatisticServiceProtocol, AlertPresenterDelegate

    private func show(quiz result: QuizResultsViewModel) {
        statisticService.store(
            correct: self.correctAnswers,
            total: self.questionsAmount
        )
        let completion = {
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            self.questionFactory?.requestNextQuestion()
        }
        let message = statisticService.getGamesStatistic(
            correct: self.correctAnswers,
            total: self.questionsAmount
        )
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

    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
    }

    private func show(quiz step: QuizStepViewModel) {
        counterLabel.text = step.questionNumber
        textLabel.text = step.question
        imageView.image = step.image
    }

    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }

        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }

            self.showNextQuestionOrResults()
            self.imageView.layer.borderColor = UIColor.clear.cgColor
        }
    }

    private func showNextQuestionOrResults() {
        showLoadingIndicator()
        if currentQuestionIndex == questionsAmount - 1 {
            let text = correctAnswers == questionsAmount ?
            "Поздравляем, вы ответили на 10 из 10!" :
            "Вы ответили на \(correctAnswers) из 10, попробуйте ещё раз!"
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть ещё раз")
            show(quiz: viewModel)
        } else {
            currentQuestionIndex += 1
            self.questionFactory?.requestNextQuestion()
        }
        changeStateButton(isEnabled: true)
    }

    // MARK: - Actions For Buttons

    private func changeStateButton(isEnabled: Bool) {
        noButton.isEnabled = isEnabled
        yesButton.isEnabled = isEnabled
    }

    private func noMultipleTouchForButton(isExclusive: Bool) {
        noButton.isExclusiveTouch = isExclusive
        yesButton.isExclusiveTouch = isExclusive
    }

    @IBAction private func noButtonClick(_ sender: UIButton) {
        if noButton.isEnabled {
            guard let currentQuestion = currentQuestion else {
                return
            }
            let givenAnswer = false
            showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
            changeStateButton(isEnabled: false)
        }
    }

    @IBAction private func yesButtonClick(_ sender: UIButton) {
        if yesButton.isEnabled {
            guard let currentQuestion = currentQuestion else {
                return
            }
            let givenAnswer = true
            showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
            changeStateButton(isEnabled: false)
        }
    }
}
