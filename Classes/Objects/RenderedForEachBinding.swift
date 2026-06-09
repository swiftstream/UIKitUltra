final class RenderedForEachBinding {
    let forEach: AnyForEach

    init(_ forEach: AnyForEach) {
        self.forEach = forEach
    }
}

extension DeclarativeProtocolInternal {
    func retainRenderedForEachBinding(_ binding: RenderedForEachBinding) {
        _properties.renderedForEachBindings.append(binding)
    }
}
