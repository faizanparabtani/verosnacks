// Force refresh on back-button navigation
window.onpageshow = function(event) {
    if (event.persisted || (window.performance && window.performance.navigation.type === 2)) {
        window.location.reload();
    }
};

document.addEventListener('DOMContentLoaded', function () {
    const hamburgerBtn = document.getElementById('hamburger');
    const mobileMenu = document.getElementById('mobile-menu');

    if (hamburgerBtn && mobileMenu) {
        hamburgerBtn.onclick = function () {
            // Toggle classes
            this.classList.toggle('is-active');
            mobileMenu.classList.toggle('menu-open');
        };
    }

    initOfferSwiper();
    initToasts();
});

function toggleMobileSearch() {
    const overlay = document.getElementById('mobile-search-overlay');
    if (overlay) {
        overlay.classList.toggle('hidden');
    }
}

function initToasts() {
    const toasts = document.querySelectorAll('.toast-message');
    toasts.forEach((toast, index) => {
        // Animate in with staggered delay
        setTimeout(() => {
            toast.classList.remove('translate-x-12', 'opacity-0');
        }, 100 + (index * 150));

        // Auto dismiss after 5 seconds
        setTimeout(() => {
            dismissToast(toast);
        }, 5000 + (index * 1000));
        
        const closeBtn = toast.querySelector('.dismiss-toast');
        if (closeBtn) {
            closeBtn.onclick = () => dismissToast(toast);
        }
    });
}

function dismissToast(element) {
    if (!element) return;
    element.classList.add('translate-x-12', 'opacity-0');
    setTimeout(() => {
        element.remove();
    }, 500);
}

function initOfferSwiper() {
    if (typeof Swiper === "undefined") return;
    new Swiper(".offer-swiper", {
        slidesPerView: 1,
        loop: true,
        speed: 800,
        autoplay: { delay: 2200 },
        effect: "slide",
    });
}
