# -*- coding: utf-8 -*-
# Generated by Django 1.9.2 on 2016-06-12 22:03


from django.db import migrations, models


class Migration(migrations.Migration):

    initial = True

    dependencies = [
    ]

    operations = [
        migrations.CreateModel(
            name='GlobalSettings',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('mpc_points', models.PositiveSmallIntegerField()),
                ('mpci_points', models.PositiveSmallIntegerField()),
                ('mpcv_points', models.PositiveSmallIntegerField()),
                ('landmark_points', models.PositiveSmallIntegerField()),
                ('outline_points', models.PositiveSmallIntegerField()),
                ('outline_min_threshold', models.PositiveSmallIntegerField()),
                ('outline_max_threshold', models.PositiveSmallIntegerField()),
            ],
        ),
    ]
