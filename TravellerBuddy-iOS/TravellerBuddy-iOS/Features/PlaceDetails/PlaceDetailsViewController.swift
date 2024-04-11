//
//  PlaceDetailsViewController.swift
//  TravellerBuddy-iOS
//
//  Created by Prabhagaran Ganesan on 31/03/24.
//

import Foundation
import UIKit

final class PlaceDetailsViewController: ASUIViewController {
        
    private lazy var button: UIButton = {
        let button: UIButton = UIButton.construct()
        button.backgroundColor = .lightGray
        return button
    }()
    
    private lazy var buttonLayer: UIView = {
        let view: UIView = UIView.construct()
        view.backgroundColor = .lightGray
        view.isUserInteractionEnabled = false
        return view
    }()
    
    private lazy var titleLabel: ASLabel = {
        let label: ASLabel = ASLabel.construct()
        label.text = "adsfkjasdjkhfashjdfhjasdfhjasdf aksfhkjasfjhasfhjk"
        label.typographyToken = theme.titleBold
        label.typographyToken = theme.typography.titleBold
        label.numberOfLines = 0
        return label
    }()
    
    var sundayGradient: CAGradientLayer?
    
    override func viewDidLoad() {
        
    }
    
    override func loadView() {
        view = ASUIView()
        setupView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let gradient = CAGradientLayer()
            gradient.frame = button.bounds
            gradient.colors = [UIColor.cyan.cgColor, UIColor.blue.cgColor, UIColor.systemPink.cgColor]
        gradient.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradient.endPoint = CGPoint(x: 1.0, y: 0.0)
        let shapeLayer = CAShapeLayer()
        shapeLayer.lineWidth = 5
        shapeLayer.path = UIBezierPath(roundedRect: button.bounds, cornerRadius: button.layer.cornerRadius).cgPath
        shapeLayer.strokeColor = UIColor.black.cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        gradient.mask = shapeLayer
        button.layer.insertSublayer(gradient, at: 0)
    }
    
    private func setupView() {
        button.addSubview(buttonLayer)
        view.addSubview(button)
        view.addSubview(titleLabel)
        self.viewBackgroundColortoken = theme.colors.fillBackground
        addCornerRadius()
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            titleLabel.topAnchor.constraint(equalTo: button.bottomAnchor, constant: 16),
            
            button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            button.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            button.heightAnchor.constraint(equalToConstant: 50),
            
            buttonLayer.leadingAnchor.constraint(equalTo: button.leadingAnchor, constant: -20),
            buttonLayer.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: 0),
            buttonLayer.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            buttonLayer.heightAnchor.constraint(equalToConstant: 50),
        ])
        
        addTapAction()
    }
    
    private func addTapAction() {
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }
    
    private func addCornerRadius() {
        button.clipsToBounds = true
        button.layer.cornerRadius = 16
    }
    
    @objc
    func buttonTapped() {

        UIView.animateKeyframes(withDuration: 0.46, delay: 0) {
            UIView.animateKeyframes(withDuration: 0.10, delay: 0) {
                self.button.transform = CGAffineTransform(scaleX: 0.76, y: 0.9)
            }
            
            UIView.animate(withDuration:  0.10, delay: 0.10, animations: {
                self.button.transform = CGAffineTransform(scaleX: 1, y: 1)
            }) { result in
                UIView.animateKeyframes(withDuration: 0.12, delay: 0, options: .calculationModeCubicPaced) {
                    self.buttonLayer.layer.opacity = 0.7
                    self.buttonLayer.transform = CGAffineTransform(scaleX: 0.5, y: 1)
                }
                
                UIView.animateKeyframes(withDuration: 0.9, delay: 0.12, options: .calculationModeCubicPaced) {
                    self.buttonLayer.layer.opacity = 0.3
                    self.buttonLayer.transform = CGAffineTransform(scaleX: 0.2, y: 1)
                }
                
                UIView.animateKeyframes(withDuration: 0.9, delay: 0.21, options: .calculationModeCubicPaced) {
                    self.buttonLayer.layer.opacity = 1
                    self.buttonLayer.transform = CGAffineTransform(scaleX: 1, y: 1)
                }
            }
        }
    }
}

extension UIView {
    func addBorderGradient() {
        let gradient = CAGradientLayer()
        gradient.frame = CGRect(origin: .zero, size: self.frame.size)
        gradient.colors = [UIColor.cyan, UIColor.blue, UIColor.systemPink]
        gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1.0, y: 0.5)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.lineWidth = 10
        shapeLayer.path = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.layer.cornerRadius).cgPath
        shapeLayer.strokeColor = UIColor.black.cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        gradient.mask = shapeLayer
        
        self.layer.insertSublayer(gradient, at: 0)
    }
}
