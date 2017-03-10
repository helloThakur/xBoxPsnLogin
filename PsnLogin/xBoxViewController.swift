//
//  xBoxViewController.swift
//  PsnLogin
//
//  Created by Ashutosh on 3/7/17.
//  Copyright © 2017 Verizon. All rights reserved.
//

import UIKit
import WebKit
import Alamofire


class xBoxViewController: UIViewController, WKNavigationDelegate {
 
    let psnUrl = "https://login.live.com/oauth20_authorize.srf?client_id=0000000048093EE3&redirect_uri=https://login.live.com/oauth20_desktop.srf&response_type=token&display=touch&scope=service::user.auth.xboxlive.com::MBI_SSL&locale=en"
    
    var webView: WKWebView!
    var accessToken: String?
    var refreshToken: String?
    
    @IBOutlet weak var closeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Preferences
        let preferences = WKPreferences()
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
        if let accessCode = (response.url?.absoluteString.matchingStrings(regex: "access_token=(.*)&token_type").first?[1]) {
            self.accessToken = accessCode
        }
        if let tokenCode = (response.url?.absoluteString.matchingStrings(regex: "refresh_token=(.*)&user_id").first?[1]) {
            self.refreshToken = tokenCode
        }
        
        if let _ = self.accessToken, let _ = self.refreshToken {
            self.sendMessage()
        }
        
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        decisionHandler(.allow)
    }
    
    func sendMessage () {
        let param: Dictionary<String, String> = [
            "access_token": self.accessToken!,
            "gamertags": "crossroadsjason",
            "message": "Hello from Ashu, testing xBox messages",
            ]
        
        Alamofire.request("https://hidden-atoll-21536.herokuapp.com/xbox_live_send_msg.php", method: .get, parameters: param).responseJSON { response in
            switch response.result {
            case .success(let value):
                print("Value: \(value)")
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






