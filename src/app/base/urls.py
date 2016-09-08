from django.conf.urls import url

from .views import site, admin

urlpatterns = [
    # Site
    url(r'^$', site.index, name='index'),
    url(r'^survey/$', site.survey, name='survey'),
    url(r'^change_password/$', site.change_password, name='change_password'),
    # Admin
    url(r'^admin/$', admin.index, name='admin_index'),
    url(r'^admin/settings/$', admin.settings, name='admin_settings'),
]
