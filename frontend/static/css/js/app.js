document.addEventListener('DOMContentLoaded', function () {
    const hamburgerBtn = document.getElementById('hamburger');
    const mobileMenu = document.getElementById('mobile-menu');
    const openIcon = document.getElementById('hamburger-open');
    const closeIcon = document.getElementById('hamburger-close');

    hamburgerBtn.addEventListener('click', function () {
        mobileMenu.classList.toggle('hidden');
        openIcon.classList.toggle('hidden');
        closeIcon.classList.toggle('hidden');
    });
});

function initOfferSwiper() {
    if (typeof Swiper === "undefined") return;

    const swiper = new Swiper(".offer-swiper", {
        slidesPerView: 1,
        loop: true,
        speed: 800,
        centeredSlides: true,
        allowTouchMove: false, // text isn't swipeable like a carousel
        autoplay: {
            delay: 2200,
            disableOnInteraction: false,
            pauseOnMouseEnter: false,
        },
        effect: "slide",

        watchOverflow: true,
        observer: true,
        observeParents: true,
    });

    return swiper;
}

document.addEventListener("DOMContentLoaded", initOfferSwiper);
