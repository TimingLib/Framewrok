from django.conf.urls import url
from . import views

urlpatterns = [
<<<<<<< HEAD
    url(r'^$', views.index, name='index'),
    #   url(r'^(?P<question_id>[0-9]+)/detail/$', views.detail, name='detail'),
    #	url(r'^(?P<question_id>[0-9]+)/results/$', views.results, name='results'),
    #	url(r'^(?P<question_id>[0-9]+)/vote/$', views.vote, name='vote'),
]
=======
	url(r'^$',views.index,name='index'),
	url(r'^(?P<question_id>[0-9]+)/detail/$', views.detail, name='detail'),
	url(r'^(?P<question_id>[0-9]+)/results/$', views.results, name='results'),
	url(r'^(?P<question_id>[0-9]+)/vote/$', views.vote, name='vote'),
	]
>>>>>>> parent of be7af50... Format the string
