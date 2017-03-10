//
//  psnViewController.swift
//  PsnLogin
//
//  Created by Ashutosh on 2/20/17.
//

import UIKit
import WebKit
import Alamofire
import SwiftyJSON


extension String {
    func matchingStrings(regex: String) -> [[String]] {
        guard let regex = try? NSRegularExpression(pattern: regex, options: []) else { return [] }
        let nsString = self as NSString
        let results  = regex.matches(in: self, options: [], range: NSMakeRange(0, nsString.length))
        return results.map { result in
            (0..<result.numberOfRanges).map { result.rangeAt($0).location != NSNotFound
                ? nsString.substring(with: result.rangeAt($0))
                : ""
            }
        }
    }
}


class psnViewController: UIViewController, WKNavigationDelegate {
    
    
    let psnUrl = "https://auth.api.sonyentertainmentnetwork.com/2.0/oauth/authorize?response_type=code&client_id=b7cbf451-6bb6-4a5a-8913-71e61f462787&scope=capone:report_submission,psn:sceapp,user:account.get,user:account.settings.privacy.get,user:account.settings.privacy.update,user:account.realName.get,user:account.realName.update,kamaji:get_account_hash,kamaji:ugc:distributor,oauth:manage_device_usercodes&request_locale=en&grant_type=authorization_code"
    
    var webView: WKWebView!
    var grantCode: String = ""
    
    @IBOutlet weak var closeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Preferences
        let preferences = WKPreferences()
        preferences.javaScriptEnabled = false
        preferences.javaScriptCanOpenWindowsAutomatically = false
        
        //Configuration
        let configuration = WKWebViewConfiguration()
        configuration.preferences = preferences
        
        webView = WKWebView(frame: self.view.bounds, configuration: configuration)
        webView.navigationDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        self.view.addSubview(self.webView)
        
        
        let url = URL(string: psnUrl)!
        let mutRequest = NSMutableURLRequest.init(url: url)
        webView.load(mutRequest as URLRequest)
        
        self.view.bringSubview(toFront: closeButton)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        
        let response = navigationResponse.response as! HTTPURLResponse
        if let code = (response.url?.query?.matchingStrings(regex: "code%3D(\\w{6,})").first?[1]) {
            self.grantCode = code
            self.sendMessage()
        }
        
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        decisionHandler(.allow)
    }
    
    func sendMessage () {
        self.webView.removeFromSuperview()
        
        let params: Dictionary<String, String> = [
            "duid": "0000000d000400808F4B3AA3301B4945B2E3636E38C0DDFC",
            "client_secret": "zsISsjmCx85zgCJg",
            "app_context": "inapp_ios",
            "client_id": "b7cbf451-6bb6-4a5a-8913-71e61f462787",
            "scope": "capone:report_submission,psn:sceapp,user:account.get,user:account.settings.privacy.get,user:account.settings.privacy.update,user:account.realName.get,user:account.realName.update,kamaji:get_account_hash,kamaji:ugc:distributor,oauth:manage_device_usercodes",
            "grant_type": "authorization_code",
            "code": self.grantCode
        ]
        
        Alamofire.request("https://auth.api.sonyentertainmentnetwork.com/2.0/oauth/token", method: .post, parameters: params).responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                let accessToken = json["access_token"].string
                let refreshToken = json["refresh_token"].string
                let param: Dictionary<String, String> = [
                    "oauth": accessToken!,
                    "refresh": refreshToken!,
                    "user": "Kaeden2010",
                    "message": "Hello from Ashu, testing PSN messages",
                    ]
                
                Alamofire.request("https://hidden-atoll-21536.herokuapp.com/messaging.php", method: .get, parameters: param).responseJSON { response in
                    switch response.result {
                    case .success(let value):
                        print("Value: \(value)")
                    case .failure(let error):
                        print(error)
                    }
                    
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    @IBAction func closeWebView () {
        self.dismiss(animated: true) {
        }
    }
}










