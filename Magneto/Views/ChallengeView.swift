//
//  ChallengeView.swift
//  Magneto
//
//  Created by syan on 26/09/2025.
//  Copyright © 2025 Syan. All rights reserved.
//

import UIKit
import WebKit
import BrightFutures

class ChallengeView: UIView {
    
    // MARK: Init
    private static var staticViews = [ChallengeView]()
    static func load(_ url: URL, maxTries: Int) -> Future<String, AppError> {
        return .init { resolver in
            var remainingTries = maxTries
            
            staticViews.append(ChallengeView(url: url) { view, result in
                remainingTries -= 1
                switch result {
                case .success(let html):
                    view.timer.invalidate()
                    staticViews.remove(view)
                    resolver(.success(html))
                    
                case .failure(let error):
                    if remainingTries == 0 {
                        view.timer.invalidate()
                        staticViews.remove(view)
                        resolver(.failure(error))
                    }
                }
            })
        }
    }

    init(url: URL, status: @escaping (ChallengeView, Result<String, AppError>) -> Void) {
        self.url = url
        self.status = status
        super.init(frame: .init(x: 0, y: 0, width: 123, height: 147))
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        webView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(webView)
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: topAnchor),
            webView.leftAnchor.constraint(equalTo: leftAnchor),
            webView.rightAnchor.constraint(equalTo: rightAnchor),
            webView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        webView.load(URLRequest(url: url))
        webView.navigationDelegate = self
        RunLoop.current.add(timer, forMode: .common)
    }
    
    override func didMoveToWindow() {
        if window == nil {
            timer.invalidate()
        }
    }
    
    // MARK: Properties
    private let url: URL
    private var status: (ChallengeView, Result<String, AppError>) -> Void
    private(set) lazy var timer = Timer(timeInterval: 1, target: self, selector: #selector(timerTick), userInfo: nil, repeats: true)
    private(set) var html: String?
    
    // MARK: Views
    private let webView: WKWebView = .init(frame: .zero, configuration: WKWebViewConfiguration())
    
    // MARK: Actions
    @objc private func timerTick() {
        loadContent()
    }
    
    // MARK: Content
    private func loadContent() {
        guard !webView.isLoading else { return }
        webView.evaluateJavaScript("document.documentElement.outerHTML.toString()") { (value, error) in
            if let value = value as? String {
                self.html = value
                self.autoComplete()
            }
        }
    }

    private func autoComplete() {
        let isShowingChallenge = html?.contains("src=\"https://challenges.cloudflare.com/turnstile/") == true
        if isShowingChallenge {
            status(self, .failure(.cancelled))
        }
        else {
            status(self, .success(html ?? ""))
        }
    }
}

extension ChallengeView: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        loadContent()
    }
}
