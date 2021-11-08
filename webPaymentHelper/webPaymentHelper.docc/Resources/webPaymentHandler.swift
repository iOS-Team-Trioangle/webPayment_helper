//
//  File.swift
//  
//
//  Created by trioangle on 01/11/21.
//

import UIKit
import PaymentHelper
import UIKit
import MessageUI
import Social
import WebKit

open struct payment_result{
    var status : String
    var payAmt : String
}

open class webPaymentHandler: UIViewController {
    var webView = WKWebView()
    var page_result:payment_result?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    public func loadWebView(url:String){
        webView = WKWebView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height),configuration: WKWebViewConfiguration())
        self.view.addSubview(webView)
        webView.load(NSURLRequest(url: NSURL(string: url)! as URL) as URLRequest)
    }
    
    public
    func getPaymentResult(url: String,
                          completion : @escaping (Result<(payment_result),Error>) -> Void) {
        self.loadWebView(url: url)
        self.webView.uiDelegate = self
        self.webView.navigationDelegate = self
        if page_result != nil {
            completion(.success(page_result!))
        } else {
            completion(.failure("Error" as! Error))
     }
        print("***********AftercallingResult*********",page_result)
    }
}

extension webPaymentHandler:WKNavigationDelegate, WKUIDelegate{
    public func webView(_ webView: WKWebView,
                 didStartProvisionalNavigation navigation: WKNavigation!) {
        print("start load:\(String(describing: webView.url))")
       // self.loader_start()
    }
    
    // 3. Fail while loading with an error
    public func webView(_ webView: WKWebView,
                 didFail navigation: WKNavigation!,
                 withError error: Error) {
        print("fail with error: \(error.localizedDescription)")
    }

    // 4. WKWebView finish loading
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("finish loading")
        //self.loader_end()
        webView.evaluateJavaScript("document.getElementById('data').innerHTML", completionHandler: { result, error in
            if let userAgent = result as? String {
                if let resFinal = self.convertStringToDictionary(text: userAgent){
                    print("*****************")
                    print(resFinal)
                    self.page_result = payment_result.init(status: resFinal["status_code"] as! String, payAmt: resFinal["wallet_amount"] as! String)
                    print("***********Result*********",page_result)
                }

            }
        })
    }
    
    
    func convertStringToDictionary(text: String) -> [String:AnyObject]? {
        if let data = text.data(using: String.Encoding.utf8) {
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:AnyObject]
                return json
            } catch {
                print("Something went wrong")
            }
        }
        return nil
    }
    
}

