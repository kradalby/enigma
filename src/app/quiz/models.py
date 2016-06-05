from django.contrib.auth.models import User
from django.db import models
from random import shuffle

from app.course.models import Course
    
class Test(models.Model):
    name = models.CharField(max_length=255)
    course = models.ForeignKey(Course)
    
    def __str__(self):
        return self.name
        
    def answered_by_user(self, user):
        return TestResult.objects.filter(test = self, user = user).first()
        
    def test_unit_count(self):
        return len(TestUnit.objects.filter(test = self))

    def multiple_choice_questions(self):
        return MultipleChoiceQuestion.objects.filter(test = self)

    def multiple_choice_questions_with_image(self):
        return MultipleChoiceQuestionWithImage.objects.filter(test = self)
        
    def multiple_choice_questions_with_video(self):
        return MultipleChoiceQuestionWithVideo.objects.filter(test = self)
        
    def landmark_questions(self):
        return LandmarkQuestion.objects.filter(test = self)
        
    def outline_questions(self):
        return OutlineQuestion.objects.filter(test = self)
               
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
        
class TestUnit(models.Model):
    question = models.CharField(max_length = 255, verbose_name = "Question")
    test = models.ManyToManyField(Test)
    
    def __str__(self):
        return self.question
        
    class Meta:
        ordering = ('question',)
        
    def as_html(self):
        return "<h1>THIS MODEL HAS NOT IMPLEMENTED AS_HTML</h1>"
        
    def times_used(self):
        return self.test.count()
            
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
            """ % (self.id, alternative, alternative, alternative)
        html += "</ul></div>"
        return html
    
class MultipleChoiceQuestionWithImage(TestUnit):
    correct_answer = models.CharField(max_length = 255, verbose_name = "Correct answer")
    wrong_answer_1 = models.CharField(max_length = 255, verbose_name = "Wrong answer")
    wrong_answer_2 = models.CharField(max_length = 255, verbose_name = "Wrong answer")
    image = models.ImageField()
    
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
            """ % (self.id, alternative, alternative, alternative)
        html += "</ul></div>"
        return html
            
class MultipleChoiceQuestionWithVideo(TestUnit):
    correct_answer = models.CharField(max_length = 255, verbose_name = "Correct answer")
    wrong_answer_1 = models.CharField(max_length = 255, verbose_name = "Wrong answer")
    wrong_answer_2 = models.CharField(max_length = 255, verbose_name = "Wrong answer")
    video = models.FileField()
    
    def as_html(self):
        html = """
        <div>
            <video id="%s" src="%s" controls></video>
        </div>
        <div>
            <ul class="list-group">
        """ % (self.id, self.video.url)
        
        alternatives = [self.correct_answer, self.wrong_answer_1, self.wrong_answer_2]
        shuffle(alternatives)
        
        for alternative in alternatives:
            html += """
            <li class="list-group-item">
                <input type='radio' name='mpcv-%s' value="%s"/>
                <label for='%s'>%s</label>
                <div class="highlight"></div>
            </li>
            """ % (self.id, alternative, alternative, alternative)
        html += "</ul></div>"
        return html
    
class LandmarkQuestion(TestUnit):
    original_image = models.ImageField()
    landmark_drawing = models.ImageField(blank=True)
    
    def __str__(self):
        return self.question or "[LANDMARK] - {0}".format(self.original_image.name)
    
    def regions(self):
        return LandmarkRegion.objects.filter(landmark_question=self)
    
    def as_html(self):
        original_image = self.original_image.url
        landmark_drawing = self.landmark_drawing.url
        width = self.original_image.width
        height = self.original_image.height
        html = """
        <div id="{0}" class="landmark-container">
        </div>
        <script>
            var a = answerRegions();
            a.enableLandmark("{0}", "{1}", "{2}", "{3}", "{4}", "{5}");
        </script>
        """.format("landmark-container-" + str(self.id), original_image, landmark_drawing, height, width, self.id)
        return html
    
class OutlineQuestion(TestUnit):
    original_image = models.ImageField()
    outline_drawing = models.ImageField(blank=True)
    
    def __str__(self):
        return self.question or "[OUTLINE] - {0}".format(self.original_image.name)
    
    def regions(self):
        return OutlineRegion.objects.filter(outline_question=self)
    
    def as_html(self):
        original_image = self.original_image.url
        outline_drawing = self.outline_drawing.url
        width = self.original_image.width
        height = self.original_image.height
        html = """
        <div id="{0}" class="outline-container">
        </div>
        <script>
            var a = answerRegions();
            a.enableOutline("{0}", "{1}", "{2}", "{3}", "{4}", "{5}");
            $("div#{0}").parent().parent().children(".panel-heading").prepend($('<div class="btn btn-default pull-right" onclick="a.clearOutline()">Clear</div>'));
        </script>
        """.format("outline-container-" + str(self.id), original_image, outline_drawing, height, width, self.id)
        return html
        
class LandmarkRegion(models.Model):
    landmark_question = models.ForeignKey(LandmarkQuestion)
    color = models.CharField(max_length=50)
    name = models.CharField(max_length=255)
    
    def __str__(self):
        return self.name
        
class OutlineRegion(models.Model):
    outline_question = models.ForeignKey(OutlineQuestion)
    color = models.CharField(max_length=50)
    name = models.CharField(max_length=255)
    
    def __str__(self):
        return self.name
    
class TestUnitResult(models.Model):
    test_unit = models.ForeignKey(TestUnit)
    correct_answer = models.BooleanField()
    test_result = models.ForeignKey(TestResult)
    answer = models.CharField(max_length=255, blank=True)
    answer_image = models.ImageField(blank=True)
    target_color_region = models.CharField(max_length=255)
    
    def target_outline_region(self):
        # try:
        print(OutlineRegion.objects.filter(outline_question = self.test_unit))
        print(self.target_color_region)
        return OutlineRegion.objects.filter(outline_question = self.test_unit).get(color=self.target_color_region)
        # except:
            # return None
            
    def target_landmark_region(self):
        try:
            return LandmarkRegion.objects.filter(landmark_question = self.test_unit).get(color=self.target_color_region)
        except:
            return "Region"
            
    def answered_landmark_region(self):
        try:
            return LandmarkRegion.objects.filter(landmark_question = self.test_unit).get(color=self.answer)
        except:
            return "Region"