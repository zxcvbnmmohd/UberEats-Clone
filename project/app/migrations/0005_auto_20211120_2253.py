# Generated by Django 3.2.5 on 2021-11-20 22:53

import cloudinary.models
from django.db import migrations


class Migration(migrations.Migration):

    dependencies = [
        ('app', '0004_alter_business_logo'),
    ]

    operations = [
        migrations.AlterField(
            model_name='business',
            name='logo',
            field=cloudinary.models.CloudinaryField(max_length=255, verbose_name='image'),
        ),
        migrations.AlterField(
            model_name='item',
            name='image',
            field=cloudinary.models.CloudinaryField(max_length=255, verbose_name='image'),
        ),
    ]
