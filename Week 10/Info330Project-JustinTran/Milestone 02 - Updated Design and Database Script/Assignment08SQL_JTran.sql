--**********************************************************************************************--
-- Title: Assigment08 - Final Milestone 02
-- Author: Justin Tran
-- Desc: This file is creating a SQL database script for patients, doctors, clinics, and appointments
-- Change Log: When,Who,What
-- 2020-03-03,Justin Tran,Created File
--***********************************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'PatientsAppointmentsDB_JustinTran')
	 Begin
	  Alter Database [PatientsAppointmentsDB_JustinTran] set Single_user With Rollback Immediate;
	  Drop Database PatientsAppointmentsDB_JustinTran;
	 End
	Create Database PatientsAppointmentsDB_JustinTran;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use PatientsAppointmentsDB_JustinTran;

-- Creating Tables --
Create Table Clinics
(
[ClinicID] int IDENTITY(1,1) NOT NULL,
[ClinicName] Nvarchar(100) NOT NULL,
[ClinicPhoneNumber] Nvarchar(100) NOT NULL,
[ClinicAddress] Nvarchar(100) NOT NULL,
[ClinicCity] Nvarchar(100) NOT NULL,
[ClinicState] NVARCHAR(2) NOT NULL,
[ClinicZipCode] Nvarchar(10) NOT NULL,
);
go

Create Table Patients
(
[PatientID] int IDENTITY(1,1) NOT NULL,
[PatientFirstName]  Nvarchar(100) NOT NUll,
[PatientLastName] Nvarchar(100) NOT NUll,
[PatientPhoneNumber] Nvarchar(100) NOT NUll,
[PatientAddress] Nvarchar(100) NOT NUll,
[PatientCity] Nvarchar(100) NOT NUll,
[PatientState] Nvarchar(2) NOT NUll,
[PatientZipCode] Nvarchar(10) NOT NUll,
);
go

Create Table Doctors
(
[DoctorID] int IDENTITY(1,1) NOT NULL,
[DoctorFirstName]  Nvarchar(100) NOT NUll,
[DoctorLastName] Nvarchar(100) NOT NUll,
[DoctorPhoneNumber] Nvarchar(100) NOT NUll,
[DoctorAddress] Nvarchar(100) NOT NUll,
[DoctorCity] Nvarchar(100) NOT NUll,
[DoctorState] Nvarchar(2) NOT NUll,
[DoctorZipCode] Nvarchar(10) NOT NUll,
);
go

Create Table Appointments
(
[AppointmentID] int IDENTITY(1,1) NOT NULL,
[AppointmentDateTime] datetime NOT NULL,
[AppointmentPatientID] int NOT NULL,
[AppointmentDoctorID] int NOT NULL,
[AppointmentClinicID] int NOT NULL,
);
go
-- Adding Constraints --
------------------------- Clinic table constraints -------------------------
Alter Table Clinics
 Add Constraint pkClinics
  Primary Key (ClinicID);
go

Alter Table Clinics
 Add Constraint uniqueClinicName
  Unique (ClinicName);
go

Alter Table Clinics
 Add Constraint checkClinicPhone
  Check(ClinicPhoneNumber like '[0-9][0-9][0-9]-[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]');
go

Alter Table Clinics
 Add Constraint checkClinicZip
  Check((ClinicZipCode like '[0-9][0-9][0-9][0-9][0-9]') or
  (ClinicZipCode like '[0-9][0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]'));
go
------------------------- Patient table constraints -------------------------
Alter Table Patients
 Add Constraint pkPatients
  Primary Key (PatientID);
go

Alter Table Patients
 Add Constraint checkPatientPhone
  Check(PatientPhoneNumber like '[0-9][0-9][0-9]-[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]');
go

Alter Table Patients
 Add Constraint checkPatientZip
  Check((PatientZipCode like '[0-9][0-9][0-9][0-9][0-9]') or
  (PatientZipCode like '[0-9][0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]'));
go
------------------------- Doctor table constraints -------------------------
Alter Table Doctors
 Add Constraint pkDoctors
  Primary Key (DoctorID);
go

Alter Table Doctors
 Add Constraint checkDoctorPhone
  Check(DoctorPhoneNumber like '[0-9][0-9][0-9]-[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]');
go

Alter Table Doctors
 Add Constraint checkDoctorZip
  Check((DoctorZipCode like '[0-9][0-9][0-9][0-9][0-9]') or
  (DoctorZipCode like '[0-9][0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]'));
go
------------------------- Appointment table constraints -------------------------
Alter Table Appointments 
 Add Constraint fkPatientstoAppointments
  Foreign Key (AppointmentPatientId) References Patients(PatientId);
go

Alter Table Appointments 
 Add Constraint fkDoctorstoAppointments
  Foreign Key (AppointmentDoctorId) References Doctors(DoctorId);
go

Alter Table Appointments 
 Add Constraint fkClinicstoAppointments
  Foreign Key (AppointmentClinicId) References Clinics(ClinicId);
go
-- Adding Views --
go
CREATE VIEW vClinics AS
SELECT TOP 100000
    ClinicID,
    ClinicName,
    ClinicPhoneNumber,
    ClinicAddress,
    ClinicCity,
    ClinicState,
    ClinicZipCode
FROM Clinics
go
Select * from vClinics;

go
CREATE VIEW vPatients AS
SELECT TOP 100000
    PatientID,
    PatientFirstName,
    PatientLastName
    PatientPhoneNumber,
    PatientAddress,
    PatientCity,
    PatientState,
    PatientZipCode
FROM Patients
go
Select * from vPatients;

go
CREATE VIEW vDoctors AS
SELECT TOP 100000
    DoctorID,
    DoctorFirstName,
    DoctorLastName
    DoctorPhoneNumber,
    DoctorAddress,
    DoctorCity,
    DoctorState,
    DoctorZipCode
FROM Doctors
go
Select * from vDoctors;

go
CREATE VIEW vAppointments AS
SELECT TOP 100000
    AppointmentID,
    AppointmentDateTime,
    AppointmentPatientID,
    AppointmentDoctorID,
    AppointmentClinicID
FROM Appointments
go
Select * from vAppointments;

go
CREATE VIEW vAppointmentsByPatientsDoctorsAndClinics AS -- Report view combines data from all tables
SELECT TOP 100000
    AppointmentID,
    Format(AppointmentDateTime, 'MM/dd/yy') as 'AppointmentDate', -- Formatting date to preferred format
    FORMAT(CAST(AppointmentDateTime AS datetime2), N'HH:mm') as 'AppointmentTime',
    PatientID,
    PatientFirstName + ' ' + PatientLastName as 'PatientName',
    PatientPhoneNumber as 'PatientPhoneNumber',
    PatientAddress,
    PatientCity,
    PatientState,
    PatientZipCode,
    DoctorID,
    DoctorFirstName + ' ' + DoctorLastName as 'DoctorName',
    DoctorPhoneNumber,
    DoctorAddress,
    DoctorCity,
    DoctorState,
    DoctorZipCode,
    ClinicID,
    ClinicName,
    ClinicPhoneNumber,
    ClinicAddress,
    ClinicCity,
    ClinicState,
    ClinicZipCode
    FROM Appointments as a JOIN Patients as p -- Simpler names
        ON a.AppointmentPatientId = p.PatientId --The match for both tables, join them by this
    JOIN Doctors as d -- Double join
        ON d.DoctorID = a.AppointmentDoctorID
    JOIN Clinics as c -- Double join
        ON c.ClinicID = a.AppointmentClinicID
go
Select * from vAppointmentsByPatientsDoctorsAndClinics;

-- Add Stored Procedures (Module 04 and 05) --
------------------------- Clinic table stored procedures -------------------------
go
Create Procedure pInsClinics(
@ClinicName Nvarchar(100),
@ClinicPhoneNumber Nvarchar(100),
@ClinicAddress Nvarchar(100),
@ClinicCity Nvarchar(100),
@ClinicState Nvarchar(2),
@ClinicZipCode Nvarchar(110)
)
/* Author: <Justin Tran>
** Desc: Processes insertion of clinic data
** Change Log: When,Who,What
** <2020-03-03>,<Justin Tran>,Created stored procedure.
*/
AS
 Begin
  Declare @RC int = 0;
  Begin Try
   Begin Transaction
    -- Transaction Code --
     Insert Into Clinics(
        ClinicName,
        ClinicPhoneNumber,
        ClinicAddress,
        ClinicCity,
        ClinicState,
        ClinicZipCode
     )
     Values(
        @ClinicName,
        @ClinicPhoneNumber,
        @ClinicAddress,
        @ClinicCity,
        @ClinicState,
        @ClinicZipCode
     )
   Commit Transaction
   Set @RC = +1
  End Try
  Begin Catch
   If(@@Trancount > 0) Rollback Transaction
   Print Error_Message()
   Set @RC = -1
  End Catch
  Return @RC;
 End
go

Create Procedure pUpdClinics(
@ClinicID int,
@ClinicName Nvarchar(100),
@ClinicPhoneNumber Nvarchar(100),
@ClinicAddress Nvarchar(100),
@ClinicCity Nvarchar(100),
@ClinicState Nvarchar(2),
@ClinicZipCode Nvarchar(10)
)
/* Author: <Justin Tran>
** Desc: Processes updating of clinic data
** Change Log: When,Who,What
** <2020-03-03>,<Justin Tran>,Created stored procedure.
*/
AS
 Begin
  Declare @RC int = 0;
  Begin Try
   Begin Transaction
    -- Transaction Code --
     Update Clinics
     Set
        ClinicName = @ClinicName,
        ClinicPhoneNumber = @ClinicPhoneNumber,
        ClinicAddress = @ClinicAddress,
        ClinicCity = @ClinicCity, 
        ClinicState = @ClinicState,
        ClinicZipCode = @ClinicZipCode
     Where ClinicID = @ClinicID
   Commit Transaction
   Set @RC = +1
  End Try
  Begin Catch
   If(@@Trancount > 0) Rollback Transaction
   Print Error_Message()
   Set @RC = -1
  End Catch
  Return @RC;
 End
go

Create Procedure pDelClinics
(@ClinicID int)
/* Author: <Justin Tran>
** Desc: Processes deletion of student data
** Change Log: When,Who,What
** <2020-03-03>,<Justin Tran>,Created stored procedure.
*/
AS
 Begin
  Declare @RC int = 0;
  Begin Try
   Begin Transaction
    -- Transaction Code --
    Delete From Appointments
    Where AppointmentClinicID = @ClinicID -- Removes enrollments that contain studentID (dependencies on Students table)
    Delete From Clinics                      -- This ensures that deleting students does not conflict with enrollments
    Where ClinicID = @ClinicID
   Commit Transaction
   Set @RC = +1
  End Try
  Begin Catch
   If(@@Trancount > 0) Rollback Transaction
   Print Error_Message()
   Set @RC = -1
  End Catch
  Return @RC;
 End
go
------------------------- Patient table stored procedures -------------------------
go
Create Procedure pInsPatients(
@PatientFirstName Nvarchar(100),
@PatientLastName Nvarchar(100),
@PatientPhoneNumber Nvarchar(100),
@PatientAddress Nvarchar(100),
@PatientCity Nvarchar(100),
@PatientState Nvarchar(2),
@PatientZipCode Nvarchar(10)
)
/* Author: <Justin Tran>
** Desc: Processes insertion of Patient data
** Change Log: When,Who,What
** <2020-03-03>,<Justin Tran>,Created stored procedure.
*/
AS
 Begin
  Declare @RC int = 0;
  Begin Try
   Begin Transaction
    -- Transaction Code --
     Insert Into Patients(
        PatientFirstName,
        PatientLastName,
        PatientPhoneNumber,
        PatientAddress,
        PatientCity,
        PatientState,
        PatientZipCode
     )
     Values(
        @PatientFirstName,
        @PatientLastName,
        @PatientPhoneNumber,
        @PatientAddress,
        @PatientCity,
        @PatientState,
        @PatientZipCode
     )
   Commit Transaction
   Set @RC = +1
  End Try
  Begin Catch
   If(@@Trancount > 0) Rollback Transaction
   Print Error_Message()
   Set @RC = -1
  End Catch
  Return @RC;
 End
go

Create Procedure pUpdPatients(
@PatientID int,
@PatientFirstName Nvarchar(100),
@PatientLastName Nvarchar(100),
@PatientPhoneNumber Nvarchar(100),
@PatientAddress Nvarchar(100),
@PatientCity Nvarchar(100),
@PatientState Nvarchar(2),
@PatientZipCode Nvarchar(10)
)
/* Author: <Justin Tran>
** Desc: Processes updating of Patient data
** Change Log: When,Who,What
** <2020-03-03>,<Justin Tran>,Created stored procedure.
*/
AS
 Begin
  Declare @RC int = 0;
  Begin Try
   Begin Transaction
    -- Transaction Code --
     Update Patients
     Set
        PatientFirstName = @PatientFirstName,
        PatientLastName = @PatientLastName,
        PatientPhoneNumber = @PatientPhoneNumber,
        PatientAddress = @PatientAddress,
        PatientCity = @PatientCity, 
        PatientState = @PatientState,
        PatientZipCode = @PatientZipCode
     Where PatientID = @PatientID
   Commit Transaction
   Set @RC = +1
  End Try
  Begin Catch
   If(@@Trancount > 0) Rollback Transaction
   Print Error_Message()
   Set @RC = -1
  End Catch
  Return @RC;
 End
go

Create Procedure pDelPatients
(@PatientID int)
/* Author: <Justin Tran>
** Desc: Processes deletion of Patient data
** Change Log: When,Who,What
** <2020-03-03>,<Justin Tran>,Created stored procedure.
*/
AS
 Begin
  Declare @RC int = 0;
  Begin Try
   Begin Transaction
    -- Transaction Code --
    Delete From Appointments
    Where AppointmentPatientID = @PatientID
    Delete From Patients
    Where PatientID = @PatientID
   Commit Transaction
   Set @RC = +1
  End Try
  Begin Catch
   If(@@Trancount > 0) Rollback Transaction
   Print Error_Message()
   Set @RC = -1
  End Catch
  Return @RC;
 End
go
------------------------- Doctor table stored procedures -------------------------
go
Create Procedure pInsDoctors(
@DoctorFirstName Nvarchar(100),
@DoctorLastName Nvarchar(100),
@DoctorPhoneNumber Nvarchar(100),
@DoctorAddress Nvarchar(100),
@DoctorCity Nvarchar(100),
@DoctorState Nvarchar(2),
@DoctorZipCode Nvarchar(10)
)
/* Author: <Justin Tran>
** Desc: Processes insertion of Doctor data
** Change Log: When,Who,What
** <2020-03-03>,<Justin Tran>,Created stored procedure.
*/
AS
 Begin
  Declare @RC int = 0;
  Begin Try
   Begin Transaction
    -- Transaction Code --
     Insert Into Doctors(
        DoctorFirstName,
        DoctorLastName,
        DoctorPhoneNumber,
        DoctorAddress,
        DoctorCity,
        DoctorState,
        DoctorZipCode
     )
     Values(
        @DoctorFirstName,
        @DoctorLastName,
        @DoctorPhoneNumber,
        @DoctorAddress,
        @DoctorCity,
        @DoctorState,
        @DoctorZipCode
     )
   Commit Transaction
   Set @RC = +1
  End Try
  Begin Catch
   If(@@Trancount > 0) Rollback Transaction
   Print Error_Message()
   Set @RC = -1
  End Catch
  Return @RC;
 End
go

Create Procedure pUpdDoctors(
@DoctorID int,
@DoctorFirstName Nvarchar(100),
@DoctorLastName Nvarchar(100),
@DoctorPhoneNumber Nvarchar(100),
@DoctorAddress Nvarchar(100),
@DoctorCity Nvarchar(100),
@DoctorState Nvarchar(2),
@DoctorZipCode Nvarchar(10)
)
/* Author: <Justin Tran>
** Desc: Processes updating of Doctor data
** Change Log: When,Who,What
** <2020-03-03>,<Justin Tran>,Created stored procedure.
*/
AS
 Begin
  Declare @RC int = 0;
  Begin Try
   Begin Transaction
    -- Transaction Code --
     Update Doctors
     Set
        DoctorFirstName = @DoctorFirstName,
        DoctorLastName = @DoctorLastName,
        DoctorPhoneNumber = @DoctorPhoneNumber,
        DoctorAddress = @DoctorAddress,
        DoctorCity = @DoctorCity, 
        DoctorState = @DoctorState,
        DoctorZipCode = @DoctorZipCode
     Where DoctorID = @DoctorID
   Commit Transaction
   Set @RC = +1
  End Try
  Begin Catch
   If(@@Trancount > 0) Rollback Transaction
   Print Error_Message()
   Set @RC = -1
  End Catch
  Return @RC;
 End
go

Create Procedure pDelDoctors
(@DoctorID int)
/* Author: <Justin Tran>
** Desc: Processes deletion of Doctor data
** Change Log: When,Who,What
** <2020-03-03>,<Justin Tran>,Created stored procedure.
*/
AS
 Begin
  Declare @RC int = 0;
  Begin Try
   Begin Transaction
    -- Transaction Code --
    Delete From Appointments
    Where AppointmentDoctorID = @DoctorID
    Delete From Doctors
    Where DoctorID = @DoctorID
   Commit Transaction
   Set @RC = +1
  End Try
  Begin Catch
   If(@@Trancount > 0) Rollback Transaction
   Print Error_Message()
   Set @RC = -1
  End Catch
  Return @RC;
 End
go
------------------------- Appointment table stored procedures -------------------------
Create Procedure pInsAppointments(
@AppointmentDateTime datetime,
@AppointmentPatientID int,
@AppointmentDoctorID int,
@AppointmentClinicID int
)
/* Author: <Justin Tran>
** Desc: Processes insertion of appointment data
** Change Log: When,Who,What
** <2020-03-03>,<Justin Tran>,Created stored procedure.
*/
AS
 Begin
  Declare @RC int = 0;
  Begin Try
   Begin Transaction
    -- Transaction Code --
     Insert Into Appointments(
        AppointmentDateTime,
        AppointmentPatientID,
        AppointmentDoctorID,
        AppointmentClinicID
    )
     Values(
        @AppointmentDateTime,
        @AppointmentPatientID,
        @AppointmentDoctorID,
        @AppointmentClinicID
    )
   Commit Transaction
   Set @RC = +1
  End Try
  Begin Catch
   If(@@Trancount > 0) Rollback Transaction
   Print Error_Message()
   Set @RC = -1
  End Catch
  Return @RC;
 End
go

Create Procedure pUpdAppointments(
@AppointmentID int,
@AppointmentDateTime datetime,
@AppointmentPatientID int,
@AppointmentDoctorID int,
@AppointmentClinicID int
)
/* Author: <Justin Tran>
** Desc: Processes updating of appointment data
** Change Log: When,Who,What
** <2020-03-03>,<Justin Tran>,Created stored procedure.
*/
AS
 Begin
  Declare @RC int = 0;
  Begin Try
   Begin Transaction
    -- Transaction Code --
    Update Appointments
    Set
        AppointmentDateTime = @AppointmentDateTime,
        AppointmentPatientID = @AppointmentPatientID,
        AppointmentDoctorID = @AppointmentDoctorID,
        AppointmentClinicID = @AppointmentClinicID
    Where AppointmentID = @AppointmentID
   Commit Transaction
   Set @RC = +1
  End Try
  Begin Catch
   If(@@Trancount > 0) Rollback Transaction
   Print Error_Message()
   Set @RC = -1
  End Catch
  Return @RC;
 End
go

Create Procedure pDelAppointments
(@AppointmentID int)
/* Author: <Justin Tran>
** Desc: Processes deletion of appointment data
** Change Log: When,Who,What
** <2020-03-03>,<Justin Tran>,Created stored procedure.
*/
AS
 Begin
  Declare @RC int = 0;
  Begin Try
   Begin Transaction
    -- Transaction Code --
    Delete From Appointments
    Where AppointmentID = @AppointmentID
   Commit Transaction
   Set @RC = +1
  End Try
  Begin Catch
   If(@@Trancount > 0) Rollback Transaction
   Print Error_Message()
   Set @RC = -1
  End Catch
  Return @RC;
 End
go
-- Setting Database Permissions --
Deny Select, Insert, Update, Delete On Clinics To Public;
Grant Select On vClinics To Public;
Grant Execute On pInsClinics To Public;
Grant Execute On pUpdClinics To Public;
Grant Execute On pDelClinics To Public;

Deny Select, Insert, Update, Delete On Doctors To Public;
Grant Select On vDoctors To Public;
Grant Execute On pInsDoctors To Public;
Grant Execute On pUpdDoctors To Public;
Grant Execute On pDelDoctors To Public;

Deny Select, Insert, Update, Delete On Patients To Public;
Grant Select On vPatients To Public;
Grant Execute On pInsPatients To Public;
Grant Execute On pUpdPatients To Public;
Grant Execute On pDelPatients To Public;

Deny Select, Insert, Update, Delete On Appointments To Public;
Grant Select On vAppointments To Public;
Grant Execute On pInsAppointments To Public;
Grant Execute On pUpdAppointments To Public;
Grant Execute On pDelAppointments To Public;

Grant Select On vAppointmentsByPatientsDoctorsAndClinics To Public;
--< Test Views and Sprocs >--
-- Testing insertion of data --
Declare @Status int,
        @NewClinicID int,
        @NewPatientID int,
        @NewDoctorID int,
        @NewAppointmentID int;

Exec @Status = pInsClinics
    @ClinicName = 'Clinic Name',
    @ClinicPhoneNumber = '123-456-7890',
    @ClinicAddress = 'Clinic Address',
    @ClinicCity = 'Clinic',
    @ClinicState = 'CA',
    @ClinicZipCode = '22222';
Select Case @Status
  When +1 Then 'Insert was successful!'
  When -1 Then 'Insert failed! Check if all the data is there'
  End as [Status]
Select * from Clinics;
Set @NewClinicID = IDENT_CURRENT('Clinics');

Exec @Status = pInsPatients
    @PatientFirstName = 'First',
    @PatientLastName = 'Last',
    @PatientPhoneNumber = '123-456-7890',
    @PatientAddress = 'Test Address',
    @PatientCity = 'Seattle',
    @PatientState = 'WA',
    @PatientZipCode = '98105';
Select Case @Status
  When +1 Then 'Insert was successful!'
  When -1 Then 'Insert failed! Check if all the data is there'
  End as [Status]
Select * from Patients;
Set @NewPatientID = IDENT_CURRENT('Patients');

Exec @Status = pInsDoctors
    @DoctorFirstName = 'Doctor',
    @DoctorLastName = 'Doctor',
    @DoctorPhoneNumber = '456-456-4564',
    @DoctorAddress = 'Doctor Address',
    @DoctorCity = 'Canada',
    @DoctorState = 'CA',
    @DoctorZipCode = '09876';
Select Case @Status
  When +1 Then 'Insert was successful!'
  When -1 Then 'Insert failed! Check if all the data is there'
  End as [Status]
Select * from Doctors;
Set @NewDoctorID = IDENT_CURRENT('Doctors');

Exec @Status = pInsAppointments
    @AppointmentDateTime = '1-1-2020 9:00',
    @AppointmentPatientID = @NewPatientID,
    @AppointmentDoctorID = @NewDoctorID,
    @AppointmentClinicID = @NewClinicID
Select Case @Status
  When +1 Then 'Insert was successful!'
  When -1 Then 'Insert failed! Check if data matches variables and check constraints are not violated.'
  End as [Status]
Select * from Appointments;
Set @NewAppointmentID = IDENT_CURRENT('Appointments');

Select * from vAppointmentsByPatientsDoctorsAndClinics
-- Testing updating of data --
Exec @Status = pUpdClinics
    @ClinicID = @NewClinicID,
    @ClinicName = 'Updated Name',
    @ClinicPhoneNumber = '123-123-1234',
    @ClinicAddress = 'Address 1',
    @ClinicCity = 'Bellevue',
    @ClinicState = 'CA',
    @ClinicZipCode = '12345';
Select Case @Status
  When +1 Then 'Update was successful!'
  When -1 Then 'Update failed! Check if all the data is there.'
  End as [Status]
Select * from Clinics;
Set @NewClinicID = IDENT_CURRENT('Clinics');

Exec @Status = pUpdPatients
    @PatientID = @NewPatientID,
    @PatientFirstName = 'New',
    @PatientLastName = 'Test',
    @PatientPhoneNumber = '000-000-0000',
    @PatientAddress = 'Hello',
    @PatientCity = 'Washington',
    @PatientState = 'WA',
    @PatientZipCode = '55555';
Select Case @Status
  When +1 Then 'Update was successful!'
  When -1 Then 'Update failed! Check if data matches variables and check constraints are not violated.'
  End as [Status]
Select * from Patients;
Set @NewPatientID = IDENT_CURRENT('Patients');

Exec @Status = pUpdDoctors
    @DoctorID = @NewDoctorID,
    @DoctorFirstName = 'Hello',
    @DoctorLastName = 'There',
    @DoctorPhoneNumber = '987-987-9876',
    @DoctorAddress = 'Doctor',
    @DoctorCity = 'Texas',
    @DoctorState = 'TX',
    @DoctorZipCode = '45678';
Select Case @Status
  When +1 Then 'Update was successful!'
  When -1 Then 'Update failed! Check if data matches variables and check constraints are not violated.'
  End as [Status]
Select * from Doctors;
Set @NewDoctorID = IDENT_CURRENT('Doctors');

Exec @Status = pUpdAppointments
    @AppointmentID = @NewAppointmentID,
    @AppointmentDateTime = '12-31-2025 23:00',
    @AppointmentPatientID = @NewPatientID,
    @AppointmentDoctorID = @NewDoctorID,
    @AppointmentClinicID = @NewClinicID;
Select Case @Status
  When +1 Then 'Update was successful!'
  When -1 Then 'Update failed! Check if data matches variables and check constraints are not violated (Course Starting Date in particular).'
  End as [Status]
Select * from Appointments;
Set @NewAppointmentID = IDENT_CURRENT('Appointments');

Select * from vAppointmentsByPatientsDoctorsAndClinics
-- Testing deletion of data --
Exec @Status = pDelClinics
    @ClinicID = @NewClinicID;
Select Case @Status
  When +1 Then 'Deletion was successful!'
  When -1 Then 'Deletion failed! Check if the dependent tables are dealt with!'
  End as [Status]
Select * from Clinics;
Set @NewClinicID = IDENT_CURRENT('Clinics');

Exec @Status = pDelPatients
    @PatientID = @NewPatientID;
Select Case @Status
  When +1 Then 'Deletion was successful!'
  When -1 Then 'Deletion failed! Check if the dependent tables are dealt with!'
  End as [Status]
Select * from Patients;
Set @NewPatientID = IDENT_CURRENT('Patients');

Exec @Status = pDelDoctors
    @DoctorID = @NewDoctorID;
Select Case @Status
  When +1 Then 'Deletion was successful!'
  When -1 Then 'Deletion failed! Check if the dependent tables are dealt with!'
  End as [Status]
Select * from Doctors;
Set @NewDoctorID = IDENT_CURRENT('Doctors');

Exec @Status = pDelAppointments
    @AppointmentID = @NewAppointmentID;
Select Case @Status
  When +1 Then 'Deletion was successful!'
  When -1 Then 'Deletion failed! Check if the dependent tables are dealt with!'
  End as [Status]
Select * from Appointments;
Set @NewAppointmentID = IDENT_CURRENT('Appointments');

Select * from vAppointmentsByPatientsDoctorsAndClinics
--{ IMPORTANT }--
-- To get full credit, your script must run without having to highlight individual statements!!!
/**************************************************************************************************/