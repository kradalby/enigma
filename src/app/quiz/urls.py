from django.conf.urls import include, url

from . import views

urlpatterns = [
    url(r'^$', views.index, name='index'),
    url(r'^view/(?P<test_id>\d+)$', views.single_test, name='single_test'),
    url(r'^submit/(?P<test_id>\d+)$', views.submit_test, name='submit_test'),
]
