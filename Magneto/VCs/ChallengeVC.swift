//
//  ChallengeVC.swift
//  Magneto
//
//  Created by syan on 26/09/2025.
//  Copyright © 2025 Syan. All rights reserved.
//

import UIKit

class ChallengeVC: UIViewController {
    
    // MARK: Init
    init(url: URL, completion: @escaping (Result<String, AppError>) -> Void) {
        self.completion = completion
        super.init(nibName: nil, bundle: nil)
        self.challengeView = .init(url: url) { [weak self] _, status in
            self?.handleStatus(status)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = L10n.Webkit.title
        navigationItem.largeTitleDisplayMode = .always
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(title: L10n.Webkit.finish, style: .done, target: self, action: #selector(finishButtonTap)),
            UIBarButtonItem(title: L10n.Webkit.cancel, style: .done, target: self, action: #selector(cancelButtonTap)),
        ]
        navigationItem.rightBarButtonItems?[0].tintColor = .normalTextOnTint
        navigationItem.rightBarButtonItems?[1].tintColor = .altTextOnTint


        view.addSubview(UIView()) // prevent large title bar from collapsing when scrolling

        challengeView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(challengeView)
        NSLayoutConstraint.activate([
            challengeView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            challengeView.leftAnchor.constraint(equalTo: view.leftAnchor),
            challengeView.rightAnchor.constraint(equalTo: view.rightAnchor),
            challengeView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // MARK: Properties
    private var completion: ((Result<String, AppError>) -> Void)?
    
    // MARK: Views
    private var challengeView: ChallengeView!
    
    // MARK: Actions
    @objc private func cancelButtonTap() {
        dismiss(animated: true) {
            self.completion?(.init(error: .cancelled))
            self.completion = nil
        }
    }

    @objc private func finishButtonTap() {
        let html = self.challengeView.html ?? ""
        self.dismiss(animated: true) {
            self.completion?(.init(value: html))
            self.completion = nil
        }
    }

    private func handleStatus(_ status: Result<String, AppError>) {
        guard case .success = status else {
            return
        }
        finishButtonTap()
    }
}
