import Foundation

// приватная часть для протокола будет описана внутри класса.
final class StatisticService {
    private let storage: UserDefaults = .standard
    
    private enum Keys: String {
        case correctAnswers = "correct" // кол-во правильных ответов.
        case bestGame =  "bestGame" // лучшая игра
        case gamesCount = "gamesCount" // счётчик сыгранных игр.
        case total = "total" // всего вопросов
        case date = "date" // дата рекорда
        case totalAccuracy = "totalAccuracy" // Средняя точность ответов
    }
}

// публичная часть для протокола будет описана внутри расширения.
extension StatisticService: StatisticServiceProtocol {
    var gamesCount: Int {
        get {
            storage.integer(forKey:  Keys.gamesCount.rawValue)
        }
        set(newValue) {
            storage.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    var bestGame: GameResult {
        get {
            GameResult(
                correctAnswers: storage.integer(forKey: Keys.correctAnswers.rawValue),
                total: storage.integer(forKey: Keys.total.rawValue),
                date: storage.object(forKey: Keys.date.rawValue ) as? Date ?? Date()
                )
        }
        set(newValue) {
            storage.set(newValue.correctAnswers, forKey: Keys.correctAnswers.rawValue)
            storage.set(newValue.total, forKey: Keys.total.rawValue)
            storage.set(newValue.date, forKey:Keys.date.rawValue)
        }
    }
    var totalAccuracy: String {
        get {
            storage.string(forKey: Keys.totalAccuracy.rawValue) ?? ""
        }
        set(newValue) {
            storage.set(newValue, forKey: Keys.totalAccuracy.rawValue)
        }
    }
    
    func store(correctAnswers: Int, questionsAmount: Int) {
        gamesCount += 1
        
        if bestGame.isNewRecord(correctAnswers) {
            bestGame = GameResult(
                correctAnswers: correctAnswers,
                total: questionsAmount,
                date: Date()
            )
        }
        
        totalAccuracy = String(format: "%.2f", Double(correctAnswers) / (10.0 * Double(gamesCount)) * 100)
    }
}
