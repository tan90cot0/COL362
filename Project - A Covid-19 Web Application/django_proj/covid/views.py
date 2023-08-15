from django.shortcuts import render
from .forms import *
from matplotlib.figure import Figure
from matplotlib.backends.backend_agg import FigureCanvasAgg
from datetime import *
import pandas as pd

# Create your views here.

from covid.models import  Country_Code, Country_Continent, Country, Hosp_defence, Hosp_gov, Hosp_railways, India_cases, India_tests, India_vaccine, Patients, State_cases, State_tests, State_vaccine, World_cases, World_tests, World_vaccine

admin_user = False
def home_page(request):
    global admin_user
    admin_user = False
    if request.method == 'POST':
        name = request.POST['uname']
        pss = request.POST['psw']
        if name=='admin' and pss =='admin':
            admin_user = True
            print("admin detected")
        print(name, pss)
        form = LoginForm(request.POST)
        if form.is_valid():
            print(form.cleaned_data['uname'])
            print(form.cleaned_data['password'])
    else:
        form = LoginForm()
    return render(request, "home.html", {"admin": not(admin_user)})

def states_cases(request):
    countries = Country_Code.objects.filter(name="Belgium")
    context = {"cnt": countries}
    return render(request, "states_cases.html", context)

def india_cases(request):
    t = None
    dates = ['9999-12-12']
    confirmed = [0]
    total_confirmed = [0]
    recovered = [0]
    total_recovered = [0]
    deceased = [0]
    total_deceased = [0]
    confirmed_on = False
    total_confirmed_on = False
    recovered_on = False
    total_recovered_on = False
    deceased_on = False
    total_deceased_on = False
    download = False
    if request.method == 'POST':
        form = IndiaCasesForm(request.POST)
        if form.is_valid():
            t = India_cases.objects.filter(date__gte=  form.cleaned_data['start_date'], date__lte= form.cleaned_data['end_date'])
            dates = []
            confirmed = []
            total_confirmed = []
            recovered = []
            total_recovered = []
            deceased = []
            total_deceased = []
            for tup in t:
                dates.append(tup.date.strftime('%Y-%m-%d'))
                confirmed.append(tup.conf)
                total_confirmed.append(tup.total_conf)
                recovered.append(tup.rec)
                total_recovered.append(tup.total_rec)
                deceased.append(tup.deceased)
                total_deceased.append(tup.total_deceased)

            confirmed_on = form.cleaned_data['confirmed']
            total_confirmed_on = form.cleaned_data['total_confirmed']
            recovered_on = form.cleaned_data['recovered']
            total_recovered_on = form.cleaned_data['total_recovered']
            deceased_on = form.cleaned_data['deceased']
            total_deceased_on = form.cleaned_data['total_deceased']
            if len(dates)>0:
                download = True
    else:
        form = IndiaCasesForm()
    
    fig = Figure()
    canvas = FigureCanvasAgg(fig)

    ax = fig.subplots()
    fig.set_figheight(10)
    fig.set_figwidth(10)
    ax.set_title("Plot of Covid-19 cases in India vs Date")

    flag = 0
    df = pd.DataFrame(dates, columns =['Dates'])
    if confirmed_on:
        ax.plot(dates, confirmed, label = 'Confirmed Patients')
        df['Confirmed'] = confirmed
        flag = 1
    if total_confirmed_on:
        flag = 1
        df['Total Confirmed'] = total_confirmed
        ax.plot(dates, total_confirmed, label = 'Total Confirmed Patients')
    if recovered_on:
        flag = 1
        df['Recovered'] = recovered
        ax.plot(dates, recovered, label = 'Recovered Patients')
    if total_recovered_on:
        flag = 1
        df['Total recovered'] = total_recovered
        ax.plot(dates, total_recovered, label = 'Total Recovered Patients')
    if deceased_on:
        flag = 1
        df['Deceased'] = deceased
        ax.plot(dates, deceased, label = 'Deceased Patients')
    if total_deceased_on:
        flag = 1
        df['Total Deceased'] = total_deceased
        ax.plot(dates, total_deceased, label = 'Total Deceased Patients')

    if flag == 0:
        print('here')
        ax.plot(['9999-12-12'], [0], label = "nothing")

    else:
        ax.legend()
        fig.autofmt_xdate()
        xtick_list = ['2020-02-15', '2020-03-01', '2020-03-15', '2020-04-01', '2020-04-15', '2020-05-01', '2020-05-15', '2020-06-01', '2020-06-15', '2020-07-01', '2020-07-15']
        xtick_list_final = []
        for a in xtick_list:
            if a in dates:
                xtick_list_final.append(a)

        if dates[0] not in xtick_list_final:
            xtick_list_final = [dates[0]] + xtick_list_final

        if dates[-1] not in xtick_list_final:
            xtick_list_final = [dates[-1]] + xtick_list_final
        
        ax.set_xticks(xtick_list_final)

    ax.set_xlabel("Date")
    ax.set_ylabel("Case Count")
    canvas.print_figure("covid/static/images/india_cases.png")
    global admin_user
    context = {"data": t, 'form': form, "download": download, "admin": admin_user}
    df.to_csv('covid/static/data/india_cases.csv')
    
    return render(request, "india_cases.html", context)

def world_cases(request):
    t = None
    dates = {}
    confirmed = {}
    total_confirmed = {}
    cases_smoothed = {}
    deaths_smoothed = {}
    deceased = {}
    total_deceased = {}
    confirmed_on = False
    total_confirmed_on = False
    cases_smoothed_on = False
    deaths_smoothed_on = False
    deceased_on = False
    total_deceased_on = False
    download = False
    country_name = "Selected Countries"
    graph = False
    n = 0

    if request.method == 'POST':
        form = WorldCasesForm(request.POST)
        # for field in form:
        #     print("Field Error:", field.name,  field.errors)
        if form.is_valid():
            temp = form.cleaned_data['country']
            if temp=="Select":
                countries = Country.objects.filter(population__gte = form.cleaned_data["pop_min"], 
                                               population__lte = form.cleaned_data["pop_max"],
                                               life_expectancy__gte = form.cleaned_data["life_min"], 
                                               life_expectancy__lte = form.cleaned_data["life_max"],
                                               hospital_beds_per_thousand__gte = form.cleaned_data["hosp_min"], 
                                               hospital_beds_per_thousand__lte = form.cleaned_data["hosp_max"],
                                               handwashing_facilities__gte = form.cleaned_data["handwash_min"], 
                                               handwashing_facilities__lte = form.cleaned_data["handwash_max"],
                                               stringency_index__gte = form.cleaned_data["stringency_min"], 
                                               stringency_index__lte = form.cleaned_data["stringency_max"],
                                               male_smokers__gte = form.cleaned_data["male_min"], 
                                               male_smokers__lte = form.cleaned_data["male_max"],
                                               female_smokers__gte = form.cleaned_data["female_min"], 
                                               female_smokers__lte = form.cleaned_data["female_max"],
                                               diabetes_prevalence__gte = form.cleaned_data["diabetes_min"], 
                                               diabetes_prevalence__lte = form.cleaned_data["diabetes_max"],
                                               cardiovasc_death_rate__gte = form.cleaned_data["cardio_min"], 
                                               cardiovasc_death_rate__lte = form.cleaned_data["cardio_max"],
                                               population_density__gte = form.cleaned_data["density_min"], 
                                               population_density__lte = form.cleaned_data["density_max"],
                                               gdp_per_capita__gte = form.cleaned_data["gdp_min"], 
                                               gdp_per_capita__lte = form.cleaned_data["gdp_max"],
                                               aged_70_older__gte = form.cleaned_data["seventy_min"], 
                                               aged_70_older__lte = form.cleaned_data["seventy_max"],
                                               aged_65_older__gte = form.cleaned_data["sixtyfive_min"], 
                                               aged_65_older__lte = form.cleaned_data["sixtyfive_max"],
                                               median_age__gte = form.cleaned_data["median_min"], 
                                               median_age__lte = form.cleaned_data["median_max"],
                                               )
            else:
                a = Country_Code.objects.get(code = temp )
                country_name = a.name
                countries = [Country.objects.get(country_code = temp)]

            dates = {}
            confirmed = {}
            total_confirmed = {}
            cases_smoothed = {}
            deaths_smoothed = {}
            deceased = {}
            total_deceased = {}
            n = 0
            for c in countries:
                n+=1
                print(c.country_code)
                t = World_cases.objects.filter(country_code = c.country_code, date__gte=  form.cleaned_data['start_date'], date__lte= form.cleaned_data['end_date'])
                
                dates[c.country_code] = []
                confirmed[c.country_code] = []
                total_confirmed[c.country_code] = []
                cases_smoothed[c.country_code] = []
                deaths_smoothed[c.country_code] = []
                deceased[c.country_code] = []
                total_deceased[c.country_code] = []
                
                for tup in t:
                    
                    dates[tup.country_code].append(tup.date.strftime('%Y-%m-%d'))

                    if tup.new_cases!=None:
                        confirmed[tup.country_code].append(int(tup.new_cases))
                    else:
                        confirmed[tup.country_code].append(0)

                    if tup.total_cases!=None:
                        total_confirmed[tup.country_code].append(int(tup.total_cases))
                    else:
                        total_confirmed[tup.country_code].append(0)

                    if tup.new_cases_smoothed!=None:
                        cases_smoothed[tup.country_code].append(int(tup.new_cases_smoothed))
                    else:
                        cases_smoothed[tup.country_code].append(0)

                    if tup.new_deaths_smoothed!=None:
                        deaths_smoothed[tup.country_code].append(int(tup.new_deaths_smoothed))
                    else:
                        deaths_smoothed[tup.country_code].append(0)

                    if tup.new_deaths!=None:
                        deceased[tup.country_code].append(int(tup.new_deaths))
                    else:
                        deceased[tup.country_code].append(0)

                    if tup.total_deaths!=None:
                        total_deceased[tup.country_code].append(int(tup.total_deaths))
                    else:
                        total_deceased[tup.country_code].append(0)


                    if len(dates[tup.country_code])!=len(confirmed[tup.country_code]):
                        print(len(dates[tup.country_code]), len(confirmed[tup.country_code]))
                        print(tup.country_code)

            confirmed_on = form.cleaned_data['confirmed']
            total_confirmed_on = form.cleaned_data['total_confirmed']
            cases_smoothed_on = form.cleaned_data['cases_smoothed']
            deaths_smoothed_on = form.cleaned_data['deaths_smoothed']
            deceased_on = form.cleaned_data['deceased']
            total_deceased_on = form.cleaned_data['total_deceased']

            if len(dates)>0:
                download = True

    else:
        form = WorldCasesForm()

    dates_list = []
    confirmed_list = []
    total_confirmed_list = []
    cases_smoothed_list = []
    deaths_smoothed_list = []
    deceased_list = []
    total_deceased_list = []
    
    for k in dates.keys():
        dates_list = dates[k]
        break

    for j in range(len(dates_list)):
        confirmed_list.append(0)
        total_confirmed_list.append(0)
        cases_smoothed_list.append(0)
        deaths_smoothed_list.append(0)
        deceased_list.append(0)
        total_deceased_list.append(0)

    for k in confirmed.keys():
        for j in range(len(dates[k])):
            confirmed_list[j]+= confirmed[k][j]
            total_confirmed_list[j]+=total_confirmed[k][j]
            cases_smoothed_list[j]+=cases_smoothed[k][j]
            deaths_smoothed_list[j]+=deaths_smoothed[k][j]
            deceased_list[j]+=deceased[k][j]
            total_deceased_list[j]+=total_deceased[k][j]
    
    dates = dates_list

    confirmed = [x/n for x in confirmed_list]
    total_confirmed = [x/n for x in total_confirmed_list]
    cases_smoothed = [x/n for x in cases_smoothed_list]
    deaths_smoothed = [x/n for x in deaths_smoothed_list]
    deceased = [x/n for x in deceased_list]
    total_deceased = [x/n for x in total_deceased_list]
    
    fig = Figure()
    canvas = FigureCanvasAgg(fig)

    ax = fig.subplots()
    fig.set_figheight(10)
    fig.set_figwidth(10)
    
    ax.set_title(f"Plot of Covid-19 cases in {country_name} vs Date")

    flag = 0
    df = pd.DataFrame(dates, columns =['Dates'])
    if confirmed_on:
        print(1)
        ax.plot(dates, confirmed, label = 'Confirmed Patients')
        df['Confirmed'] = confirmed
        flag = 1
    if total_confirmed_on:
        flag = 1
        df['Total Confirmed'] = total_confirmed
        print(2)
        ax.plot(dates, total_confirmed, label = 'Total Confirmed Patients')
    if cases_smoothed_on:
        flag = 1
        df['cases_smoothed'] = cases_smoothed
        print(3)
        ax.plot(dates, cases_smoothed, label = 'cases_smoothed Patients')
    if deaths_smoothed_on:
        flag = 1
        df['deaths_smoothed'] = deaths_smoothed
        print(4)
        ax.plot(dates, deaths_smoothed, label = 'deaths_smoothed Patients')
    if deceased_on:
        flag = 1
        df['Deceased'] = deceased
        print(5)
        ax.plot(dates, deceased, label = 'Deceased Patients')
    if total_deceased_on:
        flag = 1
        df['Total Deceased'] = total_deceased
        print(6)
        ax.plot(dates, total_deceased, label = 'Total Deceased Patients')

    if flag == 0:
        print('here')
        ax.plot(['9999-12-12'], [0], label = "nothing")
    else:
        ax.legend()
        fig.autofmt_xdate()
        s = form.cleaned_data['start_date']
        e = form.cleaned_data['end_date']
        diff = e-s
        n = diff.days
        interval = n/12
        xtick_set = set()
        for i in range(13):
            xtick_set.add(s)
            s = s + timedelta(interval)

        xtick_list = [x.strftime("%Y-%m-%d") for x in xtick_set]
        xtick_list.sort()
        ax.set_xticks(xtick_list)
        graph = True

    ax.set_xlabel("Date")
    ax.set_ylabel("Case Count")
    canvas.print_figure("covid/static/images/world_cases.png")
    global admin_user
    context = {"data": t, 'form': form, "download": download, "admin": admin_user, "graph": graph}
    df.to_csv('covid/static/data/world_cases.csv')

    return render(request, "world_cases.html", context)

def india_tests(request):
    return render(request, "india_tests.html", {})

def states_tests(request):
    return render(request, "states_tests.html", {})

def world_tests(request):
    return render(request, "world_tests.html", {})

def india_vaccine(request):
    return render(request, "india_vaccine.html", {})

def states_vaccine(request):
    return render(request, "states_vaccine.html", {})

def world_vaccine(request):
    return render(request, "world_vaccine.html", {})

def insert_data(request):
    if request.method == 'POST':
        form = InsertForm(request.POST)
        if form.is_valid():

            st = form.cleaned_data['data']
            l = st.split()
            t = form.cleaned_data['table']
            if t=="Country_Code":
                x = Country_Code(l[0], l[1])
                x.save()
            elif t=="Country_Continent":
                x = Country_Continent(l[0], l[1])
                x.save()
            elif t=="Country":
                x = Country(l[0], l[1], l[2], l[3], l[4], l[5], l[6], l[7], l[8], l[9], l[10], l[11], l[12], l[13], l[14], l[15])
                x.save()
            elif t=="Hosp_defence":
                x = Hosp_defence(l[0], l[1], l[2])
                x.save()
            elif t=="Hosp_gov":
                x = Hosp_gov(l[0], l[1], l[2], l[3], l[4])
                x.save()
            elif t=="Hosp_railways":
                x = Hosp_railways(l[0], l[1], l[2])
                x.save()
            elif t=="India_cases":
                x = India_cases(l[0], l[1], l[2], l[3], l[4], l[5], l[6])
                x.save()
            elif t=="India_tests":
                x = India_tests(l[0], l[1], l[2], l[3], l[4])
                x.save()
            elif t=="India_vaccine":
                x = India_vaccine(l[0], l[1], l[2], l[3], l[4], l[5], l[6], l[7], l[8], l[9], l[10], l[11], l[12], l[13], l[14])
                x.save()
            elif t=="Patients":
                x = Patients(l[0], l[1], l[2], l[3], l[4], l[5], l[6], l[7], l[8], l[9])
                x.save()
            elif t=="State_cases":
                x = State_cases(l[0], l[1], l[2], l[3], l[4], l[5], l[6])
                x.save()
            elif t=="State_tests":
                x = State_tests(l[0], l[1], l[2], l[3], l[4], l[5], l[6], l[7], l[8], l[9], l[10], l[11], l[12], l[13], l[14], l[15])
                x.save()
            elif t=="State_vaccine":
                x = "State_vaccine"(l[0], l[1], l[2], l[3], l[4], l[5], l[6], l[7], l[8], l[9], l[10], l[11], l[12], l[13], l[14], l[15], l[16])
                x.save()
            elif t=="World_cases":
                x = World_cases(l[0], l[1], l[2], l[3], l[4], l[5], l[6], l[7], l[8], l[9], l[10], l[11], l[12], l[13])
                x.save()
            elif t=="World_tests":
                x = World_tests(l[0], l[1], l[2], l[3], l[4], l[5], l[6], l[7])
                x.save()
            elif t=="World_vaccine":
                x = World_vaccine(l[0], l[1], l[2], l[3], l[4], l[5], l[6], l[7], l[8], l[9])
                x.save()

    else:
        form = InsertForm()
    return render(request, "insert_data.html", {'form': form})

def patients(request):
    return render(request, "patients.html", {})

def hospitals(request):
    return render(request, "hospitals.html", {})