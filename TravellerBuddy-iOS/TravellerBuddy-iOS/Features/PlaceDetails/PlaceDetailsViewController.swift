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
        label.text = "This is testing custom animation with ui component screen"
        label.typographyToken = theme.titleBold
        label.typographyToken = theme.typography.titleBold
        label.numberOfLines = 0
        return label
    }()
    let screenSize = UIScreen.main.bounds.size

    private lazy var triangleImageView: UIImageView = {
        let imageView: UIImageView = UIImageView(frame: CGRect(x: screenSize.width-50, y: screenSize.height/2, width: 200, height: 200))
        imageView.transform = CGAffineTransform(rotationAngle: 52)
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "triangle")
        return imageView
    }()
    
    private lazy var hexagonImageView: UIImageView = {
        let imageView: UIImageView = UIImageView(frame: CGRect(x: screenSize.width, y: 100, width: 130, height: 130))
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "hexagon")
        return imageView
    }()
    
    private lazy var bubbleImageView: UIImageView = {
        let imageView: UIImageView = UIImageView(frame: CGRect(x: screenSize.width, y: screenSize.height/2-100, width: 130, height: 130))
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "bubble1")
        return imageView
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
        view.addSubview(bubbleImageView)

        view.addSubview(triangleImageView)
        view.addSubview(hexagonImageView)
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
        playAnimation()
        startTimer()
    }
    
    private func addTapAction() {
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }
    
    private func addCornerRadius() {
        button.clipsToBounds = true
        button.layer.cornerRadius = 16
        triangleImageView.clipsToBounds = true
        triangleImageView.layer.cornerRadius = 40
    }
    
    private func playAnimation() {
                
        UIView.animate(withDuration: 3, delay: 0, options: [.repeat, .autoreverse], animations:  { [weak self] in
            guard let self = self else { return }
            self.triangleImageView.transform =  CGAffineTransform(rotationAngle: -180)
            self.triangleImageView.transform = CGAffineTransform(translationX: -self.screenSize.width/2-100, y: self.screenSize.height/2-150)
        })
    }
    var timer: Timer = Timer()
    
    private func startTimer() {
        playHexagonAnimation()
        timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(playHexagonAnimation), userInfo: nil, repeats: true)
    }
    
    @objc func playHexagonAnimation() {
        UIView.animateKeyframes(withDuration: 4, delay: 0) { [weak self] in
            guard let self = self else { return }

            UIView.animate(withDuration: 2, delay: 0, animations:  {
                self.hexagonImageView.transform = CGAffineTransform(translationX: -self.screenSize.width/2, y: self.screenSize.height-200)
            }) { _ in
                UIView.animate(withDuration: 2, delay: 0, animations: {
                    self.hexagonImageView.transform = CGAffineTransform(translationX: -700, y: 0).rotated(by: 57)
                })
            }
        }
        
        UIView.animate(withDuration: 2, delay: 0, animations: { [weak self] in
            guard let self = self else { return }
            self.bubbleImageView.transform = CGAffineTransform(scaleX: 3, y: 3).translatedBy(x: -self.screenSize.width/2+100, y: 150)
        }) { _ in
            UIView.animate(withDuration: 3, delay: 0, animations: { [weak self] in
                guard let self = self else { return }
                self.bubbleImageView.transform = CGAffineTransform(translationX: -530, y: -300).scaledBy(x: 0.7, y: 0.7)
            })
        }
    }
    
    @objc
    func buttonTapped() {

        UIView.animateKeyframes(withDuration: 0.46, delay: 0) { [weak self] in
            guard let self = self else { return }

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
    
    deinit {
        print("deinited")
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

