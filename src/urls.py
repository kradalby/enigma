from django.conf.urls.static import static
from django.conf.urls import include, url
from django.conf import settings
from django.contrib.auth import views as auth_views
from django.contrib import admin

urlpatterns = [
    url(r'^', include('app.base.urls')),
    url(r'^test/', include('app.quiz.urls')),
    url(r'^course/', include('app.course.urls')),
    url(r'^profile/', include('app.userprofile.urls')),
    url(r'^accounts/login/$', auth_views.login, name='login'),
    url(r'^accounts/logout/$', auth_views.logout, name='logout'),
    url(r'^api/quiz/', include('app.quiz.api_urls')),
]

urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
urlpatterns += static(settings.STATIC_URL, document_root=settings.STATIC_ROOT)

if settings.DEBUG:
    urlpatterns.append(url(r'^djangoadmin/', include(admin.site.urls)))
