#if os(macOS) || os(iOS) || os(tvOS)
#if !os(macOS)
import Foundation
import UIKit

@MainActor
public protocol UDynamicPickerableView {
    associatedtype ValueType: Codable
    var value: ValueType { get }
}

@available(*, deprecated, renamed: "UDynamicPickerView")
public typealias DynamicPickerView = UDynamicPickerView

open class UDynamicPickerView<V>: UView where V: UIView, V: UDynamicPickerableView {
    public typealias Done = (_ result: V.ValueType) -> ()
    public typealias Cancel = () -> ()
    
    let title: String
    
    public init (_ title: String? = nil) {
        self.title = title ?? ""
        super.init(frame: .zero)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Variables
    
    var defaultHeight: CGFloat = 238
    var allowImpactFeedback = true
    var cancelTitle: String = "Cancel" { didSet { cancelButton.title(cancelTitle) }}
    var doneTitle: String = "Done" { didSet { doneButton.title(doneTitle) }}
    var cancelFont: UIFont = .boldSystemFont(ofSize: 15) { didSet { cancelButton.font(v: cancelFont) }}
    var doneFont: UIFont = .boldSystemFont(ofSize: 15) { didSet { doneButton.font(v: doneFont) }}
    var titleFont: UIFont = .systemFont(ofSize: 17) { didSet { titleLabel.font(v: titleFont) }}
    var cancelColor: UIColor = .cyan { didSet { cancelButton.color(cancelColor) }}
    var doneColor: UIColor = .cyan { didSet { doneButton.color(doneColor) }}
    var cancelHighlightedColor: UIColor = .blue { didSet { cancelButton.color(cancelHighlightedColor, .highlighted) }}
    var doneHighlightedColor: UIColor = .blue { didSet { doneButton.color(doneHighlightedColor, .highlighted) }}
    var titleColor: UIColor = .black { didSet { titleLabel.color(titleColor) }}
    
    // MARK: Callbacks
    
    var onDone: Done = { _ in }
    var onChange: Done = { _ in }
    var onCancel: Cancel = {}
    
    lazy var containerView = UView.subviews {
        return [pickerView, cancelButton, titleLabel, doneButton]
    }.edgesToSuperview(leading: 0, trailing: 0, bottom: defaultHeight)
      .height(defaultHeight)
      .background(.white)
    lazy var pickerView = V()
    lazy var cancelButton = UButton(cancelTitle)
        .edgesToSuperview(top: 0, leading: 8)
        .font(v: cancelFont)
        .color(cancelColor)
        .color(cancelHighlightedColor, .highlighted)
        .onTapGesture {
        // TODO: onCancel()
    }
    lazy var titleLabel = UText(title)
        .font(v: titleFont)
        .color(titleColor)
        .centerY(to: cancelButton)
        .centerXInSuperview()
    lazy var doneButton = UButton(doneTitle)
        .edgesToSuperview(top: 0, trailing: -8)
        .font(v: doneFont)
        .color(doneColor)
        .color(doneHighlightedColor, .highlighted)
        .onTapGesture {
        // TODO: onDone()
    }
    
    open override func buildView() {
        super.buildView()
        edgesToSuperview()
        background(.init(red: 0, green: 0, blue: 0, alpha: 0.3))
        hidden()
        alpha(0)
        body {
            containerView
        }
        pickerView.leftAnchor.constraint(equalTo: containerView.leftAnchor).activated()
        pickerView.rightAnchor.constraint(equalTo: containerView.rightAnchor).activated()
        pickerView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).activated()
        pickerView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4).activated()
    }
    
    @discardableResult
    public func disableImpactFeedback() -> Self {
        allowImpactFeedback = false
        return self
    }
    
    @discardableResult
    public func height(_ value: CGFloat) -> Self {
        defaultHeight = value
        return self
    }
    
    @discardableResult
    public func onDone(_ value: @escaping Done) -> Self {
        onDone = value
        return self
    }
    
    @discardableResult
    public func onChange(_ value: @escaping Done) -> Self {
        onChange = value
        return self
    }
    
    @discardableResult
    public func onCancel(_ value: @escaping Cancel) -> Self {
        onCancel = value
        return self
    }
    
    // MARK: Fonts
    
    @discardableResult
    public func cancelFont(v: UIFont?) -> Self {
        guard let v = v else { return self }
        self.cancelFont = v
        return self
    }
    
    @discardableResult
    public func doneFont(v: UIFont?) -> Self {
        guard let v = v else { return self }
        self.doneFont = v
        return self
    }
    
    @discardableResult
    public func titleFont(v: UIFont?) -> Self {
        guard let v = v else { return self }
        self.titleFont = v
        return self
    }
    
    @discardableResult
    public func cancelFont(_ identifier: FontIdentifier, _ size: CGFloat) -> Self {
        cancelFont(v: UIFont(name: identifier.fontName, size: size))
    }
    
    @discardableResult
    public func doneFont(_ identifier: FontIdentifier, _ size: CGFloat) -> Self {
        doneFont(v: UIFont(name: identifier.fontName, size: size))
    }
    
    @discardableResult
    public func titleFont(_ identifier: FontIdentifier, _ size: CGFloat) -> Self {
        titleFont(v: UIFont(name: identifier.fontName, size: size))
    }
    
    @discardableResult
    public func buttonsFont(v: UIFont?) -> Self {
        cancelFont(v: v).doneFont(v: v)
    }
    
    @discardableResult
    public func buttonsFont(_ identifier: FontIdentifier, _ size: CGFloat) -> Self {
        buttonsFont(v: UIFont(name: identifier.fontName, size: size))
    }
    
    // MARK: Colors
    
    @discardableResult
    public func titleColor(_ color: UIColor) -> Self {
        titleColor = color
        return self
    }
    
    @discardableResult
    public func titleColor(_ number: Int) -> Self {
        titleColor(number.color)
    }
    
    @discardableResult
    public func cancelColor(_ color: UIColor) -> Self {
        cancelColor = color
        return self
    }
    
    @discardableResult
    public func cancelColor(_ number: Int) -> Self {
        cancelColor(number.color)
    }
    
    @discardableResult
    public func doneColor(_ color: UIColor) -> Self {
        doneColor = color
        return self
    }
    
    @discardableResult
    public func doneColor(_ number: Int) -> Self {
        doneColor(number.color)
    }
    
    @discardableResult
    public func buttonsColor(_ color: UIColor) -> Self {
        cancelColor(color).doneColor(color)
    }
    
    @discardableResult
    public func buttonsColor(_ number: Int) -> Self {
        buttonsColor(number.color)
    }
    
    @discardableResult
    public func cancelHighlightedColor(_ color: UIColor) -> Self {
        cancelHighlightedColor = color
        return self
    }
    
    @discardableResult
    public func cancelHighlightedColor(_ number: Int) -> Self {
        cancelHighlightedColor(number.color)
    }
    
    @discardableResult
    public func doneHighlightedColor(_ color: UIColor) -> Self {
        doneHighlightedColor = color
        return self
    }
    
    @discardableResult
    public func doneHighlightedColor(_ number: Int) -> Self {
        doneHighlightedColor(number.color)
    }
    
    @discardableResult
    public func buttonsHighlightedColor(_ color: UIColor) -> Self {
        cancelHighlightedColor(color).doneHighlightedColor(color)
    }
    
    @discardableResult
    public func buttonsHighlightedColor(_ number: Int) -> Self {
        buttonsHighlightedColor(number.color)
    }
    
    
    public func _show(in view: UIView) {
        view.body { self }
        layoutIfNeeded()
        UIView.animate(withDuration: 0.5) {
            self.alpha = 1
            self.containerView.bottom = 0
            self.layoutIfNeeded()
        }
        #if !os(tvOS)
        if allowImpactFeedback {
            ImpactFeedback.bzz(.heavy)
        }
        #endif
    }
    
    @objc
    public func hide() {
        UIView.animate(withDuration: 0.5, animations: {
            self.alpha = 0
            self.containerView.bottom = self.defaultHeight
            self.layoutIfNeeded()
        }) { _ in
            self.removeFromSuperview()
        }
    }
    
    @objc
    fileprivate func changed() {
        onChange(pickerView.value)
    }
    
    @objc
    fileprivate func cancel() {
        onCancel()
        hide()
        #if !os(tvOS)
        if allowImpactFeedback {
            ImpactFeedback.bzz(.light)
        }
        #endif
    }
    
    @objc
    fileprivate func done() {
        onDone(pickerView.value)
        hide()
        #if !os(tvOS)
        if allowImpactFeedback {
            ImpactFeedback.success()
        }
        #endif
    }
}

// MARK: PickerPopup + UIDatePicker

#if !os(tvOS)
public typealias DatePickerPopup = UDynamicPickerView<UDatePicker>

extension UIDatePicker: UDynamicPickerableView {
    public typealias ValueType = Date
    public var value: Date { return date }
}

extension UDynamicPickerView where V == UDatePicker {
    @discardableResult
    public func mode(_ value: UIDatePicker.Mode) -> Self {
        pickerView.mode(value)
        return self
    }
    
    @discardableResult
    public func locale(_ value: Locale) -> Self {
        pickerView.locale(value)
        return self
    }
    
    @discardableResult
    public func calendar(_ value: Calendar) -> Self {
        pickerView.calendar(value)
        return self
    }
    
    @discardableResult
    public func timeZone(_ value: TimeZone) -> Self {
        pickerView.timeZone(value)
        return self
    }
    
    @discardableResult
    public func date(_ value: Date) -> Self {
        pickerView.date(value)
        return self
    }
    
    @discardableResult
    public func minimumDate(_ value: Date) -> Self {
        pickerView.minimumDate(value)
        return self
    }
    
    @discardableResult
    public func maximumDate(_ value: Date) -> Self {
        pickerView.maximumDate(value)
        return self
    }
    
    @discardableResult
    public func countDownDuration(_ value: TimeInterval) -> Self {
        pickerView.countDownDuration(value)
        return self
    }
    
    @discardableResult
    public func minuteInterval(_ value: Int) -> Self {
        pickerView.minuteInterval(value)
        return self
    }
    
    public func show(in view: UIView) {
        onChange(pickerView.date)
        if let minimumDate = pickerView.minimumDate {
            pickerView.minimumDate = minimumDate
            if minimumDate > pickerView.date {
                var endOfDay = pickerView.calendar.startOfDay(for: minimumDate)
                endOfDay.addTimeInterval(86399)
                onChange(endOfDay)
            }
        }
        if let maximumDate = pickerView.maximumDate {
            pickerView.maximumDate = maximumDate
            if maximumDate < pickerView.date {
                pickerView.setDate(pickerView.maximumDate!, animated: false)
                var endOfDay = pickerView.calendar.startOfDay(for: maximumDate)
                endOfDay.addTimeInterval(86399)
                onChange(endOfDay)
            }
        }
        pickerView.onChange(onChange)
        _show(in: view)
    }
}
#endif

//// MARK: PickerPopup + WeekdayPickerView
//
//public typealias WeightPickerPopup = DynamicPickerView<WeightPickerView>
//
//extension WeightPickerView: DynamicPickerableView {
//    public typealias ValueType = Day
//    public var value: Day { return day }
//}
//
//extension DynamicPickerView where V == WeightPickerView {
//    public func show(in view: UIView,
//              day: WeekdayPickerView.Day?,
//              onChange: @escaping (WeekdayPickerView.Day) -> Void,
//              onCancel: @escaping PickerCancel,
//              completion: @escaping (WeekdayPickerView.Day) -> Void) {
//        self.onDone = completion
//        self.onChange = onChange
//        self.onCancel = onCancel
//        if let day = day {
//            picker.setDay(day, animated: false)
//        } else {
//            onChange(picker.day)
//            picker.setDay(picker.day, animated: false)
//        }
//        picker.onChange = onChange
//        show(in: view)
//    }
//}
//
//public class WeightPickerView: PickerView, UIPickerViewDataSource, UIPickerViewDelegate {
//    public enum Day: Int, Codable {
//        case sun, mon, tue, wed, thu, fri, sat
//
//        public static var all: [Day] = [.sun, .mon, .tue, .wed, .thu, .fri, .sat]
//
//        public var name: String {
//            switch self {
//            case .sun: return "Sunday"
//            case .mon: return "Monday"
//            case .tue: return "Tuesday"
//            case .wed: return "Wednesday"
//            case .thu: return "Thursday"
//            case .fri: return "Friday"
//            case .sat: return "Saturday"
//            }
//        }
//    }
//
//    public var day: Day
//
//    public init () {
//        day = Day(rawValue: Calendar(identifier: .gregorian).component(.weekday, from: Date())) ?? .mon
//        super.init(frame: .zero)
//        self.dataSource = self
//        self.delegate = self
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    public var onChange: (Day) -> Void = { _ in }
//
//    public func setDay(_ day: Day, animated: Bool) {
//        self.day = day
//        selectRow(day.rawValue, inComponent: 0, animated: animated)
//    }
//
//    // MARK: DataSource
//
//    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
//        return 7
//    }
//
//    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
//        return 1
//    }
//
//    // MARK: Delegate
//
//    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
//        return Day.all[row].name
//    }
//
//    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
//        day = Day.all[row]
//        onChange(day)
//    }
//}
#endif
#endif
