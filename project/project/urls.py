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
from app import views, apis

urlpatterns = [
    # Paths
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
    path('api/business/order/notification/<last_request_time>/', apis.business_order_notification),
    
     # APIS for CUSTOMERS
    path('api/customer/businesses/', apis.customer_get_businesses),
    path('api/customer/items/<int:business_id>', apis.customer_get_items),
    path('api/customer/order/add/', apis.customer_add_order),
    path('api/customer/order/latest/', apis.customer_get_latest_order),
    path('api/customer/order/latest_status/', apis.customer_get_latest_order_status),
    path('api/customer/driver/location/', apis.customer_get_driver_location),
    path('api/customer/payment_intent/', apis.create_payment_intent),

    # APIS for DRIVERS
    path('api/driver/order/ready/', apis.driver_get_ready_orders),
    path('api/driver/order/pick/', apis.driver_pick_order),
    path('api/driver/order/latest/', apis.driver_get_latest_order),
    path('api/driver/order/complete/', apis.driver_complete_order),
    path('api/driver/revenue/', apis.driver_get_revenue),
    path('api/driver/location/update/', apis.driver_update_location),
    path('api/driver/profile/', apis.driver_get_profile),
    path('api/driver/profile/update/', apis.driver_update_profile),
]
