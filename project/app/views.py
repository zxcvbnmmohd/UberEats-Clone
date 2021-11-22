from django.shortcuts import render, redirect
from django.contrib.auth import authenticate, login
from django.contrib.auth.decorators import login_required
from django.contrib.auth.models import User
from django.db.models import Sum, Count, Case, When
from app.forms import UserForm, BusinessForm, AccountForm, ItemForm
from app.models import Item, Order, Driver


def home(request):
    return redirect(business_home)


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


@login_required(login_url='/business/login/')
def business_account(request):
    if request.method == "POST":
        account_form = AccountForm(request.POST, instance=request.user)
        business_form = BusinessForm(
            request.POST, request.FILES, instance=request.user.business)

        if account_form.is_valid() and business_form.is_valid():
            account_form.save()
            business_form.save()

    account_form = AccountForm(instance=request.user)
    business_form = BusinessForm(instance=request.user.business)

    return render(request, 'business/account.html', {
        "account_form": account_form,
        "business_form": business_form
    })


@login_required(login_url='/business/login/')
def business_item(request):
    items = Item.objects.filter(
        business=request.user.business).order_by("-id")

    return render(request, 'business/item.html', {
        "items": items
    })


@login_required(login_url='/business/login/')
def business_add_item(request):

    if request.method == "POST":
        item_form = ItemForm(request.POST, request.FILES)

        if item_form.is_valid():
            item = item_form.save(commit=False)
            item.business = request.user.business
            item.save()
            return redirect(business_item)

    item_form = ItemForm()
    return render(request, 'business/add_item.html', {
        "item_form": item_form
    })


@login_required(login_url='/business/login/')
def business_edit_item(request, item_id):
    if request.method == "POST":
        item_form = ItemForm(request.POST, request.FILES,
                             instance=Item.objects.get(id=item_id))

        if item_form.is_valid():
            item_form.save()
            return redirect(business_item)

    item_form = ItemForm(instance=Item.objects.get(id=item_id))

    return render(request, 'business/edit_item.html', {
        "item_form": item_form
    })


@login_required(login_url='/business/login/')
def business_order(request):
    if request.method == "POST":
        order = Order.objects.get(id=request.POST["id"])

        if order.status == Order.PREPARING:
            order.status = Order.READY
            order.save()

    orders = Order.objects.filter(
        business=request.user.business).order_by("-id")

    return render(request, 'business/order.html', {
        "orders": orders
    })


@login_required(login_url='/business/login/')
def business_reports(request):
    from datetime import datetime, timedelta

    revenue = []
    orders = []
    today = datetime.now()
    current_weekdays = [
        today + timedelta(days=i) for i in range(0 - today.weekday(), 7 - today.weekday())]

    for day in current_weekdays:
        delivered_orders = Order.objects.filter(
            business=request.user.business,
            status=Order.DELIVERED,
            created_at__year=day.year,
            created_at__month=day.month,
            created_at__day=day.day,
        )

        revenue.append(sum(order.total for order in delivered_orders))
        orders.append(delivered_orders.count())

    top3_items = Item.objects.filter(business=request.user.business)\
        .annotate(total_order=Sum('orderdetails__quantity'))\
        .order_by("-total_order")[:3]

    item = {
        "labels": [item.name for item in top3_items],
        "data": [item.total_order or 0 for item in top3_items]
    }

    top3_drivers = Driver.objects.annotate(
        total_order=Count(
            Case(
                When(order__business=request.user.business, then=1)
            )
        )
    ).order_by("-total_order")[:3]

    driver = {
        "labels": [d.user.get_full_name() for d in top3_drivers],
        "data": [d.total_order for d in top3_drivers]
    }

    return render(request, 'business/report.html', {
        "revenue": revenue,
        "orders": orders,
        "item": item,
        "driver": driver,
    })
