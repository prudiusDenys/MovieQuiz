protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(quiz step: QuizStepViewModel)
    func showResults(results: AlertViewModel)
    func highlightImageBorder(isCorrectAnswer: Bool)
    func showLoadingIndicator(isHidden: Bool)
    func setAnswerButtonsState(isEnabled: Bool)
    func showNetworkError(message: String)
}
