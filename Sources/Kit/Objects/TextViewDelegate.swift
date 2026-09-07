#if os(macOS) || os(iOS) || os(tvOS)
#if !os(macOS)
import UIKit

class TextViewDelegate: NSObject, UITextViewDelegate {
    let textView: TextView
    
    init (_ textView: TextView) {
        self.textView = textView
    }
    
    public func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        self.textView.shouldBeginEditingHandler?() ?? self.textView.shouldBeginEditingHandlerText?(self.textView) ?? true
    }

    public func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        self.textView.shouldEndEditingHandler?()
            ?? self.textView.shouldEndEditingHandlerText?(self.textView)
            ?? true
    }
    
    public func textViewDidBeginEditing(_ textView: UITextView) {
        if self.textView.attributedText.string == self.textView._properties.placeholderAttrText?.string {
            self.textView.text = ""
            self.textView.textColor = self.textView.properties.textColor
        }
        self.textView.didBeginEditingHandler?()
        self.textView.didBeginEditingHandlerText?(self.textView)
    }

    public func textViewDidEndEditing(_ textView: UITextView) {
        if self.textView.text.count == 0, let text = self.textView._properties.placeholderAttrText?.string, text.count > 0 {
            self.textView.attributedText = self.textView._properties.placeholderAttrText
        }
        self.textView.didEndEditingHandler?()
        self.textView.didEndEditingHandlerText?(self.textView)
    }
    
    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        self.textView.shouldChangeTextHandler?()
            ?? self.textView.shouldChangeTextHandlerText?(self.textView)
            ?? self.textView.shouldChangeTextHandlerTextRangeString?(self.textView, range, text)
            ?? self.textView.shouldChangeTextHandlerRangeString?(range, text)
            ?? true
    }
    
    @objc private func invalidateTimer() {
        self.textView._properties.isTyping = false
    }

    public func textViewDidChange(_ textView: UITextView) {
        self.textView._properties.typingTimer?.invalidate()
        self.textView._properties.typingTimer = Timer.scheduledTimer(timeInterval: self.textView._properties.typingInterval, target: self, selector: #selector(invalidateTimer), userInfo: nil, repeats: false)
        self.textView._properties.isTyping = true
        self.textView.didChangeTextHandler?()
        self.textView.didChangeTextHandlerText?(self.textView)
        if self.textView.text.count > 0 {
            self.textView._properties.textChangeListeners.forEach {
                $0(.init(string: self.textView.text))
            }
        } else if self.textView.attributedText.string.count > 0 {
            self.textView._properties.textChangeListeners.forEach {
                $0(self.textView.attributedText)
            }
        } else {
            self.textView._properties.textChangeListeners.forEach {
                $0(.init())
            }
        }
    }
    
    public func textViewDidChangeSelection(_ textView: UITextView) {
        self.textView.didChangeSelectionHandler?()
        self.textView.didChangeSelectionHandlerText?(self.textView)
    }

    @available(iOS 10.0, *)
    public func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        let bool1 = self.textView.shouldInteractWithURLHandler?()
        let bool2 = self.textView.shouldInteractWithURLHandlerText?(self.textView)
        let bool3 = self.textView.shouldInteractWithURLHandlerURLRange?(self.textView, URL, characterRange)
        let bool4 = self.textView.shouldInteractWithURLHandlerURLRangeInteraction?(self.textView, URL, characterRange, .from(interaction))
        return bool1 ?? bool2 ?? bool3 ?? bool4 ?? true
    }

    @available(iOS 10.0, *)
    public func textView(_ textView: UITextView, shouldInteractWith textAttachment: NSTextAttachment, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        let bool1 = self.textView.shouldInteractWithTextAttachmentHandler?()
        let bool2 = self.textView.shouldInteractWithTextAttachmentHandlerText?(self.textView)
        let bool3 = self.textView.shouldInteractWithTextAttachmentHandlerRange?(self.textView, textAttachment, characterRange)
        let bool4 = self.textView.shouldInteractWithTextAttachmentHandlerRangeInteraction?(self.textView, textAttachment, characterRange, .from(interaction))
        return bool1 ?? bool2 ?? bool3 ?? bool4 ?? true
    }

    
    public func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        let bool1 = self.textView.shouldInteractWithURLHandler?()
        let bool2 = self.textView.shouldInteractWithURLHandlerText?(self.textView)
        let bool3 = self.textView.shouldInteractWithURLHandlerURLRange?(self.textView, URL, characterRange)
        let bool4 = self.textView.shouldInteractWithURLHandlerURLRangeInteraction?(self.textView, URL, characterRange, .invokeDefaultAction)
        return bool1 ?? bool2 ?? bool3 ?? bool4 ?? true
    }

    public func textView(_ textView: UITextView, shouldInteractWith textAttachment: NSTextAttachment, in characterRange: NSRange) -> Bool {
        let bool1 = self.textView.shouldInteractWithTextAttachmentHandler?()
        let bool2 = self.textView.shouldInteractWithTextAttachmentHandlerText?(self.textView)
        let bool3 = self.textView.shouldInteractWithTextAttachmentHandlerRange?(self.textView, textAttachment, characterRange)
        let bool4 = self.textView.shouldInteractWithTextAttachmentHandlerRangeInteraction?(self.textView, textAttachment, characterRange, .invokeDefaultAction)
        return bool1 ?? bool2 ?? bool3 ?? bool4 ?? true
    }
}
#endif
#endif
