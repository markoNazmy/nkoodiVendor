//
//  QRReaderViewController.swift
//  nkoodi
//
//  Created by marko nazmy on 8/2/18.
//  Copyright © 2018 Hajj Hackathon. All rights reserved.
//

import Foundation
import UIKit

class QRReaderViewController: UIViewController {
    
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var transferContactNameLabel: UILabel!
    @IBOutlet weak var qrCodeTextField: UITextField!
    @IBOutlet weak var amountTextField: UITextField!
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
            self.transferContactNameLabel.text = "user name: " + text
        }
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
    
    @IBAction func contactsButtonTapped(_ sender: Any) {
    }
    
    @IBAction func transferButtonTapped(_ sender: Any) {
        
        if qrCodeTextField.text == "" || amountTextField.text == "" {
            let alert = UIAlertController(title: "Alert!", message: "you should enter contact and amount", preferredStyle: UIAlertControllerStyle.alert)
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
            //TODO: Show Loading
            
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
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        qrCodeTextFieldHasChanged?(text)
        return true
    }
}
