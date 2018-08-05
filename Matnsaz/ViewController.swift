//
//  ViewController.swift
//  UrduKeyboard
//
//  Created by Zeerak Ahmed on 2/13/18.
//  Copyright © 2018 Zeerak Ahmed. All rights reserved.
//

import UIKit
import MessageUI

class ViewController: UIViewController , MFMailComposeViewControllerDelegate {

    @IBOutlet weak var mailButton: UIButton!
    
    @IBAction func sendMail(_ sender: Any) {
        if MFMailComposeViewController.canSendMail() {
            let emailTitle = "Comments on Matnsaz"
            let toRecipents = ["zeerak.ahmed@gmail.com"]
            let mc: MFMailComposeViewController = MFMailComposeViewController()
            mc.mailComposeDelegate = self
            mc.setSubject(emailTitle)
            mc.setToRecipients(toRecipents)
            
            self.present(mc, animated: true, completion: nil)
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        switch result.rawValue {
        case MFMailComposeResult.cancelled.rawValue:
            break
        case MFMailComposeResult.saved.rawValue:
            break
        case MFMailComposeResult.sent.rawValue:
            break
        case MFMailComposeResult.failed.rawValue:
            break
            //print("Error: \(String(describing: error?.localizedDescription))")
        default:
            break
        }
        controller.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

