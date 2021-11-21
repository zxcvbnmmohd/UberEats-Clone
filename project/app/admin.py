from django.contrib import admin
from app.models import Business, Customer, Driver, Item, Order, OrderDetails

# Register your models here
admin.site.register(Business)
admin.site.register(Customer)
admin.site.register(Driver)
admin.site.register(Item)
admin.site.register(Order)
admin.site.register(OrderDetails)