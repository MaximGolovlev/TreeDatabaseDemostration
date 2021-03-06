//
//  Alertable.swift
//  DataBaseTreeDemostration
//
//  Created by  Macbook on 23.09.2020.
//  Copyright © 2020 Golovelv Maxim. All rights reserved.
//

import UIKit

protocol Alertable {
    func showInputDialog(title:String?,
    subtitle:String?,
    actionTitle:String?,
    cancelTitle:String?,
    inputDefaultValue: String?,
    inputKeyboardType: UIKeyboardType,
    actionHandler: ((_ text: String?) -> Void)?)
}

extension Alertable where Self: UIViewController {
    func showInputDialog(title:String? = nil,
                         subtitle:String? = nil,
                         actionTitle:String? = "Add",
                         cancelTitle:String? = "Cancel",
                         inputDefaultValue: String? = nil,
                         inputKeyboardType:UIKeyboardType = UIKeyboardType.default,
                         actionHandler: ((_ text: String?) -> Void)? = nil) {

        let alert = UIAlertController(title: title, message: subtitle, preferredStyle: .alert)
        alert.addTextField { (textField:UITextField) in
            textField.text = inputDefaultValue
            textField.keyboardType = inputKeyboardType
        }
        alert.addAction(UIAlertAction(title: actionTitle, style: .default, handler: { (action:UIAlertAction) in
            guard let textField =  alert.textFields?.first else {
                actionHandler?(nil)
                return
            }
            actionHandler?(textField.text)
        }))
        alert.addAction(UIAlertAction(title: cancelTitle, style: .cancel))

        self.present(alert, animated: true, completion: nil)
    }
}
