from rest_framework import serializers
from app.models import Business, Item, Customer, Driver, Order, OrderDetails

class BusinessSerializer(serializers.ModelSerializer):
  logo = serializers.SerializerMethodField()

  def get_logo(self, business):
    request = self.context.get('request')
    logo_url = business.logo.url
    return request.build_absolute_uri(logo_url)

  class Meta:
    model = Business
    fields = ("id", "name", "phone", "address", "logo")


class ItemSerializer(serializers.ModelSerializer):
  image = serializers.SerializerMethodField()

  def get_image(self, business):
    request = self.context.get('request')
    image_url = business.image.url
    return request.build_absolute_uri(image_url)

  class Meta:
    model = Item
    fields = ("id", "name", "description", "image", "price")


# ORDER SERIALIZER

class OrderCustomerSerializer(serializers.ModelSerializer):
  name = serializers.ReadOnlyField(source="user.get_full_name")

  class Meta:
    model = Customer
    fields = ("id", "name", "avatar", "address")


class OrderDriverSerializer(serializers.ModelSerializer):
  name = serializers.ReadOnlyField(source="user.get_full_name")

  class Meta:
    model = Driver
    fields = ("id", "name", "avatar", "car_model", "plate_number")

class OrderBusinessSerializer(serializers.ModelSerializer):
  class Meta:
    model = Business
    fields = ("id", "name", "phone", "address")

class OrderItemSerializer(serializers.ModelSerializer):
  class Meta:
    model = Item
    fields = ("id", "name", "price")

class OrderDetailsSerializer(serializers.ModelSerializer):
  item = OrderItemSerializer()
  class Meta:
    model = OrderDetails
    fields = ("id", "item", "quantity", "sub_total")

class OrderSerializer(serializers.ModelSerializer):
  customer = OrderCustomerSerializer()
  driver = OrderDriverSerializer()
  business = OrderBusinessSerializer()
  order_details = OrderDetailsSerializer(many=True)
  status = serializers.ReadOnlyField(source="get_status_display")

  class Meta:
    model = Order
    fields = ("id", "customer", "business", "driver", "order_details", "total", "status", "address")

class OrderStatusSerializer(serializers.ModelSerializer):
  status = serializers.ReadOnlyField(source="get_status_display")

  class Meta:
    model = Order
    fields = ("id", "status")
