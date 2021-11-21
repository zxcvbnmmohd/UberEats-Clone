"""project URL Configuration

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/3.2/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""
from django.contrib import admin
from django.urls import path, include
from django.contrib.auth import views as auth_views
from app import views

urlpatterns = [
    path('admin/', admin.site.urls),
    path('', views.home, name='home'),
    
    path('business/', views.business_home, name='business_home'),
    path('business/register/', views.business_register, name='business_register'),
    path('business/login/', auth_views.LoginView.as_view(template_name='business/login.html'), name='business_login'),
    path('business/logout/', auth_views.LogoutView.as_view(next_page='business/'), name='business_logout'),
    
    path('business/account/', views.business_account, name='business_account'),
    path('business/item/', views.business_item, name='business_item'),
    path('business/item/add', views.business_add_item, name='business_add_item'),
    path('business/item/edit/<int:item_id>', views.business_edit_item, name='business_edit_item'),
    path('business/order/', views.business_order, name='business_order'),
    path('business/reports/', views.business_reports, name='business_reports'),
    
    # APIs
    path('api/social', include('rest_framework_social_oauth2.urls')),
]
