//
//  FeedbackViewController.swift
//  SBGenericTool_Example
//
//  Created by 王剑鹏 on 2020/10/26.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import SBGenericTool

class FeedbackViewController: UIViewController {

    @IBOutlet weak var contactTextField: UITextField!
    @IBOutlet weak var messageTextView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        contactTextField.text = "test"
        messageTextView.text = "test message"
        // Do any additional setup after loading the view.
    }
    
    @IBAction func sendAction(_ sender: Any) {
        SBServerMenager.feedback(message: messageTextView.text ?? "",
                                 contact: contactTextField.text ?? "")
        { [weak self] (success, error) in
            self?.showAlert(isSuccess: success)
        }      
    }
    
    func showAlert(isSuccess success: Bool) {
        let alert = UIAlertController(title: success ? "发送成功": "发送失败", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
