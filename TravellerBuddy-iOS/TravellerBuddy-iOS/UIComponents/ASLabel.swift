//
//  ASLabel.swift
//  TravellerBuddy-iOS
//
//  Created by Prabhagaran Ganesan on 06/04/24.
//

import UIKit

public final class TypographyToken: ThemeToken {
  /// Token Name.
  public let name: String
  /// Font Name
  public let fontName: String
  /// Font Size
  public let fontSize: Float
  /// Line Height
  public let lineHeight: Float

  /// Instantiates typography token.
  public init(name: String, fontName: String, fontSize: Float, lineHeight: Float) {
    self.name = name
    self.fontName = fontName
    self.fontSize = fontSize
    self.lineHeight = lineHeight
  }
}

public final class ShadowToken: ThemeToken {

  public let name: String
  public let blur: Float
  public let color: ColorToken
  public let x: Float
  public let y: Float

  public init(name: String, blur: Float, color: ColorToken, x: Float, y: Float) {
    self.name = name
    self.blur = blur
    self.color = color
    self.x = x
    self.y = y
  }
}


public final class ThemeColor: Equatable {
    public let red: CGFloat
    public let green: CGFloat
    public let blue: CGFloat
    public let alpha: CGFloat
    
    enum CodingKeys: String, CodingKey {
        case red = "r"
        case green = "g"
        case blue = "b"
        case alpha = "a"
    }
    
    public init(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat = 1) {
        self.red = red / 255
        self.green = green / 255
        self.blue = blue / 255
        self.alpha = alpha
    }
    
    public convenience init(_ values: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat)) {
        self.init(red: values.red, green: values.green, blue: values.blue, alpha: values.alpha)
    }
    
    public static func == (lhs: ThemeColor, rhs: ThemeColor) -> Bool {
        return (lhs.blue == rhs.blue) && (lhs.red == rhs.red) && (lhs.green == rhs.green)
        && (lhs.alpha == rhs.alpha)
    }
    
}

public protocol ThemeToken {
  var name: String { get }
}

public final class ColorToken: ThemeToken, Equatable {
    
  public let name: String
  public let light: ThemeColor
  public let dark: ThemeColor
  public let lightHC: ThemeColor
  public let darkHC: ThemeColor

  public init(
    name: String,
    light: ThemeColor,
    dark: ThemeColor,
    lightHC: ThemeColor,
    darkHC: ThemeColor
  ) {
    self.name = name
    self.light = light
    self.dark = dark
    self.lightHC = lightHC
    self.darkHC = darkHC
  }

  /// :nodoc:
  public static func == (lhs: ColorToken, rhs: ColorToken) -> Bool {
    return (lhs.dark == rhs.dark) && (lhs.light == rhs.light) && (lhs.lightHC == rhs.lightHC)
      && (lhs.darkHC == rhs.darkHC) && (lhs.name == rhs.name)
  }
}

public protocol CoreViewTheming {
    func didChangeAppearance(to appearance: UIUserInterfaceStyle, previously: UIUserInterfaceStyle)
}

public protocol ViewTheming: AnyObject, CoreViewTheming {
    var backgroundColorToken: ColorToken? { get set }
    var tintColorToken: ColorToken? { get set }
}

public protocol UIViewTheming: ViewTheming where Self: UIView {
    var shadowToken: ShadowToken? { get set }
    var backgroundColorToken: ColorToken? { get set }
    var tintColorToken: ColorToken? { get set }
    var layerBorderColorToken: ColorToken? { get set }
    func applyShadow()
}


public protocol UILabelTheme: UIViewTheming where Self: UILabel {
    var textColorToken: ColorToken? { get set }
    var highlightedTextColorToken: ColorToken? { get set }
    var typographyToken: TypographyToken? { get set }
}

protocol ApperanceSupportedThemeToken: ThemeToken {
    associatedtype Value
    
    func value(for appearance: UIUserInterfaceStyle) -> Value
}

extension ApperanceSupportedThemeToken {
    var light: Value {
        return value(for: .light)
    }
    
    var dark: Value {
        return value(for: .dark)
    }
}

extension UIApplication {
    static var isHighContrastEnabled: Bool {
        return UIAccessibility.isDarkerSystemColorsEnabled
    }
}

extension ColorToken: ApperanceSupportedThemeToken {
    
    func value(for appearance: UIUserInterfaceStyle) -> ThemeColor {
        switch (appearance, UIApplication.isHighContrastEnabled) {
        case (.light, false):
            return self.light
        case (.dark, false):
            return self.dark
        case (.light, true):
            return self.lightHC
        case (.dark, true):
            return self.darkHC
        default:
            return self.light
        }
    }
    
}

public extension ThemeColor {
    var uiColor: UIColor {
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
}

public extension UIView {
    var appearance: UIUserInterfaceStyle {
        return self.traitCollection.userInterfaceStyle
    }
}

class ASLabel: UILabel, UILabelTheme {
    
    var highlightedTextColorToken: ColorToken? {
        didSet {
            self.highlightedTextColor = self.highlightedTextColorToken?.value(for: appearance).uiColor
        }
    }
    
    var shadowToken: ShadowToken? {
        didSet {
            self.shadowColor = self.shadowToken?.color.value(for: appearance).uiColor
        }
    }
    
    var layerBorderColorToken: ColorToken? {
        didSet {
            self.layer.borderColor = self.layerBorderColorToken?.value(for: appearance).uiColor.cgColor
        }
    }
    
    func applyShadow() {
        guard let token = self.shadowToken else { return }
        //TODO: apply shadow to layer
    }
    
    public func didChangeAppearance(to appearance: UIUserInterfaceStyle, previously: UIUserInterfaceStyle) {
        if let tColr = self.textColorToken?.value(for: appearance).uiColor {
            self.textColor = tColr
        }
        if let highColor = self.highlightedTextColorToken?.value(for: appearance).uiColor {
            self.highlightedTextColor = highColor
        }
        self.didChangeAppearanceDefault(to: appearance, previously: previously)
    }
    
    public var backgroundColorToken: ColorToken? {
        didSet {
            self.backgroundColor = backgroundColorToken?.value(for: appearance).uiColor
        }
    }
    
    public var tintColorToken: ColorToken? {
        didSet {
            self.tintColor = self.tintColorToken?.value(for: appearance).uiColor ?? self.tintColor
        }
    }
    
    public var textColorToken: ColorToken? {
        didSet {
            self.shadowColor = self.textColorToken?.value(for: appearance).uiColor
        }
    }
    
    public var typographyToken: TypographyToken? {
        didSet {
            self.font = self.typographyToken?.uifont
        }
    }
}

public protocol ColorTokens {
    var borderGreen: ColorToken { get }
    var fillBackground: ColorToken { get }
    var fillSecondary: ColorToken { get }
}

public protocol ShadowTokens {
    var shadowHigh: ShadowToken { get }
    var shadowLow: ShadowToken { get }
}

public protocol TypographyTokens {
    var bodyModerate: TypographyToken { get }
    var bodySmall: TypographyToken { get }
    var titleBold: TypographyToken { get }
    var titleSemiBold: TypographyToken { get }
}

public protocol Theme: ColorTokens, TypographyTokens, ShadowTokens {
    var name: String { get }
}

public extension Theme {
    var colors: ColorTokens {
        return self
    }
    
    var typography: TypographyTokens {
        return self
    }
}

public final class Themes {
    public static let `default` = Themes()
    public let greenTheme: Theme = GreenTheme()
    public let purpletheme: Theme = GreenTheme() //TODO: create theme for purple
    public var allThemes: [Theme] { return [greenTheme, purpletheme]}
    public internal(set) var current: Theme
    private init() { self.current = greenTheme }
    public class var current: Theme { return Themes.default.current }
}

public final class GreenTheme: Theme {
    public var name: String = "green_theme"
    
    public var borderGreen: ColorToken
    
    public var fillBackground: ColorToken
    
    public var fillSecondary: ColorToken
    
    public var bodyModerate: TypographyToken
    
    public var bodySmall: TypographyToken
    
    public var titleBold: TypographyToken
    
    public var titleSemiBold: TypographyToken
    
    public var shadowHigh: ShadowToken
    
    public var shadowLow: ShadowToken
    
    public init() {
        self.borderGreen = ColorToken(
          name: "border_active",
          light: ThemeColor((0.0, 136.0, 13.0, 1.0)),
          dark: ThemeColor((0.0, 138.0, 14.0, 1.0)),
          lightHC: ThemeColor((0.0, 87.0, 9.0, 1.0)),
          darkHC: ThemeColor((0.0, 219.0, 22.0, 1.0))
        )
        self.fillBackground = ColorToken(
            name: "fill_background_primary",
            light: ThemeColor((255.0, 255.0, 255.0, 1.0)),
            dark: ThemeColor((15.0, 15.0, 15.0, 1.0)),
            lightHC: ThemeColor((255.0, 255.0, 255.0, 1.0)),
            darkHC: ThemeColor((0.0, 0.0, 0.0, 1.0))
          )
        self.fillSecondary = ColorToken(
          name: "border_brand_green",
          light: ThemeColor((0.0, 136.0, 13.0, 1.0)),
          dark: ThemeColor((0.0, 138.0, 14.0, 1.0)),
          lightHC: ThemeColor((0.0, 136.0, 13.0, 1.0)),
          darkHC: ThemeColor((0.0, 138.0, 14.0, 1.0))
        )
        self.bodyModerate =  TypographyToken(
            name: "body_moderate",
            fontName: "Poppins-Regular",
            fontSize: 16,
            lineHeight: 20
          )
        
        self.bodySmall = TypographyToken(
            name: "body_small",
            fontName: "Poppins-Regular",
            fontSize: 14,
            lineHeight: 20
          )
        
        self.titleBold = TypographyToken(
            name: "title_moderate_bold",
            fontName: "Poppins-Bold",
            fontSize: 18,
            lineHeight: 24
          )
        self.titleSemiBold = TypographyToken(
            name: "title_moderate_demi",
            fontName: "Poppins-SemiBold",
            fontSize: 18,
            lineHeight: 24
          )
        
        let shadowHighColor = ColorToken(
          name: "shadow_high_color",
          light: ThemeColor((0.0, 0.0, 0.0, 0.149)),
          dark: ThemeColor((0.0, 0.0, 0.0, 0.149)),
          lightHC: ThemeColor((0.0, 0.0, 0.0, 0.149)),
          darkHC: ThemeColor((0.0, 0.0, 0.0, 0.149))
        )
        self.shadowHigh = ShadowToken(name: "shadow_high", blur: 4, color: shadowHighColor, x: 0, y: 0)
        let shadowLowColor = ColorToken(
          name: "shadow_low_color",
          light: ThemeColor((0.0, 0.0, 0.0, 0.149)),
          dark: ThemeColor((0.0, 0.0, 0.0, 0.149)),
          lightHC: ThemeColor((0.0, 0.0, 0.0, 0.149)),
          darkHC: ThemeColor((0.0, 0.0, 0.0, 0.149))
        )
        self.shadowLow = ShadowToken(name: "shadow_low", blur: 4, color: shadowLowColor, x: 0, y: 0)
    }
}


class ASWindow: UIWindow {
    
    private(set) var overridenAppearance: UIUserInterfaceStyle?

    public var currentTheme: Theme {
        get {
            Themes.default.current
        }
        set {
            guard newValue.name != Themes.default.current.name else { return }
            Themes.default.current = newValue
            store?.saveGlobalCurrentTheme(name: newValue.name)
        }
    }
    
    override var rootViewController: UIViewController? {
        didSet {
            propagateThemeChange()
        }
    }
    
    private(set) var overrideAppearance: UIUserInterfaceStyle?
    
    override var overrideUserInterfaceStyle: UIUserInterfaceStyle {
        didSet {
            overrideAppearance = overrideUserInterfaceStyle
        }
    }
    
    private let store: ThemePreferenceStoring?
    
    public required init(frame: CGRect, current: Theme? = nil, store: ThemePreferenceStoring?, overrideAppearance: UIUserInterfaceStyle? = nil) {
        self.store = store
        let theme = store?.preferredGlobalCurrentTheme(in: Themes.default.allThemes) ?? current ?? Themes.current
        super.init(frame: frame)
        self.currentTheme = theme
        if let appearance = overrideAppearance {
            self.overrideUserInterfaceStyle = appearance
        }
        propagateThemeChange()
        NotificationCenter.default.addObserver(self, selector: #selector(didChangeDarkerSystemColors), name: UIAccessibility.darkerSystemColorsStatusDidChangeNotification, object: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func didChangeDarkerSystemColors() {
        traitCollectionDidChange(self.traitCollection)
        if let rootVC = self.rootViewController as? UIViewControllerTheming {
            rootVC.propagateAppearanceChangeToViews()
        }
        propagateThemeChange()
    }
    
    func propagateThemeChange() {
        if let rootVC = self.rootViewController as? UIViewControllerTheming {
            rootVC.theme = currentTheme
        }
    }
}

public final class ASFrameWork {
    
    public static let shared = ASFrameWork()
    public private(set) var preferredApperanceProvider: (() -> UIUserInterfaceStyle)?
    
    public private(set) var overriddenIsHighContrastEnabled: Bool?
    
    public private(set) var ignoreSystemFontScaling = true
    public private(set) var preferredAppearanceProvider: (() -> UIUserInterfaceStyle)?
    
    private init() {}
    
    public static func initialize(appearance: (() -> UIUserInterfaceStyle)?) {
        self.shared.preferredApperanceProvider = appearance
    }
    
    func overrideAppearance(to appearance: UIUserInterfaceStyle, on window: UIWindow? = nil) {
        guard let currentActiveWindow = window else { return }
        UIView.transition(with: currentActiveWindow, duration: 0.3, options: .transitionCrossDissolve, animations: {
            currentActiveWindow.overrideUserInterfaceStyle = appearance
            
            if appearance == .unspecified {
                currentActiveWindow.overrideUserInterfaceStyle = UIScreen.main.traitCollection.userInterfaceStyle
                currentActiveWindow.overrideUserInterfaceStyle = .unspecified
            }
        })
    }
    
    static func overrideContrast(to contrast: UIAccessibilityContrast, on window: UIWindow? = nil) {
        guard let currentActiveWindow = window else { return }
        UIView.transition(with: currentActiveWindow, duration: 0.3, options: .transitionCrossDissolve, animations: {
            if contrast == .unspecified {
                shared.overriddenIsHighContrastEnabled  = nil
            } else {
                shared.overriddenIsHighContrastEnabled = (contrast == .high)
            }
            
            (currentActiveWindow as? ASWindow)?.didChangeDarkerSystemColors()
        })
    }
    public static func shouldIgnoreOSFontScaling(ignore: Bool) {
        shared.ignoreSystemFontScaling = ignore
    }
}

public protocol UIViewControllerTheming where Self: UIViewController {
    var viewBackgroundColortoken: ColorToken? { get set }
    var theme: Theme { get set }
    var overrideTheme: Theme? { get }
    func themeDidChange()
}
public protocol ThemePreferenceStoring {
    func saveGlobalCurrentTheme(name: String)
    func preferredGlobalCurrentTheme() -> String?
}

extension ThemePreferenceStoring {
    func preferredGlobalCurrentTheme(in themes: [Theme]) -> Theme? {
        guard let name = self.preferredGlobalCurrentTheme() else { return nil }
        return themes.named(name)
    }
}

public extension Sequence where Self.Element == Theme {
    func named(_ name: String) -> Theme? {
        return self.first { $0.name == name }
    }
}


extension UIViewControllerTheming {
    func propagateAppearanceChange() {
        guard isViewLoaded else { return }
        self.children.forEach {
            ($0 as UITraitEnvironment).traitCollectionDidChange(self.traitCollection)
            ($0 as? UIViewControllerTheming)?.propagateAppearanceChange()
        }
        propagateAppearanceChangeToViews()
    }
    
    func propagateAppearanceChangeToViews() {
        guard isViewLoaded else { return }
        var stack = [UIView]()
        stack.append(contentsOf: self.view?.subviews ?? [])
        while stack.isEmpty == false {
            let aView = stack.removeLast()
            aView.traitCollectionDidChange(self.traitCollection)
        }
        let subviews = self.view.getAtomicSubviews()
        subviews.forEach { $0.traitCollectionDidChange(self.traitCollection) }
    }
}

extension UIView {
    func getAtomicSubviews() -> [UIView] {
        var atomicSubviews = [UIView]()
        for subview in self.subviews {
            atomicSubviews += subview.getAtomicSubviews()
            if subview.subviews.isEmpty && !subview.conforms(to: UILayoutSupport.self) {
                atomicSubviews.append(subview)
            }
        }
        return atomicSubviews
    }
}

extension TypographyToken {
    public var uifont: UIFont {
        return ASFrameWork.shared.ignoreSystemFontScaling ? nonScaledUIFont : scaledUIfont
    }
    
    var style: UIFont.TextStyle {
        switch self.name {
        case TypographyTokenNames.titleBold.rawValue:
            return .largeTitle
        case TypographyTokenNames.titleSemiBold.rawValue:
            return .title1
        case TypographyTokenNames.bodySmall.rawValue:
            return .footnote
        case TypographyTokenNames.bodyModerate.rawValue:
            return .body
        default:
            return .body
        }
    }
    
    public var scaledUIfont: UIFont {
        let metrics = UIFontMetrics(forTextStyle: style)
        return metrics.scaledFont(for: self.nonScaledUIFont)
    }
    
    public var nonScaledUIFont: UIFont {
        guard let font = UIFont(name: self.fontName, size: CGFloat(self.fontSize)) else {
            if let fontURL = Bundle.assetsBundle.url(forResource: self.fontName, withExtension: "ttf", subdirectory: "Fonts") {
                CTFontManagerRegisterFontsForURL(fontURL as CFURL, .process, nil)
            }
            return UIFont(name: self.fontName, size: CGFloat(self.fontSize)) ?? UIFont.systemFont(ofSize: CGFloat(self.fontSize))
        }
        return font
    }
}

public enum TypographyTokenNames: String, CaseIterable {
    case body_moderate, bodyModerate
    case body_small, bodySmall
    case title_bold, titleBold
    case title_semi_bold, titleSemiBold
}

public extension UIViewTheming {
    func didChangeAppearanceDefault(to appearance: UIUserInterfaceStyle, previously: UIUserInterfaceStyle) {
        if let background = self.backgroundColorToken?.value(for: appearance).uiColor {
            self.backgroundColor = background
        }
        
        if let tintColor = self.tintColorToken?.value(for: appearance).uiColor {
            self.tintColor = tintColor
        }
        if let borderColor = self.layerBorderColorToken?.value(for: appearance).uiColor.cgColor {
            self.layer.borderColor = borderColor
        }
        
        if self.shadowToken != nil {
            self.applyShadow()
        }
    }
}

extension Bundle {
    private class BundleIdentifierDetection {}

    /// A reference to the current bundle.
    class var this: Bundle {
        #if SWIFT_PACKAGE
        return Bundle.module
        #else
        return Bundle(for: BundleIdentifierDetection.self)
        #endif
    }

    /// Reference to the bundle containing all the assets
    public class var assetsBundle: Bundle {
        return Bundle.this
    }
}
