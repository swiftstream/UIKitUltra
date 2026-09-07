#if os(macOS) || os(iOS) || os(tvOS)
//
//  NSEvent+Key.swift
//  UIKit-Plus
//
//  Created by Mihael Isaev on 25.08.2020.
//

#if os(macOS)
import Foundation

extension NSEvent {
    public enum Key: UInt16, CustomStringConvertible {
        case enter = 36
        case q = 12
        case w = 13
        case e = 14
        case r = 15
        case t = 17
        case y = 16
        case u = 32
        case i = 34
        case o = 31
        case p = 35
        case a = 0
        case s = 1
        case d = 2
        case f = 3
        case g = 5
        case h = 4
        case j = 38
        case k = 40
        case l = 37
        case z = 6
        case x = 7
        case c = 8
        case v = 10
        case b = 11
        case n = 45
        case m = 46
        case tab = 48
        case backspace = 51
        case unknown = 10000
        
        static func parse(_ code: UInt16) -> Key {
            Key(rawValue: code) ?? .unknown
        }
        
        public var description: String {
            switch self {
            case .enter: return "enter"
            case .q: return "q"
            case .w: return "w"
            case .e: return "e"
            case .r: return "r"
            case .t: return "t"
            case .y: return "y"
            case .u: return "u"
            case .i: return "i"
            case .o: return "o"
            case .p: return "p"
            case .a: return "a"
            case .s: return "s"
            case .d: return "d"
            case .f: return "f"
            case .g: return "g"
            case .h: return "h"
            case .j: return "j"
            case .k: return "k"
            case .l: return "l"
            case .z: return "z"
            case .x: return "x"
            case .c: return "c"
            case .v: return "v"
            case .b: return "b"
            case .n: return "n"
            case .m: return "m"
            case .tab: return "tab"
            case .backspace: return "backspace"
            case .unknown: return "unknown"
            }
        }
    }
    
    public var key: Key {
        .parse(keyCode)
    }
}
#endif
#endif
