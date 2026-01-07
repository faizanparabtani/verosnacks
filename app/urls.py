from django.urls import path
from django.contrib.auth import views as auth_views
from . import views

urlpatterns = [
    # Core & Shop
    path('', views.index, name='index'),
    path('our-story/', views.our_story, name='our_story'),
    path('contact/', views.contact, name='contact'),
    path('shop/', views.product_list, name='product_list'),
    path('shop/search/', views.search, name='search'),
    path('shop/<slug:category_slug>/', views.product_list, name='product_list_by_category'),
    path('product/<int:id>/<slug:slug>/', views.product_detail, name='product_detail'),
    
    # Cart
    path('cart/', views.cart_detail, name='cart_detail'),
    path('cart/add/<int:product_id>/', views.cart_add, name='cart_add'),
    path('cart/update/<int:product_id>/', views.cart_update, name='cart_update'),
    path('cart/remove/<int:product_id>/', views.cart_remove, name='cart_remove'),
    
    # Checkout & Payments
    path('order/create/', views.order_create, name='order_create'),
    path('payment/process/', views.payment_process, name='payment_process'),
    path('payment/completed/', views.payment_completed, name='payment_completed'),
    path('payment/canceled/', views.payment_canceled, name='payment_canceled'),
    path('webhook/', views.stripe_webhook, name='stripe_webhook'),
    
    # User Accounts & Reviews
    path('login/', auth_views.LoginView.as_view(template_name='account/login.html'), name='login'),
    path('register/', views.register, name='register'),
    path('profile/orders/', views.order_list, name='order_list'),
    path('profile/edit/', views.profile_edit, name='profile_edit'),
    path('product/<int:product_id>/review/', views.add_review, name='add_review'),
]