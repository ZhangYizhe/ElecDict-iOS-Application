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

class ViewController: UIViewController,WKUIDelegate, WKNavigationDelegate {
    
    var webView : WKWebView?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.init(red: 27/255, green: 42/255, blue: 88/255, alpha: 1)
        
        // 加载DOM脚本
        let scriptURL = Bundle.main.path(forResource: "DisposeCambridgeDict", ofType: "js")
        guard let scriptContent = try? String(contentsOfFile: scriptURL!, encoding: .utf8) else {
            return
        }
        let userScript = WKUserScript(source: scriptContent, injectionTime: .atDocumentStart, forMainFrameOnly: true)

        // 注入DOM
        let contentController = WKUserContentController()
        contentController.addUserScript(userScript)

        let webViewConfiguration = WKWebViewConfiguration()
        webViewConfiguration.userContentController = contentController

        // 初始化
        webView = WKWebView(frame: .zero, configuration: webViewConfiguration)
        webView?.uiDelegate = self
        webView?.navigationDelegate = self
        self.view.addSubview(webView ?? UIView())
        
        layoutInit()
        
        let myURL = URL(string:"https://dictionary.cambridge.org/dictionary/english/")
        let myRequest = URLRequest(url: myURL!)
        webView?.load(myRequest)
        
            

    }

    private func layoutInit()
    {
        webView?.snp.makeConstraints { (make) in
            make.top.equalTo(self.view.safeAreaLayoutGuide)
            make.bottom.equalTo(self.view)
            make.left.equalTo(self.view.safeAreaLayoutGuide)
            make.right.equalTo(self.view.safeAreaLayoutGuide)
        }
    }

}

