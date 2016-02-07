//
//  ViewController.swift
//  Drop-In UI with Pods - Swift
//
//  Created by Orcun on 05/02/2016.
//  Copyright © 2016 Orcun. All rights reserved.
//

import UIKit




class ViewController: UIViewController, BTDropInViewControllerDelegate {
    
    var braintreeClient: BTAPIClient?

    
    @IBOutlet weak var buy02Button: UIButton!
    @IBOutlet weak var buy01Button: UIButton!
    @IBOutlet weak var label01: UILabel!
    @IBOutlet weak var label02: UILabel!
    @IBOutlet weak var label03: UILabel!
    @IBOutlet weak var label04: UILabel!
    @IBOutlet weak var label05: UILabel!
    
    var price: Double!
    var guitarName:String!
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        buy01Button.tag=1
        buy02Button.tag=2
        
        buy01Button.addTarget(self, action: "buttonClicked:", forControlEvents: .TouchUpInside)
        buy02Button.addTarget(self, action: "buttonClicked:", forControlEvents: .TouchUpInside)

        
        let clientTokenURL = NSURL(string: "http://orcodevbox.co.uk/BTOrcun/tokenGen.php")!
        let clientTokenRequest = NSMutableURLRequest(URL: clientTokenURL)
        clientTokenRequest.setValue("text/plain", forHTTPHeaderField: "Accept")
        
        NSURLSession.sharedSession().dataTaskWithRequest(clientTokenRequest) { (data, response, error) -> Void in
            // TODO: Handle errors
            let clientToken = String(data: data!, encoding: NSUTF8StringEncoding)
            
            self.braintreeClient = BTAPIClient(authorization: clientToken!)
            
            // Log the client token to confirm that it is returned from server
            NSLog(clientToken!);
            
            // As an example, you may wish to present our Drop-in UI at this point.
            // Continue to the next section to learn more...
            }.resume()
    }
    
    // Setup the appropriate amount and item name for each button
    func buttonClicked(sender: AnyObject)
    {
        switch sender.tag {
        case 1:
        price = 2200.00;
        guitarName = "Gibson Zakk Wylde";
        
        // Launch Drop-In View Controller
        tappedMyPayButton()
        
        break;
        case 2:
        price = 1300.00;
        guitarName = "Ibanez Universe ";
        
        // Launch Drop-In View Controller
        tappedMyPayButton();
        
        break;
        default: ()
        break;
        }
        
    }
    
    
    
    func tappedMyPayButton() {
        
        // If you haven't already, create and retain a `BTAPIClient` instance with a
        // tokenization key OR a client token from your server.
        // Typically, you only need to do this once per session.
        // braintreeClient = BTAPIClient(authorization: aClientToken)
        
        // Create a BTDropInViewController
        let dropInViewController = BTDropInViewController(APIClient: braintreeClient!)
        dropInViewController.delegate = self
        
        // This is where you might want to customize your view controller (see below)
        
        // The way you present your BTDropInViewController instance is up to you.
        // In this example, we wrap it in a new, modally-presented navigation controller:
        dropInViewController.navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: UIBarButtonSystemItem.Cancel,
            target: self, action: "userDidCancelPayment")
        let navigationController = UINavigationController(rootViewController: dropInViewController)
        presentViewController(navigationController, animated: true, completion: nil)

        
           }
    
    func userDidCancelPayment() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func dropInViewController(viewController: BTDropInViewController,
        didSucceedWithTokenization paymentMethodNonce: BTPaymentMethodNonce)
    {
        
        // Send payment method nonce to your server for processing
        postNonceToServer(paymentMethodNonce.nonce)
        dismissViewControllerAnimated(true, completion: nil)
        
        // Log the payment nonce to confirm it's successfully generated
         print("Payment nonce: \(paymentMethodNonce.nonce)")
    }
    
    func dropInViewControllerDidCancel(viewController: BTDropInViewController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func postNonceToServer(paymentMethodNonce: String) {
        let paymentURL = NSURL(string: "http://orcodevbox.co.uk/BTOrcun/iosPayment.php")!
        let request = NSMutableURLRequest(URL: paymentURL)
        request.HTTPBody = "amount=\(Double(price))&payment_method_nonce=\(paymentMethodNonce)".dataUsingEncoding(NSUTF8StringEncoding);
        request.HTTPMethod = "POST"
        
        
        NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, response, error) -> Void in
            // TODO: Handle success or failure
            let responseData = String(data: data!, encoding: NSUTF8StringEncoding)
            // Log the response in console
            print(responseData);
            
            // Display the result in an alert view
            dispatch_async(dispatch_get_main_queue(), {
                let alertResponse = UIAlertController(title: "Result", message: "\(responseData)", preferredStyle: UIAlertControllerStyle.Alert)
                
                // add an action to the alert (button)
                alertResponse.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                
                // show the alert
                self.presentViewController(alertResponse, animated: true, completion: nil)
                
            })

            }.resume()
    }
    
    
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

