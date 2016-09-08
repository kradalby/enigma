# -*- coding: utf-8 -*-
# Generated by Django 1.9.2 on 2016-06-12 22:55


from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('base', '0001_initial'),
    ]

    operations = [
        migrations.AlterField(
            model_name='globalsettings',
            name='landmark_points',
            field=models.PositiveSmallIntegerField(verbose_name='Points for landmark questions'),
        ),
        migrations.AlterField(
            model_name='globalsettings',
            name='mpc_points',
            field=models.PositiveSmallIntegerField(verbose_name='Points for multiple choice questions'),
        ),
        migrations.AlterField(
            model_name='globalsettings',
            name='mpci_points',
            field=models.PositiveSmallIntegerField(verbose_name='Points for multiple choice questions with image'),
        ),
        migrations.AlterField(
            model_name='globalsettings',
            name='mpcv_points',
            field=models.PositiveSmallIntegerField(verbose_name='Points for multiple choice questions with video'),
        ),
        migrations.AlterField(
            model_name='globalsettings',
            name='outline_max_threshold',
            field=models.PositiveSmallIntegerField(verbose_name='Outline maximum threshold'),
        ),
        migrations.AlterField(
            model_name='globalsettings',
            name='outline_min_threshold',
            field=models.PositiveSmallIntegerField(verbose_name='Outline minimum threshold'),
        ),
        migrations.AlterField(
            model_name='globalsettings',
            name='outline_points',
            field=models.PositiveSmallIntegerField(verbose_name='Maximum points for outline questions'),
        ),
    ]
