# Generated by Django 3.2.5 on 2021-11-20 22:43

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('app', '0002_auto_20211120_2137'),
    ]

    operations = [
        migrations.AlterField(
            model_name='business',
            name='logo',
            field=models.CharField(blank=True, max_length=255),
        ),
    ]