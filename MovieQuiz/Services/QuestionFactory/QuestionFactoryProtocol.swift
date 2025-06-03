//Метод requestNextQuestion() в новой логике будет не возвращать вопрос сразу, а передавать его делегату QuestionFactoryDelegate в функцию didReceiveNextQuestion(question:).

protocol QuestionFactoryProtocol {
    func requestNextQuestion()
    func loadData()
}
