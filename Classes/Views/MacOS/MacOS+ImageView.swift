#if os(macOS)
import AppKit

open class UImage: NSImageView, AnyDeclarativeProtocol, DeclarativeProtocolInternal {
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
    
    var contentMode: CALayerContentsGravity = .resize
    
    open override var image: NSImage? {
        set {
            let l = CALayer()
            if let v = self.layer?.cornerRadius {
                l.cornerRadius = v
            }
            if let v = self.layer?.opacity {
                l.opacity = v
            }
            if let v = self.layer?.masksToBounds {
                l.masksToBounds = v
            }
            l.borderColor = self.layer?.borderColor
            if let v = self.layer?.borderWidth {
                l.borderWidth = v
            }
            l.contentsGravity = contentMode
            l.contents = newValue
            self.layer = l
            self.wantsLayer = true
            super.image = newValue
        }
        get { super.image }
    }
    
    public init (_ named: String) {
        super.init(frame: .zero)
        image = NSImage(named: named)
        _setup()
    }
    
    public init (_ image: NSImage?) {
        super.init(frame: .zero)
        self.image = image
        _setup()
    }
    
    public init (_ image: State<NSImage?>) {
        super.init(frame: .zero)
        self.image = image.wrappedValue
        _setup()
        image.listen { [weak self] old, new in
            self?.image = new
        }
        .holdIfOwned(by: self)
    }
    
    public init (_ url: State<URL>, defaultImage: NSImage? = nil, loader: ImageLoader = .defaultRelease) {
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
    
    public init (_ url: State<String>, defaultImage: NSImage? = nil, loader: ImageLoader = .defaultRelease) {
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
    
    public init (url: URL, defaultImage: NSImage? = nil, loader: ImageLoader = .defaultRelease) {
        super.init(frame: .zero)
        _setup()
        self.image = defaultImage
        self._imageLoader = loader
        self._imageLoader.load(url, imageView: self, defaultImage: defaultImage)
    }
    
    public init (url: String, defaultImage: NSImage? = nil, loader: ImageLoader = .defaultRelease) {
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
    
    private var _clipsToBounds = false
    open override var wantsDefaultClipping: Bool { !_clipsToBounds }
    
    private func _setup() {
        translatesAutoresizingMaskIntoConstraints = false
        buildView()
    }
    
    deinit {
        _imageLoader.cancel()
    }
    
    open func buildView() {}
    
    open override func layout() {
        super.layout()
        onLayoutSubviews()
    }
    
    open override func viewDidMoveToSuperview() {
        super.viewDidMoveToSuperview()
        movedToSuperview()
    }
    
    @discardableResult
    public func mode(_ mode: CALayerContentsGravity) -> Self {
        contentMode = mode
        image = super.image
        return self
    }
    
    @discardableResult
    public func clipsToBounds(_ value: Bool) -> Self {
        _clipsToBounds = value
        return self
    }
    
    @discardableResult
    public func load(url: URL, defaultImage: NSImage? = nil, loader: ImageLoader = .defaultRelease) -> Self {
        image = defaultImage
        _imageLoader = loader
        _imageLoader.load(url, imageView: self, defaultImage: defaultImage)
        return self
    }
    
    @discardableResult
    public func load(url: String, defaultImage: NSImage? = nil, loader: ImageLoader = .defaultRelease) -> Self {
        image = defaultImage
        _imageLoader = loader
        _imageLoader.load(url, imageView: self, defaultImage: defaultImage)
        return self
    }
}

extension UImage: _Tintable {
    var _tintState: State<UColor> {
        get { properties.tintState }
        set {}
    }
    
    func _setTint(_ v: NSColor?) {
        guard let v = v else { return }
        image = tintedImage(with: v)
    }
    
    func tintedImage(with tintColor: NSColor) -> NSImage? {
        self.image?.image(withTintColor: tintColor)
    }
}

extension NSImage {
   public func image(withTintColor tintColor: NSColor) -> NSImage {
       guard isTemplate else { return self }
       guard let copiedImage = self.copy() as? NSImage else { return self }
       copiedImage.lockFocus()
       tintColor.set()
       let imageBounds = NSMakeRect(0, 0, copiedImage.size.width, copiedImage.size.height)
       imageBounds.fill(using: .sourceAtop)
       copiedImage.unlockFocus()
       copiedImage.isTemplate = false
       return copiedImage
   }
}
#endif
