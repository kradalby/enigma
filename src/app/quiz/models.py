from django.contrib.auth.models import User
from django.db import models
from random import shuffle

class TestUnit(models.Model):
    question = models.CharField(max_length = 255, verbose_name = "Question", blank = True, unique = True)
    
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
    
    def as_html(self, key_prefix="mpc"):
        html = '<div><ul class="list-group">'
        alternatives = [self.correct_answer, self.wrong_answer_1, self.wrong_answer_2]
        shuffle(alternatives)
        
        for alternative in alternatives:
            html += """
            <li class="list-group-item">
                <input type='radio' name='%s-%s' value="%s"/>
                <label for='%s'>%s</label>
                <div class="highlight"></div>
            </li>
            """ % (key_prefix, self, alternative, alternative, alternative)
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
        return html + super(MultipleChoiceQuestionWithImage, self).as_html("mpci")
    
class LandmarkQuestion(TestUnit):
    original_image = models.ImageField(upload_to=image_directory_path)
    landmark_drawing = models.ImageField(upload_to=image_directory_path)
    
    def as_html(self):
        html = """
        <div class="landmark-container">
            <img class="landmark" src="%s" />
            <img class="landmark hide" src="%s" />
        </div>
        """ % (self.original_image.url, self.landmark_drawing.url)
        return html
    
class Test(models.Model):
    name = models.CharField(max_length=255)
    multiple_choice_questions = models.ManyToManyField(MultipleChoiceQuestion, related_name="multiple_choice_questions", blank=True)
    multiple_choice_questions_with_image = models.ManyToManyField(MultipleChoiceQuestionWithImage, related_name="multiple_choice_questions_with_image", blank=True)
    landmark_questions = models.ManyToManyField(LandmarkQuestion, related_name="landmark_questions", blank=True)
    
    def __str__(self):
        return self.name
        
    def answered_by_user(self, user):
        return TestResult.objects.filter(test = self, user = user).first()
        
    class Meta:
        ordering = ('name',)
        
class TestResult(models.Model):
    test = models.ForeignKey(Test)
    user = models.ForeignKey(User)
    answered = models.DateField(auto_now=True)
    
    def test_unit_results(self):
        return TestUnitResult.objects.filter(test_result = self)
    
class TestUnitResult(models.Model):
    test_unit = models.ForeignKey(TestUnit)
    correct_answer = models.BooleanField()
    test_result = models.ForeignKey(TestResult)