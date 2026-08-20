from django.shortcuts import render, get_object_or_404, redirect
from django.contrib import messages
from django.db import models
from app.models import Category, Product, Testimonial, Order, ContactInquiry
from app.forms import CartAddProductForm

def index(request):
    products = Product.objects.filter(available=True)[:4]
    testimonials = Testimonial.objects.filter(active=True)[:3]
    return render(request, 'app/index.html', {
        'products': products,
        'testimonials': testimonials
    })

def product_list(request, category_slug=None):
    category = None
    categories = Category.objects.all()
    products = Product.objects.filter(available=True)
    if category_slug:
        category = get_object_or_404(Category, slug=category_slug)
        products = products.filter(category=category)
    return render(request, 'shop/product_list.html', {
        'category': category,
        'categories': categories,
        'products': products
    })

def product_detail(request, id, slug):
    product = get_object_or_404(Product, id=id, slug=slug, available=True)
    cart_product_form = CartAddProductForm()
    reviews = product.reviews.all()
    
    can_review = False
    if request.user.is_authenticated:
        can_review = Order.objects.filter(
            user=request.user, 
            paid=True, 
            items__product=product
        ).exists()
        
    return render(request, 'shop/product_detail.html', {
        'product': product,
        'cart_product_form': cart_product_form,
        'reviews': reviews,
        'can_review': can_review
    })

def search(request):
    query = request.GET.get('q')
    products = []
    if query:
        products = Product.objects.filter(
            models.Q(name__icontains=query) | 
            models.Q(description__icontains=query),
            available=True
        )
    return render(request, 'shop/product_list.html', {
        'products': products,
        'query': query,
        'categories': Category.objects.all()
    })

def our_story(request):
    return render(request, 'app/our_story.html')

def contact(request):
    if request.method == 'POST':
        name = request.POST.get('name', '').strip()
        email = request.POST.get('email', '').strip()
        message = request.POST.get('message', '').strip()
        if name and email and message:
            ContactInquiry.objects.create(name=name, email=email, message=message)
            messages.success(request, 'Your message has been sent! We\'ll get back to you soon.')
            return redirect('contact')
        else:
            messages.error(request, 'Please fill in all fields.')
    return render(request, 'app/contact.html')
