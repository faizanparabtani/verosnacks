from decimal import Decimal
from django.conf import settings
from .models import Product

class Cart:
    def __init__(self, request):
        self.session = request.session
        cart = self.session.get(settings.CART_SESSION_ID)
        if not cart:
            cart = self.session[settings.CART_SESSION_ID] = {}
        self.cart = cart

    def add(self, product, quantity=1, override_quantity=False):
        product_id = str(product.id)
        # Security: Always fetch the latest price from DB, never trust session or input
        fresh_product = Product.objects.get(id=product.id)
        
        if product_id not in self.cart:
            self.cart[product_id] = {'quantity': 0, 'price': str(fresh_product.price)}
        
        # Update price anyway in case it changed in admin
        self.cart[product_id]['price'] = str(fresh_product.price)
        
        if override_quantity:
            self.cart[product_id]['quantity'] = quantity
        else:
            self.cart[product_id]['quantity'] += quantity
        self.save()

    def save(self):
        self.session.modified = True

    def remove(self, product):
        product_id = str(product.id)
        if product_id in self.cart:
            del self.cart[product_id]
            self.save()

    def __iter__(self):
        product_ids = self.cart.keys()
        products = Product.objects.filter(id__in=product_ids)
        cart = self.cart.copy()
        for product in products:
            cart[str(product.id)]['product'] = product

        for item in cart.values():
            item['price'] = Decimal(item['price'])
            item['total_price'] = item['price'] * item['quantity']
            yield item

    def __len__(self):
        return sum(item['quantity'] for item in self.cart.values())

    @property
    def get_subtotal(self):
        return sum(Decimal(item['price']) * item['quantity'] for item in self.cart.values())

    @property
    def get_shipping_cost(self):
        subtotal = self.get_subtotal
        if subtotal == 0:
            return Decimal('0.00')
        if subtotal >= settings.FREE_SHIPPING_THRESHOLD:
            return Decimal('0.00')
        return Decimal(str(settings.SHIPPING_FLAT_RATE))

    @property
    def get_tax(self):
        # HST in Ontario applies to both goods and shipping
        taxable_amount = self.get_subtotal + self.get_shipping_cost
        return (taxable_amount * Decimal(str(settings.ONTARIO_TAX_RATE))).quantize(Decimal('0.01'))

    @property
    def get_total_price(self):
        return self.get_subtotal + self.get_shipping_cost + self.get_tax

    def get_item_quantity(self, product_id):
        product_id = str(product_id)
        if product_id in self.cart:
            return self.cart[product_id]['quantity']
        return 0

    def clear(self):
        del self.session[settings.CART_SESSION_ID]
        self.save()