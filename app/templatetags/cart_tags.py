from django import template

register = template.Library()

@register.filter
def get_quantity(cart, product_id):
    product_id = str(product_id)
    if product_id in cart.cart:
        return cart.cart[product_id]['quantity']
    return 0
