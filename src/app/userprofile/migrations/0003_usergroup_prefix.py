# -*- coding: utf-8 -*-
# Generated by Django 1.9.2 on 2016-06-12 23:59


from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('userprofile', '0002_userprofile_autogenerated'),
    ]

    operations = [
        migrations.AddField(
            model_name='usergroup',
            name='prefix',
            field=models.CharField(blank=True, max_length=255, null=True),
        ),
    ]
