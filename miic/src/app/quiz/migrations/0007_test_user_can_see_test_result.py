# -*- coding: utf-8 -*-
# Generated by Django 1.9.2 on 2016-06-13 20:11


from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('quiz', '0006_testunitresult_max_score'),
    ]

    operations = [
        migrations.AddField(
            model_name='test',
            name='user_can_see_test_result',
            field=models.BooleanField(default=False),
        ),
    ]