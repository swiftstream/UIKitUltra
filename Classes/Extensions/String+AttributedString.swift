import Foundation
#if os(macOS)
import AppKit
#else
import UIKit
#endif

@MainActor
extension String {
    /// UColor, default nil: no background
    @discardableResult
    public func background(_ state: State<UColor>, at range: ClosedRange<Int>? = nil) -> AttributedString {
        AttrStr(self).background(state, at: range)
    }
    
    /// UColor, default nil: no background
    @discardableResult
    public func background(_ value: UColor, at range: ClosedRange<Int>? = nil) -> AttributedString {
        AttrStr(self).background(value, at: range)
    }
    
    /// Hex color, default nil: no background
    @discardableResult
    public func background(_ value: Int, at range: ClosedRange<Int>? = nil) -> AttributedString {
        AttrStr(self).background(value, at: range)
    }
    
    /// UColor, default blackColor
    @discardableResult
    public func foreground(_ state: State<UColor>, at range: ClosedRange<Int>? = nil) -> AttributedString {
        AttrStr(self).foreground(state, at: range)
    }
    
    /// UColor, default blackColor
    @discardableResult
    public func foreground(_ value: UColor, at range: ClosedRange<Int>? = nil) -> AttributedString {
        AttrStr(self).foreground(value, at: range)
    }
    
    /// Hex color, default blackColor
    @discardableResult
    public func foreground(_ value: Int, at range: ClosedRange<Int>? = nil) -> AttributedString {
        AttrStr(self).foreground(value, at: range)
    }
    
    /// UColor, default blackColor
    @available(*, deprecated, renamed: "foreground")
    @discardableResult
    public func color(_ value: UColor, at range: ClosedRange<Int>? = nil) -> AttributedString {
        AttrStr(self).foreground(value, at: range)
    }
    
    /// Hex color, default blackColor
    @available(*, deprecated, renamed: "foreground")
    @discardableResult
    public func color(_ value: Int, at range: ClosedRange<Int>? = nil) -> AttributedString {
        AttrStr(self).foreground(value, at: range)
    }
    
    @discardableResult
    @MainActor
    public func font(v: UFont, at range: ClosedRange<Int>? = nil) -> AttributedString {
        guard let range = range else {
            return AttrStr(self).font(v: v)
        }
        return AttrStr(self).font(v: v, at: range)
    }
    
    @discardableResult
    public func font(_ identifier: FontIdentifier, _ size: CGFloat, at range: ClosedRange<Int>? = nil) -> AttributedString {
        guard let range = range else {
            return AttrStr(self).font(identifier, size)
        }
        return AttrStr(self).font(identifier, size, at: range)
    }
    
    /// NSParagraphStyle, default defaultParagraphStyle
    @discardableResult
    public func paragraphStyle(_ value: NSParagraphStyle, at range: ClosedRange<Int>? = nil) -> AttributedString {
        AttrStr(self).paragraphStyle(value, at: range)
    }
    
    /// NSNumber containing integer, default 1: default ligatures, 0: no ligatures
    @discardableResult
    public func ligature(_ value: Float, at range: ClosedRange<Int>? = nil) -> AttributedString {
        AttrStr(self).ligature(value, at: range)
    }
    
    /// NSNumber containing floating point value, in points; amount to modify default kerning. 0 means kerning is disabled.
    @discardableResult
    public func kern(_ value: Float, at range: ClosedRange<Int>? = nil) -> AttributedString {
        AttrStr(self).kern(value, at: range)
    }
    
    /// NSNumber containing integer, default 0: no strikethrough
    @discardableResult
    public func strikethroughStyle(_ value: Float, at range: ClosedRange<Int>? = nil) -> AttributedString {
        AttrStr(self).strikethroughStyle(value, at: range)
    }
    
    /// NSNumber containing integer, default 0: no underline
    @discardableResult
    public func underlineStyle(_ value: NSUnderlineStyle, at range: ClosedRange<Int>? = nil) -> AttributedString {
        AttrStr(self).underlineStyle(value, at: range)
    }
    
    /// UColor, default nil: same as foreground color
    @discardableResult
    public func strokeColor(_ value: UColor, at range: ClosedRange<Int>? = nil) -> AttributedString {
        AttrStr(self).strokeColor(value, at: range)
    }
    
    /// Hex color, default nil: same as foreground color
    @discardableResult
    public func strokeColor(_ value: Int, at range: ClosedRange<Int>? = nil) -> AttributedString {
        AttrStr(self).strokeColor(value, at: range)
    }
    
    /// NSNumber containing floating point value, in percent of font point size, default 0: no stroke; positive for stroke alone, negative for stroke and fill (a typical value for outlined text would be 3.0)
    @discardableResult
    public func strokeWidth(_ value: Float, at range: ClosedRange<Int>? = nil) -> AttributedString {
        AttrStr(self).strokeWidth(value, at: range)
    }
    
    /// Shadow, default nil: no shadow
    @discardableResult
    public func shadow(offset: CGSize = .zero, blur: CGFloat = 0, color: UColor = .clear, at range: ClosedRange<Int>? = nil) -> AttributedString {
        AttrStr(self).shadow(offset: offset, blur: blur, color: color, at: range)
    }
    
    /// NSString, default nil: no text effect
    @discardableResult
    public func textEffect(_ value: String, at range: ClosedRange<Int>? = nil) -> AttributedString {
        AttrStr(self).textEffect(value, at: range)
    }
    
    /// NSTextAttachment, default nil
    @discardableResult
    public func attachment(_ value: NSTextAttachment, at range: ClosedRange<Int>? = nil) -> AttributedString {
        AttrStr(self).attachment(value, at: range)
    }
    
    /// NSTextAttachment(data: Data, ofType: String), default nil
    @discardableResult
    public func attachment(_ data: Data?, type: String, at range: ClosedRange<Int>? = nil) -> AttributedString {
        AttrStr(self).attachment(data, type: type, at: range)
    }
    
    @discardableResult
    public func link(_ value: URL, at range: ClosedRange<Int>? = nil) -> AttributedString {
        AttrStr(self).link(value, at: range)
    }
    
    @discardableResult
    public func link(_ value: String, at range: ClosedRange<Int>? = nil) -> AttributedString {
        AttrStr(self).link(value, at: range)
    }
    
    /// NSNumber containing floating point value, in points; offset from baseline, default 0
    @discardableResult
    public func baselineOffset(_ value: Float, at range: ClosedRange<Int>? = nil) -> AttributedString {
        AttrStr(self).baselineOffset(value, at: range)
    }
    
    /// UIColor, default nil: same as foreground color
    @discardableResult
    public func underlineColor(_ value: UColor, at range: ClosedRange<Int>? = nil) -> AttributedString {
        AttrStr(self).underlineColor(value, at: range)
    }
    
    /// Hex color, default nil: same as foreground color
    @discardableResult
    public func underlineColor(_ value: Int, at range: ClosedRange<Int>? = nil) -> AttributedString {
        AttrStr(self).underlineColor(value, at: range)
    }
    
    /// UIColor, default nil: same as foreground color
    @discardableResult
    public func strikethroughColor(_ value: UColor, at range: ClosedRange<Int>? = nil) -> AttributedString {
        AttrStr(self).strikethroughColor(value, at: range)
    }
    
    /// Hex color, default nil: same as foreground color
    @discardableResult
    public func strikethroughColor(_ value: Int, at range: ClosedRange<Int>? = nil) -> AttributedString {
        AttrStr(self).strikethroughColor(value, at: range)
    }
    
    /// NSNumber containing floating point value; skew to be applied to glyphs, default 0: no skew
    @discardableResult
    public func obliqueness(_ value: Float, at range: ClosedRange<Int>? = nil) -> AttributedString {
        AttrStr(self).obliqueness(value, at: range)
    }
    
    /// NSNumber containing floating point value; log of expansion factor to be applied to glyphs, default 0: no expansion
    @discardableResult
    public func expansion(_ value: Float, at range: ClosedRange<Int>? = nil) -> AttributedString {
        AttrStr(self).expansion(value, at: range)
    }
    
    @discardableResult
    public func glyphForm(_ form: AttributedString.GlyphForm, at range: ClosedRange<Int>? = nil) -> AttributedString {
        AttrStr(self).glyphForm(form, at: range)
    }
    
    @discardableResult
    public func writingDirection(_ direction: NSWritingDirection, at range: ClosedRange<Int>? = nil) -> AttributedString {
        AttrStr(self).writingDirection(direction, at: range)
    }
    
    // MARK: - Paragraph Style proxy
    
    // MARK: Line Spacing
    
    @discardableResult
    public func lineSpacing(_ v: CGFloat) -> AttributedString {
        AttrStr(self).lineSpacing(v)
    }
    
    @discardableResult
    public func lineSpacing(_ state: State<CGFloat>) -> AttributedString {
        AttrStr(self).lineSpacing(state)
    }
    
    // MARK: Paragraph Spacing
    
    @discardableResult
    public func paragraphSpacing(_ v: CGFloat) -> AttributedString {
        AttrStr(self).paragraphSpacing(v)
    }
    
    @discardableResult
    public func paragraphSpacing(_ state: State<CGFloat>) -> AttributedString {
        AttrStr(self).paragraphSpacing(state)
    }
    
    // MARK: First Line Head Indent
    
    @discardableResult
    public func firstLineHeadIndent(_ v: CGFloat) -> AttributedString {
        AttrStr(self).firstLineHeadIndent(v)
    }
    
    @discardableResult
    public func firstLineHeadIndent(_ state: State<CGFloat>) -> AttributedString {
        AttrStr(self).firstLineHeadIndent(state)
    }
    
    // MARK: Head Indent
    
    @discardableResult
    public func headIndent(_ v: CGFloat) -> AttributedString {
        AttrStr(self).headIndent(v)
    }
    
    @discardableResult
    public func headIndent(_ state: State<CGFloat>) -> AttributedString {
        AttrStr(self).headIndent(state)
    }
    
    // MARK: Tail Indent
    
    @discardableResult
    public func tailIndent(_ v: CGFloat) -> AttributedString {
        AttrStr(self).tailIndent(v)
    }
    
    @discardableResult
    public func tailIndent(_ state: State<CGFloat>) -> AttributedString {
        AttrStr(self).tailIndent(state)
    }
    
    // MARK: Minimum Line Height
    
    @discardableResult
    public func minimumLineHeight(_ v: CGFloat) -> AttributedString {
        AttrStr(self).minimumLineHeight(v)
    }
    
    @discardableResult
    public func minimumLineHeight(_ state: State<CGFloat>) -> AttributedString {
        AttrStr(self).minimumLineHeight(state)
    }
    
    // MARK: Maximum Line Height
    
    @discardableResult
    public func maximumLineHeight(_ v: CGFloat) -> AttributedString {
        AttrStr(self).maximumLineHeight(v)
    }
    
    @discardableResult
    public func maximumLineHeight(_ state: State<CGFloat>) -> AttributedString {
        AttrStr(self).maximumLineHeight(state)
    }
    
    // MARK: Line Height Multiple
    
    @discardableResult
    public func lineHeightMultiple(_ v: CGFloat) -> AttributedString {
        AttrStr(self).lineHeightMultiple(v)
    }
    
    @discardableResult
    public func lineHeightMultiple(_ state: State<CGFloat>) -> AttributedString {
        AttrStr(self).lineHeightMultiple(state)
    }
    
    // MARK: Default Tab Interval
    
    @discardableResult
    public func defaultTabInterval(_ v: CGFloat) -> AttributedString {
        AttrStr(self).defaultTabInterval(v)
    }
    
    @discardableResult
    public func defaultTabInterval(_ state: State<CGFloat>) -> AttributedString {
        AttrStr(self).defaultTabInterval(state)
    }
    
    // MARK: Paragraph Spacing Before
    
    @discardableResult
    public func paragraphSpacingBefore(_ v: CGFloat) -> AttributedString {
        AttrStr(self).paragraphSpacingBefore(v)
    }
    
    @discardableResult
    public func paragraphSpacingBefore(_ state: State<CGFloat>) -> AttributedString {
        AttrStr(self).paragraphSpacingBefore(state)
    }
    
    // MARK: Hyphenation Factor
    
    @discardableResult
    public func hyphenationFactor(_ v: Float) -> AttributedString {
        AttrStr(self).hyphenationFactor(v)
    }
    
    @discardableResult
    public func hyphenationFactor(_ state: State<Float>) -> AttributedString {
        AttrStr(self).hyphenationFactor(state)
    }
    
    #if os(macOS)
    // MARK: Tightening Factor For Truncation
    
    @discardableResult
    public func tighteningFactorForTruncation(_ v: Float) -> AttributedString {
        AttrStr(self).tighteningFactorForTruncation(v)
    }
    
    @discardableResult
    public func tighteningFactorForTruncation(_ state: State<Float>) -> AttributedString {
        AttrStr(self).tighteningFactorForTruncation(state)
    }
    
    // MARK: Header Level
    
    @discardableResult
    public func headerLevel(_ v: Int) -> AttributedString {
        AttrStr(self).headerLevel(v)
    }
    
    @discardableResult
    public func headerLevel(_ state: State<Int>) -> AttributedString {
        AttrStr(self).headerLevel(state)
    }
    
    // MARK: Allows Default Tightening For Truncation
    
    @discardableResult
    public func allowsDefaultTighteningForTruncation(_ v: Bool) -> AttributedString {
        AttrStr(self).allowsDefaultTighteningForTruncation(v)
    }
    
    @discardableResult
    public func allowsDefaultTighteningForTruncation(_ state: State<Bool>) -> AttributedString {
        AttrStr(self).allowsDefaultTighteningForTruncation(state)
    }
    #endif
    
    // MARK: Alignment
    
    @discardableResult
    public func alignment(_ v: NSTextAlignment) -> AttributedString {
        AttrStr(self).alignment(v)
    }
    
    @discardableResult
    public func alignment(_ state: State<NSTextAlignment>) -> AttributedString {
        AttrStr(self).alignment(state)
    }
    
    // MARK: Line Break Mode
    
    @discardableResult
    public func lineBreakMode(_ v: NSLineBreakMode) -> AttributedString {
        AttrStr(self).lineBreakMode(v)
    }
    
    @discardableResult
    public func lineBreakMode(_ state: State<NSLineBreakMode>) -> AttributedString {
        AttrStr(self).lineBreakMode(state)
    }
    
    // MARK: Base Writing Direction
    
    @discardableResult
    public func baseWritingDirection(_ v: NSWritingDirection) -> AttributedString {
        AttrStr(self).baseWritingDirection(v)
    }
    
    @discardableResult
    public func baseWritingDirection(_ state: State<NSWritingDirection>) -> AttributedString {
        AttrStr(self).baseWritingDirection(state)
    }
    
    // MARK: Tab Stops
    
    @discardableResult
    public func tabStops(_ v: [NSTextTab]) -> AttributedString {
        AttrStr(self).tabStops(v)
    }
    
    @discardableResult
    public func tabStops(_ state: State<[NSTextTab]>) -> AttributedString {
        AttrStr(self).tabStops(state)
    }
    
    #if os(macOS)
    // MARK: Text Blocks
    
    @discardableResult
    public func textBlocks(_ v: [NSTextBlock]) -> AttributedString {
        AttrStr(self).textBlocks(v)
    }
    
    @discardableResult
    public func textBlocks(_ state: State<[NSTextBlock]>) -> AttributedString {
        AttrStr(self).textBlocks(state)
    }
    
    // MARK: Text Lists
    
    @discardableResult
    public func textLists(_ v: [NSTextList]) -> AttributedString {
        AttrStr(self).textLists(v)
    }
    
    @discardableResult
    public func textLists(_ state: State<[NSTextList]>) -> AttributedString {
        AttrStr(self).textLists(state)
    }
    #endif
}
