//
//  QRReaderViewController.swift
//  nkoodi
//
//  Created by marko nazmy on 8/2/18.
//  Copyright © 2018 Hajj Hackathon. All rights reserved.
//

import Foundation
import UIKit

class QRReaderViewController: BaseViewController {
    
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var transferContactNameLabel: UILabel!
    @IBOutlet weak var qrCodeTextField: UITextField!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var container1: UIView!
    @IBOutlet weak var conatiner2: UIView!
    @IBOutlet weak var transferButton: UIButton!
    var loading: UIActivityIndicatorView!
    var qrCodeTextFieldHasChanged: ((String)->())?
    
    public static func create() -> QRReaderViewController {
        return UIStoryboard(name: "QRReader", bundle: Bundle.main).instantiateViewController(withIdentifier: String(describing: self)) as! QRReaderViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loading = UIActivityIndicatorView(frame: self.view.bounds)
        qrCodeTextField.delegate = self
        qrCodeTextFieldHasChanged = { text in
            TransactionsManager.shared.getUserWithQR(text, completion: { (user) in
                guard let user = user else { return }
                self.transferContactNameLabel.text = "Will transfer to: " + user.name
            })
            //self.transferContactNameLabel.text = "user name: " + text
        }
        self.view.backgroundColor = UIColor(hexString: "#00c6c10")
        ////
        qrCodeTextField.borderStyle = .none
        let option1 = NSMutableAttributedString(string: "QR code")
        option1.addAttribute(NSForegroundColorAttributeName, value: UIColor.white, range: NSRange(location: 0, length: option1.length))
//        option1.addAttribute(NSFontAttributeName, value: UIFont.init(name: "Arial", size: 16), range: NSRange(location: 0, length: option1.length))
        qrCodeTextField.attributedPlaceholder = option1
        container1.layer.cornerRadius = 22
        container1.layer.borderColor = UIColor.white.cgColor
        container1.layer.borderWidth = 1
        /////
        amountTextField.borderStyle = .none
        let option2 = NSMutableAttributedString(string: "Amount")
        option2.addAttribute(NSForegroundColorAttributeName, value: UIColor.white, range: NSRange(location: 0, length: option2.length))
//        option2.addAttribute(NSFontAttributeName, value: UIFont.init(name: "Arial", size: 16), range: NSRange(location: 0, length: option2.length))
        amountTextField.attributedPlaceholder = option2
        conatiner2.layer.cornerRadius = 22
        conatiner2.layer.borderColor = UIColor.white.cgColor
        conatiner2.layer.borderWidth = 1
        /////
        transferButton.layer.cornerRadius = 22
        
    }
    
    @IBAction func camerButtonTapped(_ sender: Any) {
        let vc = QRCodeReaderViewController.create()
        vc.qrReadingCompletion = {[weak self] token in
            self?.qrCodeTextField.text = token
            self?.qrCodeTextFieldHasChanged?(token)
            self?.amountTextField.becomeFirstResponder()
        }
        present(vc, animated: true, completion: nil)
    }
    
    @IBAction func transferButtonTapped(_ sender: Any) {
        
        if qrCodeTextField.text == "" || amountTextField.text == "" {
            let alert = UIAlertController(title: "Alert!", message: "You should enter QR code and amount", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                switch action.style{
                case .default:
                    print("default")
                    
                case .cancel:
                    print("cancel")
                    
                case .destructive:
                    print("destructive")
                    
                }}))
            self.present(alert, animated: true, completion: nil)
        }else {
            self.view.addSubview(loading)
            loading.startAnimating()
            requestTransaction()
            
        }
    }
    func requestTransaction(){
        if let userQr = qrCodeTextField.text,
            let amountStr = amountTextField.text,
            let amount = Double(amountStr){
            TransactionsManager.shared.getUserWithQR(userQr) { (user) in
                guard let user = user else{ return }
                TransactionsManager.shared.createOperation(for: user, amount: amount, vendor: "Vendor", completion: { (status) in
                    self.loading.stopAnimating()
                })
            }
        }
        
    }
}

extension QRReaderViewController: UITextFieldDelegate {
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        guard let text = textField.text else { return true }
        qrCodeTextFieldHasChanged?(text)
        return true
    }
}

//
//


