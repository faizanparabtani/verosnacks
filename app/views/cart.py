from django.shortcuts import render, redirect, get_object_or_404
from app.models import Product
from app.cart import Cart
from app.forms import CartAddProductForm


def cart_add(request, product_id):
    cart = Cart(request)
    product = get_object_or_404(Product, id=product_id)
    form = CartAddProductForm(request.POST)
    if form.is_valid():
        cd = form.cleaned_data
        quantity = max(1, min(int(cd["quantity"]), 10))
        cart.add(product=product, quantity=quantity, override_quantity=cd["override"])

    if request.headers.get("HX-Request"):
        # Return the button and trigger navbar/cart updates
        return render(
            request,
            "shop/partials/cart_item_added.html",
            {"product": product, "cart": cart},
        )
    return redirect("cart_detail")


def cart_detail(request):
    cart = Cart(request)
    return render(request, "shop/cart.html", {"cart": cart})


def cart_remove(request, product_id):
    cart = Cart(request)
    product = get_object_or_404(Product, id=product_id)
    cart.remove(product)

    if request.headers.get("HX-Request"):
        return render(
            request,
            "shop/partials/cart_updates.html",
            {"product": product, "cart": cart},
        )
    return redirect("cart_detail")


def cart_update(request, product_id):
    cart = Cart(request)
    product = get_object_or_404(Product, id=product_id)
    try:
        quantity = int(request.POST.get("quantity", 1))
        if quantity <= 0:
            cart.remove(product)
            # If quantity becomes 0, we treat it as a removal
            return render(
                request,
                "shop/partials/cart_item_update_zero.html",
                {"product": product, "cart": cart},
            )
        quantity = max(1, min(quantity, 10))
    except (ValueError, TypeError):
        quantity = 1

    cart.add(product=product, quantity=quantity, override_quantity=True)

    item_total = product.price * quantity

    return render(
        request,
        "shop/partials/cart_item_update.html",
        {"product": product, "item_total": item_total, "cart": cart},
    )
