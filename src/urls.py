from django.conf.urls.static import static
from django.conf.urls import include, url
from django.conf import settings
from django.contrib.auth.forms import UserCreationForm
from django.contrib.auth import views as auth_views
#from django.contrib import admin
from django.views.generic.edit import CreateView

urlpatterns = [
    #url(r'^admin/', admin.site.urls),
    url(r'^', include('app.quiz.urls')),
    url(r'^accounts/login/$', auth_views.login),
    url(r'^accounts/logout/$', auth_views.logout),
    url(r'^accounts/password_change/$', auth_views.password_change),
    url(r'^accounts/password_change/done/$', auth_views.password_change_done),
    url('^register/', CreateView.as_view(
            template_name='register.html',
            form_class=UserCreationForm,
            success_url='/'
    )),
    url('^accountss/', include('django.contrib.auth.urls')),
]

urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
urlpatterns += static(settings.STATIC_URL, document_root=settings.STATIC_ROOT)