#if os(macOS) || os(iOS) || os(tvOS)
#if !os(macOS)
import UIKit

public class CustomCorners {
    let radius: CGFloat
    let corners: [UIRectCorner]
    var backgroundColor: UIColor?
    
    init (radius: CGFloat, corners: [UIRectCorner]) {
        self.radius = radius
        self.corners = corners
    }
}
#endif
#endif
