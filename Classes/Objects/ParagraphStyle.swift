//
//  ParagraphStyle.swift
//  UIKit-Plus
//
//  Created by Mihael Isaev on 27.08.2020.
//

#if os(macOS)
import AppKit
#else
import UIKit
#endif

public class ParagraphStyle: NSMutableParagraphStyle, @unchecked Sendable {
    private var _onUpdate: (@Sendable (ParagraphStyle) -> Void)?

    func setOnUpdate(_ handler: @escaping @Sendable (ParagraphStyle) -> Void) {
        _onUpdate = handler
    }

    private let _stateBindingHolder = TempStatesHolder()

    var stateBindingHolder: TempStatesHolder {
        _stateBindingHolder
    }

    override init () {
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @discardableResult
    public func remove(tabStop: NSTextTab) -> Self {
        super.removeTabStop(tabStop)
        _onUpdate?(self)
        return self
    }
    
    @discardableResult
    public func add(tabStop: NSTextTab) -> Self {
        super.addTabStop(tabStop)
        _onUpdate?(self)
        return self
    }
    
    public override func setParagraphStyle(_ obj: NSParagraphStyle) {
        lineSpacing(obj.lineSpacing)
        paragraphSpacing(obj.paragraphSpacing)
        firstLineHeadIndent(obj.firstLineHeadIndent)
        headIndent(obj.headIndent)
        tailIndent(obj.tailIndent)
        minimumLineHeight(obj.minimumLineHeight)
        maximumLineHeight(obj.maximumLineHeight)
        lineHeightMultiple(obj.lineHeightMultiple)
        defaultTabInterval(obj.defaultTabInterval)
        paragraphSpacingBefore(obj.paragraphSpacingBefore)
        hyphenationFactor(obj.hyphenationFactor)
        #if os(macOS)
        tighteningFactorForTruncation(obj.tighteningFactorForTruncation)
        headerLevel(obj.headerLevel)
        allowsDefaultTighteningForTruncation(obj.allowsDefaultTighteningForTruncation)
        #endif
        alignment(obj.alignment)
        lineBreakMode(obj.lineBreakMode)
        baseWritingDirection(obj.baseWritingDirection)
        tabStops(obj.tabStops)
        #if os(macOS)
        textBlocks(obj.textBlocks)
        textLists(obj.textLists)
        #endif
    }
    
    func mergeWithParagraphStyle(_ v: ParagraphStyle) {
        lineSpacingState.merge(with: v.lineSpacingState).hold(in: stateBindingHolder)
        paragraphSpacingState.merge(with: v.paragraphSpacingState).hold(in: stateBindingHolder)
        firstLineHeadIndentState.merge(with: v.firstLineHeadIndentState).hold(in: stateBindingHolder)
        headIndentState.merge(with: v.headIndentState).hold(in: stateBindingHolder)
        tailIndentState.merge(with: v.tailIndentState).hold(in: stateBindingHolder)
        minimumLineHeightState.merge(with: v.minimumLineHeightState).hold(in: stateBindingHolder)
        maximumLineHeightState.merge(with: v.maximumLineHeightState).hold(in: stateBindingHolder)
        lineHeightMultipleState.merge(with: v.lineHeightMultipleState).hold(in: stateBindingHolder)
        defaultTabIntervalState.merge(with: v.defaultTabIntervalState).hold(in: stateBindingHolder)
        paragraphSpacingBeforeState.merge(with: v.paragraphSpacingBeforeState).hold(in: stateBindingHolder)
        hyphenationFactorState.merge(with: v.hyphenationFactorState).hold(in: stateBindingHolder)
        #if os(macOS)
        tighteningFactorForTruncationState.merge(with: v.tighteningFactorForTruncationState).hold(in: stateBindingHolder)
        headerLevelState.merge(with: v.headerLevelState).hold(in: stateBindingHolder)
        allowsDefaultTighteningForTruncationState.merge(with: v.allowsDefaultTighteningForTruncationState).hold(in: stateBindingHolder)
        #endif
        alignmentState.merge(with: v.alignmentState).hold(in: stateBindingHolder)
        lineBreakModeState.merge(with: v.lineBreakModeState).hold(in: stateBindingHolder)
        baseWritingDirectionState.merge(with: v.baseWritingDirectionState).hold(in: stateBindingHolder)
        tabStopsState.merge(with: v.tabStopsState).hold(in: stateBindingHolder)
        #if os(macOS)
        textBlocksState.merge(with: v.textBlocksState).hold(in: stateBindingHolder)
        textListsState.merge(with: v.textListsState).hold(in: stateBindingHolder)
        #endif
    }
    
    // MARK: Line Spacing
    
    public override var lineSpacing: CGFloat {
        get { super.lineSpacing }
        set {
            super.lineSpacing = newValue
            _onUpdate?(self)
        }
     }
    
    lazy var lineSpacingState: State<CGFloat> = .init(wrappedValue: lineSpacing)
    private var isListeningLineSpace = false
    
    @discardableResult
    public func lineSpacing(_ v: CGFloat) -> Self {
        lineSpacing = v
        if !isListeningLineSpace {
            isListeningLineSpace = true
            lineSpacingState.listen { [weak self] in
                self?.lineSpacing($0)
            }
        }
        return self
    }
    
    @discardableResult
    public func lineSpacing(_ state: State<CGFloat>) -> Self {
        lineSpacingState.merge(with: state).hold(in: stateBindingHolder)
        return lineSpacing(state.wrappedValue)
    }
    
    // MARK: Paragraph Spacing
    
    public override var paragraphSpacing: CGFloat {
        get { super.paragraphSpacing }
        set {
            super.paragraphSpacing = newValue
            _onUpdate?(self)
        }
    }
    
    lazy var paragraphSpacingState: State<CGFloat> = .init(wrappedValue: paragraphSpacing)
    private var isListeningParagraphSpacing = false
    
    @discardableResult
    public func paragraphSpacing(_ v: CGFloat) -> Self {
        paragraphSpacing = v
        if !isListeningParagraphSpacing {
            isListeningParagraphSpacing = true
            paragraphSpacingState.listen { [weak self] in
                self?.paragraphSpacing($0)
            }
        }
        return self
    }
    
    @discardableResult
    public func paragraphSpacing(_ state: State<CGFloat>) -> Self {
        paragraphSpacingState.merge(with: state).hold(in: stateBindingHolder)
        return paragraphSpacing(state.wrappedValue)
    }
    
    // MARK: First Line Head Indent
    
    public override var firstLineHeadIndent: CGFloat {
        get { super.firstLineHeadIndent }
        set {
            super.firstLineHeadIndent = newValue
            _onUpdate?(self)
        }
    }
    
    lazy var firstLineHeadIndentState: State<CGFloat> = .init(wrappedValue: firstLineHeadIndent)
    private var isListeningFirstLineHeadIndent = false
    
    @discardableResult
    public func firstLineHeadIndent(_ v: CGFloat) -> Self {
        firstLineHeadIndent = v
        if !isListeningFirstLineHeadIndent {
            isListeningFirstLineHeadIndent = true
            firstLineHeadIndentState.listen { [weak self] in
                self?.firstLineHeadIndent($0)
            }
        }
        return self
    }
    
    @discardableResult
    public func firstLineHeadIndent(_ state: State<CGFloat>) -> Self {
        firstLineHeadIndentState.merge(with: state).hold(in: stateBindingHolder)
        return firstLineHeadIndent(state.wrappedValue)
    }
    
    // MARK: Head Indent
    
    public override var headIndent: CGFloat {
        get { super.headIndent }
        set {
            super.headIndent = newValue
            _onUpdate?(self)
        }
    }
    
    lazy var headIndentState: State<CGFloat> = .init(wrappedValue: headIndent)
    private var isListeningHeadIndent = false
    
    @discardableResult
    public func headIndent(_ v: CGFloat) -> Self {
        headIndent = v
        if !isListeningHeadIndent {
            isListeningHeadIndent = true
            headIndentState.listen { [weak self] in
                self?.headIndent($0)
            }
        }
        return self
    }
    
    @discardableResult
    public func headIndent(_ state: State<CGFloat>) -> Self {
        headIndentState.merge(with: state).hold(in: stateBindingHolder)
        return headIndent(state.wrappedValue)
    }
    
    // MARK: Tail Indent
    
    public override var tailIndent: CGFloat {
        get { super.tailIndent }
        set {
            super.tailIndent = newValue
            _onUpdate?(self)
        }
    }
    
    lazy var tailIndentState: State<CGFloat> = .init(wrappedValue: tailIndent)
    private var isListeningTailIndent = false
    
    @discardableResult
    public func tailIndent(_ v: CGFloat) -> Self {
        tailIndent = v
        if !isListeningTailIndent {
            isListeningTailIndent = true
            tailIndentState.listen { [weak self] in
                self?.tailIndent($0)
            }
        }
        return self
    }
    
    @discardableResult
    public func tailIndent(_ state: State<CGFloat>) -> Self {
        tailIndentState.merge(with: state).hold(in: stateBindingHolder)
        return tailIndent(state.wrappedValue)
    }
    
    // MARK: Minimum Line Height
    
    public override var minimumLineHeight: CGFloat {
        get { super.minimumLineHeight }
        set {
            super.minimumLineHeight = newValue
            _onUpdate?(self)
        }
    }
    
    lazy var minimumLineHeightState: State<CGFloat> = .init(wrappedValue: minimumLineHeight)
    private var isListeningMinimumLineHeight = false
    
    @discardableResult
    public func minimumLineHeight(_ v: CGFloat) -> Self {
        minimumLineHeight = v
        if !isListeningMinimumLineHeight {
            isListeningMinimumLineHeight = true
            minimumLineHeightState.listen { [weak self] in
                self?.minimumLineHeight($0)
            }
        }
        return self
    }
    
    @discardableResult
    public func minimumLineHeight(_ state: State<CGFloat>) -> Self {
        minimumLineHeightState.merge(with: state).hold(in: stateBindingHolder)
        return minimumLineHeight(state.wrappedValue)
    }
    
    // MARK: Maximum Line Height
    
    public override var maximumLineHeight: CGFloat {
        get { super.maximumLineHeight }
        set {
            super.maximumLineHeight = newValue
            _onUpdate?(self)
        }
    }
    
    lazy var maximumLineHeightState: State<CGFloat> = .init(wrappedValue: maximumLineHeight)
    private var isListeningMaximumLineHeight = false
    
    @discardableResult
    public func maximumLineHeight(_ v: CGFloat) -> Self {
        maximumLineHeight = v
        if !isListeningMaximumLineHeight {
            isListeningMaximumLineHeight = true
            maximumLineHeightState.listen { [weak self] in
                self?.maximumLineHeight($0)
            }
        }
        return self
    }
    
    @discardableResult
    public func maximumLineHeight(_ state: State<CGFloat>) -> Self {
        maximumLineHeightState.merge(with: state).hold(in: stateBindingHolder)
        return maximumLineHeight(state.wrappedValue)
    }
    
    // MARK: Line Height Multiple
    
    public override var lineHeightMultiple: CGFloat {
        get { super.lineHeightMultiple }
        set {
            super.lineHeightMultiple = newValue
            _onUpdate?(self)
        }
    }
    
    lazy var lineHeightMultipleState: State<CGFloat> = .init(wrappedValue: lineHeightMultiple)
    private var isListeningLineHeightMultiple = false
    
    @discardableResult
    public func lineHeightMultiple(_ v: CGFloat) -> Self {
        lineHeightMultiple = v
        if !isListeningLineHeightMultiple {
            isListeningLineHeightMultiple = true
            lineHeightMultipleState.listen { [weak self] in
                self?.lineHeightMultiple($0)
            }
        }
        return self
    }
    
    @discardableResult
    public func lineHeightMultiple(_ state: State<CGFloat>) -> Self {
        lineHeightMultipleState.merge(with: state).hold(in: stateBindingHolder)
        return lineHeightMultiple(state.wrappedValue)
    }
    
    // MARK: Default Tab Interval
    
    public override var defaultTabInterval: CGFloat {
        get { super.defaultTabInterval }
        set {
            super.defaultTabInterval = newValue
            _onUpdate?(self)
        }
    }
    
    lazy var defaultTabIntervalState: State<CGFloat> = .init(wrappedValue: defaultTabInterval)
    private var isListeningDefaultTabInterval = false
    
    @discardableResult
    public func defaultTabInterval(_ v: CGFloat) -> Self {
        defaultTabInterval = v
        if !isListeningDefaultTabInterval {
            isListeningDefaultTabInterval = true
            defaultTabIntervalState.listen { [weak self] in
                self?.defaultTabInterval($0)
            }
        }
        return self
    }
    
    @discardableResult
    public func defaultTabInterval(_ state: State<CGFloat>) -> Self {
        defaultTabIntervalState.merge(with: state).hold(in: stateBindingHolder)
        return defaultTabInterval(state.wrappedValue)
    }
    
    // MARK: Paragraph Spacing Before
    
    public override var paragraphSpacingBefore: CGFloat {
        get { super.paragraphSpacingBefore }
        set {
            super.paragraphSpacingBefore = newValue
            _onUpdate?(self)
        }
    }
    
    lazy var paragraphSpacingBeforeState: State<CGFloat> = .init(wrappedValue: paragraphSpacingBefore)
    private var isListeningParagraphSpacingBefore = false
    
    @discardableResult
    public func paragraphSpacingBefore(_ v: CGFloat) -> Self {
        paragraphSpacingBefore = v
        if !isListeningParagraphSpacingBefore {
            isListeningParagraphSpacingBefore = true
            paragraphSpacingBeforeState.listen { [weak self] in
                self?.paragraphSpacingBefore($0)
            }
        }
        return self
    }
    
    @discardableResult
    public func paragraphSpacingBefore(_ state: State<CGFloat>) -> Self {
        paragraphSpacingBeforeState.merge(with: state).hold(in: stateBindingHolder)
        return paragraphSpacingBefore(state.wrappedValue)
    }
    
    // MARK: Hyphenation Factor
    
    public override var hyphenationFactor: Float {
        get { super.hyphenationFactor }
        set {
            super.hyphenationFactor = newValue
            _onUpdate?(self)
        }
    }
    
    lazy var hyphenationFactorState: State<Float> = .init(wrappedValue: hyphenationFactor)
    private var isListeningHyphenationFactor = false
    
    @discardableResult
    public func hyphenationFactor(_ v: Float) -> Self {
        hyphenationFactor = v
        if !isListeningHyphenationFactor {
            isListeningHyphenationFactor = true
            hyphenationFactorState.listen { [weak self] in
                self?.hyphenationFactor($0)
            }
        }
        return self
    }
    
    @discardableResult
    public func hyphenationFactor(_ state: State<Float>) -> Self {
        hyphenationFactorState.merge(with: state).hold(in: stateBindingHolder)
        return hyphenationFactor(state.wrappedValue)
    }
    
    #if os(macOS)
    // MARK: Tightening Factor For Truncation
    
    public override var tighteningFactorForTruncation: Float {
        get { super.tighteningFactorForTruncation }
        set {
            super.tighteningFactorForTruncation = newValue
            _onUpdate?(self)
        }
    }
    
    lazy var tighteningFactorForTruncationState: State<Float> = .init(wrappedValue: tighteningFactorForTruncation)
    private var isListeningTighteningFactorForTruncation = false
    
    @discardableResult
    public func tighteningFactorForTruncation(_ v: Float) -> Self {
        tighteningFactorForTruncation = v
        if !isListeningTighteningFactorForTruncation {
            isListeningTighteningFactorForTruncation = true
            tighteningFactorForTruncationState.listen { [weak self] in
                self?.tighteningFactorForTruncation($0)
            }
        }
        return self
    }
    
    @discardableResult
    public func tighteningFactorForTruncation(_ state: State<Float>) -> Self {
        tighteningFactorForTruncationState.merge(with: state).hold(in: stateBindingHolder)
        return tighteningFactorForTruncation(state.wrappedValue)
    }
    
    // MARK: Header Level
    
    public override var headerLevel: Int {
        get { super.headerLevel }
        set {
            super.headerLevel = newValue
            _onUpdate?(self)
        }
    }
    
    lazy var headerLevelState: State<Int> = .init(wrappedValue: headerLevel)
    private var isListeningHeaderLevel = false
    
    @discardableResult
    public func headerLevel(_ v: Int) -> Self {
        headerLevel = v
        if !isListeningHeaderLevel {
            isListeningHeaderLevel = true
            headerLevelState.listen { [weak self] in
                self?.headerLevel($0)
            }
        }
        return self
    }
    
    @discardableResult
    public func headerLevel(_ state: State<Int>) -> Self {
        headerLevelState.merge(with: state).hold(in: stateBindingHolder)
        return headerLevel(state.wrappedValue)
    }
    
    // MARK: Allows Default Tightening For Truncation
    
    public override var allowsDefaultTighteningForTruncation: Bool {
        get { super.allowsDefaultTighteningForTruncation }
        set {
            super.allowsDefaultTighteningForTruncation = newValue
            _onUpdate?(self)
        }
    }
    
    lazy var allowsDefaultTighteningForTruncationState: State<Bool> = .init(wrappedValue: allowsDefaultTighteningForTruncation)
    private var isListeningAllowsDefaultTighteningForTruncation = false
    
    @discardableResult
    public func allowsDefaultTighteningForTruncation(_ v: Bool = true) -> Self {
        allowsDefaultTighteningForTruncation = v
        if !isListeningAllowsDefaultTighteningForTruncation {
            isListeningAllowsDefaultTighteningForTruncation = true
            allowsDefaultTighteningForTruncationState.listen { [weak self] in
                self?.allowsDefaultTighteningForTruncation($0)
            }
        }
        return self
    }
    
    @discardableResult
    public func allowsDefaultTighteningForTruncation(_ state: State<Bool>) -> Self {
        allowsDefaultTighteningForTruncationState.merge(with: state).hold(in: stateBindingHolder)
        return allowsDefaultTighteningForTruncation(state.wrappedValue)
    }
    #endif
    
    // MARK: Alignment
    
    public override var alignment: NSTextAlignment {
        get { super.alignment }
        set {
            super.alignment = newValue
            _onUpdate?(self)
        }
    }
    
    lazy var alignmentState: State<NSTextAlignment> = .init(wrappedValue: alignment)
    private var isListeningAlignment = false
    
    @discardableResult
    public func alignment(_ v: NSTextAlignment) -> Self {
        alignment = v
        if !isListeningAlignment {
            isListeningAlignment = true
            alignmentState.listen { [weak self] in
                self?.alignment($0)
            }
        }
        return self
    }
    
    @discardableResult
    public func alignment(_ state: State<NSTextAlignment>) -> Self {
        alignmentState.merge(with: state).hold(in: stateBindingHolder)
        return alignment(state.wrappedValue)
    }
    
    // MARK: Line Break Mode
    
    public override var lineBreakMode: NSLineBreakMode {
        get { super.lineBreakMode }
        set {
            super.lineBreakMode = newValue
            _onUpdate?(self)
        }
    }
    
    lazy var lineBreakModeState: State<NSLineBreakMode> = .init(wrappedValue: lineBreakMode)
    private var isListeningLineBreakMode = false
    
    @discardableResult
    public func lineBreakMode(_ v: NSLineBreakMode) -> Self {
        lineBreakMode = v
        if !isListeningLineBreakMode {
            isListeningLineBreakMode = true
            lineBreakModeState.listen { [weak self] in
                self?.lineBreakMode($0)
            }
        }
        return self
    }
    
    @discardableResult
    public func lineBreakMode(_ state: State<NSLineBreakMode>) -> Self {
        lineBreakModeState.merge(with: state).hold(in: stateBindingHolder)
        return lineBreakMode(state.wrappedValue)
    }
    
    // MARK: Base Writing Direction
    
    public override var baseWritingDirection: NSWritingDirection {
        get { super.baseWritingDirection }
        set {
            super.baseWritingDirection = newValue
            _onUpdate?(self)
        }
    }
    
    lazy var baseWritingDirectionState: State<NSWritingDirection> = .init(wrappedValue: baseWritingDirection)
    private var isListeningBaseWritingDirection = false
    
    @discardableResult
    public func baseWritingDirection(_ v: NSWritingDirection) -> Self {
        baseWritingDirection = v
        if !isListeningBaseWritingDirection {
            isListeningBaseWritingDirection = true
            baseWritingDirectionState.listen { [weak self] in
                self?.baseWritingDirection($0)
            }
        }
        return self
    }
    
    @discardableResult
    public func baseWritingDirection(_ state: State<NSWritingDirection>) -> Self {
        baseWritingDirectionState.merge(with: state).hold(in: stateBindingHolder)
        return baseWritingDirection(state.wrappedValue)
    }
    
    // MARK: Tab Stops
    
    public override var tabStops: [NSTextTab]! {
        get { super.tabStops }
        set {
            super.tabStops = newValue
            _onUpdate?(self)
        }
    }
    
    lazy var tabStopsState: State<[NSTextTab]> = .init(wrappedValue: tabStops)
    private var isListeningTabStops = false
    
    @discardableResult
    public func tabStops(_ v: [NSTextTab]) -> Self {
        tabStops = v
        if !isListeningTabStops {
            isListeningTabStops = true
            tabStopsState.listen { [weak self] in
                self?.tabStops($0)
            }
        }
        return self
    }
    
    @discardableResult
    public func tabStops(_ state: State<[NSTextTab]>) -> Self {
        tabStopsState.merge(with: state).hold(in: stateBindingHolder)
        return tabStops(state.wrappedValue)
    }
    
    #if os(macOS)
    // MARK: Text Blocks
    
    public override var textBlocks: [NSTextBlock] {
        get { super.textBlocks }
        set {
            super.textBlocks = newValue
            _onUpdate?(self)
        }
    }
    
    lazy var textBlocksState: State<[NSTextBlock]> = .init(wrappedValue: textBlocks)
    private var isListeningTextBlocks = false
    
    @discardableResult
    public func textBlocks(_ v: [NSTextBlock]) -> Self {
        textBlocks = v
        if !isListeningTextBlocks {
            isListeningTextBlocks = true
            textBlocksState.listen { [weak self] in
                self?.textBlocks($0)
            }
        }
        return self
    }
    
    @discardableResult
    public func textBlocks(_ state: State<[NSTextBlock]>) -> Self {
        textBlocksState.merge(with: state).hold(in: stateBindingHolder)
        return textBlocks(state.wrappedValue)
    }
    
    // MARK: Text Lists
    
    public override var textLists: [NSTextList] {
        get { super.textLists }
        set {
            super.textLists = newValue
            _onUpdate?(self)
        }
    }
    
    lazy var textListsState: State<[NSTextList]> = .init(wrappedValue: textLists)
    private var isListeningTextLists = false
    
    @discardableResult
    public func textLists(_ v: [NSTextList]) -> Self {
        textLists = v
        if !isListeningTextLists {
            isListeningTextLists = true
            textListsState.listen { [weak self] in
                self?.textLists($0)
            }
        }
        return self
    }
    
    @discardableResult
    public func textLists(_ state: State<[NSTextList]>) -> Self {
        textListsState.merge(with: state).hold(in: stateBindingHolder)
        return textLists(state.wrappedValue)
    }
    #endif
}
