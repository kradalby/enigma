from django.conf.urls import include, url, patterns

from .views import site, admin

urlpatterns = [
    # Site
    url(r'^$', site.index, name='index'),
    url(r'^survey/$', site.survey, name='survey'),
    # Admin
    url(r'^admin/$', admin.index, name='admin_index'),
    url(r'^admin/settings/$', admin.settings, name='admin_settings'),
]
