//
//  TransactionsManager.swift
//  nkoodiVendor
//
//  Created by Michael Attia on 8/2/18.
//  Copyright © 2018 hajj hackathon. All rights reserved.
//

import Foundation
import FirebaseDatabase

class TransactionsManager{
   
    var ref: DatabaseReference
    
    private(set) static var shared = TransactionsManager()
    
    private init() {
        ref = Database.database().reference()
    }
    
    func getUserWithQR(_ qr: String, completion: @escaping (User?)->()){
        ref.child("users").observeSingleEvent(of: .value, with: { snapShot in
            guard let users = snapShot.value as? NSDictionary,
                let keys = users.allKeys as? [String] else{
                    completion(nil)
                    return
            }
            
            for key in keys{
                if let userData = users[key] as? NSDictionary,
                    let user = User(dict: userData, id: key),
                    user.qr == qr{
                    completion(user)
                    return
                }
            }
            completion(nil)
        })
    }
    
    func createOperation(for user: User, amount: Double, vendor: String, completion: @escaping (String?) -> Void){
        let operationId = IdGenerator.generateId()
        let operationData: [String: Any] = ["status" : "pending",
                                        "vendor" : vendor,
                                        "amount": amount]
        let operation: [String: Any] = [ operationId: operationData]
        ref.child("users").child(user.id).child("pending_operations").updateChildValues(operation)
        observeOperation(operationId, for: user, amount: amount, vendor: vendor, completion: completion)
    }
    
    func observeOperation(_ operationId: String, for user: User, amount: Double, vendor: String, completion: @escaping (String?) -> Void){
        ref.child("users").child(user.id).child("pending_operations").child(operationId).child("status").observe(.value, with: {snap in
            guard let status = snap.value as? String, status != "pending" else {return}
            self.ref.child("users").child(user.id).child("pending_operations").child(operationId).removeValue()
            self.createTransaction(for: user, amount: amount, vendor: vendor, status: status, completion: completion)
        })
        
    }
    
    func createTransaction(for user: User, amount: Double, vendor: String, status: String, completion: @escaping (String?) -> Void){
        let operation = status == "approved" ? "payment" : "cancelled"
        let transaction : [AnyHashable : Any] = ["date" : Date().timeIntervalSince1970,
                                                 "amount_changed" : amount * -1,
                                                 "vendor" : vendor,
                                                 "operation" : operation]
        ref.child("users").child(user.id).child("balance_history").updateChildValues(transaction)
        if status == "approved"{
            ref.child("users").child(user.id).child("current_balance").observeSingleEvent(of: .value, with: {snapshot in
                if let oldAmount = snapshot.value as? Double{
                    let newAmount = oldAmount - amount
                    self.ref.child("users").child(user.id).child("current_balance").setValue(newAmount)
                    completion(status)
                }
            })
        }else{
          completion(status)
        }
        
        
    }
    
    
}

class IdGenerator{
    static func generateId() -> String{
        return UUID().uuidString
    }
}
