#if os(macOS) || os(iOS) || os(tvOS)
#if os(macOS)
import Foundation
import AppKit

fileprivate final class _USecureTextFieldInsetCell: NSSecureTextFieldCell, _MacOSInsettableCell {
    private var insets = _MacOSControlInsets.zero

    var _macOSControlInsets: _MacOSControlInsets { insets }

    override init(textCell string: String) {
        super.init(textCell: string)
    }

    required init(coder: NSCoder) {
        super.init(coder: coder)
    }

    func _setMacOSControlInsets(_ insets: _MacOSControlInsets) {
        self.insets = insets
    }

    override func drawInterior(withFrame cellFrame: NSRect, in controlView: NSView) {
        guard !insets.isZero else {
            super.drawInterior(withFrame: cellFrame, in: controlView)
            return
        }
        super.drawInterior(withFrame: insets.contentFrame(for: cellFrame), in: controlView)
    }

    override func edit(
        withFrame rect: NSRect,
        in controlView: NSView,
        editor textObj: NSText,
        delegate: Any?,
        event: NSEvent?
    ) {
        guard !insets.isZero else {
            super.edit(withFrame: rect, in: controlView, editor: textObj, delegate: delegate, event: event)
            return
        }
        super.edit(withFrame: insets.contentFrame(for: rect), in: controlView, editor: textObj, delegate: delegate, event: event)
    }

    override func select(
        withFrame rect: NSRect,
        in controlView: NSView,
        editor textObj: NSText,
        delegate: Any?,
        start selStart: Int,
        length selLength: Int
    ) {
        guard !insets.isZero else {
            super.select(withFrame: rect, in: controlView, editor: textObj, delegate: delegate, start: selStart, length: selLength)
            return
        }
        super.select(withFrame: insets.contentFrame(for: rect), in: controlView, editor: textObj, delegate: delegate, start: selStart, length: selLength)
    }

    override func cellSize(forBounds rect: NSRect) -> NSSize {
        guard !insets.isZero else {
            return super.cellSize(forBounds: rect)
        }
        return insets.expandedSize(super.cellSize(forBounds: insets.contentFrame(for: rect)))
    }
}

open class USecureTextField: UTextField {
    override func _setup() {
        isEditable = true
        super._setup()
    }

    override open class var cellClass: AnyClass? {
        get { _USecureTextFieldInsetCell.self }
        set {}
    }
}

//extension USecureTextField: _Secureable {
//    func _setSecure(_ v: Bool) {
//        var isEditable = self.isEditable
//        guard let cell = cell as? NSTextFieldCell else { return }
//        let c: NSTextFieldCell
//        if v {
//            c = NSSecureTextFieldCell(textCell: attributedStringValue.string)
//        } else {
//            c = NSTextFieldCell(textCell: attributedStringValue.string)
//        }
//        c.backgroundColor = cell.backgroundColor
//        c.drawsBackground = cell.drawsBackground
//        c.textColor = cell.textColor
//        c.bezelStyle = cell.bezelStyle
//        c.placeholderString = cell.placeholderString
//        c.placeholderAttributedString = cell.placeholderAttributedString
//        c.allowedInputSourceLocales = cell.allowedInputSourceLocales
//        self.cell = c
//        self.isEditable = isEditable
//
////        resignFirstResponder()
////        abortEditing()
////        becomeFirstResponder()
//
////        setNeedsDisplay()
////        layer?.layoutIfNeeded()
//
//    }
//}

extension USecureTextField: _BulletsEchoable {
    func _setEchosBullets(_ v: Bool) {
        (cell as? NSSecureTextFieldCell)?.echosBullets = v
    }
}
#endif
#endif
