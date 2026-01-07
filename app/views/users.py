from django.shortcuts import render, redirect, get_object_or_404
from django.contrib.auth.decorators import login_required
from django.contrib.auth import login
from django.contrib import messages
from app.models import Product, Review, Order
from app.forms import UserRegistrationForm, UserEditForm, ProfileEditForm

@login_required
def order_list(request):
    orders = Order.objects.filter(user=request.user, paid=True)
    return render(request, 'account/order_list.html', {'orders': orders})

def register(request):
    if request.method == 'POST':
        user_form = UserRegistrationForm(request.POST)
        if user_form.is_valid():
            new_user = user_form.save(commit=False)
            new_user.set_password(user_form.cleaned_data['password'])
            new_user.save()
            login(request, new_user)
            return render(request, 'account/register_done.html', {'new_user': new_user})
    else:
        user_form = UserRegistrationForm()
    return render(request, 'account/register.html', {'user_form': user_form})

@login_required
def profile_edit(request):
    if request.method == 'POST':
        user_form = UserEditForm(instance=request.user, data=request.POST)
        profile_form = ProfileEditForm(instance=request.user.profile, data=request.POST)
        if user_form.is_valid() and profile_form.is_valid():
            user_form.save()
            profile_form.save()
            messages.success(request, 'Profile updated successfully')
            return redirect('profile_edit')
    else:
        user_form = UserEditForm(instance=request.user)
        profile_form = ProfileEditForm(instance=request.user.profile)
    
    # Get unique addresses from previous orders
    try:
        saved_addresses = Order.objects.filter(user=request.user).values(
            'address', 'city', 'postal_code', 'country'
        ).distinct()
    except Exception:
        saved_addresses = []

    return render(request, 'account/profile_edit.html', {
        'user_form': user_form,
        'profile_form': profile_form,
        'saved_addresses': saved_addresses
    })

@login_required
def add_review(request, product_id):
    product = get_object_or_404(Product, id=product_id)
    
    # Check if user has purchased the product
    has_purchased = Order.objects.filter(
        user=request.user, 
        paid=True, 
        items__product=product
    ).exists()
    
    if not has_purchased:
        messages.error(request, "You can only review products you have purchased.")
        return redirect('product_detail', id=product.id, slug=product.slug)

    if request.method == 'POST':
        rating = request.POST.get('rating', 5)
        comment = request.POST.get('comment')
        Review.objects.create(
            product=product,
            user=request.user,
            rating=rating,
            comment=comment
        )
        messages.success(request, "Thank you for your review!")
    return redirect('product_detail', id=product.id, slug=product.slug)
