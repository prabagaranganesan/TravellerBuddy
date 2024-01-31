//
//  ShimmerView.swift
//  TravellerBuddy-iOS
//
//  Created by Prabhagaran Ganesan on 30/01/24.
//

import Foundation
import UIKit

public class ShimmerView: UIView {
    public enum ShimmerShape: CaseIterable {
        case rectangle
        case capsule
        case circle
        case custom

        fileprivate func getCornerRadius() -> CGFloat {
            switch self {
            case .rectangle:
                return 16.0
            case .capsule:
                return 4.0
            case .circle, .custom:
                return 0.0
            }
        }
    }
    public var shape: ShimmerShape = .rectangle
    private var gradientLayer: CAGradientLayer = {
        let motion = ShimmerMotion()
        motion.isRemovedOnCompletion = false
        return motion.getGradientLayer()
    }()

    /// :nodoc:
    override public init(frame: CGRect) {
        super.init(frame: CGRect.zero)
        self.initialSetup()
    }

    /// :nodoc:
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.initialSetup()
    }

    private func initialSetup() {
        self.isAccessibilityElement = true
    }

    public func build() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.layer.masksToBounds = true
        self.clipsToBounds = true
        self.backgroundColor = .systemGray4
        gradientLayer.removeFromSuperlayer()
        self.layer.addSublayer(gradientLayer)
    }

    /// :nodoc:
    override public func layoutSubviews() {
        super.layoutSubviews()
        if self.shape == .circle {
            self.layer.cornerRadius = self.bounds.width.half
            gradientLayer.cornerRadius = self.bounds.width.half
        } else if self.shape != .custom {
            self.layer.cornerRadius = shape.getCornerRadius()
            gradientLayer.cornerRadius = self.shape.getCornerRadius()
        }
        let corner1 = CGPoint(x: self.bounds.minX, y: self.bounds.maxY)
        let corner2 = CGPoint(x: self.bounds.maxX, y: self.bounds.minY)
        let diagonalLength = CGPointDistance(from: corner2, to: corner1)
        gradientLayer.bounds = CGRect(x: self.center.x - diagonalLength, y: self.center.y - diagonalLength, width: 2 * diagonalLength, height: 2 * diagonalLength)
    }

    func CGPointDistance(from: CGPoint, to: CGPoint) -> CGFloat {
        let distanceSqrd = (from.x - to.x) * (from.x - to.x) + (from.y - to.y) * (from.y - to.y)
        return sqrt(distanceSqrd)
    }

    /// Restart shimmer animation on this view. The animation plays by default after intialization.
    public func start() {
        if gradientLayer.superlayer != nil {
            gradientLayer.removeFromSuperlayer()
        }
        self.layer.addSublayer(gradientLayer)
        self.layoutIfNeeded()
    }

    /// Stop shimmer animation on this view
    public func stop() {
        gradientLayer.removeFromSuperlayer()
    }
}

public extension UIView {
    /// Add an animated shimmering view on top of your view.
    /// This adds a `ShimmerView` on top of the view on which this is called, with constraints
    /// matching bounds of this view.
    /// - Parameters:
    ///   - theme: The theme instance
    ///   - shape: A `ShimmerShape`. Defaults to `.custom`, ie, no corner radius of its own.
    func beginShimmer(shape: ShimmerView.ShimmerShape = .custom) {
        let shimmerView = ShimmerView()
        shimmerView.shape = shape
        shimmerView.build()
        if shape == .custom {
            shimmerView.layer.cornerRadius = self.layer.cornerRadius
            shimmerView.layer.maskedCorners = self.layer.maskedCorners
        }
        self.addSubview(shimmerView)
        
        NSLayoutConstraint.activate([
            shimmerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            shimmerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            shimmerView.topAnchor.constraint(equalTo: self.topAnchor),
            shimmerView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
        ])
    }
    /// Removes any `ShimmerView` added on top of a view.
    /// This also removes the multiple shimmers added by `Shimmer`'s `.show(onView:)`
    func endShimmer() {
        let shimmerViews = self.subviews.filter({ $0 is ShimmerView })
        shimmerViews.forEach({ $0.removeFromSuperview() })
        // Removes the container added via `Shimmer`
        let shimmerContainer = self.subviews.first(where: { $0.accessibilityIdentifier == "Shimmer" })
        shimmerContainer?.removeFromSuperview()
    }
}

/// The protocol which serves as the interface for `ShimmerMotion`
public protocol ShimmeringMotion: BasicMotion {
    var timeBetweenShimmers: TimeInterval { get }
}

/// Adds a shimmer effect on a view or a layer.
public final class ShimmerMotion: NSObject, ShimmeringMotion, CAAnimationDelegate {
    public var options: CAMediaTiming = LayerAnimationOptions()
    public var isRemovedOnCompletion = true
    public var curve = MotionCurve.moveIn
    public let animationKey = "ShimmerMotion"

    /// Duration of the animation.
    public var duration: TimeInterval {
        get {
            return options.duration
        }
        set {
            self.options.duration = newValue
        }
    }
    public let timeBetweenShimmers: TimeInterval
    public let animation = CABasicAnimation(keyPath: (\CAGradientLayer.locations).stringValue)
    public let gradient = CAGradientLayer()
    private let colorTokens: [UIColor] = [UIColor(red: 238, green: 238, blue: 238, alpha: 0.0),
                                             UIColor(red: 239, green: 239, blue: 239, alpha: 0.11),
                                             UIColor(red: 244, green: 244, blue: 244, alpha: 0.7),
                                             UIColor(red: 248, green: 248, blue: 248, alpha: 0.7),
                                             UIColor(red: 252, green: 252, blue: 252, alpha: 0.2),
                                             UIColor(red: 238, green: 238, blue: 238, alpha: 0.0)]
    private var completion: ((Bool) -> Void)?

    public init(duration: TimeInterval = 1.0, repeatCount: Float = .infinity, timeBetweenShimmers: TimeInterval = 1.0) {
        options.duration = duration
        options.repeatCount = repeatCount
        self.timeBetweenShimmers = timeBetweenShimmers
        super.init()
        setup()
    }

    public func animate(_ view: UIView, withDelay delay: TimeInterval, _ completion: ((Bool) -> Void)? = nil) {
        self.completion = completion
        let frame = self.gradientRect(in: view.bounds)
        animate(view.layer, frame: frame, withDelay: delay)
    }

    public func remove(from view: UIView) {
        self.remove(from: view.layer)
    }

    private func animate(_ layer: CALayer, frame: CGRect, withDelay delay: TimeInterval) {
        let group = CAAnimationGroup()
        group.animations = [animation]
        group.apply(duration: timeBetweenShimmers + duration, delay: delay, options: options, isRemovedOnCompletion: isRemovedOnCompletion, curve: self.curve)
        group.delegate = self
        gradient.name = "ShimmerGradient"
        gradient.colors = colorTokens.map { $0.cgColor }
        gradient.frame = frame
        gradient.transform = CATransform3DMakeRotation(10.0 / 180.0 * .pi, 0.0, 0.0, 1.0)
        gradient.add(group, forKey: animationKey)
        layer.addSublayer(gradient)
    }

    public func animate(_ layer: CALayer, withDelay delay: TimeInterval, _ completion: ((Bool) -> Void)?) {
        self.completion = completion
        let frame = self.gradientRect(in: layer.bounds)
        animate(layer, frame: frame, withDelay: delay)
    }

    public func remove(from layer: CALayer) {
        layer.removeAnimation(forKey: animationKey)
        _ = layer.sublayers?.map {
            if $0.name == "ShimmerGradient" {
                $0.removeFromSuperlayer()
            }
        }
    }

    func getGradientLayer() -> CAGradientLayer {
        let group = CAAnimationGroup()
        group.animations = [animation]
        group.apply(duration: timeBetweenShimmers + duration, options: options, isRemovedOnCompletion: isRemovedOnCompletion, curve: curve)
        gradient.name = animationKey
        gradient.colors = colorTokens.map { $0.cgColor }
        gradient.transform = CATransform3DMakeRotation(10.0 / 180.0 * .pi, 0.0, 0.0, 1.0)
        gradient.add(group, forKey: animationKey)
        return gradient
    }

    private func gradientRect(in bounds: CGRect) -> CGRect {
        var height = bounds.height
        let x: CGFloat = 0
        var y: CGFloat = 0

        if bounds.width > height {
            /// If the height is less than width, make height equal to width and
            /// moves the Y position to make the gradient layer to fit in the center
            y = -((bounds.width.half) - (height.half))
            height = bounds.width
        } else {
            /// If the width is less than height, increase height by    0.2 times and
            /// moves the Y position to make the gradient layer to fit in the center
            height += height * 0.2
            y = -(height * 0.1)
        }
        return CGRect(x: x, y: y, width: bounds.width, height: height)
    }

    private func setup() {
        animation.fromValue = [-1.0, -0.9, -0.8, -0.7, -0.6, -0.5]
        animation.toValue = [1.1, 1.2, 1.3, 1.4, 1.5, 1.6]
        animation.duration = duration
        animation.autoreverses = false
        animation.isRemovedOnCompletion = false
        animation.fillMode = .forwards
        animation.timingFunction = curve.timingFunction

        /// all the colors occupy a 6px space in a 58px container approximately 0.1x of the width,
        /// hence each color has 0.1 representation in a unit coordinate space
        gradient.locations = [-1.0, -0.9, -0.8, -0.7, -0.6, -0.5]
        gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1.0, y: 0.5)
    }

    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        completion?(flag)
    }
}

public protocol BasicMotion {
    /// The duration of the motion.
    var duration: TimeInterval { get set }

    /// The animation key used in case of a `CABasicAnimation`
    var animationKey: String { get }

    /// Applicable only on layer animations. Defaults to `true`.
    var isRemovedOnCompletion: Bool { get set }

    /// Provides more control into the layer animation timing. You can use `LayerAnimationOptions` to customise and set it to this property.
    /// - Note: When animating a view only `autoreverses`, `repeatCount` and `duration` are considered. Everything else is ignored. If you need control over the animation with other values, apply the motion on the layer.
    var options: CAMediaTiming { get set }

    /// A timing function or curve used for performing animations. Defaults to `Linear`
    var curve: MotionCurve { get set }

    func animate(_: CALayer, withDelay delay: TimeInterval, _ completion: ((Bool) -> Void)?)

    /// Removes the animation from the layer.
    /// - Parameter layer: The layer reference
    func remove(from layer: CALayer)

    /// Animates the view by applying this motion.
    /// - Parameters:
    ///   - on: The view to animate.
    ///   - delay: The delay to start the animation.
    ///   - completion: The animation completion block.
    func animate(_: UIView, withDelay delay: TimeInterval, _ completion: ((Bool) -> Void)?)

    /// Removes the animation from the view.
    /// - Parameter view: The view reference.
    func remove(from view: UIView)
}

/// This is a wrapper class to hold the animation options.
///
/// While animating a view, not all of these options will be supported. Currently we only support `repeatCount` and `autoreverses`.
///
/// If you need to use any other options here, please consider animating the layer instead of the view. This way you will have the granular control to modify these options.
public class LayerAnimationOptions: CAMediaTiming {
    public init(beginTime: CFTimeInterval = 0,
                duration: CFTimeInterval = 0,
                speed: Float = 1,
                timeOffset: CFTimeInterval = 0,
                repeatCount: Float = 0,
                repeatDuration: CFTimeInterval = 0,
                autoreverses: Bool = false,
                fillMode: CAMediaTimingFillMode = .forwards) {
        self.beginTime = beginTime
        self.duration = duration
        self.speed = speed
        self.timeOffset = timeOffset
        self.repeatCount = repeatCount
        self.repeatDuration = repeatDuration
        self.autoreverses = autoreverses
        self.fillMode = fillMode
    }

    public var beginTime: CFTimeInterval
    public var duration: CFTimeInterval
    public var speed: Float
    public var timeOffset: CFTimeInterval
    public var repeatCount: Float
    public var repeatDuration: CFTimeInterval
    public var autoreverses: Bool
    public var fillMode: CAMediaTimingFillMode
}

extension CAAnimation {
    /// Applies animation options to a layer.
    /// - Parameters:
    ///   - duration: Duration of the animation.
    ///   - delay: Delay to start the animation
    ///   - options: The options to apply.
    ///   - isRemovedOnCompletion: Denotes if the animation would be removed from layers once complete.
    ///   - curve: The curve to apply when animating.
    func apply(duration: TimeInterval? = nil, delay: TimeInterval = 0, options: CAMediaTiming? = LayerAnimationOptions(), isRemovedOnCompletion: Bool, curve: MotionCurve) {
        self.isRemovedOnCompletion = isRemovedOnCompletion
        self.timingFunction = curve.timingFunction
        if let options = options {
            self.beginTime = options.beginTime
            self.duration = options.duration
            self.speed = options.speed
            self.repeatCount = options.repeatCount
            self.timeOffset = options.timeOffset
            self.autoreverses = options.autoreverses
            self.fillMode = options.fillMode
        }
        // The duration passed as parameter would get higher priority than the duration present in `options`
        if let duration = duration {
            self.duration = duration
        }
        if delay > 0 {
            self.beginTime = CACurrentMediaTime() + delay
        }
    }
}

extension BasicMotion {
    func actualAnimationDelay(_ original: TimeInterval) -> TimeInterval {
        #if DEBUG
        return UIView.areAnimationsEnabled ? original : 0
        #else
        return original
        #endif
    }
}

/// A custom animation curve that can be used along with all `BasicMotion`s.
public final class MotionCurve: NSObject, UITimingCurveProvider {
    /// Motion curve constants as per design spec: https://go-jek.atlassian.net/wiki/spaces/MoD/pages/1977295820/Functional+motion+design
    /// This curve is derived from the standard Ease-In curve. This cure is mainly used for components that are set to enter the screen.
    public static let moveIn = MotionCurve(0.3, 0.28, 0.6, 1.0)

    /// This curve as the name says is used for elements moving out of the screen. This curve is used for components that are set to exit the screen of the user.
    public static let moveOut = MotionCurve(0.2, 1.0, 0.3, 1.0)

    /// As the word Flair (Not Flare) suggests this curve has a style of itself and this curve is tweaked with respect to our characterized branding, this curve has that smoothness in entering and landing both.
    public static let flairIn = MotionCurve(0.34, 0.0, 0.2, 0.99)

    /// Linear animation basically means animating from 0% to 100% without any changes in speed (i.e, no easing).
    public static let linear = MotionCurve(0.0, 0.0, 1.0, 1.0)

    // The curve will be set only when `MotionCurve` is initialised with a known value of `UIView.AnimationCurve`.
    public private(set) var animationCurve: UIView.AnimationCurve?

    /// A timing curve. Defaults to `.builtin`
    public private(set) var timingCurveType: UITimingCurveType = .builtin

    /// Set when the curve is a custom cubic bezier curve.
    public private(set) var cubicTimingParameters: UICubicTimingParameters?

    /// Set for spring animations parameters.
    public private(set) var springTimingParameters: UISpringTimingParameters?

    /// A timing function of the curve. Use this when applying this curve to a layer,
    public var timingFunction: CAMediaTimingFunction? {
        guard let params = self.cubicTimingParameters else {
            return self.animationCurve?.timingFunction
        }
        return CAMediaTimingFunction(controlPoints: Float(params.controlPoint1.x),
                                     Float(params.controlPoint1.y),
                                     Float(params.controlPoint2.x),
                                     Float(params.controlPoint2.y))
    }

    /// Instantiates a `builtin` `Linear` motion curve.
    override public init() {
        self.animationCurve = .linear
        self.timingCurveType = .builtin
    }

    /// Instantiates the curve with a `CAMediaTimingFunction`
    /// - Parameter timingFunction: A timing function.
    public convenience init(_ timingFunction: CAMediaTimingFunction) {
        if let curve = timingFunction.matchingBuiltInAnimationCurve {
            self.init(curve)
        } else {
            var controlPoint1: [Float] = [0, 0]
            var controlPoint2: [Float] = [0, 0]
            timingFunction.getControlPoint(at: 1, values: &controlPoint1)
            timingFunction.getControlPoint(at: 2, values: &controlPoint2)
            self.init(controlPoint1[0], controlPoint1[1], controlPoint2[0], controlPoint2[1])
        }
    }

    /// Instantiates the curve with a built in animation curve. Refer to `UIView.AnimationCurve` for available options.
    /// - Parameter curve: The built in curve.
    public init(_ curve: UIView.AnimationCurve) {
        self.timingCurveType = .builtin
        self.animationCurve = curve
    }

    /// Instantiates a cubic bezier curve.
    /// - Parameters:
    ///   - c1x: The x value of control point 1
    ///   - c1y: The y value of control point 1
    ///   - c2x: The x value of control point 2
    ///   - c2y: The y value of control point 2
    public init(_ c1x: Float, _ c1y: Float, _ c2x: Float, _ c2y: Float) {
        self.timingCurveType = .cubic
        let controlPoint1 = CGPoint(x: CGFloat(c1x), y: CGFloat(c1y))
        let controlPoint2 = CGPoint(x: CGFloat(c2x), y: CGFloat(c2y))
        self.cubicTimingParameters = UICubicTimingParameters(controlPoint1: controlPoint1, controlPoint2: controlPoint2)
    }

    /// Instantiates a cubic bezier curve.
    /// - Parameters:
    ///   - point1: Control point 1
    ///   - point2: Control point 2
    public init(controlPoint1 point1: CGPoint, controlPoint2 point2: CGPoint) {
        self.timingCurveType = .cubic
        self.cubicTimingParameters = UICubicTimingParameters(controlPoint1: point1, controlPoint2: point2)
    }

    /// Instantiates the curve with spring animations parameter.
    /// - Parameter springAnimation: Spring animation parameter. s
    public init(_ springAnimation: UISpringTimingParameters) {
        self.timingCurveType = .spring
        self.springTimingParameters = springAnimation
    }

    /// Instantiates a combined animation curve.
    /// - Parameters:
    ///   - spring: The spring animation params.
    ///   - cubic: The cubic animation params.
    public init(composed spring: UISpringTimingParameters, and cubic: UICubicTimingParameters) {
        self.timingCurveType = .composed
        self.springTimingParameters = spring
        self.cubicTimingParameters = cubic
    }

    private enum Keys: CodingKey {
        case animationCurve
        case timingCurveType
        case cubicTimingParameters
        case springTimingParameters
    }

    /// :nodoc:
    public func encode(with coder: NSCoder) {
        if let curve = animationCurve?.rawValue {
            coder.encode(curve, forKey: Keys.animationCurve.stringValue)
        }
        coder.encode(timingCurveType.rawValue, forKey: Keys.timingCurveType.stringValue)
        coder.encode(cubicTimingParameters, forKey: Keys.cubicTimingParameters.stringValue)
        coder.encode(springTimingParameters, forKey: Keys.springTimingParameters.stringValue)
    }

    /// :nodoc:
    public init?(coder: NSCoder) {
        self.animationCurve = UIView.AnimationCurve(rawValue: coder.decodeInteger(forKey: Keys.animationCurve.stringValue))
        self.timingCurveType = UITimingCurveType(rawValue: coder.decodeInteger(forKey: Keys.timingCurveType.stringValue)) ?? .builtin
        self.cubicTimingParameters = coder.decodeObject(forKey: Keys.cubicTimingParameters.stringValue) as? UICubicTimingParameters
        self.springTimingParameters = coder.decodeObject(forKey: Keys.springTimingParameters.stringValue) as? UISpringTimingParameters
    }

    /// :nodoc:
    public func copy(with zone: NSZone? = nil) -> Any {
        let copy = MotionCurve()
        copy.timingCurveType = self.timingCurveType
        copy.cubicTimingParameters = self.cubicTimingParameters?.copy(with: zone) as? UICubicTimingParameters
        copy.springTimingParameters = self.springTimingParameters?.copy(with: zone) as? UISpringTimingParameters
        return copy
    }
}

extension UIView.AnimationCurve {
    var timingFunction: CAMediaTimingFunction {
        switch self {
        case .linear:
            return CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        case .easeIn:
            return CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn)
        case .easeInOut:
            return CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        case .easeOut:
            return CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        @unknown default:
            return CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        }
    }
}

extension CAMediaTimingFunction {
    var matchingBuiltInAnimationCurve: UIView.AnimationCurve? {
        switch self {
        case CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear):
            return .linear
        case CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn):
            return .easeIn
        case CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut):
            return .easeInOut
        case CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut):
            return .easeOut
        default:
            return nil
        }
    }
}

extension KeyPath where Root: NSObject {
    var stringValue: String {
        return NSExpression(forKeyPath: self).keyPath
    }
}

extension CGFloat {
    var half: CGFloat {
        return self.divided(by: 2.0)
    }

    func rounded(toPrecisionDigits digits: Int, rule: FloatingPointRoundingRule) -> CGFloat {
        let multiplier = pow(10.0, CGFloat(digits))
        return (self * multiplier).rounded(rule).divided(by: multiplier)
    }

    func divided(by value: CGFloat) -> CGFloat {
        if self.isEqual(to: .zero) {
            return .zero
        }

        if value.isEqual(to: .zero) {
            return .zero
        }

        let result = self / value
        return result
    }
}
