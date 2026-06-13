#if !os(macOS)
import UIKit

open class UImage: UIImageView, AnyDeclarativeProtocol, DeclarativeProtocolInternal {
    public var declarativeView: UImage { self }
    public lazy var properties = Properties<UImage>()
    lazy var _properties = PropertiesInternal()
    
    @State public var height: CGFloat = 0
    @State public var width: CGFloat = 0
    @State public var top: CGFloat = 0
    @State public var leading: CGFloat = 0
    @State public var left: CGFloat = 0
    @State public var trailing: CGFloat = 0
    @State public var right: CGFloat = 0
    @State public var bottom: CGFloat = 0
    @State public var centerX: CGFloat = 0
    @State public var centerY: CGFloat = 0
    
    var __height: State<CGFloat> { _height }
    var __width: State<CGFloat> { _width }
    var __top: State<CGFloat> { _top }
    var __leading: State<CGFloat> { _leading }
    var __left: State<CGFloat> { _left }
    var __trailing: State<CGFloat> { _trailing }
    var __right: State<CGFloat> { _right }
    var __bottom: State<CGFloat> { _bottom }
    var __centerX: State<CGFloat> { _centerX }
    var __centerY: State<CGFloat> { _centerY }
    
    var _imageLoader: ImageLoader = .defaultRelease
    
    public init (named: String) {
        super.init(frame: .zero)
        image = UIImage(named: named)
        _setup()
    }
    
    public init (named name: State<String>) {
        super.init(frame: .zero)
        self.image = UIImage(named: name.wrappedValue)
        _setup()
        name.listen { [weak self] new in
            self?.image = UIImage(named: new)
        }
        .holdIfOwned(by: self)
    }
    
    public init (_ image: UIImage?) {
        super.init(frame: .zero)
        self.image = image
        _setup()
    }
    
    public init (_ image: State<UIImage?>) {
        super.init(frame: .zero)
        self.image = image.wrappedValue
        _setup()
        image.listen { [weak self] new in
            self?.image = new
        }
        .holdIfOwned(by: self)
    }
    
    public convenience init (url: State<URL?>, defaultImage: UIImage? = nil, loader: ImageLoader = .defaultRelease) {
        self.init(url: url.map { $0?.absoluteString }, defaultImage: defaultImage, loader: loader)
    }
    
    public init (url: State<String?>, defaultImage: UIImage? = nil, loader: ImageLoader = .defaultRelease) {
        super.init(frame: .zero)
        _setup()
        self.image = defaultImage
        self._imageLoader = loader
        self._imageLoader.load(url.wrappedValue, imageView: self, defaultImage: defaultImage)
        url.listen { [weak self] old, new in
            guard let self = self else { return }
            self._imageLoader.load(new, imageView: self, defaultImage: defaultImage)
        }
    }
    
    public init (url: URL?, defaultImage: UIImage? = nil, loader: ImageLoader = .defaultRelease) {
        super.init(frame: .zero)
        _setup()
        self.image = defaultImage
        self._imageLoader = loader
        self._imageLoader.load(url, imageView: self, defaultImage: defaultImage)
    }
    
    public init (url: String?, defaultImage: UIImage? = nil, loader: ImageLoader = .defaultRelease) {
        super.init(frame: .zero)
        _setup()
        self.image = defaultImage
        self._imageLoader = loader
        self._imageLoader.load(url, imageView: self, defaultImage: defaultImage)
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func _setup() {
        translatesAutoresizingMaskIntoConstraints = false
        clipsToBounds = true
        if #available(iOS 17.0, *) {
            registerForTraitChanges([UITraitUserInterfaceStyle.self]) { [weak self] (self: Self?, previousTraitCollection) in
                guard let self else { return }
                self.properties.traitCollectionDidChangeHandlers.values.forEach { $0(self.traitCollection) }
            }
        }
        buildView()
    }
    
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if #available(iOS 13.0, *) {
            if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                properties.traitCollectionDidChangeHandlers.values.forEach { $0(traitCollection) }
            }
        }
    }
    
    deinit {
        _imageLoader.cancel()
    }
    
    open func buildView() {}
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        onLayoutSubviews()
    }
    
    open override func didMoveToSuperview() {
        super.didMoveToSuperview()
        movedToSuperview()
    }
    
    @discardableResult
    public func mode(_ mode: UIView.ContentMode) -> Self {
        contentMode = mode
        return self
    }
    
    @discardableResult
    public func clipsToBounds(_ value: Bool) -> Self {
        clipsToBounds = value
        return self
    }
    
    @discardableResult
    public func load(url: URL, defaultImage: UIImage? = nil, loader: ImageLoader = .defaultRelease) -> Self {
        image = defaultImage
        _imageLoader = loader
        _imageLoader.load(url, imageView: self, defaultImage: defaultImage)
        return self
    }
    
    @discardableResult
    public func load(url: String, defaultImage: UIImage? = nil, loader: ImageLoader = .defaultRelease) -> Self {
        image = defaultImage
        _imageLoader = loader
        _imageLoader.load(url, imageView: self, defaultImage: defaultImage)
        return self
    }
}
#endif
