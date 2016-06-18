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