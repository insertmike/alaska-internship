//////////////////////////////////////////////////////////////////////
///
/// <summary>
/// 'employeeHolidays.prg' test group.
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

CLASS EmployeeHolidayGroup FROM GenericTestGroup
 EXPORTED:
   METHOD ignoreSetupEmployee()
   METHOD ignoreTearDownEmployee()


   METHOD testUpdateHolidaysPerYear
   METHOD testGetHolidayDaysLeft()

   METHOD testRetrackHolidayRequest()
   METHOD testSendHolidayRequest()
   METHOD testRejectHoliday()
   METHOD testFindSpecificForPeriod

ENDCLASS


METHOD EmployeeHolidayGroup:testFindSpecificForPeriod()
  LOCAL oUser, oData, nEmpId, cStartDateRaw, cEndDateRaw, nHolidayDays, cReason, lResult
  LOCAL n,nCurrHolidayId, xStartDateRequestFound, xEndDateRequestFound, cStartExpectOutput, cEndExpectOutput, aHolidayRequests

   // Remove if there is cached employee from previous test
   ::ignoreTearDownEmployee()

   // -- Set up  --
   lResult := .F.
   oUser := ::ignoreSetupEmployee("unit@test.co", "unitPassword1", "UnitTest", 2, 100 )
   nEmpId := oUser:employee_id

   // Data required to send holiday request
   cStartDateRaw := "01/01/1999"
   cEndDateRaw := "02/02/1999"
   cStartExpectOutput := "19990101"
   cEndExpectOutput := "19990202"
   cReason := "Unit Test"
   nHolidayDays := 100

   // Send Holiday Request
   Employee_Holiday():sendHolidayRequest(nEmpId, cStartDateRaw, cEndDateRaw, cReason, nHolidayDays)

   // Approve the request dynamically
    aHolidayRequests := Employee_Holiday():findAllBy( "employee_id", nEmpId )
    FOR n:= 1 TO Len( aHolidayRequests )
      // Get current iteration id
      nCurrHolidayId := aHolidayRequests[n]:employee_holiday_id
      // Approve current iteration id
      EmployeeModel():approveHolidayRequest(nCurrHolidayId)
    NEXT


   // Find request and check if it is the same one
   oData := Employee_Holiday():findSpecificForPeriod(cStartDateRaw,cEndDateRaw, nEmpId)
   IF(!Empty(oData))
      xStartDateRequestFound := DtoS(oData[1][3])
      xEndDateRequestFound := DtoS(oData[1][4])
      IF(xStartDateRequestFound == cStartExpectOutput .AND. xEndDateRequestFound == cEndExpectOutput)
         lResult = .T.
      ENDIF
   ENDIF


   // Clean data after the test
   ::ignoreTearDownEmployee()

   CHECK_TRUE(lResult)

RETURN self

METHOD EmployeeHolidayGroup:testRejectHoliday()
  LOCAL oUser, oData, nEmpId, cStartDateRaw, cEndDateRaw, nHolidayId, nHolidayDays, cReason, resolution, lResult

   // Remove if there is cached employee from previous test
   ::ignoreTearDownEmployee()

   // -- Set up  --
   lResult := .F.
   nHolidayDays := 10
   cReason := "Unit Test"
   oUser := ::ignoreSetupEmployee("unit@test.co", "unitPassword1", cReason, 2, nHolidayDays )
   nEmpId := oUser:employee_id
   cStartDateRaw := "01/01/1999"
   cEndDateRaw := "01/01/1999"

   // -- Exercise --

    // Send Holiday Request
    Employee_Holiday():sendHolidayRequest(nEmpId, cStartDateRaw, cEndDateRaw, cReason, nHolidayDays)

   // Find request
   oData := Employee_Holiday():findBy( "employee_id", nEmpId )
   IF(!Empty(oData))
      // Get request id
      nHolidayId := oData:employee_holiday_id
      // Reject request
      Employee_Holiday():rejectHoliday( nHolidayId )
   ENDIF

   // Updated data
   oData := Employee_Holiday():findBy( "employee_id", nEmpId )

   // Store resolution
   resolution := oData:resolution

   // Check if resolution is -1 ( Rejected )
   IF(resolution == -1)
      lResult := .T.
   ENDIF

   // Clean data after the test
   ::ignoreTearDownEmployee()

   CHECK_TRUE(lResult)

RETURN self

METHOD EmployeeHolidayGroup:testSendHolidayRequest()
   LOCAL oUser, oData, nEmpId, cStartDateRaw, cEndDateRaw, nHolidayDays, cReason, lResult

   // Remove if there is cached employee from previous test
   ::ignoreTearDownEmployee()

   // -- Set up  --
   lResult := .F.
   nHolidayDays := 1
   oUser := ::ignoreSetupEmployee("unit@test.co", "unitPassword1", "UnitTest", 2, nHolidayDays )
   nEmpId := oUser:employee_id
   cStartDateRaw := "01/01/1999"
   cEndDateRaw := "01/01/1999"
   cReason := "Unit Test"

   // Exercise
   Employee_Holiday():sendHolidayRequest(nEmpId, cStartDateRaw, cEndDateRaw, cReason, nHolidayDays)
   oData := Employee_Holiday():findBy( "employee_id", nEmpId )

   IF(!Empty(oData))
      lResult := .T.
   ENDIF

  // Clean data after the test
  ::ignoreTearDownEmployee()
  // -- Verify --
  CHECK_TRUE(lResult)
RETURN self

METHOD EmployeeHolidayGroup:testRetrackHolidayRequest()
  LOCAL oUser, oData, nEmpId, cStartDateRaw, cEndDateRaw, cReason, lResult, n , nHolidayId

   // Remove if there is cached employee from previous test
   ::ignoreTearDownEmployee()

   // -- Set up  --
   oUser := ::ignoreSetupEmployee("unit@test.co", "unitPassword1", "UnitTest", 2, 1 )
   nEmpId := oUser:employee_id
   cStartDateRaw := "01/01/1999"
   cEndDateRaw := "01/01/1999"
   cReason := "Unit Test"
   lResult := .F.

  // -- Exercise --

  // Request Holiday
  IF(EmployeeModel():requestHoliday(nEmpId, cStartDateRaw, cEndDateRaw, cReason))
   oData := Employee_Holiday():findAllBy( "employee_id", nEmpId )
   FOR n:= 1 TO Len( oData )
      nHolidayId := oData[n]:employee_holiday_id
      Employee_Holiday():retrackHolidayRequest(nHolidayId)
   NEXT
  ENDIF

   // Check if all requests are retracked
   IF(Empty(Employee_Holiday():findAllBy( "employee_id", nEmpId ) ))
    lResult := .T.
   ENDIF

   // Verify
   CHECK_TRUE(lResult)

   // Clean
   ::ignoreTearDownEmployee()

RETURN self


METHOD EmployeeHolidayGroup:testGetHolidayDaysLeft()
   // Set up
   LOCAL oUser, nSetHolidayDays, nGetHolidayDays, nEmpId
   // Remove if there is cached employee from previous test
   ::ignoreTearDownEmployee()

   nSetHolidayDays := 10
   // Creating new user object assigning holiday days left
   oUser := ::ignoreSetupEmployee("unit@test.co","","unitTest",2, nSetHolidayDays)
   nEmpId := oUser:employee_id

   // Exercise
   nGetHolidayDays := Employee_Holiday():getHolidayDaysLeft(nEmpId)


   // Verify
   CHECK_EQUAL(nSetHolidayDays, nGetHolidayDays)

   // Clean up
   ::ignoreTearDownEmployee()

RETURN self

METHOD EmployeeHolidayGroup:testUpdateHolidaysPerYear()
   // Set up
   LOCAL oUser, nAfterHolidaysPerYear, nEmpId
   // Remove if there is cached employee from previous test
   ::ignoreTearDownEmployee()


   // Creating new user object assigning user role
   oUser := ::ignoreSetupEmployee("unit@test.co","","unitTest",2, 1)
   nEmpId := oUser:employee_id
   nAfterHolidaysPerYear := 22
   // Exercise
   Employee_Holiday():updateHolidaysPerYear(nEmpId, nAfterHolidaysPerYear )

   // Verify
   CHECK_EQUAL(Employee_Holiday():getHolidayDaysLeft(nEmpId), nAfterHolidaysPerYear)

   // Clean up
   ::ignoreTearDownEmployee()

RETURN self

METHOD EmployeeHolidayGroup:ignoreSetupEmployee(cEmail,cCurrPassword, cName,nEmpRole, nHolidaysPerYear)
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


METHOD EmployeeHolidayGroup:ignoreTearDownEmployee()
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
