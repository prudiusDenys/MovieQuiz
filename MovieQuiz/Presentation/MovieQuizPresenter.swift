import UIKit

final class MovieQuizPresenter {
    // MARK: - Public Properties
    let questionsAmount = 10
    var correctAnswers = 0
    var currentQuestion: QuizQuestion?
    var questionFactory: QuestionFactoryProtocol?
    var statisticService: StatisticServiceProtocol?
    var alertPresenter: AlertPresenterProtocol?
    
    weak var viewController: MovieQuizViewController?
    
    // MARK: - Private Properties
    private var currentQuestionIndex: Int = 0
    
    
    // MARK: - Public Methods
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func addCorrectAnswer() {
        correctAnswers += 1
    }
    
    func noButtonClicked() {
          didAnswer(isYes: false)
    }
    
    func yesButtonClicked() {
         didAnswer(isYes: true)
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question else {
            return
        }
        
        currentQuestion = question
        
        let viewModel = convert(model: question)
                
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
    
    // метод, который содержит логику перехода в один из сценариев
    // метод ничего не принимает и ничего не возвращает
     func showNextQuestionOrResults() {
         if self.isLastQuestion() {
            statisticService?.store(correctAnswers: self.correctAnswers, questionsAmount: self.questionsAmount)
            
            alertPresenter?.showAlert(alertData: AlertViewModel(
                title: "Этот раунд окончен!",
                text: """
                Ваш результат: \(correctAnswers)/\(self.questionsAmount)
                Количество сыгранных квизов: \(statisticService?.gamesCount ?? 0)
                Рекорд: \(statisticService?.bestGame.correctAnswers ?? 0)/\(statisticService?.bestGame.total ?? 0) (\(statisticService?.bestGame.date.dateTimeString ?? ""))
                Средняя точность: \(statisticService?.totalAccuracy ?? "0.00")%
                """,
                buttonText: "Сыграть ещё раз",
                completion: { [weak self] in
                    guard let self else { return }
                    
                    self.restartGame()
                    self.questionFactory?.requestNextQuestion()
                }
            ))
        } else {
            self.switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
    }
    
    // MARK: - Private Methods
    private func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        viewController?.showAnswerResult(isCorrect: currentQuestion.correctAnswer == isYes)
    }
}
