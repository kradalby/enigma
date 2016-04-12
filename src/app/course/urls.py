from django.conf.urls import include, url, patterns

urlpatterns = patterns('app.course.views',
    # Admin
    url(r'^admin/new/$', "admin.new_course", name='admin_new_course'),
)
