from django.shortcuts import render
from django.contrib.auth.decorators import login_required
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

# Create your views here.

def home(request):
    return render(request, 'home.html', {})

@login_required(login_url='/business/login/')
def business_home(request):
    return render(request, 'business/home.html', {})
