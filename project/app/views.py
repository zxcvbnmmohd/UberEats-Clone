from django.shortcuts import render
from django.contrib.auth import authenticate, login
from django.contrib.auth.decorators import login_required
from django.contrib.auth.models import User
from app.forms import UserForm, BusinessForm


def home(request):
    return render(request, 'home.html', {})


@login_required(login_url='/business/login/')
def business_home(request):
    return render(request, 'business/home.html', {})


def business_register(request):
    user_form = UserForm()
    business_form = BusinessForm()

    if request.method == "POST":
        user_form = UserForm(request.POST)
        business_form = BusinessForm(request.POST, request.FILES)

    if user_form.is_valid() and business_form.is_valid():
        new_user = User.objects.create_user(**user_form.cleaned_data)
        new_business = business_form.save(commit=False)
        new_business.user = new_user
        new_business.save()

        login(request, authenticate(
            username=user_form.cleaned_data["username"],
            password=user_form.cleaned_data["password"]
        ))

        return redirect(business_home)

    return render(request, 'business/register.html', {
        "user_form": user_form,
        "business_form": business_form
    })