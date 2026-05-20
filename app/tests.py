from decimal import Decimal

from django.contrib.auth.models import User
from django.test import Client, TestCase
from django.urls import reverse

from app.models import Category, Order, OrderItem, Product


class CategoryModelTest(TestCase):
    def setUp(self):
        self.category = Category.objects.create(name="Chips", slug="chips")

    def test_str(self):
        self.assertEqual(str(self.category), "Chips")

    def test_default_ordering_is_alphabetical(self):
        Category.objects.create(name="Nuts", slug="nuts")
        Category.objects.create(name="Bars", slug="bars")
        names = list(Category.objects.values_list("name", flat=True))
        self.assertEqual(names, sorted(names))


class ProductModelTest(TestCase):
    def setUp(self):
        category = Category.objects.create(name="Chips", slug="chips")
        self.product = Product.objects.create(
            category=category,
            name="Sea Salt Chips",
            slug="sea-salt-chips",
            price=Decimal("4.99"),
            available=True,
        )

    def test_str(self):
        self.assertEqual(str(self.product), "Sea Salt Chips")

    def test_available_defaults_to_true(self):
        self.assertTrue(self.product.available)


class OrderModelTest(TestCase):
    def setUp(self):
        category = Category.objects.create(name="Chips", slug="chips")
        product = Product.objects.create(
            category=category,
            name="Sea Salt Chips",
            slug="sea-salt-chips",
            price=Decimal("4.99"),
            available=True,
        )
        self.order = Order.objects.create(
            first_name="Jane",
            last_name="Doe",
            email="jane@example.com",
            address="123 Main St",
            postal_code="M5V 1A1",
            city="Toronto",
        )
        OrderItem.objects.create(
            order=self.order,
            product=product,
            price=Decimal("4.99"),
            quantity=2,
        )

    def test_str(self):
        self.assertEqual(str(self.order), f"Order {self.order.id}")

    def test_get_total_cost(self):
        self.assertEqual(self.order.get_total_cost(), Decimal("9.98"))

    def test_paid_defaults_to_false(self):
        self.assertFalse(self.order.paid)


class OrderItemTest(TestCase):
    def setUp(self):
        category = Category.objects.create(name="Chips", slug="chips")
        product = Product.objects.create(
            category=category,
            name="Sea Salt Chips",
            slug="sea-salt-chips",
            price=Decimal("4.99"),
            available=True,
        )
        order = Order.objects.create(
            first_name="Jane",
            last_name="Doe",
            email="jane@example.com",
            address="123 Main St",
            postal_code="M5V 1A1",
            city="Toronto",
        )
        self.item = OrderItem.objects.create(
            order=order,
            product=product,
            price=Decimal("4.99"),
            quantity=3,
        )

    def test_get_cost(self):
        self.assertEqual(self.item.get_cost(), Decimal("14.97"))


class ProfileSignalTest(TestCase):
    def test_profile_auto_created_on_user_creation(self):
        user = User.objects.create_user(username="testuser", password="pass")
        self.assertTrue(hasattr(user, "profile"))
        self.assertEqual(user.profile.user, user)


class ShopViewTest(TestCase):
    def setUp(self):
        self.client = Client()
        category = Category.objects.create(name="Chips", slug="chips")
        self.product = Product.objects.create(
            category=category,
            name="Sea Salt Chips",
            slug="sea-salt-chips",
            price=Decimal("4.99"),
            available=True,
        )

    def test_product_list(self):
        response = self.client.get(reverse("product_list"))
        self.assertEqual(response.status_code, 200)
        self.assertIn(self.product, response.context["products"])

    def test_product_list_filtered_by_category(self):
        response = self.client.get(
            reverse("product_list_by_category", args=["chips"])
        )
        self.assertEqual(response.status_code, 200)
        self.assertIn(self.product, response.context["products"])

    def test_product_list_by_unknown_category_returns_404(self):
        response = self.client.get(
            reverse("product_list_by_category", args=["does-not-exist"])
        )
        self.assertEqual(response.status_code, 404)

    def test_product_detail(self):
        response = self.client.get(
            reverse("product_detail", args=[self.product.id, self.product.slug])
        )
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.context["product"], self.product)

    def test_product_detail_unavailable_returns_404(self):
        self.product.available = False
        self.product.save()
        response = self.client.get(
            reverse("product_detail", args=[self.product.id, self.product.slug])
        )
        self.assertEqual(response.status_code, 404)

    def test_search_returns_matching_products(self):
        response = self.client.get(reverse("search"), {"q": "salt"})
        self.assertEqual(response.status_code, 200)
        self.assertIn(self.product, response.context["products"])

    def test_search_with_no_query_returns_empty(self):
        response = self.client.get(reverse("search"))
        self.assertEqual(response.status_code, 200)
        self.assertEqual(list(response.context["products"]), [])
