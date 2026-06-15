@MainActor
public protocol Refreshable: AnyObject {
    func refresh()
}

extension Refreshable {
    // MARK: Reaction on @State
    
    @discardableResult
    public func react<A>(to a: State<A>) -> Self {
        a.listen { [weak self] _, _ in self?.refresh() }
            .holdIfOwned(by: self)
        return self
    }
    
    @discardableResult
    public func react<A, B>(to a: State<A>, _ b: State<B>) -> Self {
        a.listen { [weak self] _, _ in self?.refresh() }
            .holdIfOwned(by: self)
        b.listen { [weak self] _, _ in self?.refresh() }
            .holdIfOwned(by: self)
        return self
    }
    
    @discardableResult
    public func react<A, B, C>(to a: State<A>, _ b: State<B>, _ c: State<C>) -> Self {
        a.listen { [weak self] _, _ in self?.refresh() }
            .holdIfOwned(by: self)
        b.listen { [weak self] _, _ in self?.refresh() }
            .holdIfOwned(by: self)
        c.listen { [weak self] _, _ in self?.refresh() }
            .holdIfOwned(by: self)
        return self
    }
    
    @discardableResult
    public func react<A, B, C, D>(to a: State<A>, _ b: State<B>, _ c: State<C>, _ d: State<D>) -> Self {
        a.listen { [weak self] _, _ in self?.refresh() }
            .holdIfOwned(by: self)
        b.listen { [weak self] _, _ in self?.refresh() }
            .holdIfOwned(by: self)
        c.listen { [weak self] _, _ in self?.refresh() }
            .holdIfOwned(by: self)
        d.listen { [weak self] _, _ in self?.refresh() }
            .holdIfOwned(by: self)
        return self
    }
    
    @discardableResult
    public func react<A, B, C, D, E>(to a: State<A>, _ b: State<B>, _ c: State<C>, _ d: State<D>, _ e: State<E>) -> Self {
        a.listen { [weak self] _, _ in self?.refresh() }
            .holdIfOwned(by: self)
        b.listen { [weak self] _, _ in self?.refresh() }
            .holdIfOwned(by: self)
        c.listen { [weak self] _, _ in self?.refresh() }
            .holdIfOwned(by: self)
        d.listen { [weak self] _, _ in self?.refresh() }
            .holdIfOwned(by: self)
        e.listen { [weak self] _, _ in self?.refresh() }
            .holdIfOwned(by: self)
        return self
    }
}
