@MainActor
public func +(lhs: AttrStr, rhs: AttrStr) -> AttrStr {
    let attrStr = AttrStr("")
    attrStr._attributedString.append(lhs._attributedString)
    attrStr._attributedString.append(rhs._attributedString)
    return attrStr
}
