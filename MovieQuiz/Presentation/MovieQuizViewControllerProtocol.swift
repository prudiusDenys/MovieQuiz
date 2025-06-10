import UIKit

protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(quiz step: QuizStepViewModel)
    func highlightImageBorder(isCorrectAnswer: Bool)
    func showLoadingIndicator(isHidden: Bool)
    func didShowAlert(alert: UIAlertController)
    func setAnswerButtonsState(isEnabled: Bool)
}
