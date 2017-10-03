import Foundation
import CoreGraphics

struct KeyboardInfo {
    let isHidden: Bool
    let frame: CGRect
}

class KeyboardManager {
    static let sharedInstance = KeyboardManager()
    private var blocksArray: [(KeyboardInfo) -> Void] = [(KeyboardInfo) -> Void]()

    private init() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.keyboardWillShowNotification(notification:)),
            name: NSNotification.Name.UIKeyboardWillShow, object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.keyboardWillHideNotification(notification:)),
            name: NSNotification.Name.UIKeyboardWillHide, object: nil
        )
    }

    @objc func keyboardWillHideNotification(notification: NSNotification) {
        for block in self.blocksArray {
            guard let rect: CGRect = notification.userInfo!["UIKeyboardBoundsUserInfoKey"] as? CGRect else {
                return
            }
            block(KeyboardInfo.init(isHidden: true, frame: rect))
        }
    }

    @objc func keyboardWillShowNotification(notification: NSNotification) {
        for block in self.blocksArray {

            guard let rect: CGRect = notification.userInfo!["UIKeyboardBoundsUserInfoKey"] as? CGRect else {
                return
            }
            block(KeyboardInfo.init(isHidden: false, frame: rect))
        }
    }

    func addBlock(block: @escaping (KeyboardInfo) -> Void) {
        self.blocksArray.append(block)
    }
}
