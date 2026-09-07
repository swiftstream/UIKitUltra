#if os(macOS) || os(iOS) || os(tvOS)
//
//  StackForEach.swift
//  UIKit-Plus
//
//  Created by Mihael Isaev on 01.01.2020.
//

protocol StackForEach {
    func subscribeToChanges(_ handler: @escaping (_ old: [Any], _ new: [Any], _ deletions: [Int], _ insertions: [Int], _ reloads: [Int]) -> Void)
}

#endif
