import Foundation
#if os(macOS)
import AppKit
#else
import UIKit
#endif

public typealias AttrStr = AttributedString

public protocol AnyString {
    func onUpdate(_ handler: @escaping (NSAttributedString) -> Void)
    var attributedString: NSAttributedString { get }
    
    static func make(_ v: NSAttributedString) -> Self
}

extension Optional: AnyString where Wrapped == AnyString {
    public func onUpdate(_ handler: @escaping (NSAttributedString) -> Void) {
        switch self {
        case .none: break
        case .some(let str): str.onUpdate(handler)
        }
    }
    
    public var attributedString: NSAttributedString {
        switch self {
        case .none: return .init()
        case .some(let str): return str.attributedString
        }
    }
    
    public static func make(_ v: NSAttributedString) -> Self {
        .init(v)
    }
}

extension NSAttributedString: AnyString {
    public func onUpdate(_ handler: @escaping (NSAttributedString) -> Void) {}
    
    public var attributedString: NSAttributedString { self }
    
    public static func make(_ v: NSAttributedString) -> Self {
        .init(attributedString: v)
    }
}

extension String: AnyString, BodyBuilderItemable {
    public var bodyBuilderItem: BodyBuilderItem { .single(UText(self)) }
    
    public func onUpdate(_ handler: @escaping (NSAttributedString) -> Void) {}
    
    public var attributedString: NSAttributedString {
        .init(string: self)
    }
    
    public static func make(_ v: NSAttributedString) -> Self {
        v.string
    }
}

@MainActor
open class AttributedString: AnyString, BodyBuilderItemable {
    private let _stateBindingHolder = TempStatesHolder()

    var stateBindingHolder: TempStatesHolder {
        _stateBindingHolder
    }

    public var bodyBuilderItem: BodyBuilderItem { .single(UText(self)) }
    
    public func onUpdate(_ handler: @escaping (NSAttributedString) -> Void) {
        _updateHandler = handler
    }
    
    public var attributedString: NSAttributedString { _attributedString }
    
    var _attributedString: NSMutableAttributedString
    
    var _updateHandler: ((NSAttributedString) -> Void)?
    
    private lazy var _paragraphStyle = ParagraphStyle(self)
    
    public static func make(_ v: NSAttributedString) -> Self {
        .init(v)
    }
    
    public required init (_ attrString: NSAttributedString) {
        _attributedString = .init(attributedString: attrString)
    }
    
    public init (_ string: String) {
        _attributedString = .init(string: string)
    }
    
    public init (_ localized: LocalizedString...) {
        _attributedString = .init(string: String(localized))
    }
    
    public init (_ localized: [LocalizedString]) {
        _attributedString = .init(string: String(localized))
    }
    
    convenience init (anyStrings: [AnyString]) {
        self.init()
        anyStrings.onUpdate { [weak self] in
            self?._attributedString = .init(attributedString: $0)
            self?._updateHandler?($0)
        }
    }
    
    @discardableResult
    func addAttribute(_ attr: NSAttributedString.Key, _ value: Any, at range: ClosedRange<Int>? = nil) -> AttributedString {
        // TODO: check range
        let range = range ?? 0..._attributedString.length
        _attributedString.addAttribute(attr, value: value, range: range.nsRange)
        _updateHandler?(_attributedString)
        return self
    }
    
    @discardableResult
    func removeAttribute(_ attr: NSAttributedString.Key, at range: ClosedRange<Int>? = nil) -> AttributedString {
        // TODO: check range
        let range = range ?? 0..._attributedString.length
        _attributedString.removeAttribute(attr, range: range.nsRange)
        _updateHandler?(_attributedString)
        return self
    }
    
    /// UColor, default nil: no background
    @discardableResult
    public func background(_ state: State<UColor>, at range: ClosedRange<Int>? = nil) -> Self {
        background(state.wrappedValue, at: range)
        state.listen { [weak self] new in
            self?.background(new, at: range)
        }
        .hold(in: stateBindingHolder)
        return self
    }
    
    /// UColor, default nil: no background
    @discardableResult
    public func background(_ value: UColor, at range: ClosedRange<Int>? = nil) -> AttributedString {
        addAttribute(.backgroundColor, value.current, at: range)
    }
    
    /// Hex color, default nil: no background
    @discardableResult
    public func background(_ value: Int, at range: ClosedRange<Int>? = nil) -> AttributedString {
        addAttribute(.backgroundColor, value.color.current, at: range)
    }
    
    /// UColor, default blackColor
    @discardableResult
    public func foreground(_ state: State<UColor>, at range: ClosedRange<Int>? = nil) -> Self {
        foreground(state.wrappedValue, at: range)
        state.listen { [weak self] new in
            self?.foreground(new, at: range)
        }
        .hold(in: stateBindingHolder)
        return self
    }
    
    /// UColor, default blackColor
    @discardableResult
    public func foreground(_ value: UColor, at range: ClosedRange<Int>? = nil) -> AttributedString {
        #if os(macOS)
        value.onChange { [weak self] new in
            self?.addAttribute(.foregroundColor, new, at: range)
        }
        #endif
        return addAttribute(.foregroundColor, value.current, at: range)
    }
    
    /// Hex color, default blackColor
    @discardableResult
    public func foreground(_ value: Int, at range: ClosedRange<Int>? = nil) -> AttributedString {
        foreground(value.color, at: range)
    }
    
    /// NSParagraphStyle, default defaultParagraphStyle
    @discardableResult
    public func paragraphStyle(_ value: NSParagraphStyle, at range: ClosedRange<Int>? = nil) -> AttributedString {
        addAttribute(.paragraphStyle, value, at: range)
    }
    
    /// NSNumber containing integer, default 1: default ligatures, 0: no ligatures
    @discardableResult
    public func ligature(_ value: Float, at range: ClosedRange<Int>? = nil) -> AttributedString {
        addAttribute(.ligature, value, at: range)
    }
    
    /// NSNumber containing floating point value, in points; amount to modify default kerning. 0 means kerning is disabled.
    @discardableResult
    public func kern(_ value: Float, at range: ClosedRange<Int>? = nil) -> AttributedString {
        addAttribute(.kern, value, at: range)
    }
    
    /// NSNumber containing integer, default 0: no strikethrough
    @discardableResult
    public func strikethroughStyle(_ value: Float, at range: ClosedRange<Int>? = nil) -> AttributedString {
        addAttribute(.strikethroughStyle, value, at: range)
    }
    
    /// NSNumber containing integer, default 0: no underline
    @discardableResult
    public func underlineStyle(_ value: NSUnderlineStyle, at range: ClosedRange<Int>? = nil) -> AttributedString {
        addAttribute(.underlineStyle, value.rawValue, at: range)
    }
    
    /// UColor, default nil: same as foreground color
    @discardableResult
    public func strokeColor(_ value: UColor, at range: ClosedRange<Int>? = nil) -> AttributedString {
        addAttribute(.strokeColor, value.current, at: range)
    }
    
    /// Hex color, default nil: same as foreground color
    @discardableResult
    public func strokeColor(_ value: Int, at range: ClosedRange<Int>? = nil) -> AttributedString {
        addAttribute(.strokeColor, value.color.current, at: range)
    }
    
    /// NSNumber containing floating point value, in percent of font point size, default 0: no stroke; positive for stroke alone, negative for stroke and fill (a typical value for outlined text would be 3.0)
    @discardableResult
    public func strokeWidth(_ value: Float, at range: ClosedRange<Int>? = nil) -> AttributedString {
        addAttribute(.strokeWidth, value, at: range)
    }
    
    /// Shadow, default nil: no shadow
    @discardableResult
    public func shadow(offset: CGSize = .zero, blur: CGFloat = 0, color: UColor = .clear, at range: ClosedRange<Int>? = nil) -> AttributedString {
        let shadow = NSShadow()
        shadow.shadowOffset = offset
        shadow.shadowBlurRadius = blur
        #if os(macOS)
        shadow.shadowColor = color.current
        color.onChange { new in
            shadow.shadowColor = new
        }
        #else
        shadow.shadowColor = color
        #endif
        return addAttribute(.shadow, shadow, at: range)
    }
    
    /// NSString, default nil: no text effect
    @discardableResult
    public func textEffect(_ value: String, at range: ClosedRange<Int>? = nil) -> AttributedString {
        addAttribute(.textEffect, value, at: range)
    }
    
    /// NSTextAttachment, default nil
    @discardableResult
    public func attachment(_ value: NSTextAttachment, at range: ClosedRange<Int>? = nil) -> AttributedString {
        addAttribute(.attachment, value, at: range)
    }
    
    /// NSTextAttachment(data: Data, ofType: String), default nil
    @discardableResult
    public func attachment(_ data: Data?, type: String, at range: ClosedRange<Int>? = nil) -> AttributedString {
        addAttribute(.attachment, NSTextAttachment(data: data, ofType: type), at: range)
    }
    
    @discardableResult
    public func link(_ value: URL, at range: ClosedRange<Int>? = nil) -> AttributedString {
        addAttribute(.link, value, at: range)
    }
    
    @discardableResult
    public func link(_ value: String, at range: ClosedRange<Int>? = nil) -> AttributedString {
        addAttribute(.link, value, at: range)
    }
    
    /// NSNumber containing floating point value, in points; offset from baseline, default 0
    @discardableResult
    public func baselineOffset(_ value: Float, at range: ClosedRange<Int>? = nil) -> AttributedString {
        addAttribute(.baselineOffset, value, at: range)
    }
    
    /// UColor, default nil: same as foreground color
    @discardableResult
    public func underlineColor(_ value: UColor, at range: ClosedRange<Int>? = nil) -> AttributedString {
        addAttribute(.underlineColor, value.current, at: range)
    }
    
    /// Hex color, default nil: same as foreground color
    @discardableResult
    public func underlineColor(_ value: Int, at range: ClosedRange<Int>? = nil) -> AttributedString {
        addAttribute(.underlineColor, value.color.current, at: range)
    }
    
    /// UColor, default nil: same as foreground color
    @discardableResult
    public func strikethroughColor(_ value: UColor, at range: ClosedRange<Int>? = nil) -> AttributedString {
        addAttribute(.strikethroughColor, value.current, at: range)
    }
    
    /// Hex color, default nil: same as foreground color
    @discardableResult
    public func strikethroughColor(_ value: Int, at range: ClosedRange<Int>? = nil) -> AttributedString {
        addAttribute(.strikethroughColor, value.color.current, at: range)
    }
    
    /// NSNumber containing floating point value; skew to be applied to glyphs, default 0: no skew
    @discardableResult
    public func obliqueness(_ value: Float, at range: ClosedRange<Int>? = nil) -> AttributedString {
        addAttribute(.obliqueness, value, at: range)
    }
    
    /// NSNumber containing floating point value; log of expansion factor to be applied to glyphs, default 0: no expansion
    @discardableResult
    public func expansion(_ value: Float, at range: ClosedRange<Int>? = nil) -> AttributedString {
        addAttribute(.expansion, value, at: range)
    }
    
    public enum GlyphForm: Int {
        case horizontal, vertical
    }
    
    @discardableResult
    public func glyphForm(_ form: GlyphForm, at range: ClosedRange<Int>? = nil) -> AttributedString {
        addAttribute(.verticalGlyphForm, form.rawValue, at: range)
    }
    
    @discardableResult
    public func writingDirection(_ direction: NSWritingDirection, at range: ClosedRange<Int>? = nil) -> AttributedString {
        addAttribute(.writingDirection, direction, at: range)
    }
}

extension AttributedString: _StateBindingOwner {}

// MARK: ParagraphStyleDelegate

extension AttributedString: ParagraphStyleDelegate {
    func onParagraphUpdate(_ p: ParagraphStyle) {
        paragraphStyle(p)
    }
}

extension AttrStr: _FontableAtRange {
    func _setFont(_ v: UFont?) {
        guard let v = v else {
            removeAttribute(.font)
            return
        }
        addAttribute(.font, v)
    }
    
    public func font(v: UFont?, at range: ClosedRange<Int>) -> Self {
        guard let v = v else {
            removeAttribute(.font, at: range)
            return self
        }
        addAttribute(.font, v, at: range)
        return self
    }
    
    // MARK: - Paragraph Style proxy
    
    // MARK: Line Spacing
    
    @discardableResult
    public func lineSpacing(_ v: CGFloat) -> Self {
        _paragraphStyle.lineSpacing(v)
        return self
    }
    
    @discardableResult
    public func lineSpacing(_ state: State<CGFloat>) -> Self {
        _paragraphStyle.lineSpacing(state)
        return lineSpacing(state.wrappedValue)
    }
    
    // MARK: Paragraph Spacing
    
    @discardableResult
    public func paragraphSpacing(_ v: CGFloat) -> Self {
        _paragraphStyle.paragraphSpacing(v)
        return self
    }
    
    @discardableResult
    public func paragraphSpacing(_ state: State<CGFloat>) -> Self {
        _paragraphStyle.paragraphSpacing(state)
        return paragraphSpacing(state.wrappedValue)
    }
    
    // MARK: First Line Head Indent
    
    @discardableResult
    public func firstLineHeadIndent(_ v: CGFloat) -> Self {
        _paragraphStyle.firstLineHeadIndent(v)
        return self
    }
    
    @discardableResult
    public func firstLineHeadIndent(_ state: State<CGFloat>) -> Self {
        _paragraphStyle.firstLineHeadIndent(state)
        return firstLineHeadIndent(state.wrappedValue)
    }
    
    // MARK: Head Indent
    
    @discardableResult
    public func headIndent(_ v: CGFloat) -> Self {
        _paragraphStyle.headIndent(v)
        return self
    }
    
    @discardableResult
    public func headIndent(_ state: State<CGFloat>) -> Self {
        _paragraphStyle.headIndent(state)
        return headIndent(state.wrappedValue)
    }
    
    // MARK: Tail Indent
    
    @discardableResult
    public func tailIndent(_ v: CGFloat) -> Self {
        _paragraphStyle.tailIndent(v)
        return self
    }
    
    @discardableResult
    public func tailIndent(_ state: State<CGFloat>) -> Self {
        _paragraphStyle.tailIndent(state)
        return tailIndent(state.wrappedValue)
    }
    
    // MARK: Minimum Line Height
    
    @discardableResult
    public func minimumLineHeight(_ v: CGFloat) -> Self {
        _paragraphStyle.minimumLineHeight(v)
        return self
    }
    
    @discardableResult
    public func minimumLineHeight(_ state: State<CGFloat>) -> Self {
        _paragraphStyle.minimumLineHeight(state)
        return minimumLineHeight(state.wrappedValue)
    }
    
    // MARK: Maximum Line Height
    
    @discardableResult
    public func maximumLineHeight(_ v: CGFloat) -> Self {
        _paragraphStyle.maximumLineHeight(v)
        return self
    }
    
    @discardableResult
    public func maximumLineHeight(_ state: State<CGFloat>) -> Self {
        _paragraphStyle.maximumLineHeight(state)
        return maximumLineHeight(state.wrappedValue)
    }
    
    // MARK: Line Height Multiple
    
    @discardableResult
    public func lineHeightMultiple(_ v: CGFloat) -> Self {
        _paragraphStyle.lineHeightMultiple(v)
        return self
    }
    
    @discardableResult
    public func lineHeightMultiple(_ state: State<CGFloat>) -> Self {
        _paragraphStyle.lineHeightMultiple(state)
        return self
    }
    
    // MARK: Default Tab Interval
    
    @discardableResult
    public func defaultTabInterval(_ v: CGFloat) -> Self {
        _paragraphStyle.defaultTabInterval(v)
        return self
    }
    
    @discardableResult
    public func defaultTabInterval(_ state: State<CGFloat>) -> Self {
        _paragraphStyle.defaultTabInterval(state)
        return defaultTabInterval(state.wrappedValue)
    }
    
    // MARK: Paragraph Spacing Before
    
    @discardableResult
    public func paragraphSpacingBefore(_ v: CGFloat) -> Self {
        _paragraphStyle.paragraphSpacingBefore(v)
        return self
    }
    
    @discardableResult
    public func paragraphSpacingBefore(_ state: State<CGFloat>) -> Self {
        _paragraphStyle.paragraphSpacingBefore(state)
        return paragraphSpacingBefore(state.wrappedValue)
    }
    
    // MARK: Hyphenation Factor
    
    @discardableResult
    public func hyphenationFactor(_ v: Float) -> Self {
        _paragraphStyle.hyphenationFactor(v)
        return self
    }
    
    @discardableResult
    public func hyphenationFactor(_ state: State<Float>) -> Self {
        _paragraphStyle.hyphenationFactor(state)
        return hyphenationFactor(state.wrappedValue)
    }
    
    #if os(macOS)
    // MARK: Tightening Factor For Truncation
    
    @discardableResult
    public func tighteningFactorForTruncation(_ v: Float) -> Self {
        _paragraphStyle.tighteningFactorForTruncation(v)
        return self
    }
    
    @discardableResult
    public func tighteningFactorForTruncation(_ state: State<Float>) -> Self {
        _paragraphStyle.tighteningFactorForTruncation(state)
        return tighteningFactorForTruncation(state.wrappedValue)
    }
    
    // MARK: Header Level
    
    @discardableResult
    public func headerLevel(_ v: Int) -> Self {
        _paragraphStyle.headerLevel(v)
        return self
    }
    
    @discardableResult
    public func headerLevel(_ state: State<Int>) -> Self {
        _paragraphStyle.headerLevel(state)
        return headerLevel(state.wrappedValue)
    }
    
    // MARK: Allows Default Tightening For Truncation
    
    @discardableResult
    public func allowsDefaultTighteningForTruncation(_ v: Bool) -> Self {
        _paragraphStyle.allowsDefaultTighteningForTruncation(v)
        return self
    }
    
    @discardableResult
    public func allowsDefaultTighteningForTruncation(_ state: State<Bool>) -> Self {
        _paragraphStyle.allowsDefaultTighteningForTruncation(state)
        return allowsDefaultTighteningForTruncation(state.wrappedValue)
    }
    #endif
    
    // MARK: Alignment
    
    @discardableResult
    public func alignment(_ v: NSTextAlignment) -> Self {
        _paragraphStyle.alignment(v)
        return self
    }
    
    @discardableResult
    public func alignment(_ state: State<NSTextAlignment>) -> Self {
        _paragraphStyle.alignment(state)
        return alignment(state.wrappedValue)
    }
    
    // MARK: Line Break Mode
    
    @discardableResult
    public func lineBreakMode(_ v: NSLineBreakMode) -> Self {
        _paragraphStyle.lineBreakMode(v)
        return self
    }
    
    @discardableResult
    public func lineBreakMode(_ state: State<NSLineBreakMode>) -> Self {
        _paragraphStyle.lineBreakMode(state)
        return lineBreakMode(state.wrappedValue)
    }
    
    // MARK: Base Writing Direction
    
    @discardableResult
    public func baseWritingDirection(_ v: NSWritingDirection) -> Self {
        _paragraphStyle.baseWritingDirection(v)
        return self
    }
    
    @discardableResult
    public func baseWritingDirection(_ state: State<NSWritingDirection>) -> Self {
        _paragraphStyle.baseWritingDirection(state)
        return baseWritingDirection(state.wrappedValue)
    }
    
    // MARK: Tab Stops
    
    @discardableResult
    public func tabStops(_ v: [NSTextTab]) -> Self {
        _paragraphStyle.tabStops(v)
        return self
    }
    
    @discardableResult
    public func tabStops(_ state: State<[NSTextTab]>) -> Self {
        _paragraphStyle.tabStops(state)
        return tabStops(state.wrappedValue)
    }
    
    #if os(macOS)
    // MARK: Text Blocks
    
    @discardableResult
    public func textBlocks(_ v: [NSTextBlock]) -> Self {
        _paragraphStyle.textBlocks(v)
        return self
    }
    
    @discardableResult
    public func textBlocks(_ state: State<[NSTextBlock]>) -> Self {
        _paragraphStyle.textBlocks(state)
        return textBlocks(state.wrappedValue)
    }
    
    // MARK: Text Lists
    
    @discardableResult
    public func textLists(_ v: [NSTextList]) -> Self {
        _paragraphStyle.textLists(v)
        return self
    }
    
    @discardableResult
    public func textLists(_ state: State<[NSTextList]>) -> Self {
        _paragraphStyle.textLists(state)
        return textLists(state.wrappedValue)
    }
    #endif
}
