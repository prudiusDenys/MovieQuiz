import UIKit

struct ViewModel {
  let image: UIImage
  let question: String
  let questionNumber: String
}

final class MovieQuizViewController: UIViewController {
    // MARK: - IB Outlets
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var questionLabel: UILabel!
    
    @IBOutlet private var noButtonLabel: UIButton!
    @IBOutlet private var yesButtonLabel: UIButton!
    
    @IBOutlet private var imageView: UIImageView!
    
    // MARK: - Private Properties
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    private var questionsAmount = 10
    private var questionFactory: QuestionFactoryProtocol = QuestionFactory()
    private var currentQuestion: QuizQuestion?
    
    // MARK: - Initializers
    override func viewDidLoad() {
        super.viewDidLoad()
        setFonts()
    
        if let firstQuestion = questionFactory.requestNextQuestion() {
            currentQuestion = firstQuestion
            
            let convertedData = convert(model: firstQuestion)
            show(quiz: convertedData)
        }
    }
    
    // MARK: - IB Actions
    @IBAction private func noButtonClicked(_ sender: Any) {
        showAnswerResult(isCorrect: currentQuestion?.correctAnswer == false)
        
        noButtonLabel.isEnabled = false
    }
    
    @IBAction private func yesButtonClicked(_ sender: Any) {
        showAnswerResult(isCorrect: currentQuestion?.correctAnswer == true)
        
        yesButtonLabel.isEnabled = false
    }
    
    // MARK: - Private Methods
    private func setFonts() {
        questionLabel.font = UIFont(name: "YSDisplay-Medium", size: 20)
        counterLabel.font = UIFont(name: "YSDisplay-Medium", size: 20)
        noButtonLabel.titleLabel?.font = UIFont(name: "YSDisplay-Medium", size: 20)
        yesButtonLabel.titleLabel?.font = UIFont(name: "YSDisplay-Medium", size: 20)
        textLabel.font = UIFont(name: "YSDisplay-Bold", size: 23)
    }
    
    // приватный метод конвертации, который принимает моковый вопрос и возвращает вью модель для главного экрана
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        
        return questionStep
    }
    
    // приватный метод для показа результатов раунда квиза
    // принимает вью модель QuizResultsViewModel и ничего не возвращает
    private func showResults(quiz result: QuizResultsViewModel) {
        let alert = UIAlertController(
            title: result.title,
            message: result.text,
            preferredStyle: .alert)
        
        let action = UIAlertAction(title: result.buttonText, style: .default) { [weak self]  _ in
            guard let self = self else {return}
            
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            
            if let firstQuestion = self.questionFactory.requestNextQuestion() {
                self.currentQuestion = firstQuestion
                
                let viewModel = self.convert(model: firstQuestion)
                self.show(quiz: viewModel)
            }
        }
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    // приватный метод вывода на экран вопроса, который принимает на вход вью модель вопроса и ничего не возвращает
    private func show(quiz step: QuizStepViewModel) {
        imageView.layer.borderWidth = 0
        imageView.layer.cornerRadius = 20
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    // приватный метод, который содержит логику перехода в один из сценариев
    // метод ничего не принимает и ничего не возвращает
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionsAmount - 1 {
            let text = correctAnswers == questionsAmount ?
                    "Поздравляем, вы ответили на 10 из 10!" :
                    "Вы ответили на \(correctAnswers) из \(questionsAmount), попробуйте ещё раз!"
            
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть ещё раз")
            
            showResults(quiz: viewModel)
        } else {
            currentQuestionIndex += 1
            if let nextQuestion = questionFactory.requestNextQuestion() {
                currentQuestion = nextQuestion
                
                let viewModel = convert(model: nextQuestion)
                show(quiz: viewModel)
            }
        }
        noButtonLabel.isEnabled = true
        yesButtonLabel.isEnabled = true
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
        
        imageView.layer.masksToBounds = true // даём разрешение на рисование рамки
        imageView.layer.borderWidth = 8
        imageView.layer.cornerRadius = 20
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        // запускаем задачу через 1 секунду c помощью диспетчера задач
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0)  { [weak self] in
            guard let self = self else {return}
            // код, который мы хотим вызвать через 1 секунду
            self.showNextQuestionOrResults()
        }
    }
}
