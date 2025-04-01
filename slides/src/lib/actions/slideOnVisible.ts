
interface SlideParams {
    duration: number;
}

export function slideOnVisible(node: HTMLElement, params: SlideParams = { duration: 2000 }) {
    let observer: IntersectionObserver;

    function animate(isVisible: boolean) {
        const keyframes = isVisible
            ? [
                    { transform: 'translateY(100%)', opacity: 0 },
                    { transform: 'translateY(0)', opacity: 1 }
                ]
            : [
                    { transform: 'translateY(0)', opacity: 1 },
                    { transform: 'translateY(100%)', opacity: 0 }
                ];

        node.animate(keyframes, {
            duration: params.duration,
            easing: 'cubic-bezier(0.16, 1, 0.3, 1)'
        });
    }

    observer = new IntersectionObserver(
        (entries) => {
            entries.forEach((entry) => {
                animate(entry.isIntersecting);
            });
        },
        { threshold: 0.1 }
    );

    observer.observe(node);

    return {
        destroy() {
            observer?.disconnect();
        },
        update(newParams: SlideParams) {
            params = newParams;
        }
    };
}