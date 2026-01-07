from django import forms
from django.db import models
from django.contrib.auth.models import User
from .models import Profile, Order

class CartAddProductForm(forms.Form):
    quantity = forms.TypedChoiceField(choices=[(i, str(i)) for i in range(1, 21)], coerce=int)
    override = forms.BooleanField(required=False, initial=False, widget=forms.HiddenInput)

class UserRegistrationForm(forms.ModelForm):
    password = forms.CharField(widget=forms.PasswordInput)
    password_confirm = forms.CharField(widget=forms.PasswordInput, label="Confirm password")

    class Meta:
        model = User
        fields = ['username', 'email']

    def clean_password_confirm(self):
        cd = self.cleaned_data
        if cd['password'] != cd['password_confirm']:
            raise forms.ValidationError('Passwords don\'t match.')
        return cd['password_confirm']

class UserEditForm(forms.ModelForm):
    class Meta:
        model = User
        fields = ['first_name', 'last_name', 'email']

class ProfileEditForm(forms.ModelForm):
    class Meta:
        model = Profile
        fields = ['address', 'city', 'postal_code', 'country', 'phone']

class OrderCreateForm(forms.ModelForm):
    class Meta:
        model = Order
        fields = ['first_name', 'last_name', 'email', 'address', 'postal_code', 'city', 'country']

