#if os(macOS) || os(iOS) || os(tvOS)
//
//  Credits to Florian Friedrich https://gist.github.com/ffried/2e1176e302f8f37100b1eb00cb5f2b7d
//

#if !os(macOS)
import UIKit

class ULayerView<Layer: CALayer>: UView {
    override final class var layerClass: AnyClass {
        Layer.self
    }
    
    final var concreteLayer: Layer {
        layer as! Layer
    }
}
#endif
#endif
