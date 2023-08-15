from covid.models import  Country_Code, Country_Continent, Country, Hosp_defence, Hosp_gov, Hosp_railways, India_cases, India_tests, India_vaccine, Patients, State_cases, State_tests, State_vaccine, World_cases, World_tests, World_vaccine
import csv
from tqdm import tqdm


def run():
    with open('covid/data/country_code.csv') as file:
        reader = csv.reader(file)
        next(reader)  # Advance past the header

        Country_Code.objects.all().delete()
        for row in tqdm(reader):
            for i in range(len(row)):
                if len(row[i])==0:
                    row[i] = None 
            v = Country_Code(row[0], row[1])
            v.save()

    # print(1)
    # with open('covid/data/country.csv') as file:
    #     reader = csv.reader(file)
    #     next(reader)  # Advance past the header

    #     Country.objects.all().delete()
    #     for row in tqdm(reader):
    #         for i in range(len(row)):
    #             if len(row[i])==0:
    #                 row[i] = None 
    #         v = Country(row[0], row[1], row[2], row[3], row[4], row[5], row[6], row[7], row[8], row[9], row[10], row[11], row[12], row[13], row[14], row[15])
    #         v.save()

    # print(2)
    # with open('covid/data/country_continent.csv') as file:
    #     reader = csv.reader(file)
    #     next(reader)  # Advance past the header

    #     Country_Continent.objects.all().delete()
    #     for row in tqdm(reader):
    #         for i in range(len(row)):
    #             if len(row[i])==0:
    #                 row[i] = None 
    #         v = Country_Continent(row[0], row[1])
    #         v.save()

    # print(3)
    # with open('covid/data/hosp_defence.csv') as file:
    #     reader = csv.reader(file)
    #     next(reader)  # Advance past the header

    #     Hosp_defence.objects.all().delete()
    #     for row in tqdm(reader):
    #         for i in range(len(row)):
    #             if len(row[i])==0:
    #                 row[i] = None 
    #         v = Hosp_defence(row[0], row[1], row[2])
    #         v.save()

    # print(4)
    # with open('covid/data/hosp_gov.csv') as file:
    #     reader = csv.reader(file)
    #     next(reader)  # Advance past the header

    #     Hosp_gov.objects.all().delete()
    #     for row in tqdm(reader):
    #         for i in range(len(row)):
    #             if len(row[i])==0:
    #                 row[i] = None 
    #         v = Hosp_gov(row[0], row[1], row[2], row[3], row[4])
    #         v.save()

    # print(5)
    # with open('covid/data/hosp_railways.csv') as file:
    #     reader = csv.reader(file)
    #     next(reader)  # Advance past the header

    #     Hosp_railways.objects.all().delete()
    #     for row in tqdm(reader):
    #         for i in range(len(row)):
    #             if len(row[i])==0:
    #                 row[i] = None 
    #         v = Hosp_railways(row[0], row[1], row[2])
    #         v.save()

    # print(6)
    # with open('covid/data/india_cases.csv') as file:
    #     reader = csv.reader(file)
    #     next(reader)  # Advance past the header

    #     India_cases.objects.all().delete()
    #     for row in tqdm(reader):
    #         for i in range(len(row)):
    #             if len(row[i])==0:
    #                 row[i] = None 
    #         v = India_cases(row[0], row[1], row[2], row[3], row[4], row[5], row[6])
    #         v.save()

    # print(7)
    # with open('covid/data/india_tests.csv') as file:
    #     reader = csv.reader(file)
    #     next(reader)  # Advance past the header

    #     India_tests.objects.all().delete()
    #     for row in tqdm(reader):
    #         for i in range(len(row)):
    #             if len(row[i])==0:
    #                 row[i] = None 
    #         v = India_tests(row[0], row[1], row[2], row[3], row[4])
    #         v.save()

    # print(8)
    # with open('covid/data/india_vaccine.csv') as file:
    #     reader = csv.reader(file)
    #     next(reader)  # Advance past the header

    #     India_vaccine.objects.all().delete()
    #     for row in tqdm(reader):
    #         for i in range(len(row)):
    #             if len(row[i])==0:
    #                 row[i] = None 
    #         v = India_vaccine(row[0], row[1], row[2], row[3], row[4], row[5], row[6], row[7], row[8], row[9], row[10], row[11], row[12], row[13], row[14])
    #         v.save()

    # print(9)
    # with open('covid/data/patients.csv') as file:
    #     reader = csv.reader(file)
    #     next(reader)  # Advance past the header

    #     Patients.objects.all().delete()
    #     for row in tqdm(reader):
    #         for i in range(len(row)):
    #             if len(row[i])==0:
    #                 row[i] = None 
    #         v = Patients(row[0], row[1], row[2], row[3], row[4], row[5], row[6], row[7], row[8], row[9])
    #         v.save()

    # print(10)
    # with open('covid/data/state_cases.csv') as file:
    #     reader = csv.reader(file)
    #     next(reader)  # Advance past the header

    #     State_cases.objects.all().delete()
    #     for row in tqdm(reader):
    #         for i in range(len(row)):
    #             if len(row[i])==0:
    #                 row[i] = None 
    #         v = State_cases(row[0], row[1], row[2], row[3], row[4], row[5], row[6])
    #         v.save()

    # print(11)
    # with open('covid/data/state_tests.csv') as file:
    #     reader = csv.reader(file)
    #     next(reader)  # Advance past the header

    #     State_tests.objects.all().delete()
    #     for row in tqdm(reader):
    #         for i in range(len(row)):
    #             if len(row[i])==0:
    #                 row[i] = None 
    #         v = State_tests(row[0], row[1], row[2], row[3], row[4], row[5], row[6], row[7], row[8], row[9], row[10], row[11], row[12], row[13], row[14], row[15])
    #         v.save()

    # print(12)
    # with open('covid/data/state_vaccine.csv') as file:
    #     reader = csv.reader(file)
    #     next(reader)  # Advance past the header

    #     State_vaccine.objects.all().delete()
    #     for row in tqdm(reader):
    #         for i in range(len(row)):
    #             if len(row[i])==0:
    #                 row[i] = None 
    #         v = State_vaccine(row[0], row[1], row[2], row[3], row[4], row[5], row[6], row[7], row[8], row[9], row[10], row[11], row[12], row[13], row[14], row[15], row[16])
    #         v.save()

    # print(13)
    # with open('covid/data/world_cases.csv') as file:
    #     reader = csv.reader(file)
    #     next(reader)  # Advance past the header

    #     World_cases.objects.all().delete()
    #     for row in tqdm(reader):
    #         for i in range(len(row)):
    #             if len(row[i])==0:
    #                 row[i] = None 
    #         v = World_cases(row[0], row[1], row[2], row[3], row[4], row[5], row[6], row[7], row[8], row[9], row[10], row[11], row[12], row[13])
    #         v.save()

    # print(14)
    # with open('covid/data/world_tests.csv') as file:
    #     reader = csv.reader(file)
    #     next(reader)  # Advance past the header

    #     World_tests.objects.all().delete()
    #     for row in tqdm(reader):
    #         for i in range(len(row)):
    #             if len(row[i])==0:
    #                 row[i] = None 
    #         v = World_tests(row[0], row[1], row[2], row[3], row[4], row[5], row[6], row[7])
    #         v.save()

    # print(15)
    # with open('covid/data/world_vaccine.csv') as file:
    #     reader = csv.reader(file)
    #     next(reader)  # Advance past the header

    #     World_vaccine.objects.all().delete()
    #     for row in tqdm(reader):
    #         for i in range(len(row)):
    #             if len(row[i])==0:
    #                 row[i] = None 
    #         v = World_vaccine(row[0], row[1], row[2], row[3], row[4], row[5], row[6], row[7], row[8], row[9])
    #         v.save()
    # print(16)
    print("done")