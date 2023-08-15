from django import forms
from django.forms.widgets import NumberInput  
from datetime import datetime
from covid.models import  Country_Code

class IndiaCasesForm(forms.Form):
    start_date_str = '2020-01-30'
    start_date_object = datetime.strptime(start_date_str, '%Y-%m-%d').date
    end_date_str = '2020-08-06'
    end_date_object = datetime.strptime(end_date_str, '%Y-%m-%d').date

    start_date = forms.DateField(widget = NumberInput(attrs={'type':'date'}), required=True, initial= start_date_object)
    end_date = forms.DateField(widget = NumberInput(attrs={'type':'date'}), required=True, initial= end_date_object)
    confirmed = forms.BooleanField(required=False)
    total_confirmed = forms.BooleanField(required=False)
    recovered = forms.BooleanField(required=False)
    total_recovered = forms.BooleanField(required=False)
    deceased = forms.BooleanField(required=False)
    total_deceased = forms.BooleanField(required=False)

class WorldCasesForm(forms.Form):
    a = Country_Code.objects.all()
    cnt = [('Select', 'Select')]
    for tup in a:
        cnt.append((tup.code, tup.name))
    start_date_str = '2020-01-03'
    start_date_object = datetime.strptime(start_date_str, '%Y-%m-%d').date
    end_date_str = '2023-03-16'
    end_date_object = datetime.strptime(end_date_str, '%Y-%m-%d').date

    country = forms.CharField(widget=forms.Select(choices=cnt), required=False)
    start_date = forms.DateField(widget = NumberInput(attrs={'type':'date'}), required=True, initial= start_date_object)
    end_date = forms.DateField(widget = NumberInput(attrs={'type':'date'}), required=True, initial= end_date_object)
    confirmed = forms.BooleanField(required=False)
    total_confirmed = forms.BooleanField(required=False)
    cases_smoothed = forms.BooleanField(required=False)
    deaths_smoothed = forms.BooleanField(required=False)
    deceased = forms.BooleanField(required=False)
    total_deceased = forms.BooleanField(required=False)
    reproduction_rate = forms.BooleanField(required=False)
    icu_patients = forms.BooleanField(required=False)
    hosp_patients = forms.BooleanField(required=False)
    weekly_icu_admissions = forms.BooleanField(required=False)
    weekly_hosp_admissions = forms.BooleanField(required=False)

    pop_min= forms.DecimalField(required=False, min_value=0, max_value=1425887361, initial = 0, label="Min Val", decimal_places=1, widget=forms.NumberInput())
    pop_max= forms.DecimalField(required=False, min_value=0, max_value=1425887361, initial = 1425887361, label="Max Val", decimal_places=1, widget=forms.NumberInput())

    life_min= forms.DecimalField(required=False, min_value=0, max_value=88, initial = 0, label="Min Val", decimal_places=1, widget=forms.NumberInput())
    life_max= forms.DecimalField(required=False, min_value=0, max_value=88, initial = 88, label="Max Val", decimal_places=1, widget=forms.NumberInput())

    hosp_min= forms.DecimalField(required=False, min_value=0, max_value=14, initial = 0, label="Min Val", decimal_places=1, widget=forms.NumberInput())
    hosp_max= forms.DecimalField(required=False, min_value=0, max_value=14, initial = 14, label="Max Val", decimal_places=1, widget=forms.NumberInput())

    handwash_min= forms.DecimalField(required=False, min_value=0, max_value=100, initial = 0, label="Min Val", decimal_places=1, widget=forms.NumberInput())
    handwash_max= forms.DecimalField(required=False, min_value=0, max_value=100, initial = 100, label="Max Val", decimal_places=1, widget=forms.NumberInput())

    stringency_min= forms.DecimalField(required=False, min_value=0, max_value=100, initial = 0, label="Min Val", decimal_places=1, widget=forms.NumberInput())
    stringency_max= forms.DecimalField(required=False, min_value=0, max_value=100, initial = 100, label="Max Val", decimal_places=1, widget=forms.NumberInput())

    male_min= forms.DecimalField(required=False, min_value=0, max_value=79, initial = 0, label="Min Val", decimal_places=1, widget=forms.NumberInput())
    male_max= forms.DecimalField(required=False, min_value=0, max_value=79, initial = 79, label="Max Val", decimal_places=1, widget=forms.NumberInput())

    female_min= forms.DecimalField(required=False, min_value=0, max_value=45, initial = 0, label="Min Val", decimal_places=1, widget=forms.NumberInput())
    female_max= forms.DecimalField(required=False, min_value=0, max_value=45, initial = 45, label="Max Val", decimal_places=1, widget=forms.NumberInput())

    diabetes_min= forms.DecimalField(required=False, min_value=0, max_value=31, initial = 0, label="Min Val", decimal_places=1, widget=forms.NumberInput())
    diabetes_max= forms.DecimalField(required=False, min_value=0, max_value=31, initial = 31, label="Max Val", decimal_places=1, widget=forms.NumberInput())

    cardio_min= forms.DecimalField(required=False, min_value=0, max_value=725, initial = 0, label="Min Val", decimal_places=1, widget=forms.NumberInput())
    cardio_max= forms.DecimalField(required=False, min_value=0, max_value=725, initial = 725, label="Max Val", decimal_places=1, widget=forms.NumberInput())

    density_min= forms.DecimalField(required=False, min_value=0, max_value=20547, initial = 0, label="Min Val", decimal_places=1, widget=forms.NumberInput())
    density_max= forms.DecimalField(required=False, min_value=0, max_value=20547, initial = 20547, label="Max Val", decimal_places=1, widget=forms.NumberInput())

    gdp_min= forms.DecimalField(required=False, min_value=0, max_value=116936, initial = 0, label="Min Val", decimal_places=1, widget=forms.NumberInput())
    gdp_max= forms.DecimalField(required=False, min_value=0, max_value=116936, initial = 116936, label="Max Val", decimal_places=1, widget=forms.NumberInput())

    seventy_min= forms.DecimalField(required=False, min_value=0, max_value=19, initial = 0, label="Min Val", decimal_places=1, widget=forms.NumberInput())
    seventy_max= forms.DecimalField(required=False, min_value=0, max_value=19, initial = 19, label="Max Val", decimal_places=1, widget=forms.NumberInput())

    sixtyfive_min= forms.DecimalField(required=False, min_value=0, max_value=28, initial = 0, label="Min Val", decimal_places=1, widget=forms.NumberInput())
    sixtyfive_max= forms.DecimalField(required=False, min_value=0, max_value=28, initial = 28, label="Max Val", decimal_places=1, widget=forms.NumberInput())

    median_min= forms.DecimalField(required=False, min_value=0, max_value=49, initial = 0, label="Min Val", decimal_places=1, widget=forms.NumberInput())
    median_max= forms.DecimalField(required=False, min_value=0, max_value=49, initial = 49, label="Max Val", decimal_places=1, widget=forms.NumberInput())

class LoginForm(forms.Form):
    uname = forms.CharField(label = "uname")
    password = forms.CharField(label = "psw")

class InsertForm(forms.Form):
    table = forms.CharField(label = "table", required=True)
    data = forms.CharField(label = "data", required=True)