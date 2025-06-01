import UIKit

final class AlertPresenter: AlertPresenterProtocol {
    weak var delegate: AlertPresenterDelegate?
    
    init(delegate: AlertPresenterDelegate? = nil) {
        self.delegate = delegate
    }
    
    func createAlertController(alertData: AlertViewModel) -> UIAlertController {
        let alert = UIAlertController(
            title: alertData.title,
            message: alertData.text ,
            preferredStyle: .alert
        )
        
        let action = UIAlertAction(title: alertData.buttonText, style: .default) { _ in
            guard let completion = alertData.completion else { return }
            
            completion()
        }
        
        alert.addAction(action)
        return alert
    }
    
    func showAlert(alertData: AlertViewModel) {
        let alert = createAlertController(alertData: alertData)
        self.delegate?.didShowAlert(alert: alert)
    }
}
