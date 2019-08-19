//////////////////////////////////////////////////////////////////////
///
/// <summary>
/// Implements employee specific data model logic
/// </summary>
///
///
/// <remarks>
/// - the model frameworks derives the table name from your models classname by removing the term "model"
/// - to tell your model which connection shall be used you need to override :open() further details see there.
/// </remarks>
///
///
/// <copyright>
/// Alaska Software Inc. && Mihail Yonchev (c) 2018. All rights reserved.
/// </copyright>
///
//////////////////////////////////////////////////////////////////////
#include "dac.ch"
#include "asinet.ch"
#pragma library("alaska-software.model-framework.lib")
#define CRLF  Chr(13)+Chr(10)

CLASS EmployeeModel FROM MOFSqlModel
  PROTECTED:
  // Calculate password hash with a given salt
  CLASS METHOD calculatePasswordHash()
  // Generates random salt given a number ( length )
  CLASS METHOD generateSalt()

  EXPORTED:
  // Establish connection with DB
  CLASS METHOD open()
  CLASS METHOD beforeSave()
  CLASS METHOD afterLoad()
  // Sends a holiday request if employee has the days for it TESTED
  CLASS METHOD requestHoliday()
  // Approves holiday request
  CLASS METHOD approveHolidayRequest()

ENDCLASS



/// ------ PROTECTED METHODS ------
/// <summary>
/// Generates a n character salt from the A-Za-z alphabet.
/// </summary>
///
CLASS METHOD EmployeeModel:generateSalt( nLen )
  LOCAL n
  LOCAL cSalt

  cSalt := ""
  FOR n:=1 TO nLen
    cSalt += Chr( IIF(RandomInt(0,1)==1,RandomInt(Asc('A'),Asc('Z')),RandomInt(Asc('a'),Asc('z'))) )
  NEXT n
RETURN cSalt

/// <summary>
/// Calcualtes password hash with a given salt
/// </summary>
///
CLASS METHOD EmployeeModel:calculatePasswordHash( cPwd, cSalt )
  LOCAL cHash
  LOCAL cText

  cText := cSalt + AllTrim(cPwd)
  cHash := Char2Hash( cText, 256 )
RETURN cHash






/// ------ EXPORTED METHODS ------
 /// <summary>
/// - Updates Holidays Per Year For Given EmpId
/// </summary>
/// <remarks>
/// This method is used by the managers to approve holiday requests
/// </remarks>
/// <returns> True ( Approved ) / False ( Failed to approve ) </returns>
CLASS METHOD EmployeeModel:approveHolidayRequest(nHolidayId)
   LOCAL oData
   // Make sure it's manager approving
      // Find holiday to be approved
      oData := Employee_Holiday():findBy( "employee_holiday_id", nHolidayId )
      // Get current user
      oUser := AccountMgmt():getCurrentUser()
      // Make sure the user does not approve his own request
      IF(oData:employee_id == oUser:employee_id)
         RETURN .F.
      ENDIF

      // If holiday found, set resolution and update
      IF(!Empty(oData))
         oData:resolution := 1
         Employee_Holiday():update( nHolidayId, oData )
      RETURN .T.
      ENDIF

RETURN .F.





 /// <summary>
/// - Sends holiday request, employee
/// </summary>
/// <remarks>
/// ///  This function is used by the user to request a holiday
///
/// [update]: This method can be updated to get the current user id,
/// and then to send the request for this id, so the user does not
/// somehow pass other or invalid id
///
/// </remarks>
/// <returns> True ( Sent ) / False ( Rejected ) </returns>
CLASS METHOD EmployeeModel:requestHoliday(nEmpId, cStartDateRaw, cEndDateRaw, cReason)
 // Set Up
 LOCAL nUserHolidayDays,nDifferenceBetweenDates, nHolidayDays
 // All parameters passed check
 IF(Empty(cStartDateRaw) .OR. Empty(cEndDateRaw) .OR. Empty(nEmpId))
  RETURN .F.
 ENDIF
 // Count how many not working days are in this period of time
 nHolidayDays := DateController():countWeekendDays(cStartDateRaw, cEndDateRaw)

 // Retrieve employee holiday days left
 nUserHolidayDays := Employee_Holiday():getHolidayDaysLeft(nEmpId)

 // Get absolute days difference for the period including the end date
 nDifferenceBetweenDates := DateController():getDifferenceBetweenTwoDates(cStartDateRaw, cEndDateRaw)
 // Subtract the not working days from the absolute value
 nDifferenceBetweenDates := nDifferenceBetweenDates - nHolidayDays

 IF(nDifferenceBetweenDates == 0)
   RETURN .T.
 ENDIF

 // User has the days requested left check
 IF(nUserHolidayDays>=nDifferenceBetweenDates)

      // Approve request
       IF(Employee_Holiday():sendHolidayRequest(nEmpId, cStartDateRaw, cEndDateRaw, cReason, nHolidayDays))
         // Updating the holiday days left for the employee
         nUserHolidayDays := nUserHolidayDays - nDifferenceBetweenDates
         IF(Employee_Holiday():updateHolidaysPerYear(nEmpId, nUserHolidayDays))
            RETURN .T.
         ENDIF
      ENDIF
 ENDIF
RETURN .F.




/// <summary>
/// :open() is basically the only method you need to override to get your model working. To
/// make you model fly you need to:
/// - tell him the dbms connection/session to be used ::bindSession()
/// - tell him the primary key ::setPrimaryKey()
/// - call super class :open to do the initilization.
/// </summary>
///
CLASS METHOD EmployeeModel:open()

  ::bindSession( "hr-vacation" )
  ::setPrimaryKey("employee_id")

  SUPER
  XppRtFileLogger():info( "EmployeeModel:open done")
RETURN


/// <summary>
/// We use :afterLoad() to add a member "password" to the dataobject, this is
/// used to temporarilly store the plaintext password as entered by the user.
/// </summary>
///
/// <remarks>
/// This method is automatically executed by the model-framework
/// whenever data is loaded from thje employee table into a dataobject.
/// </remarks>
///
CLASS METHOD EmployeeModel:afterLoad( oData )

  /*
   * we add an empty password field to our dataobject
   * upper level logic may define some content which leads
   * to a new password hash calculation in beforeSave()
   */
  oData:password := ""
RETURN .T.


/// <summary>
/// - Ensure that last update date is correct
/// - In the event a new employee gets added we calculate the salt
/// - If a plaintext password is given, we calc the salted hash and "forget" password
/// </summary>
/// <remarks>
/// This method is automatically executed by the model-framework
/// before a SQL INSERT or SQL UPDATE statement is executed. It allows us
/// to do some generic house keeping with our data.
/// </remarks>
///
CLASS METHOD EmployeeModel:beforeSave( oData )

  // last update happens now - so current date is used
  oData:last_update := Date()

  // ensure that we have a salt
  IF(Empty(oData:password_salt))
    oData:password_salt := ::generateSalt( 8 )
  ENDIF

  // if password is given we need to calc the password hash
  IF(!Empty(oData:password))
    oData:password_hash := ::calculatePasswordHash( oData:password, oData:password_salt)
    oData:password      := ""
  ENDIF
RETURN .T.




