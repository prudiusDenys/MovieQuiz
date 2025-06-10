import UIKit

struct ViewModel {
  let image: UIImage
  let question: String
  let questionNumber: String
}

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {
    // MARK: - IB Outlets
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var questionLabel: UILabel!
    
    @IBOutlet private var noButtonLabel: UIButton!
    @IBOutlet private var yesButtonLabel: UIButton!
    
    @IBOutlet private var imageView: UIImageView!
    
    @IBOutlet private var loader: UIActivityIndicatorView!
    
    // MARK: - Private Properties
    private var presenter: MovieQuizPresenter!
    
    // MARK: - Initializers
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setFonts()
        setUpImageView()
        
        presenter = MovieQuizPresenter(viewController: self)
    
        showLoadingIndicator(isHidden: false)
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
    
    // метод вывода на экран вопроса, который принимает на вход вью модель вопроса и ничего не возвращает
     func show(quiz step: QuizStepViewModel) {
        imageView.layer.borderWidth = 0
        imageView.layer.cornerRadius = 20
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
    }
    
    func showLoadingIndicator(isHidden: Bool) {
        loader.isHidden = isHidden
        loader.startAnimating()
    }
    
    func setAnswerButtonsState(isEnabled: Bool) {
       yesButtonLabel.isEnabled = isEnabled
       noButtonLabel.isEnabled = isEnabled
   }
    
    func didShowAlert(alert: UIAlertController) {
        alert.view.accessibilityIdentifier = "GameResult"
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Private Methods
    private func setFonts() {
        questionLabel.font = UIFont(name: "YSDisplay-Medium", size: 20)
        counterLabel.font = UIFont(name: "YSDisplay-Medium", size: 20)
        noButtonLabel.titleLabel?.font = UIFont(name: "YSDisplay-Medium", size: 20)
        yesButtonLabel.titleLabel?.font = UIFont(name: "YSDisplay-Medium", size: 20)
        textLabel.font = UIFont(name: "YSDisplay-Bold", size: 23)
    }
    
    private func setUpImageView() {
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 20
    }
}
