from django.shortcuts import render
from django.contrib.auth.decorators import login_required
from app.forms import UserForm, BusinessForm
import pyrebase

firebaseConfig = {
    "apiKey": "AIzaSyAdG5AtZlsqQ4ha6BlsAHETIpoIQjjUQ1s",
    "authDomain": "ubereats-b4011.firebaseapp.com",
    "projectId": "ubereats-b4011",
    "storageBucket": "ubereats-b4011.appspot.com",
    "messagingSenderId": "1003457484258",
    "appId": "1:1003457484258:web:39cbcea1c240b8174215bb",
    "measurementId": "G-NSZ7TRFTZM",
    "databaseURL": "",
}

firebase = pyrebase.initialize_app(firebaseConfig)
storage = firebase.storage()

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
      new_restaurant = business_form.save(commit=False)
      new_restaurant.user = new_user
      new_restaurant.save()

      login(request, authenticate(
        username=user_form.cleaned_data["username"],
        password=user_form.cleaned_data["password"]
      ))

      return redirect(restaurant_home)

    return render(request, 'business/register.html', {
        "user_form": user_form,
        "business_form": business_form
    })