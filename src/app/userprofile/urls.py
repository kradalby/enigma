from django.conf.urls import include, url, patterns

urlpatterns = patterns('app.userprofile.views',
    # Admin
    url(r'^admin/delete/(?P<userprofile_id>\d+)/(?P<course_id>\d+)/$', "delete_userprofile", name='admin_delete_userprofile'),
)