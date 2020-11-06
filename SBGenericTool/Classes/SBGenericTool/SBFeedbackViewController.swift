//
//  SBFeedbackViewController.swift
//  Pods
//
//  Created by 王剑鹏 on 2020/10/30.
//

import UIKit

public class SBFeedbackViewController: UIViewController {
    
    public var themeColor : UIColor = .systemBlue
    public var backgroundColor : UIColor = .white
    public var textColor : UIColor = .black
    public var textViewColor : UIColor = UIColor.init(netHex: 0xF3F3F4)
    
    /// 发送成功回调
    /// 不为空的情况下 ，发送成功会自动pop本页面，并触发回调，请做好处理
    /// 为空情况下，本页面会弹窗提示发送成功，不会自动消失
    public var sendSuccessComplete : (()->())?
    
    func dismissAction() {
        if self.navigationController != nil  {
            self.navigationController?.popViewController(animated: true)
            sendSuccessComplete?()
        }else{
            self.dismiss(animated: true) {
                self.sendSuccessComplete?()
            }
        }
    }
    
    
    private var scrollView : UIScrollView!
    private lazy var stackView : UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = 25
        stackView.axis = .vertical
        return stackView
    }()
    
    private lazy var messageTextView : UITextView = {
        let view = UITextView()
        view.backgroundColor = textViewColor
        view.textColor = textColor
        view.font = .systemFont(ofSize: 14)
        view.layer.cornerRadius = 12
        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(equalToConstant: 150),
        ])
        return view
    }()
    
    private lazy var contactTextField : UITextField = {
        let view = UITextField()
        view.backgroundColor = textViewColor
        view.textColor = textColor
        view.layer.cornerRadius = 12
        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(equalToConstant: 44),
        ])
        view.setLeftPaddingPoints(8)
        view.setRightPaddingPoints(8)
        return view
    }()
    
    private lazy var centerStackView : UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = 10
        stackView.axis = .vertical
        stackView.addArrangedSubview(label(text: "message".SBlocalized, size: 14, alpha: 1))
        stackView.addArrangedSubview(label(text: "message_supplement".SBlocalized, size: 12, alpha: 0.5))
        stackView.addArrangedSubview(messageTextView)
        stackView.addArrangedSubview(label(text: "connet".SBlocalized, size: 14, alpha: 1))
        stackView.addArrangedSubview(contactTextField)
        return stackView
    }()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        configureHierarchy()
        addkeyboardNotification()
    }
    
}

extension SBFeedbackViewController {
    private func label(text: String, size: CGFloat, alpha : CGFloat) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = UIFont.systemFont(ofSize: size)
        label.textColor = self.textColor
        label.alpha = alpha
        label.numberOfLines = 0
        return label
    }

    fileprivate func configureHierarchy() {
        self.title = "Feedback".SBlocalized
        
        view.backgroundColor = backgroundColor
        // scrollView
        scrollView = UIScrollView(frame: view.bounds)
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.keyboardDismissMode = .interactive
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        let margin = view.layoutMarginsGuide
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: margin.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: margin.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: margin.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: margin.bottomAnchor)
        ])
        
        //stackView
        stackView.addArrangedSubview(label(text: "Feedbacktitle".SBlocalized, size: 12, alpha: 1))
        stackView.addArrangedSubview(centerStackView)
        stackView.addArrangedSubview(UIView())
        
        // stackView layout
        scrollView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 10),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 10),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -10),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -10),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -20)
        ])
        
        // item
        let item = UIBarButtonItem(title: "send".SBlocalized, style: .plain, target: self, action: #selector(sendAction))
        self.navigationItem.rightBarButtonItem = item
    }
}

// MARK: - 键盘
extension SBFeedbackViewController {
    @objc func keyboardWillShow(notification:NSNotification) {
        guard let userInfo = notification.userInfo else { return }
        guard var keyboardFrame = userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as? CGRect else {
            return
        }
        
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)

        var contentInset:UIEdgeInsets = self.scrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height + 20
        scrollView.contentInset = contentInset
    }

    @objc func keyboardWillHide(notification:NSNotification) {
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInset
    }
    
    fileprivate func addkeyboardNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:UIResponder.keyboardWillHideNotification, object: nil)
    }
}

// MARK: - 提交
extension SBFeedbackViewController {
    @objc func sendAction(_ sender: UIBarButtonItem? = nil) {
        if messageTextView.text.isEmpty {
            self.showNoMessageAlert()
            return
        }
        sender?.isEnabled = false
        sender?.title = "sending".SBlocalized
        view.endEditing(true)
        SBServerMenager.feedback(message: messageTextView.text ?? "",
                                 contact: contactTextField.text ?? "")
        { [weak self] (success, error) in
            sender?.isEnabled = true
            sender?.title = "send".SBlocalized
            if self?.sendSuccessComplete != nil {
                self?.dismissAction()
            }else{
                self?.showAlert(isSuccess: success)
            }
        }
    }
    
    func showAlert(isSuccess success: Bool) {
        let alert = UIAlertController(title: success ? "Sent successfully".SBlocalized : "Failed to send".SBlocalized,
                                      message: nil,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    func showNoMessageAlert() {
        let alert = UIAlertController(title: "Message cannot be empty".SBlocalized, message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension UITextField {
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
}
