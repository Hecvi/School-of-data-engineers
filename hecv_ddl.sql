CREATE TABLE itde1.hecv_shelter (
    Shelter_id CHAR(4),
    City VARCHAR2(32) NOT NULL,
    Number_of_seats CHAR(4) NOT NULL,
    Number_of_available_seats CHAR(4) NOT NULL,
    State_owned CHAR(4) NOT NULL,
    By_spent_time VARCHAR2(16) NOT NULL,
    CONSTRAINT hecv_shelter_shelter_id_PK PRIMARY KEY (Shelter_id)
)

/
CREATE TABLE itde1.hecv_veterinary_services (
	Shelter_id CHAR(4),
	X_ray CHAR(3) NOT NULL,
	Surgery CHAR(3) NOT NULL,
	Therapy CHAR(3) NOT NULL,
	Dentistry CHAR(3) NOT NULL,
	Cardiology CHAR(3) NOT NULL,
	Ultrasound CHAR(3) NOT NULL,
	Ophthalmology CHAR(3) NOT NULL,
	Gastroenterology CHAR(3) NOT NULL,
	Electrocardiogram CHAR(3) NOT NULL,
    CONSTRAINT vet_services_x_shelter_FK FOREIGN KEY (Shelter_id)
    REFERENCES itde1.hecv_shelter (Shelter_id)
)

/
CREATE TABLE itde1.hecv_pets (
	Pet_id CHAR(4),
	Shelter_id CHAR(4),
	Nickname VARCHAR2(32),
	Type_of_animal CHAR(3) NOT NULL CHECK (Type_of_animal IN ('Cat', 'Dog')),
	Age NUMBER,
	Gender CHAR(6) NOT NULL CHECK (Gender IN ('Male', 'Female')),
	Breed VARCHAR2(32) NOT NULL,
	CONSTRAINT itde1_hecv_pets_PK PRIMARY KEY (Pet_id),
    CONSTRAINT hecv_pets_x_hecv_shelter_FK FOREIGN KEY (Shelter_id)
    REFERENCES itde1.hecv_shelter (Shelter_id)
)

/
CREATE TABLE itde1.hecv_people (
	Human_id CHAR(4) NOT NULL,
	Name_of_person VARCHAR2(32) DEFAULT 'None' NOT NULL,
	Surname_of_person VARCHAR2(32) DEFAULT 'None' NOT NULL,
	Phone_number VARCHAR2(32) NOT NULL,
	CONSTRAINT itde1_hecv_people_PK PRIMARY KEY (Human_id)
)

/
CREATE TABLE itde1.hecv_want_to_take_home (
	Human_id CHAR(4) NOT NULL,
	Pet_id CHAR(4) NOT NULL,
    CONSTRAINT want_to_take_home_x_people_FK FOREIGN KEY (Human_id)
    REFERENCES itde1.hecv_people (Human_id),
    CONSTRAINT want_to_take_home_x_pets_FK FOREIGN KEY (Pet_id)
    REFERENCES itde1.hecv_pets (Pet_id)
);




    
    