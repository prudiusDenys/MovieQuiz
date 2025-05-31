protocol StatisticServiceProtocol {
    // количество завершённых игр.
    var gamesCount: Int { get }
    // информация о лучшей попытке.
    var bestGame: GameResult { get }
    // средняя точность правильных ответов за все игры в процентах.
    var totalAccuracy: String { get }
    
    func store(correctAnswers: Int, questionsAmount: Int)
}
