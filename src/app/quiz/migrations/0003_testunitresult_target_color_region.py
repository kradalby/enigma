# -*- coding: utf-8 -*-
# Generated by Django 1.9.2 on 2016-06-05 22:38
from __future__ import unicode_literals

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('quiz', '0002_auto_20160531_2224'),
    ]

    operations = [
        migrations.AddField(
            model_name='testunitresult',
            name='target_color_region',
            field=models.CharField(default='', max_length=255),
            preserve_default=False,
        ),
    ]
