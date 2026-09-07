#if os(macOS) || os(iOS) || os(tvOS)
public protocol ConstraintValue {
    var constraintValue: ConstraintValueType { get }
}
#endif
