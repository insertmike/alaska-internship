//////////////////////////////////////////////////////////////////////
///
/// <summary>
/// 'userservice.prg' test group.
/// </summary>

/// <remarks>
/// </remarks>
///
///
/// <copyright>
/// Your-Company. All Rights Reserved.
/// </copyright>
///
//////////////////////////////////////////////////////////////////////
#include "pgdbe.ch"
#include "..\..\.assets\xpp-unit\unit-test.ch"
#pragma library("accountmgmt.lib")

CLASS UserServiceGroup FROM GenericTestGroup
 EXPORTED:
   METHOD ignoreSetupEmployee()
   METHOD ignoreTearDownEmployee()

   METHOD testIsValidEmailWithValidEmail()
   METHOD testIsValidEmailWithInvalidEmail()

   METHOD testGetUserRoleForManager()
   METHOD testGetUserRoleForRegularEmployee()

   METHOD testVerifyPasswordWithCorrectPw()
   METHOD testVerifyPasswordWithIncorrectPw()

   METHOD testGetByEmail()
   METHOD testGetById()


   METHOD testChangePassword()
   METHOD testResetPassword()
ENDCLASS

METHOD UserServiceGroup:testChangePassword()
  LOCAL oData, cCurrPassword, cNewPassword, lResult, cEmail ,oUser
   // Remove if there is cached employee from previous test
   ::ignoreTearDownEmployee()

   // -- Set up  --
   lResult := .F.
   cCurrPassword := "currentPassword1"
   cNewPassword := "newPassword1"

   // Set up new employee
   oUser := ::ignoreSetupEmployee("unit@test.co", cCurrPassword, "UnitTest", 2, 1 )

   // Save email for passing into changeEmpPassword()
   cEmail := oUser:email

   // -- Exercise --

   UserService():changePassword(cEmail,cCurrPassword, cNewPassword)

   oData:= UserService():getByEMail( cEMail )
   IF(UserService():verifyPassword( oData, cNewPassword ))
      lResult := .T.
   ENDIF


   // -- Verify --
   CHECK_TRUE(lResult)

   // Delete employee
   ::ignoreTearDownEmployee()
 RETURN self


METHOD UserServiceGroup:testResetPassword()
  LOCAL oData, cPresetPassword, lResult, cEmail ,oUser
   // Remove if there is cached employee from previous test
   ::ignoreTearDownEmployee()

   // -- Set up  --
   lResult := .F.
   cPresetPassword := "presetPassword1"
   oUser := ::ignoreSetupEmployee("unit@test.co", cPresetPassword, "UnitTest", 2, 1 )
   cEmail := oUser:email

   // -- Exercise --

   UserService():resetPassword(cEmail)
   oData:= UserService():getByEMail( cEMail )

   // Verify that the password is not longer the present one
   // There is a chance inclining to 0 the preset password and the new generated to match
   IF(.NOT.UserService():verifyPassword( oData, cPresetPassword ))
      lResult := .T.
   ENDIF


   // -- Verify --
   CHECK_TRUE(lResult)

   // Delete employee
   ::ignoreTearDownEmployee()
RETURN self

METHOD UserServiceGroup:testGetById()
   // Set up
   LOCAL oUser, lResult, nEmpId, oUserFromFound
   // Remove if there is cached employee from previous test
   ::ignoreTearDownEmployee()
   lResult := .F.
   // Creating new user object assigning user role
   oUser := ::ignoreSetupEmployee("unit@test.co","","unitTest",2, 1)
   nEmpId := oUser:employee_id

   oUserFromFound := UserService():getById( nEmpId )

   // Exercise
   IF(oUser:employee_id == oUserFromFound:employee_id )
      lResult := .T.
   ENDIF

   // Verify
   CHECK_TRUE(lResult)
   // Clean up
   ::ignoreTearDownEmployee()

RETURN self

METHOD UserServiceGroup:testGetByEmail()
   // Set up
   LOCAL oUser, cName, cEmail, lResult, oUserFromFound
   // Remove if there is cached employee from previous test
   ::ignoreTearDownEmployee()
   lResult := .F.
   cEmail := "unit@test.co"
   cName := "UnitTest"
   // Creating new user object assigning user role
   oUser := ::ignoreSetupEmployee(cEmail,"",cName,2, 1)
   oUserFromFound := UserService():getByEmail( cEmail )

   // Exercise
   IF(oUser:employee_id == oUserFromFound:employee_id )
      lResult := .T.
   ENDIF

   // Verify
   CHECK_TRUE(lResult)
   // Clean up
   ::ignoreTearDownEmployee()

RETURN self


METHOD UserServiceGroup:testVerifyPasswordWithIncorrectPw()
   // Set up
   LOCAL oUser, cPassword, lResult
   // Remove if there is cached employee from previous test
   ::ignoreTearDownEmployee()
   cPassword := "unitTest1"
   oUser := ::ignoreSetupEmployee("unit@test.co",cPassword, "UnitTest",2, 1)

   // Exercise
   cPassword += "new"
   lResult := UserService():verifyPassword( oUser, cPassword )

   // Verify
   CHECK_FALSE(lResult)
   // Clean up
   ::ignoreTearDownEmployee()
RETURN self

METHOD UserServiceGroup:testVerifyPasswordWithCorrectPw()
   // Set up
   LOCAL oUser, cPassword, lResult
   // Remove if there is cached employee from previous test
   ::ignoreTearDownEmployee()
   cPassword := "unitTest1"
   // Creating new user object assigning user role
   oUser := ::ignoreSetupEmployee("unit@test.co",cPassword, "UnitTest",2, 1)
   // Exercise
   lResult := UserService():verifyPassword( oUser, cPassword )
   // Verify
   CHECK_TRUE(lResult)
   // Clean up
   ::ignoreTearDownEmployee()
RETURN self


METHOD UserServiceGroup:testGetUserRoleForRegularEmployee()
   // Set up
   LOCAL oUser, nEmpId, nUserRole, cResult
   // Remove if there is cached employee from previous test
   ::ignoreTearDownEmployee()
   // User Role - 1 => Regular Employee
   nUserRole := 1
   // Creating new user object assigning user role
   oUser := ::ignoreSetupEmployee("unit@test.co","", "UnitTest",nUserRole, 1)
   nEmpId := oUser:employee_id
   // Exercise
   cResult := UserService():getUserRole(nEmpId)

   // Verify
   CHECK_EQUAL("Regular Employee", cResult)
   // Clean up
   ::ignoreTearDownEmployee()
RETURN self

METHOD UserServiceGroup:testGetUserRoleForManager()
   // Set up
   LOCAL oUser, nEmpId, nUserRole, cResult
   // Remove if there is cached employee from previous test
   ::ignoreTearDownEmployee()
   // User Role - 2 => Manager
   nUserRole := 2
   // Creating new user object assigning user role
   oUser := ::ignoreSetupEmployee("unit@test.co","", "UnitTest",nUserRole, 2)
   nEmpId := oUser:employee_id
   // Exercise
   cResult := UserService():getUserRole(nEmpId)

   // Verify
   CHECK_EQUAL("Manager", cResult)
   // Clean up
   ::ignoreTearDownEmployee()
RETURN self


METHOD UserServiceGroup:testIsValidEmailWithInvalidEmail()
   // Set up
   LOCAL cEmail, lResult
   lResult := .F.
   cEmail := "unit@@test"

   // Exercise
   // There is format check for email when adding employee, either
   // I am checking invalid email format
   lResult := UserService():isValidEmail(cEmail)

   // Verify
   CHECK_FALSE(lResult)
RETURN self

METHOD UserServiceGroup:testIsValidEmailWithValidEmail()
   // Set up
   LOCAL cEmail, lResult
   // Remove if there is cached employee from previous test
   ::ignoreTearDownEmployee()

   cEmail := "unit@test.co"
   // Creating new user object assigning email
   ::ignoreSetupEmployee(cEmail,"", "UnitTest",2, 2)

   // Exercise
   lResult := UserService():isValidEmail(cEmail)

   // Verify
   CHECK_TRUE(lResult)
   // Clean up
   ::ignoreTearDownEmployee()
RETURN self


METHOD UserServiceGroup:ignoreSetupEmployee(cEmail,cCurrPassword, cName,nEmpRole, nHolidaysPerYear)
  LOCAL nEmpId, oData
  // If changing this value, change it in ::tearDownEmployee as well!
  nEmpId := 1 - 2

  // Create new emp object
  oData := EmployeeModel():default()

  // Assign passed data to emp object
  oData:employee_id := nEmpId
  oData:employee_name := cName
  oData:email := cEmail
  oData:employee_role := nEmpRole
  oData:holidays_per_year := nHolidaysPerYear
  oData:password := cCurrPassword
  // Insert in db
  EmployeeModel():insert( oData )

RETURN oData


METHOD UserServiceGroup:ignoreTearDownEmployee()
  LOCAL nEmpId, aHolidayRequests, n, nCurrHolidayId
  // If changing this value, change it in ::setupEmployee as well!
  nEmpId := 1 - 2
   // Get all matches of current user id from Employee_Holiday Table
  aHolidayRequests := Employee_Holiday():findAllBy( "employee_id", nEmpId )
  // Delete all requests so I can delete employee after ( tables are linked )
  FOR n:= 1 TO Len( aHolidayRequests )
   // Get current iteration id
   nCurrHolidayId := aHolidayRequests[n]:employee_holiday_id
   // Retrack current iteration id
   Employee_Holiday():retrackHolidayRequest(nCurrHolidayId)
  NEXT

  EmployeeModel():delete( nEmpId )
RETURN
