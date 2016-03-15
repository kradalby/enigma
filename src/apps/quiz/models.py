from django.db import models

class Question(models.Model):
    question = models.CharField(max_length = 255, verbose_name = "Question")
    correct_answer = models.CharField(max_length = 255, verbose_name = "Correct answer")
    wrong_answer_1 = models.CharField(max_length = 255, verbose_name = "Wrong answer")
    wrong_answer_2 = models.CharField(max_length = 255, verbose_name = "Wrong answer")
    
    def __str__(self):
        return self.question
        
    class Meta:
        ordering = ('question',)
    
class Questionnaire(models.Model):
    headline = models.CharField(max_length=255)
    questions = models.ManyToManyField(Question)
    
    def __str__(self):
        return self.headline
        
    class Meta:
        ordering = ('headline',)