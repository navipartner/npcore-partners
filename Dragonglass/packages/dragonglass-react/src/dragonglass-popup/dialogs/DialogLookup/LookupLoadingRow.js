import React, { useEffect, useRef } from "react";

export const LookupLoadingRow = props => {
    const { root, refresh } = props;

    const observer = root.current && new IntersectionObserver(
        entries => {
            if (entries.length && entries[0] && entries[0].isIntersecting)
                refresh();
        },
        {
            root: root.current,
            rootMargin: "0px",
            threshold: 0.0
        });

    const dom = useRef(null);

    useEffect(() => {
        if (observer && dom.current) {
            observer.observe(dom.current);
        }

        return () => {
            if (observer && dom.current) {
                observer.unobserve(dom.current);
            }
        };
    });

    return <div ref={dom} className="lookup-loading"><span>Loading...</span><div className="lookup-loading__icon fa fa-spinner"></div></div>
}
