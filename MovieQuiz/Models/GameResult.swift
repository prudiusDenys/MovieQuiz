import Foundation

struct GameResult {
    let correctAnswers: Int
    let total: Int
    let date: Date

    // метод сравнения по количеству верных ответов
    func isNewRecord(_ correctAnswers: Int ) -> Bool {
        correctAnswers > self.correctAnswers
    }
}
