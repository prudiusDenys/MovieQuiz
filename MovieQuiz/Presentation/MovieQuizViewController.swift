import UIKit

struct ViewModel {
  let image: UIImage
  let question: String
  let questionNumber: String
}

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate, AlertPresenterDelegate {
    // MARK: - IB Outlets
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var questionLabel: UILabel!
    
    @IBOutlet private var noButtonLabel: UIButton!
    @IBOutlet private var yesButtonLabel: UIButton!
    
    @IBOutlet private var imageView: UIImageView!
    
    @IBOutlet private var loader: UIActivityIndicatorView!
    
    // MARK: - Private Properties
    private var correctAnswers = 0
    private var questionFactory: QuestionFactoryProtocol?
    private var alertPresenter: AlertPresenterProtocol?
    private var statisticService: StatisticServiceProtocol?
    private let presenter = MovieQuizPresenter()
    
    // MARK: - Initializers
    override func viewDidLoad() {
        super.viewDidLoad()
        setFonts()
        setUpImageView()
        
        alertPresenter = AlertPresenter(delegate: self)
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        statisticService = StatisticService()
        
        showLoadingIndicator(isHidden: false)
        questionFactory?.loadData()
        
        presenter.viewController = self
    }
    
    // MARK: - IB Actions
    @IBAction private func noButtonClicked(_ sender: Any) {
        presenter.noButtonClicked()
        setAnswerButtonsState(isEnabled: false)
    }
    
    @IBAction private func yesButtonClicked(_ sender: Any) {
        presenter.yesButtonClicked()
        setAnswerButtonsState(isEnabled: false)
    }
    
    // MARK: - Public Methods
    func didShowAlert(alert: UIAlertController) {
        alert.view.accessibilityIdentifier = "Game Result"
        self.present(alert, animated: true, completion: nil)
    }
    
    func didLoadDataFromServer() {
        loader.isHidden = true
        questionFactory?.requestNextQuestion()
    }

    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }
    
    func showAnswerResult(isCorrect: Bool) {
       if isCorrect {
           correctAnswers += 1
       }
       
       imageView.layer.borderWidth = 8
       imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
       
       // запускаем задачу через 1 секунду c помощью диспетчера задач
       DispatchQueue.main.asyncAfter(deadline: .now() + 1.0)  { [weak self] in
           guard let self else {return}
           // код, который мы хотим вызвать через 1 секунду
           self.showNextQuestionOrResults()
       }
   }
    
//    func didRecieveNextQuestion(question: QuizQuestion?) {
//        presenter.didRecieveNextQuestion(question: question)
//    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        presenter.didReceiveNextQuestion(question: question)
    }
    
    // метод вывода на экран вопроса, который принимает на вход вью модель вопроса и ничего не возвращает
     func show(quiz step: QuizStepViewModel) {
        imageView.layer.borderWidth = 0
        imageView.layer.cornerRadius = 20
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    // MARK: - Private Methods
    private func setFonts() {
        questionLabel.font = UIFont(name: "YSDisplay-Medium", size: 20)
        counterLabel.font = UIFont(name: "YSDisplay-Medium", size: 20)
        noButtonLabel.titleLabel?.font = UIFont(name: "YSDisplay-Medium", size: 20)
        yesButtonLabel.titleLabel?.font = UIFont(name: "YSDisplay-Medium", size: 20)
        textLabel.font = UIFont(name: "YSDisplay-Bold", size: 23)
    }
    
    private func setAnswerButtonsState(isEnabled: Bool) {
        yesButtonLabel.isEnabled = isEnabled
        noButtonLabel.isEnabled = isEnabled
    }
    
    private func setUpImageView() {
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 20
    }
    
    // приватный метод, который содержит логику перехода в один из сценариев
    // метод ничего не принимает и ничего не возвращает
    private func showNextQuestionOrResults() {
        if presenter.isLastQuestion() {
            statisticService?.store(correctAnswers: correctAnswers, questionsAmount: presenter.questionsAmount)
            
            alertPresenter?.showAlert(alertData: AlertViewModel(
                title: "Этот раунд окончен!",
                text: """
                Ваш результат: \(correctAnswers)/\(presenter.questionsAmount)
                Количество сыгранных квизов: \(statisticService?.gamesCount ?? 0)
                Рекорд: \(statisticService?.bestGame.correctAnswers ?? 0)/\(statisticService?.bestGame.total ?? 0) (\(statisticService?.bestGame.date.dateTimeString ?? ""))
                Средняя точность: \(statisticService?.totalAccuracy ?? "0.00")%
                """,
                buttonText: "Сыграть ещё раз",
                completion: { [weak self] in
                    guard let self else { return }
                    
                    self.presenter.resetQuestionIndex()
                    self.correctAnswers = 0
                    
                    self.questionFactory?.requestNextQuestion()
                }
            ))
        } else {
            self.presenter.switchToNextQuestion()
            self.questionFactory?.requestNextQuestion()
        }
        setAnswerButtonsState(isEnabled: true)
    }
    
    private func showLoadingIndicator(isHidden: Bool) {
        loader.isHidden = isHidden
        loader.startAnimating()
    }
    
    private func showNetworkError(message: String) {
        showLoadingIndicator(isHidden: true)
        
        alertPresenter?.showAlert(alertData: AlertViewModel(
            title: "Ошибка",
            text: message,
            buttonText: "Попробовать еще раз",
            completion: { [weak self] in
                guard let self else { return }
                
                self.presenter.resetQuestionIndex()
                self.correctAnswers = 0
                
                self.questionFactory?.requestNextQuestion()
            }
        ))
    }
}
