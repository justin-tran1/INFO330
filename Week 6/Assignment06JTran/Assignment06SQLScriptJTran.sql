--**********************************************************************************************--
-- Title: Assigment06 - Midterm
-- Author: Justin Tran
-- Desc: This file demonstrates how to design and create;
--       tables, constraints, views, stored procedures, and permissions
-- Change Log: When,Who,What
-- 2020-02-18,Justin Tran,Created File
--***********************************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_JustinTran')
	 Begin
	  Alter Database [Assignment06DB_JustinTran] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_JustinTran;
	 End
	Create Database Assignment06DB_JustinTran;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_JustinTran;

-- Create Tables (Module 01)--
Create Table Students
(
[StudentID] int IDENTITY(1,1) NOT NULL,
[StudentNumber] Nvarchar(100) NOT NULL,
[StudentFirstName] Nvarchar(100) NOT NULL,
[StudentLastName] Nvarchar(100) NOT NULL,
[StudentEmail] Nvarchar(100) NOT NULL,
[StudentPhone] Nvarchar(100) NULL,
[StudentAddress1] Nvarchar(100) NOT NULL,
[StudentAddress2] Nvarchar(100) NULL,
[StudentCity] Nvarchar(100) NOT NULL,
[StudentStateCode] Nvarchar(100) NOT NULL,
[StudentZipCode] Nvarchar(100) NOT NULL,
);
go

Create Table Courses
(
[CourseID] int IDENTITY(1,1) NOT NULL,
[CourseName]  Nvarchar(100) NOT NUll,
[CourseStartDate] date NULL,
[CourseEndDate] date NULL,
[CourseStartTime] time NULL,
[CourseEndTime] time NULL,
[CourseWeekDays] Nvarchar(100) NULL,
[CourseCurrentPrice] money NULL,
);
go

Create Table Enrollments
(
[EnrollmentID] int IDENTITY(1,1) NOT NULL,
[StudentID] int NOT NULL,
[CourseID] int NOT NULL,
[EnrollmentDateTime] Datetime NOT NULL,
[EnrollmentPrice] money NOT NULL,
);
go

-- Add Constraints (Module 02) --
Alter Table Students
 Add Constraint pkStudents
  Primary Key (StudentID);
go

Alter Table Courses
 Add Constraint pkCourses
  Primary Key (CourseID);
go

Alter Table Enrollments
 Add Constraint pkEnrollments
  Primary Key (EnrollmentID);
go

Alter Table Enrollments
 Add Constraint fkStudentsToEnrollments
  Foreign Key (StudentId) References Students(StudentId);
go

Alter Table Enrollments
 Add Constraint fkCoursesToEnrollments
  Foreign Key (CourseId) References Courses(CourseId);
go

Alter Table Courses
 Add Constraint uniqueCheckCourse
  Unique (CourseName);
go

Alter Table Students
 Add Constraint uniqueCheckStudentNum
  Unique (StudentNumber);
go

Alter Table Students
 Add Constraint uniqueCheckStudentEmail
  Unique (StudentEmail);
go

Alter Table Students
 Add Constraint checkZip
  Check((StudentZipCode like '[0-9][0-9][0-9][0-9][0-9]') or
  (StudentZipCode like '[0-9][0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]'));
go

Alter Table Students
 Add Constraint checkPhone
  Check(StudentPhone like '([0-9][0-9][0-9])-[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]');
go

Alter Table Courses
 Add Constraint checkEndDate
  Check (CourseEndDate > CourseStartDate);
go

Alter Table Courses
 Add Constraint checkEndTime
  Check (CourseEndTime > CourseStartTime);
go

Alter Table Enrollments
 Add Constraint dfEnrollmentDateTime
  Default GetDate() For EnrollmentDateTime;
go

Create FUNCTION dbo.fnGetStartingDate -- From Professor's Root video in module 4
(@CourseID int)
Returns datetime
AS
    Begin
    Return(Select CourseStartDate
        From Courses
        Where CourseID = @CourseID)
    End
go

Alter Table Enrollments
 Add Constraint checkStartingDate
  Check (EnrollmentDateTime < dbo.fnGetStartingDate(CourseID)); -- Using the function that returned a datetime data type
go

-- Add Views (Module 03 and 04) --
go
CREATE VIEW vStudents AS
SELECT TOP 100000
    StudentID,
    StudentNumber,
    StudentFirstName,
    StudentLastName,
    StudentEmail,
    StudentPhone,
    StudentAddress1,
    StudentAddress2,
    StudentCity,
    StudentStateCode,
    StudentZipCode
FROM Students
go
Select * from vStudents;

go
CREATE VIEW vCourses AS
SELECT TOP 100000
    CourseID,
    CourseName,
    CourseStartDate,
    CourseEndDate,
    CourseStartTime,
    CourseEndTime,
    CourseWeekDays,
    CourseCurrentPrice
FROM Courses
go
Select * from vCourses;

go
CREATE VIEW vEnrollments AS
SELECT TOP 100000
    EnrollmentID,
    StudentID,
    CourseID,
    EnrollmentDateTime,
    EnrollmentPrice
FROM Enrollments
go
Select * from vEnrollments;

go
CREATE VIEW vReportView AS -- Report view combines data from all tables
SELECT TOP 100000
    CourseName as 'Course',
    Format(CourseStartDate, 'MM/dd/yy') + ' to ' + FORMAT(CourseEndDate, 'MM/dd/yy') as 'Dates1', -- Formatting date to preferred format
    FORMAT(CAST(CourseStartTime AS datetime2), N'hh:mm') + 'PM' as 'Start',
    FORMAT(CAST(CourseEndTime AS datetime2), N'hh:mm') + 'PM' as 'End',
    CourseWeekDays as 'Days',
    Format(CourseCurrentPrice, 'C0', 'en-US') as 'Price',
    StudentFirstName + ' ' + StudentLastName as 'Student',
    StudentNumber as 'Number',
    StudentEmail as 'Email',
    StudentPhone as 'Phone',
    StudentAddress1 + ' ' + StudentCity + ', ' + StudentStateCode + ', ' + StudentZipCode as 'Address',
    Format(EnrollmentDateTime, 'MM/dd/yy') as 'Signup Date', -- Formatting date to preferred format
    Format(EnrollmentPrice, 'C0', 'en-US') as 'Paid' -- Shows $ and no decimals, just like the in the metadata spreadsheet
    FROM Students as s JOIN Enrollments as e -- Simpler names
        ON s.StudentId = e.StudentId --The match for both tables, join them by this
    JOIN Courses as c -- Double join
        ON e.CourseID = c.CourseID
go
Select * from vReportView;

-- Add Stored Procedures (Module 04 and 05) --
go
Create Procedure pInsStudents(
@StudentNumber Nvarchar(100),
@StudentFirstName Nvarchar(100),
@StudentLastName Nvarchar(100),
@StudentEmail Nvarchar(100),
@StudentPhone Nvarchar(100),
@StudentAddress1 Nvarchar(100),
@StudentAddress2 Nvarchar(100),
@StudentCity Nvarchar(100),
@StudentStateCode Nvarchar(100),
@StudentZipCode Nvarchar(100)
)
/* Author: <Justin Tran>
** Desc: Processes insertion of student data
** Change Log: When,Who,What
** <2020-02-07>,<Justin Tran>,Created stored procedure.
*/
AS
 Begin
  Declare @RC int = 0;
  Begin Try
   Begin Transaction
    -- Transaction Code --
     Insert Into Students(
        StudentNumber,
        StudentFirstName,
        StudentLastName,
        StudentEmail,
        StudentPhone,
        StudentAddress1,
        StudentAddress2,
        StudentCity,
        StudentStateCode,
        StudentZipCode
     )
     Values(
        @StudentNumber,
        @StudentFirstName,
        @StudentLastName,
        @StudentEmail,
        @StudentPhone,
        @StudentAddress1,
        @StudentAddress2,
        @StudentCity,
        @StudentStateCode,
        @StudentZipCode
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

Create Procedure pUpdStudents(
@StudentNumber Nvarchar(100),
@StudentFirstName Nvarchar(100),
@StudentLastName Nvarchar(100),
@StudentEmail Nvarchar(100),
@StudentPhone Nvarchar(100),
@StudentAddress1 Nvarchar(100),
@StudentAddress2 Nvarchar(100),
@StudentCity Nvarchar(100),
@StudentStateCode Nvarchar(100),
@StudentZipCode Nvarchar(100)
)
/* Author: <Justin Tran>
** Desc: Processes updating of student data
** Change Log: When,Who,What
** <2020-02-07>,<Justin Tran>,Created stored procedure.
*/
AS
 Begin
  Declare @RC int = 0;
  Begin Try
   Begin Transaction
    -- Transaction Code --
     Update Students
     Set
        StudentNumber = @StudentNumber,
        StudentFirstName = @StudentFirstName,
        StudentLastName = @StudentLastName,
        StudentEmail = @StudentEmail,
        StudentPhone = @StudentPhone,
        StudentAddress1 = @StudentAddress1,
        StudentAddress2 = @StudentAddress2,
        StudentCity = @StudentCity,
        StudentStateCode = @StudentStateCode,
        StudentZipCode = @StudentZipCode
     Where StudentID = IDENT_CURRENT('Students')
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

Create Procedure pDelStudents
/* Author: <Justin Tran>
** Desc: Processes deletion of student data
** Change Log: When,Who,What
** <2020-02-07>,<Justin Tran>,Created stored procedure.
*/
AS
 Begin
  Declare @RC int = 0;
  Begin Try
   Begin Transaction
    -- Transaction Code --
    Delete From Enrollments
    Where StudentID = IDENT_CURRENT('Students') -- Removes enrollments that contain studentID (dependencies on Students table)
    Delete From Students                        -- This ensures that deleting students does not conflict with enrollments
    Where StudentID = IDENT_CURRENT('Students')
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

Create Procedure pInsCourses(
@CourseName Nvarchar(100),
@CourseStartDate date,
@CourseEndDate date,
@CourseStartTime time,
@CourseEndTime time,
@CourseWeekDays Nvarchar(100),
@CourseCurrentPrice money
)
/* Author: <Justin Tran>
** Desc: Processes insertion of course data
** Change Log: When,Who,What
** <2020-02-07>,<Justin Tran>,Created stored procedure.
*/
AS
 Begin
  Declare @RC int = 0;
  Begin Try
   Begin Transaction
    -- Transaction Code --
     Insert Into Courses(
        CourseName,
        CourseStartDate,
        CourseEndDate,
        CourseStartTime,
        CourseEndTime,
        CourseWeekDays,
        CourseCurrentPrice
    )
     Values(
        @CourseName,
        @CourseStartDate,
        @CourseEndDate,
        @CourseStartTime,
        @CourseEndTime,
        @CourseWeekDays,
        @CourseCurrentPrice
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

Create Procedure pUpdCourses(
@CourseName Nvarchar(100),
@CourseStartDate date,
@CourseEndDate date,
@CourseStartTime time,
@CourseEndTime time,
@CourseWeekDays Nvarchar(100),
@CourseCurrentPrice money
)
/* Author: <Justin Tran>
** Desc: Processes updating of course data
** Change Log: When,Who,What
** <2020-02-07>,<Justin Tran>,Created stored procedure.
*/
AS
 Begin
  Declare @RC int = 0;
  Begin Try
   Begin Transaction
    -- Transaction Code --
    Update Courses
    Set
        CourseName =  @CourseName,
        CourseStartDate = @CourseStartDate,
        CourseEndDate = @CourseEndDate,
        CourseStartTime = @CourseStartTime,
        CourseEndTime = @CourseEndTime,
        CourseWeekDays = @CourseWeekDays,
        CourseCurrentPrice = @CourseCurrentPrice
    Where CourseID = IDENT_CURRENT('Courses')
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

Create Procedure pDelCourses
/* Author: <Justin Tran>
** Desc: Processes deletion of course data
** Change Log: When,Who,What
** <2020-02-07>,<Justin Tran>,Created stored procedure.
*/
AS
 Begin
  Declare @RC int = 0;
  Begin Try
   Begin Transaction
    -- Transaction Code --
    Delete From Enrollments
    Where CourseID = IDENT_CURRENT('Courses')
    Delete From Courses
    Where CourseID = IDENT_CURRENT('Courses')
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

Create Procedure pInsEnrollments(
@StudentID int,
@EnrollmentDateTime date,
@EnrollmentPrice money
)
/* Author: <Justin Tran>
** Desc: Processes insertion of enrollment data
** Change Log: When,Who,What
** <2020-02-07>,<Justin Tran>,Created stored procedure.
*/
AS
 Begin
  Declare @RC int = 0;
  Begin Try
   Begin Transaction
    -- Transaction Code --
     Insert Into Enrollments(
        StudentID,
        CourseID,
        EnrollmentDateTime,
        EnrollmentPrice
    )
     Values(
        @StudentID,
        IDENT_CURRENT('Courses'),
        @EnrollmentDateTime,
        @EnrollmentPrice
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

Create Procedure pUpdEnrollments(
@EnrollmentDateTime date,
@EnrollmentPrice money
)
/* Author: <Justin Tran>
** Desc: Processes updating of enrollment data
** Change Log: When,Who,What
** <2020-02-07>,<Justin Tran>,Created stored procedure.
*/
AS
 Begin
  Declare @RC int = 0;
  Begin Try
   Begin Transaction
    -- Transaction Code --
    Update Enrollments
    Set StudentID = IDENT_CURRENT('Students'),
    CourseID = IDENT_CURRENT('Courses'),
    EnrollmentDateTime = @EnrollmentDateTime,
    EnrollmentPrice = @EnrollmentPrice
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

Create Procedure pDelEnrollments
/* Author: <Justin Tran>
** Desc: Processes deletion of enrollment data
** Change Log: When,Who,What
** <2020-02-07>,<Justin Tran>,Created stored procedure.
*/
AS
 Begin
  Declare @RC int = 0;
  Begin Try
   Begin Transaction
    -- Transaction Code --
    Delete From Enrollments
    Where EnrollmentID = IDENT_CURRENT('Enrollments')
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
-- Set Permissions (Module 06) --
Deny Select, Insert, Update, Delete On Students To Public;
Grant Select On vStudents To Public;
Grant Execute On pInsStudents To Public;
Grant Execute On pUpdStudents To Public;
Grant Execute On pDelStudents To Public;

Deny Select, Insert, Update, Delete On Courses To Public;
Grant Select On vCourses To Public;
Grant Execute On pInsCourses To Public;
Grant Execute On pUpdCourses To Public;
Grant Execute On pDelCourses To Public;

Deny Select, Insert, Update, Delete On Enrollments To Public;
Grant Select On vEnrollments To Public;
Grant Execute On pInsEnrollments To Public;
Grant Execute On pUpdEnrollments To Public;
Grant Execute On pDelEnrollments To Public;
--< Test Views and Sprocs >--
-- Testing insertion of data --
Declare @Status int;
Exec @Status = pInsStudents
    @StudentNumber = '123456789',
    @StudentFirstName = 'First',
    @StudentLastName = 'Name',
    @StudentEmail = 'email@email.com',
    @StudentPhone = '(123)-456-7890',
    @StudentAddress1 = 'Test Address',
    @StudentAddress2 = Null,
    @StudentCity = 'Seatte',
    @StudentStateCode = 'WA',
    @StudentZipCode = '98105';
Select Case @Status
  When +1 Then 'Insert was successful!'
  When -1 Then 'Insert failed! Check if all the data is there'
  End as [Status]
Select * from Students;
go

Declare @Status int;
Exec @Status = pInsCourses
    @CourseName = 'Fake Course',
    @CourseStartDate = '5-6-2017',
    @CourseEndDate = '6-6-2018',
    @CourseStartTime = '7:00',
    @CourseEndTime = '8:00',
    @CourseWeekDays = 'MTWThF',
    @CourseCurrentPrice = 500000
Select Case @Status
  When +1 Then 'Insert was successful!'
  When -1 Then 'Insert failed! Check if data matches variables and check constraints are not violated.'
  End as [Status]
Select * from Courses;
go

Declare @Status int;
Exec @Status = pInsEnrollments
    @StudentID = @@IDENTITY,
    @EnrollmentDateTime = '5-1-2017',
    @EnrollmentPrice = 60000000
Select Case @Status
  When +1 Then 'Insert was successful!'
  When -1 Then 'Insert failed! Check if data matches variables and check constraints are not violated.'
  End as [Status]
Select * from Enrollments;
go

Select * from vReportView

-- Testing updates --
Declare @Status int;
Exec @Status = pUpdStudents
    @StudentNumber = '987654321',
    @StudentFirstName = 'Second Fist',
    @StudentLastName = 'Second Last',
    @StudentEmail = 'email2@2email.com',
    @StudentPhone = '(098)-765-4321',
    @StudentAddress1 = 'Test Address 2',
    @StudentAddress2 = 'Address Part 2 Test',
    @StudentCity = 'Washington',
    @StudentStateCode = 'SEA',
    @StudentZipCode = '50189';
Select Case @Status
  When +1 Then 'Update was successful!'
  When -1 Then 'Update failed! Check if all the data is there.'
  End as [Status]
Select * from Students;
go

Declare @Status int;
Exec @Status = pUpdCourses
    @CourseName = 'Fake Course 2',
    @CourseStartDate = '1-1-2021',
    @CourseEndDate = '12-31-2021',
    @CourseStartTime = '1:00',
    @CourseEndTime = '11:00',
    @CourseWeekDays = 'F',
    @CourseCurrentPrice = 5
Select Case @Status
  When +1 Then 'Update was successful!'
  When -1 Then 'Update failed! Check if data matches variables and check constraints are not violated.'
  End as [Status]
Select * from Courses;
go

Declare @Status int;  -- NOTE This one should fail on purpose to test the check constraint (if the enrollment time is after course start date)
Exec @Status = pUpdEnrollments
    @EnrollmentDateTime = '1-1-2028',
    @EnrollmentPrice = 2
Select Case @Status
  When +1 Then 'Update was successful!'
  When -1 Then 'Update failed! Check if data matches variables and check constraints are not violated (Course Starting Date in particular).'
  End as [Status]
Select * from Enrollments;
go

-- Testing Deletes --
Declare @Status int;
Exec @Status = pDelStudents
Select Case @Status
  When +1 Then 'Deletion was successful!'
  When -1 Then 'Deletion failed! Check if the dependent tables are dealt with!'
  End as [Status]
Select * from Students;
go

Declare @Status int;
Exec @Status = pDelCourses
Select Case @Status
  When +1 Then 'Deletion was successful!'
  When -1 Then 'Deletion failed! Check if the dependent tables are dealt with!'
  End as [Status]
Select * from Courses;
go

Declare @Status int;
Exec @Status = pDelEnrollments
Select Case @Status
  When +1 Then 'Deletion was successful!'
  When -1 Then 'Deletion failed! Check if the dependent tables are dealt with!'
  End as [Status]
Select * from Enrollments;
go
--{ IMPORTANT }--
-- To get full credit, your script must run without having to highlight individual statements!!!
/**************************************************************************************************/

-- Final Insertion of Data --

Declare @Status int;
Exec @Status = pInsStudents
    @StudentNumber = 'B-Smith-071',
    @StudentFirstName = 'Bob',
    @StudentLastName = 'Smith',
    @StudentEmail = 'Bsmith@HipMail.com',
    @StudentPhone = '(206)-111-2222',
    @StudentAddress1 = '123 Main St.',
    @StudentAddress2 = Null,
    @StudentCity = 'Seattle',
    @StudentStateCode = 'WA',
    @StudentZipCode = '98001';
Select Case @Status
  When +1 Then 'Insert was successful!'
  When -1 Then 'Insert failed! Check if all the data is there'
  End as [Status]
Select * from Students;
go

Declare @Status int;
Exec @Status = pInsCourses
    @CourseName = 'SQL1 - Winter 2017',
    @CourseStartDate = '1-10-2017',
    @CourseEndDate = '1-24-2017',
    @CourseStartTime = '6:00',
    @CourseEndTime = '8:50',
    @CourseWeekDays = 'T',
    @CourseCurrentPrice = 399
Select Case @Status
  When +1 Then 'Insert was successful!'
  When -1 Then 'Insert failed! Check if data matches variables and check constraints are not violated.'
  End as [Status]
Select * from Courses;
go

Declare @Status int;
Exec @Status = pInsEnrollments
    @StudentID = @@IDENTITY,
    @EnrollmentDateTime = '1-3-2017',
    @EnrollmentPrice = 399
Select Case @Status
  When +1 Then 'Insert was successful!'
  When -1 Then 'Insert failed! Check if data matches variables and check constraints are not violated.'
  End as [Status]
Select * from Enrollments;
go

Declare @Status int;
Exec @Status = pInsStudents
    @StudentNumber = 'S-Jones-003',
    @StudentFirstName = 'Sue',
    @StudentLastName = 'Jones',
    @StudentEmail = 'SueJones@YaYou.com',
    @StudentPhone = '(206)-231-4321',
    @StudentAddress1 = '333 1st Ave.',
    @StudentAddress2 = Null,
    @StudentCity = 'Seattle',
    @StudentStateCode = 'WA',
    @StudentZipCode = '98001';
Select Case @Status
  When +1 Then 'Insert was successful!'
  When -1 Then 'Insert failed! Check if all the data is there'
  End as [Status]
Select * from Students;
go

Declare @Status int;
Exec @Status = pInsEnrollments
    @StudentID = @@IDENTITY,
    @EnrollmentDateTime = '12-14-2016',
    @EnrollmentPrice = 349
Select Case @Status
  When +1 Then 'Insert was successful!'
  When -1 Then 'Insert failed! Check if data matches variables and check constraints are not violated.'
  End as [Status]
Select * from Enrollments;
go

Declare @Status int;
Exec @Status = pInsCourses
    @CourseName = 'SQL2 - Winter 2017',
    @CourseStartDate = '1-31-2017',
    @CourseEndDate = '2-14-2017',
    @CourseStartTime = '6:00',
    @CourseEndTime = '8:50',
    @CourseWeekDays = 'T',
    @CourseCurrentPrice = 399
Select Case @Status
  When +1 Then 'Insert was successful!'
  When -1 Then 'Insert failed! Check if data matches variables and check constraints are not violated.'
  End as [Status]
Select * from Courses;
go

Declare @Status int;
Exec @Status = pInsEnrollments
    @StudentID = @@IDENTITY,
    @EnrollmentDateTime = '12-14-2016',
    @EnrollmentPrice = 349
Select Case @Status
  When +1 Then 'Insert was successful!'
  When -1 Then 'Insert failed! Check if data matches variables and check constraints are not violated.'
  End as [Status]
Select * from Enrollments;
go

Declare @Status int;
Exec @Status = pInsEnrollments
    @StudentID = 2,
    @EnrollmentDateTime = '1-12-2017',
    @EnrollmentPrice = 399
Select Case @Status
  When +1 Then 'Insert was successful!'
  When -1 Then 'Insert failed! Check if data matches variables and check constraints are not violated.'
  End as [Status]
Select * from Enrollments;
go

Select * from vReportView
