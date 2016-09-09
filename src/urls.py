from django.conf.urls.static import static
from django.conf.urls import include, url
from django.conf import settings
from django.contrib.auth import views as auth_views

urlpatterns = [
    url(r'^', include('app.base.urls')),
    url(r'^test/', include('app.quiz.urls')),
    url(r'^course/', include('app.course.urls')),
    url(r'^profile/', include('app.userprofile.urls')),
    url(r'^accounts/login/$', auth_views.login, name='login'),
    url(r'^accounts/logout/$', auth_views.logout, name='logout'),
]

urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
urlpatterns += static(settings.STATIC_URL, document_root=settings.STATIC_ROOT)
