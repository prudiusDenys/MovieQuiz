import UIKit

protocol AlertPresenterDelegate: AnyObject {
    func didShowAlert(alert: UIAlertController)
}
