#if os(macOS) || os(iOS) || os(tvOS)
//
//  Spoken.swift
//  UIKit-Plus
//
//  Created by Mihael Isaev on 31.03.2020.
//

import Foundation

public protocol SpokenNumberable {
    func spoken(one: String) -> String
    func spoken(one: String, two: String) -> String
    func spoken(one: String, ten: String) -> String
    func spoken(one: String, two: String?, ten: String?) -> String
    func spoken(_ type: SpokenNumber) -> String
}

extension SpokenNumberable {
    public func spoken(one: String) -> String {
        spoken(one: one, two: nil, ten: nil)
    }
    
    public func spoken(one: String, two: String) -> String {
        spoken(one: one, two: two, ten: nil)
    }
    
    public func spoken(one: String, ten: String) -> String {
        spoken(one: one, two: nil, ten: ten)
    }
    
    public func spoken(one: String, two: String?, ten: String?) -> String {
        spoken(.init(one: one, two: two, ten: ten))
    }
}

public struct SpokenNumber {
    let one, two, ten: String
    
    public init (one: String, many: String) {
        self.one = one
        self.two = many
        self.ten = many
    }
    
    public init (one: String, two: String? = nil, ten: String? = nil) {
        self.one = one
        self.two = two ?? ten ?? one
        self.ten = ten ?? two ?? one
    }
    
    func result(_ num: Int) -> String {
        result(Double(num))
    }
    
    func result(_ num: Int64) -> String {
        result(Double(num))
    }
    
    func result(_ num: Double) -> String {
        let d = num
        let s = d.rounded()
        let y = s.truncatingRemainder(dividingBy: 10)
        let x = s / 10.truncatingRemainder(dividingBy: 10)
        if x == 1 {
            return ten
        }
        if y == 1 {
            return one
        }
        if let _ = [2, 3, 4].firstIndex(of: y) {
            return two
        }
        return ten
    }
}

extension Double: SpokenNumberable {
    public func spoken(_ type: SpokenNumber) -> String {
        type.result(self)
    }
}

extension Int: SpokenNumberable {
    public func spoken(_ type: SpokenNumber) -> String {
        type.result(self)
    }
}

extension Int64: SpokenNumberable {
    public func spoken(_ type: SpokenNumber) -> String {
        type.result(self)
    }
}
#endif
