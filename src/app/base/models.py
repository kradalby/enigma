from django.db import models

class GlobalSettings(models.Model):
    mpc_points = models.PositiveSmallIntegerField(verbose_name="Points for multiple choice questions")
    mpci_points = models.PositiveSmallIntegerField(verbose_name="Points for multiple choice questions with image")
    mpcv_points = models.PositiveSmallIntegerField(verbose_name="Points for multiple choice questions with video")
    landmark_points = models.PositiveSmallIntegerField(verbose_name="Points for landmark questions")
    outline_points = models.PositiveSmallIntegerField(verbose_name="Maximum points for outline questions")
    outline_solution_points = models.PositiveSmallIntegerField(verbose_name="Points for outline solution questions")
    outline_min_threshold = models.PositiveSmallIntegerField(verbose_name="Outline minimum threshold")
    outline_max_threshold = models.PositiveSmallIntegerField(verbose_name="Outline maximum threshold")
    
try:
    global_settings = GlobalSettings.objects.all().first()
    if not global_settings:
        global_settings = GlobalSettings()
        global_settings.mpc_points = 1
        global_settings.mpci_points = 1
        global_settings.mpcv_points = 1
        global_settings.landmark_points = 1
        global_settings.outline_points = 1
        global_settings.outline_max_threshold = 5
        global_settings.outline_min_threshold = 5
        global_settings.outline_solution_points = 1
        global_settings.save()
except:
    pass