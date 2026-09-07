#if os(macOS) || os(iOS) || os(tvOS)
//
//  GesturesBuilder.swift
//  UIKit-Plus
//
//  Created by Mihael Isaev on 17.04.2020.
//

import Foundation

@resultBuilder public struct GesturesBuilder {
    public typealias Block = () -> GesturesBuilderItem
    
    /// Builds an empty preview from an block containing no statements, `{ }`.
    public static func buildBlock() -> GesturesBuilderItem { [] }
    
    /// Passes a single preview written as a child view (e..g, `{ Text("Hello") }`) through unmodified.
    @MainActor
    public static func buildBlock(_ attrs: GesturesBuilderItem...) -> GesturesBuilderItem {
        buildBlock(attrs)
    }
    
    /// Passes a single preview written as a child view (e..g, `{ Text("Hello") }`) through unmodified.
    @MainActor
    public static func buildBlock(_ attrs: [GesturesBuilderItem]) -> GesturesBuilderItem {
        attrs.flatMap { $0.gestureRecognizers }
    }
    
    /// Provides support for "if" statements in multi-statement closures, producing an `Optional` preview
    /// that is visible only when the `if` condition evaluates `true`.
    public static func buildIf(_ content: GesturesBuilderItem?) -> GesturesBuilderItem {
        guard let content = content else { return [] }
        return content
    }
    
    /// Provides support for "if" statements in multi-statement closures, producing
    /// ConditionalContent for the "then" branch.
    public static func buildEither(first: GesturesBuilderItem) -> GesturesBuilderItem {
        first
    }

    /// Provides support for "if-else" statements in multi-statement closures, producing
    /// ConditionalContent for the "else" branch.
    public static func buildEither(second: GesturesBuilderItem) -> GesturesBuilderItem {
        second
    }
}

@MainActor
public protocol GesturesBuilderItem {
    var gestureRecognizers: [UGestureRecognizer] { get }
}

extension UGestureRecognizer: GesturesBuilderItem {
    public var gestureRecognizers: [UGestureRecognizer] { [self] }
}

extension Array: GesturesBuilderItem where Element: UGestureRecognizer {
    public var gestureRecognizers: [UGestureRecognizer] { self }
}
#endif
