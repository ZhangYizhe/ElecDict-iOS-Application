//
//  ViewController.swift
//  ElecDict
//
//  Created by 张艺哲 on 2020/5/29.
//  Copyright © 2020 Elecoxy. All rights reserved.
//

import UIKit
import WebKit
import SnapKit

class ViewController: UIViewController, UITextFieldDelegate, WKUIDelegate, WKNavigationDelegate {
    
    var searchTextField : UITextField?
    
    var webView : WKWebView?
    
    var webViewEstimatedProgressObservation: NSKeyValueObservation?
    
    var webViewProgressView : UIProgressView?
    
    override var preferredStatusBarStyle: UIStatusBarStyle
    {
        .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.init(red: 36/255, green: 44/255, blue: 93/255, alpha: 1)
        
        // 初始化搜索框
        searchTextField = SearchTextField()
        searchTextField?.clearButtonMode = .whileEditing
        searchTextField?.delegate = self
        searchTextField?.placeholder = "Search English"
        searchTextField?.layer.masksToBounds = true
        searchTextField?.layer.cornerRadius = 20
        searchTextField?.backgroundColor = UIColor.white
        searchTextField?.returnKeyType = .search
        searchTextField?.keyboardType = .asciiCapable
        self.view.addSubview(searchTextField ?? UIView())
        
        // 加载DOM脚本
        let scriptURL = Bundle.main.path(forResource: "DisposeCambridgeDict", ofType: "js")
        guard let scriptContent = try? String(contentsOfFile: scriptURL!, encoding: .utf8) else {
            return
        }
        let userScript = WKUserScript(source: scriptContent, injectionTime: .atDocumentEnd, forMainFrameOnly: true)

        // 注入DOM
        let contentController = WKUserContentController()
        contentController.addUserScript(userScript)

        let webViewConfiguration = WKWebViewConfiguration()
        webViewConfiguration.userContentController = contentController

        // 初始化WebView
        webView = WKWebView(frame: .zero, configuration: webViewConfiguration)
        webView?.uiDelegate = self
        webView?.navigationDelegate = self
        webView?.allowsBackForwardNavigationGestures = true // 允许通过手势操作返回
        webView?.scrollView.keyboardDismissMode = .onDrag
        // listen the web process
        webViewEstimatedProgressObservation = webView?.observe(\.estimatedProgress, options: .new, changeHandler: { [weak self] (webView, value) in
            self?.webViewProgressView?.setProgress(Float(value.newValue ?? 0), animated: true)
        })
        self.view.addSubview(webView ?? UIView())
        
        webViewProgressView = UIProgressView()
        webViewProgressView?.trackTintColor = UIColor.clear
        webViewProgressView?.progressTintColor = UIColor.init(red: 251/255, green: 187/255, blue: 0/255, alpha: 1)
        self.view.addSubview(webViewProgressView ?? UIView())
        
        layoutInit()

        loadUrl("https://dictionary.cambridge.org/dictionary/english/")
    }

    private func layoutInit()
    {
        searchTextField?.snp.makeConstraints({ (make) in
            make.top.equalTo(self.view.safeAreaLayoutGuide).offset(10)
            make.left.equalTo(self.view.safeAreaLayoutGuide).offset(20)
            make.right.equalTo(self.view.safeAreaLayoutGuide).offset(-20)
            make.height.equalTo(40)
        })
        
        webView?.snp.makeConstraints { (make) in
            make.top.equalTo(searchTextField!.snp.bottom).offset(10)
            make.bottom.equalTo(self.view)
            make.left.equalTo(self.view.safeAreaLayoutGuide)
            make.right.equalTo(self.view.safeAreaLayoutGuide)
        }
        
        webViewProgressView?.snp.makeConstraints({ (make) in
            make.top.equalTo(webView!)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
        })
    }
    
    // load webview
    func loadUrl(_ string: String) {
        var string = string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        string = string.replacingOccurrences(of: " ", with: "+")
        guard let myURL = URL(string: string) else {
            loadUrl("https://dictionary.cambridge.org/dictionary/english/")
            return
        }
        let myRequest = URLRequest(url: myURL)
        webView?.load(myRequest)
    }
    
    // delegate webview
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        searchTextField?.text = nil
    }
    
    // keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        loadUrl("https://dictionary.cambridge.org/search/direct/?datasetsearch=english&q=\(textField.text ?? "")")
        return true
    }

    deinit {
        webViewEstimatedProgressObservation?.invalidate()
    }
}

