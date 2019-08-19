//////////////////////////////////////////////////////////////////////
///
/// <summary>
/// 'Employee.prg' test group.
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

CLASS EmployeeGroup FROM GenericTestGroup
 EXPORTED:
   METHOD ignoreSetupEmployee()
   METHOD ignoreTearDownEmployee()

   METHOD testRequestHoliday()
   METHOD testApproveHolidayRequest()


ENDCLASS

METHOD EmployeeGroup:testApproveHolidayRequest()
   LOCAL oUser, nEmpId, n,  cStartDateRaw, cEndDateRaw, cReason, lResult,aHolidayRequests, nCurrHolidayId

   // Remove if there is cached employee from previous test
   ::ignoreTearDownEmployee()

   // -- Set up  --
   // Add employee
   oUser := ::ignoreSetupEmployee("unit@test.co", "unitPassword1", "UnitTest", 2, 100 )
   nEmpId := oUser:employee_id
   cStartDateRaw := "01/01/1999"
   cEndDateRaw := "01/01/1999"
   cReason := "Unit Test"
   lResult := .T.

  // -- Exercise --
IF(EmployeeModel():requestHoliday(nEmpId, cStartDateRaw, cEndDateRaw, cReason))
    aHolidayRequests := Employee_Holiday():findAllBy( "employee_id", nEmpId )

    // Approve all requests
    FOR n:= 1 TO Len( aHolidayRequests )
      // Get current iteration id
      nCurrHolidayId := aHolidayRequests[n]:employee_holiday_id
      // Retrack current iteration id
      EmployeeModel():approveHolidayRequest(nCurrHolidayId)
    NEXT

    // Retrieve updated data
    aHolidayRequests := Employee_Holiday():findAllBy( "employee_id", nEmpId )

    // Make sure requests are approved
    FOR n:= 1 TO Len( aHolidayRequests )
      IF(aHolidayRequests[n]:resolution != 1)
         lResult := .F.
      ENDIF
    NEXT
ELSE
   // Request failed
   lResult := .F.
ENDIF

  // Clean data after the test
  ::ignoreTearDownEmployee()

  // -- Verify --
 CHECK_TRUE(lResult)
RETURN self


METHOD EmployeeGroup:testRequestHoliday()
   LOCAL oUser, nEmpId, cStartDateRaw, cEndDateRaw, cReason, lResult

   // Remove if there is cached employee from previous test
   ::ignoreTearDownEmployee()

   // -- Set up  --
   // Add employee with 1 holiday per year
   oUser := ::ignoreSetupEmployee("unit@test.co", "unitPassword1", "UnitTest", 2, 1 )
   nEmpId := oUser:employee_id
   // Dates with difference 1 day
   cStartDateRaw := "01/01/1999"
   cEndDateRaw := "01/01/1999"
   cReason := "Unit Test"
   lResult := .F.

  // -- Exercise --
  IF(EmployeeModel():requestHoliday(nEmpId, cStartDateRaw, cEndDateRaw, cReason))
   lResult := .T.
  ENDIF

  // Clean data after the test
  ::ignoreTearDownEmployee()
  // -- Verify --
 CHECK_TRUE(lResult)
RETURN self


METHOD EmployeeGroup:ignoreSetupEmployee(cEmail,cCurrPassword, cName,nEmpRole, nHolidaysPerYear)
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


METHOD EmployeeGroup:ignoreTearDownEmployee()
  LOCAL nEmpId, aHolidayRequests, n , nCurrHolidayId
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
