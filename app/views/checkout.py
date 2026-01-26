import stripe
from decimal import Decimal
from django.conf import settings
from django.shortcuts import render, redirect, get_object_or_404
from django.urls import reverse
from django.contrib import messages
from django.http import HttpResponse
from django.views.decorators.csrf import csrf_exempt
from app.models import Order, OrderItem
from app.cart import Cart
from app.forms import OrderCreateForm

stripe.api_key = settings.STRIPE_SECRET_KEY


def order_create(request):
    cart = Cart(request)
    if not cart:
        return redirect("product_list")

    if request.method == "POST":
        form = OrderCreateForm(request.POST)
        if form.is_valid():
            order = form.save(commit=False)
            if request.user.is_authenticated:
                order.user = request.user
            order.save()
            for item in cart:
                OrderItem.objects.create(
                    order=order,
                    product=item["product"],
                    price=item["price"],
                    quantity=item["quantity"],
                )
            cart.clear()
            request.session["order_id"] = order.id
            return redirect("payment_process")
    else:
        initial_data = {}
        if request.user.is_authenticated:
            profile = request.user.profile
            initial_data = {
                "first_name": request.user.first_name,
                "last_name": request.user.last_name,
                "email": request.user.email,
                "address": profile.address,
                "postal_code": profile.postal_code,
                "city": profile.city,
                "country": profile.country,
            }
        form = OrderCreateForm(initial=initial_data)
    return render(request, "shop/order_create.html", {"cart": cart, "form": form})


def payment_process(request):
    order_id = request.session.get("order_id")
    if not order_id:
        return redirect("product_list")

    order = get_object_or_404(Order, id=order_id)

    # Security: Ensure user owns the order if logged in
    if order.user and order.user != request.user:
        return redirect("product_list")

    # Security: Prevent re-paying for already paid orders
    if order.paid:
        return redirect("payment_completed")

    if request.method == "POST":
        success_url = request.build_absolute_uri(reverse("payment_completed"))
        cancel_url = request.build_absolute_uri(reverse("payment_canceled"))

        session_data = {
            "mode": "payment",
            "client_reference_id": order.id,
            "success_url": success_url,
            "cancel_url": cancel_url,
            "line_items": [],
        }

        for item in order.items.all():
            session_data["line_items"].append(
                {
                    "price_data": {
                        "unit_amount": int(item.price * Decimal("100")),
                        "currency": "usd",
                        "product_data": {
                            "name": item.product.name,
                        },
                    },
                    "quantity": item.quantity,
                }
            )

        # Calculate shipping and tax based on the cart logic
        subtotal = sum(item.price * item.quantity for item in order.items.all())
        shipping_cost = Decimal("0.00")
        if subtotal < settings.FREE_SHIPPING_THRESHOLD:
            shipping_cost = Decimal(str(settings.SHIPPING_FLAT_RATE))

        tax = (
            (subtotal + shipping_cost) * Decimal(str(settings.ONTARIO_TAX_RATE))
        ).quantize(Decimal("0.01"))

        if shipping_cost > 0:
            session_data["line_items"].append(
                {
                    "price_data": {
                        "unit_amount": int(shipping_cost * Decimal("100")),
                        "currency": "usd",
                        "product_data": {
                            "name": "Shipping",
                        },
                    },
                    "quantity": 1,
                }
            )

        if tax > 0:
            session_data["line_items"].append(
                {
                    "price_data": {
                        "unit_amount": int(tax * Decimal("100")),
                        "currency": "usd",
                        "product_data": {
                            "name": "HST (13%)",
                        },
                    },
                    "quantity": 1,
                }
            )

        try:
            stripe_session = stripe.checkout.Session.create(**session_data)
            return redirect(stripe_session.url, code=303)
        except Exception as e:
            messages.error(
                request, "There was an error connecting to Stripe. Please try again."
            )
            return render(request, "shop/payment_process.html", {"order": order})
    else:
        return render(request, "shop/payment_process.html", {"order": order})


def payment_completed(request):
    if "order_id" in request.session:
        del request.session["order_id"]
    return render(request, "shop/payment_completed.html")


def payment_canceled(request):
    return render(request, "shop/payment_canceled.html")


@csrf_exempt
def stripe_webhook(request):
    payload = request.body
    sig_header = request.META.get("HTTP_STRIPE_SIGNATURE")
    event = None

    try:
        event = stripe.Webhook.construct_event(
            payload, sig_header, settings.STRIPE_WEBHOOK_SECRET
        )
    except ValueError as e:
        return HttpResponse(status=400)
    except stripe.error.SignatureVerificationError as e:
        return HttpResponse(status=400)

    if event["type"] == "checkout.session.completed":
        session = event["data"]["object"]
        if session.mode == "payment" and session.payment_status == "paid":
            try:
                order = Order.objects.get(id=session.client_reference_id)
            except Order.DoesNotExist:
                return HttpResponse(status=404)
            order.paid = True
            order.stripe_id = session.payment_intent
            order.save()

    return HttpResponse(status=200)
