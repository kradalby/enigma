from django.contrib.auth.models import User
from django.db import models
from random import shuffle

from app.course.models import Course
    
class Test(models.Model):
    name = models.CharField(max_length=255)
    course = models.ForeignKey(Course)
    
    def __str__(self):
        return self.name
        
    def test_unit_count(self):
        return len(TestUnit.objects.filter(test = self))
        
    def answered_by_user(self, user):
        return TestResult.objects.filter(test = self, user = user).first()
                
    def multiple_choice_questions(self):
        return MultipleChoiceQuestion.objects.filter(test = self)
        
    def multiple_choice_questions_with_image(self):
        return MultipleChoiceQuestionWithImage.objects.filter(test = self)
        
    def landmark_questions(self):
        return LandmarkQuestion.objects.filter(test = self)
        
class TestUnit(models.Model):
    question = models.CharField(max_length = 255, verbose_name = "Question")
    test = models.ForeignKey(Test)
    
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
                <input type='radio' name='mpc-%s' value="%s"/>
                <label for='%s'>%s</label>
                <div class="highlight"></div>
            </li>
            """ % (self, alternative, alternative, alternative)
        html += "</ul></div>"
        return html

def image_directory_path(instance, filename):
    return 'upload/quiz/{0}/{1}'.format(instance.id, filename)
    
class MultipleChoiceQuestionWithImage(TestUnit):
    correct_answer = models.CharField(max_length = 255, verbose_name = "Correct answer")
    wrong_answer_1 = models.CharField(max_length = 255, verbose_name = "Wrong answer")
    wrong_answer_2 = models.CharField(max_length = 255, verbose_name = "Wrong answer")
    image = models.ImageField(upload_to=image_directory_path)
    
    def as_html(self):
        html = """
        <div>
            <img src="%s" />
        </div>
        <div>
            <ul class="list-group">
        """ % (self.image.url)
        
        alternatives = [self.correct_answer, self.wrong_answer_1, self.wrong_answer_2]
        shuffle(alternatives)
        
        for alternative in alternatives:
            html += """
            <li class="list-group-item">
                <input type='radio' name='mpci-%s' value="%s"/>
                <label for='%s'>%s</label>
                <div class="highlight"></div>
            </li>
            """ % (self, alternative, alternative, alternative)
        html += "</ul></div>"
        return html
    
class LandmarkQuestion(TestUnit):
    original_image = models.ImageField(upload_to=image_directory_path)
    landmark_drawing = models.ImageField(upload_to=image_directory_path, blank=True)
    
    def regions(self):
        return LandmarkRegion.objects.filter(landmark_question=self)
    
    def as_html(self):
        original_image = self.original_image.url
        landmark_drawing = self.landmark_drawing.url
        width = self.original_image.width
        height = self.original_image.height
        html = """
        <div class="landmark-container">
            <canvas id="viewport" width="{3}" height="{4}"></canvas>
            <input type="hidden" id="landmark_answer" name="landmark_question-{0}" value="{{}}">
        </div>
        <script>
            landmark("{1}", "{2}", {3}, {4});
        </script>
        """.format(self.question, original_image, landmark_drawing, width, height)
        return html
        
class LandmarkRegion(models.Model):
    landmark_question = models.ForeignKey(LandmarkQuestion)
    color = models.CharField(max_length=50)
    name = models.CharField(max_length=255)
        
class TestResult(models.Model):
    test = models.ForeignKey(Test)
    user = models.ForeignKey(User)
    answered = models.DateField(auto_now=True)
    
    def test_unit_results(self):
        return TestUnitResult.objects.filter(test_result = self)
        
    def correct_answers(self):
        test_units = self.test_unit_results()
        return [x for x in test_units if x.correct_answer]
        
    def incorrect_answers(self):
        test_units = self.test_unit_results()
        return [x for x in test_units if not x.correct_answer]
    
class TestUnitResult(models.Model):
    test_unit = models.ForeignKey(TestUnit)
    correct_answer = models.BooleanField()
    test_result = models.ForeignKey(TestResult)