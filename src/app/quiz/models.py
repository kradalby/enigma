from django.db import models
from random import shuffle

class TestUnit(models.Model):
    question = models.CharField(max_length = 255, verbose_name = "Question", blank = True)
    
    def __str__(self):
        return self.question
        
    class Meta:
        ordering = ('question',)
        
    def as_html(self):
        return "<h1>THIS MODEL HAS NOT IMPLEMENTED AS_HTML</h1>"
    
class MultipleChoiceQuestion(TestUnit):
    correct_answer = models.CharField(max_length = 255, verbose_name = "Correct answer")
    wrong_answer_1 = models.CharField(max_length = 255, verbose_name = "Wrong answer")
    wrong_answer_2 = models.CharField(max_length = 255, verbose_name = "Wrong answer")
    
    def as_html(self):
        html = '<div><ul class="list-group">'
        alternatives = [self.correct_answer, self.wrong_answer_1, self.wrong_answer_2]
        shuffle(alternatives)
        
        for alternative in alternatives:
            html += """
            <li class="list-group-item">
                <input type='radio' name='%s' id="%s"/>
                <label for='%s'>%s</label>
                <div class="highlight"></div>
            </li>
            """ % (self, alternative, alternative, alternative)
        html += "</ul></div>"
        return html

def image_directory_path(instance, filename):
    return 'upload/quiz/{0}/{1}'.format(instance.id, filename)
    
class MultipleChoiceQuestionWithImage(MultipleChoiceQuestion):
    image = models.ImageField(upload_to=image_directory_path)
    
    def as_html(self):
        html = """
        <div><img src="%s" /></div>
        """ % (self.image.url)
        return super(MultipleChoiceQuestionWithImage, self).as_html() + html
    
class LandmarkQuestion(TestUnit):
    original_image = models.ImageField(upload_to=image_directory_path)
    landmark_drawing = models.ImageField(upload_to=image_directory_path)
    
class Test(models.Model):
    headline = models.CharField(max_length=255)
    multiple_choice_questions = models.ManyToManyField(MultipleChoiceQuestion, related_name="multiple_choice_questions", blank=True)
    multiple_choice_questions_with_image = models.ManyToManyField(MultipleChoiceQuestionWithImage, related_name="multiple_choice_questions_with_image", blank=True)
    landmark_questions = models.ManyToManyField(LandmarkQuestion, related_name="landmark_questions", blank=True)
    
    def __str__(self):
        return self.headline
        
    class Meta:
        ordering = ('headline',)