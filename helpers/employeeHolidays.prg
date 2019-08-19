//////////////////////////////////////////////////////////////////////
///
/// <summary>
/// Employee Holiday model provides interfaces related to the user
/// holidays table and may also manage the user holiday days per year
/// such as updating the number of days avalible
/// </summary>
///
///
/// <remarks>
/// - Uses Date Controller for string manipulation on the dates
/// </remarks>
///
///
/// <copyright>
/// Alaska Software Inc. && Mihail Yonchev (c) 2019. All rights reserved.
/// </copyright>
///
//////////////////////////////////////////////////////////////////////
#include "dac.ch"
#pragma library("alaska-software.model-framework.lib")

CLASS Employee_Holiday FROM MOFSqlModel

  EXPORTED:
  CLASS METHOD open()

  CLASS METHOD updateHolidaysPerYear()
  CLASS METHOD getHolidayDaysLeft()
  CLASS METHOD retrackHolidayRequest()
  CLASS METHOD sendHolidayRequest()
  CLASS METHOD rejectHoliday()
  // Returns 2 dimentional array of all requests for a specific employee id for a period of time
  CLASS METHOD findSpecificForPeriod()
  // Returns a 2 dimentional array of all requests for a period of time
  CLASS METHOD findAllForPeriod()





ENDCLASS



/// <summary>
/// - Updates Holidays Per Year For Given EmpId
/// </summary>
/// <remarks>
/// This method is part of the validation for a holiday request
/// </remarks>
/// <returns> True ( Updated ) / False ( Failed to update ) </returns>
CLASS METHOD Employee_Holiday:updateHolidaysPerYear(nEmpId, nHolidaysPerYear )
   LOCAL oData
   oData := EmployeeModel():findBy( "employee_id", nEmpId )
   IF(!Empty(oData))
      oData:holidays_per_year := nHolidaysPerYear
      EmployeeModel():update( nEmpId, oData )

      RETURN .T.
   ENDIF
RETURN .F.

 /// <summary>
/// - Returns employee holiday days left for given employee id
/// </summary>
/// <remarks>
/// This method is part of the validation for holiday request
/// </remarks>
/// <returns> Number of holiday days left </returns>
CLASS METHOD Employee_Holiday:getHolidayDaysLeft(nEmpId)
  LOCAL oUser, nHolidayDaysLeft
  // Get user
  oUser := UserService():getById( nEmpId )
  // Get user holidays per year
  nHolidayDaysLeft := oUser:holidays_per_year
RETURN nHolidayDaysLeft




// Specific employee approved requests
CLASS METHOD Employee_Holiday:findSpecificForPeriod( xPeriodStart, xPeriodEnd, nEmpId )
  LOCAL cStmt, oStmt
  LOCAL oSession

  LOCAL oData, aData, cEmpId
  xPeriodStart := DateController():formatRawDate( xPeriodStart )
  xPeriodEnd := DateController():formatRawDate( xPeriodEnd )
  cEmpId := Str(nEmpId)

  cStmt := "SELECT * FROM employee_holiday eh"
  cStmt += " where eh.employee_id = " + cEmpId + " and " + "eh.start_date between " + "'" + xPeriodStart + "'" + " and " + "'" + xPeriodEnd + "'" + " and eh.end_date between " + "'" + xPeriodStart + "'" + " and " + "'" + xPeriodEnd + "'"
  cStmt += " and eh.resolution = 1"

  XppRtFileLogger():info( "SqlModel query("+cStmt+")")

 SELECT 0
  oSession := ::session:get()
  oStmt := DacSqlStatement( oSession ):fromChar( cStmt )


  oStmt:build()
  oStmt:query()

  IF(!Empty(oSession:getLastError()))
    //::setLastError("sql failed with error:"+oSession:getLastMessage())
   // RETURN NIL
  ENDIF

  aData := Array( RecCount() )
  GO TOP
  DO WHILE!EOF()
    oData := ::createDataObject()
    ::fromWorkarea( oData )
    aData[RecNo()] := oData

    SKIP 1
  ENDDO

  DbCloseArea()
RETURN aData


// ALL APPROVED REQUESTS
CLASS METHOD Employee_Holiday:findAllForPeriod( xPeriodStart, xPeriodEnd )
  LOCAL cStmt, oStmt
  LOCAL oSession
  LOCAL oData, aData
  xPeriodStart := DateController():formatRawDate( xPeriodStart )
  xPeriodEnd := DateController():formatRawDate( xPeriodEnd )

  cStmt := "SELECT * FROM employee_holiday eh"
  cStmt += " where eh.start_date between " + "'" + xPeriodStart + "'" + " and " + "'" + xPeriodEnd + "'" + " and eh.end_date between " + "'" + xPeriodStart + "'" + " and " + "'" + xPeriodEnd + "'"
  cStmt += " and eh.resolution = 1"
  XppRtFileLogger():info( "SqlModel query("+cStmt+")")

 SELECT 0
  oSession := ::session:get()
  oStmt := DacSqlStatement( oSession ):fromChar( cStmt )


  oStmt:build()
  oStmt:query()
  aData := Array( RecCount() )
  
  GO TOP
  DO WHILE!EOF()
    oData := ::createDataObject()
    ::fromWorkarea( oData )
    aData[RecNo()] := oData

    SKIP 1
  ENDDO

  DbCloseArea()
RETURN aData


CLASS METHOD Employee_Holiday:retrackHolidayRequest(nHolidayId)
  LOCAL oData, nEmpId,daysRequested,nUserHolidayDays
  oData := Employee_Holiday():findBy( "employee_holiday_id", nHolidayId )
  IF(!Empty(oData))
    // Get user id
    nEmpId := oData:employee_id
    // Get request days
    daysRequested := oData:used_days
    // Get days left
    nUserHolidayDays := Employee_Holiday():getHolidayDaysLeft(nEmpId)
    // Add back request days to days left
    nUserHolidayDays := nUserHolidayDays + daysRequested
    // Return used days to employee
    IF(Employee_Holiday():updateHolidaysPerYear(nEmpId, nUserHolidayDays))
    Employee_Holiday():delete( nHolidayId )
    RETURN .T.
    ENDIF
    //

  ENDIF
RETURN .F.
 /// <summary>
/// - Given request id, dates and resolution it sends new holiday request for given employee
/// </summary>
/// <remarks>
/// This method is used for sending a new holiday request
/// </remarks>
/// <returns> True ( Sent  ) / False ( Failed to send ) </returns>
CLASS METHOD Employee_Holiday:sendHolidayRequest(nEmpId, cStartDateRaw, cEndDateRaw, cReason, nHolidayDays)
   LOCAL oData
   oData := Employee_Holiday():default()
   oData:end_date := StoD(DateController():formatRawDate( cEndDateRaw ))
   oData:start_date := StoD(DateController():formatRawDate( cStartDateRaw ))
   oData:reason := cReason
   oData:employee_id := nEmpId
   // Adding 1 for the case the 2 dates are the same
   oData:used_days := oData:end_date - oData:start_date + 1 - nHolidayDays
   IF(Employee_Holiday():insert(oData))
      RETURN .T.
   ENDIF
RETURN .F.

 /// <summary>
/// - Given request id, rejects the corresponding request
/// </summary>
/// <remarks>
/// This method is used for the Manager Panel -> Holiday Requests to reject a holiday
/// </remarks>
/// <returns> True ( Rejected ) / False ( Failed to reject ) </returns>
CLASS METHOD Employee_Holiday:rejectHoliday( nHolidayId )

   LOCAL oData, nEmpId,daysRequested,nUserHolidayDays
   // Find coresponding holiday Id
  oData := Employee_Holiday():findBy( "employee_holiday_id", nHolidayId )
  IF(!Empty(oData))
    nEmpId := oData:employee_id
    oData:resolution := 1 - 2
    Employee_Holiday():update( nHolidayId, oData )
     // Get user id

     // Get request days
    daysRequested := oData:used_days
    // Get days left
    nUserHolidayDays := Employee_Holiday():getHolidayDaysLeft(nEmpId)
    // Add back request days to days left
    nUserHolidayDays := nUserHolidayDays + daysRequested
    // Return used days to employee
    IF(Employee_Holiday():updateHolidaysPerYear(nEmpId, nUserHolidayDays))

      RETURN .T.
    ENDIF
  ENDIF

 */
RETURN .F.

/// <summary>
/// :open() is basically the only method you need to override to get your model working. To
/// make you model fly you need to:
/// - tell him the dbms connection/session to be used ::bindSession()
/// - tell him the primary key ::setPrimaryKey()
/// - call super class :open to do the initilization.
/// </summary>
///
CLASS METHOD Employee_Holiday:open()

  ::bindSession( "hr-vacation" )
  ::setPrimaryKey("employee_holiday_id")

  SUPER
  XppRtFileLogger():info("Employee_Holiday:open done")
RETURN


