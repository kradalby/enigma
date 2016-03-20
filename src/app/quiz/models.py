from django.db import models

class TestUnit(models.Model):
    question = models.CharField(max_length = 255, verbose_name = "Question", blank = True)
    
    def __str__(self):
        return self.question
        
    class Meta:
        ordering = ('question',)
    
class MultipleChoiceQuestion(TestUnit):
    correct_answer = models.CharField(max_length = 255, verbose_name = "Correct answer")
    wrong_answer_1 = models.CharField(max_length = 255, verbose_name = "Wrong answer")
    wrong_answer_2 = models.CharField(max_length = 255, verbose_name = "Wrong answer")

def image_directory_path(instance, filename):
    return 'upload/quiz/{0}/{1}'.format(instance.id, filename)
    
class MultipleChoiceQuestionWithImage(MultipleChoiceQuestion):
    image = models.ImageField(upload_to=image_directory_path)
    
class LandmarkQuestion(TestUnit):
    original_image = models.ImageField(upload_to=image_directory_path)
    landmark_drawing = models.ImageField(upload_to=image_directory_path)
    
class Test(models.Model):
    headline = models.CharField(max_length=255)
    multiple_choice_questions = models.ManyToManyField(MultipleChoiceQuestion, related_name="multiple_choice_questions")
    multiple_choice_questions_with_image = models.ManyToManyField(MultipleChoiceQuestionWithImage, related_name="multiple_choice_questions_with_image")
    landmark_questions = models.ManyToManyField(LandmarkQuestion, related_name="landmark_questions")
    
    def __str__(self):
        return self.headline
        
    class Meta:
        ordering = ('headline',)