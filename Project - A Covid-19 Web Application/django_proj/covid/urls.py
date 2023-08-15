from django.urls import path

from . import views

urlpatterns = [

    path("", views.home_page, name="home_page"),
    path("states/cases", views.states_cases, name="states_cases"),
    path("india/cases", views.india_cases, name="india_cases"),
    path("world/cases", views.world_cases, name="world_cases"),
    path("states/tests", views.states_tests, name="states_tests"),
    path("india/tests", views.india_tests, name="india_tests"),
    path("world/tests", views.world_tests, name="world_tests"),
    path("states/vaccine", views.states_vaccine, name="states_vaccine"),
    path("india/vaccine", views.india_vaccine, name="india_vaccine"),
    path("world/vaccine", views.world_vaccine, name="world_vaccine"),
    path("insert_data", views.insert_data, name="insert_data"),
    path("patients", views.patients, name="patients"),
    path("hospitals", views.hospitals, name="hospitals"),

]