# -*- coding: utf-8 -*-
# Generated by Django 1.9.2 on 2016-06-12 22:55


from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('quiz', '0004_auto_20160606_2014'),
    ]

    operations = [
        migrations.AddField(
            model_name='testunitresult',
            name='score',
            field=models.PositiveSmallIntegerField(default=0),
            preserve_default=False,
        ),
    ]
