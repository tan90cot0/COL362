from django.db import models

# Create your models here.
class Country_Code(models.Model):
    name = models.CharField(max_length=40, null = True)
    code = models.CharField(max_length=3, primary_key=True)

class Country_Continent(models.Model):
    continent_name = models.CharField(max_length=15, null = True)
    country_code = models.CharField(max_length=3, primary_key=True)

class Country(models.Model):
    country_code = models.CharField(max_length=3, primary_key=True)
    population = models.DecimalField(max_digits = 11, decimal_places = 1, null = True)   #try int
    life_expectancy = models.DecimalField(max_digits = 5, decimal_places = 2, null = True)
    hospital_beds_per_thousand = models.DecimalField(max_digits = 5, decimal_places = 3, null = True)
    handwashing_facilities = models.DecimalField(max_digits = 6, decimal_places = 3, null = True)
    male_smokers = models.DecimalField(max_digits = 3, decimal_places = 1, null = True)
    female_smokers = models.DecimalField(max_digits = 3, decimal_places = 1, null = True)
    diabetes_prevalence = models.DecimalField(max_digits = 4, decimal_places = 2, null = True)
    cardiovasc_death_rate = models.DecimalField(max_digits = 6, decimal_places = 3, null = True)
    extreme_poverty = models.DecimalField(max_digits = 3, decimal_places = 1, null = True)
    gdp_per_capita = models.DecimalField(max_digits = 9, decimal_places = 3, null = True)
    aged_70_older = models.DecimalField(max_digits = 5, decimal_places = 3, null = True)
    aged_65_older = models.DecimalField(max_digits = 5, decimal_places = 3, null = True)
    median_age = models.DecimalField(max_digits = 3, decimal_places = 1, null = True)
    population_density = models.DecimalField(max_digits = 8, decimal_places = 3, null = True)
    stringency_index = models.DecimalField(max_digits = 5, decimal_places = 2, null = True)

class Hosp_defence(models.Model):
    name = models.CharField(max_length=30, primary_key=True)
    no_hospitals = models.IntegerField(null = True)
    no_beds = models.IntegerField(null = True)

class Hosp_gov(models.Model):
    state_name = models.CharField(max_length=30, primary_key=True)
    rural_hosp = models.IntegerField(null = True)
    rural_beds = models.IntegerField(null = True)
    urban_hosp = models.IntegerField(null = True)
    urban_beds = models.IntegerField(null = True)

class Hosp_railways(models.Model):
    zone = models.CharField(max_length=50, primary_key=True)
    no_hospitals = models.IntegerField(null = True)
    no_beds = models.IntegerField(null = True)

class India_cases(models.Model):
    date = models.DateField(primary_key = True)
    conf = models.IntegerField(null = True)
    total_conf = models.IntegerField(null = True)
    rec = models.IntegerField(null = True)
    total_rec = models.IntegerField(null = True)
    deceased = models.IntegerField(null = True)
    total_deceased = models.IntegerField(null = True)

class India_tests(models.Model):
    date = models.DateField(primary_key = True)
    total_samples = models.DecimalField(max_digits = 9, decimal_places = 1, null = True)     #convert to int
    total_positive = models.IntegerField(null = True)
    tpcc = models.DecimalField(max_digits = 4, decimal_places = 2, null = True)
    tpm = models.DecimalField(max_digits = 6, decimal_places = 1, null = True)

class India_vaccine(models.Model):
    date = models.DateField(primary_key = True)
    total_doses = models.DecimalField(max_digits = 10, decimal_places = 1, null = True)
    sessions = models.DecimalField(max_digits = 9, decimal_places = 1, null = True)
    sites = models.DecimalField(max_digits = 6, decimal_places = 1, null = True)
    first_dose = models.DecimalField(max_digits = 10, decimal_places = 1, null = True)
    second_dose = models.DecimalField(max_digits = 10, decimal_places = 1, null = True)
    male = models.DecimalField(max_digits = 10, decimal_places = 1, null = True)
    female = models.DecimalField(max_digits = 10, decimal_places = 1, null = True)
    trans = models.DecimalField(max_digits = 6, decimal_places = 1, null = True)
    covaxin = models.DecimalField(max_digits = 9, decimal_places = 1, null = True)
    covishield = models.DecimalField(max_digits = 10, decimal_places = 1, null = True)
    sputnikv = models.DecimalField(max_digits = 7, decimal_places = 1, null = True)
    doses_18to44 = models.DecimalField(max_digits = 10, decimal_places = 1, null = True)
    doses_45to60 = models.DecimalField(max_digits = 10, decimal_places = 1, null = True)
    doses_60plus = models.DecimalField(max_digits = 10, decimal_places = 1, null = True)

class Patients(models.Model):
    date = models.DateField(null = True)
    patient_no = models.IntegerField(primary_key = True)
    age = models.DecimalField(max_digits = 4, decimal_places = 1, null = True)
    gender = models.CharField(max_length=10, null = True)
    city = models.CharField(max_length=40, null = True)
    district = models.CharField(max_length=30, null = True)
    state = models.CharField(max_length=40, null = True)
    state_code = models.CharField(max_length=2, null = True)
    nationality = models.CharField(max_length=50, null = True)
    transmission = models.CharField(max_length=10, null = True)

class State_cases(models.Model):
    record_id = models.IntegerField(primary_key = True)
    date = models.DateField(null = True)
    state_code = models.CharField(max_length=2, null = True)
    conf = models.IntegerField(null = True)
    rec = models.IntegerField(null = True)
    deceased = models.IntegerField(null = True)
    state_name = models.CharField(max_length=40, null = True)

class State_tests(models.Model):
    record_id = models.IntegerField(primary_key = True)
    date = models.DateField(null = True)
    state = models.CharField(max_length=40, null = True)
    total_test = models.DecimalField(max_digits = 8, decimal_places = 1, null = True)
    positive = models.DecimalField(max_digits = 7, decimal_places = 1, null = True)
    negative = models.DecimalField(max_digits = 7, decimal_places = 0, null = True)
    unconfirmed = models.DecimalField(max_digits = 7, decimal_places = 1, null = True)
    total_quarantine = models.DecimalField(max_digits = 7, decimal_places = 1, null = True)
    total_quarantine_released = models.DecimalField(max_digits = 8, decimal_places = 1, null = True)
    people_icu = models.DecimalField(max_digits = 7, decimal_places = 1, null = True)
    people_venti = models.DecimalField(max_digits = 7, decimal_places = 1, null = True)
    num_iso_beds = models.DecimalField(max_digits = 7, decimal_places = 1, null = True)
    num_icu_beds = models.DecimalField(max_digits = 7, decimal_places = 1, null = True)
    num_venti = models.DecimalField(max_digits = 7, decimal_places = 1, null = True)
    tpm = models.DecimalField(max_digits = 7, decimal_places = 1, null = True)
    tpcc = models.DecimalField(max_digits = 5, decimal_places = 1, null = True)

class State_vaccine(models.Model):
    record_id = models.IntegerField(primary_key = True)
    date = models.DateField(null = True)
    state = models.CharField(max_length=40, null = True)
    total_doses = models.DecimalField(max_digits = 10, decimal_places = 1, null = True)
    sessions = models.DecimalField(max_digits = 9, decimal_places = 1, null = True)
    sites = models.DecimalField(max_digits = 6, decimal_places = 1, null = True)
    first_dose = models.DecimalField(max_digits = 10, decimal_places = 1, null = True)
    second_dose = models.DecimalField(max_digits = 10, decimal_places = 1, null = True)
    male = models.DecimalField(max_digits = 10, decimal_places = 1, null = True)
    female = models.DecimalField(max_digits = 10, decimal_places = 1, null = True)
    trans = models.DecimalField(max_digits = 6, decimal_places = 1, null = True)
    covaxin = models.DecimalField(max_digits = 9, decimal_places = 1, null = True)
    covishield = models.DecimalField(max_digits = 10, decimal_places = 1, null = True)
    sputnikv = models.DecimalField(max_digits = 7, decimal_places = 1, null = True)
    doses_18to44 = models.DecimalField(max_digits = 10, decimal_places = 1, null = True)
    doses_45to60 = models.DecimalField(max_digits = 10, decimal_places = 1, null = True)
    doses_60plus = models.DecimalField(max_digits = 10, decimal_places = 1, null = True)


class World_cases(models.Model):
    record_id = models.IntegerField(primary_key = True)
    country_code = models.CharField(max_length=15, null = True)
    date = models.DateField(null = True)
    total_cases = models.DecimalField(max_digits = 11, decimal_places = 1, null = True)
    new_cases = models.DecimalField(max_digits = 9, decimal_places = 1, null = True)
    new_cases_smoothed = models.DecimalField(max_digits = 9, decimal_places = 1, null = True)
    total_deaths= models.DecimalField(max_digits = 8, decimal_places = 1, null = True)
    new_deaths= models.DecimalField(max_digits = 8, decimal_places = 1, null = True)
    new_deaths_smoothed = models.DecimalField(max_digits = 8, decimal_places = 1, null = True)
    reproduction_rate = models.DecimalField(max_digits = 4, decimal_places = 1, null = True)
    icu_patients = models.DecimalField(max_digits = 6, decimal_places = 1, null = True)
    hosp_patients = models.DecimalField(max_digits = 7, decimal_places = 1, null = True)
    weekly_icu_admissions = models.DecimalField(max_digits = 6, decimal_places = 1, null = True)
    weekly_hosp_admissions = models.DecimalField(max_digits = 7, decimal_places = 1, null = True)


class World_tests(models.Model):
    record_id = models.IntegerField(primary_key = True)
    country_code = models.CharField(max_length=15, null = True)
    date = models.DateField(null = True)
    total_tests = models.DecimalField(max_digits = 11, decimal_places = 1, null = True)
    new_tests = models.DecimalField(max_digits = 9, decimal_places = 1, null = True)
    new_tests_smoothed = models.DecimalField(max_digits = 9, decimal_places = 1, null = True)
    postive_rate = models.DecimalField(max_digits = 8, decimal_places = 5, null = True)
    tests_per_case = models.DecimalField(max_digits = 8, decimal_places = 1, null = True)

class World_vaccine(models.Model):
    record_id = models.IntegerField(primary_key = True)
    country_code = models.CharField(max_length=15, null = True)
    date = models.DateField(null = True)
    total_vaccinations = models.DecimalField(max_digits = 11, decimal_places = 1, null = True)
    people_vaccinated = models.DecimalField(max_digits = 11, decimal_places = 1, null = True)
    people_fully_vaccinated = models.DecimalField(max_digits = 11, decimal_places = 1, null = True)
    total_boosters = models.DecimalField(max_digits = 11, decimal_places = 1, null = True)
    new_vaccinations = models.DecimalField(max_digits = 9, decimal_places = 1, null = True)
    new_vaccinations_smoothed = models.DecimalField(max_digits = 9, decimal_places = 1, null = True)
    new_people_vaccinated_smoothed = models.DecimalField(max_digits = 9, decimal_places = 1, null = True)