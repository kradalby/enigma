from django.conf.urls.static import static
from django.conf.urls import include, url
from django.conf import settings
from django.contrib.auth.forms import UserCreationForm
from django.contrib.auth import views as auth_views
#from django.contrib import admin
from django.views.generic.edit import CreateView

urlpatterns = [
    url(r'^', include('app.quiz.urls')),
    url(r'^course/', include('app.course.urls')),
    url(r'^accounts/login/$', auth_views.login),
    url(r'^accounts/logout/$', auth_views.logout),
]

urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
urlpatterns += static(settings.STATIC_URL, document_root=settings.STATIC_ROOT)