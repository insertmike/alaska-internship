//////////////////////////////////////////////////////////////////////
///
/// <summary>
/// Bank Holiday model provides interfaces related to the bank holiday
/// database such as managing the bank holidays data
/// </summary>
///
///
/// <remarks>
/// - Uses Date Controller for string manipulation on the dates
/// </remarks>
///
///
/// <copyright>
/// Mihail Yonchev. (c) 2019. All rights reserved.
/// </copyright>
///
//////////////////////////////////////////////////////////////////////
#include "dac.ch"
#pragma library("alaska-software.model-framework.lib")

CLASS Bank_HolidayModel FROM MOFSqlModel
  EXPORTED:
  CLASS METHOD open()
  CLASS METHOD isBankHolidayDay()
  CLASS METHOD addBankHolidayDay()
ENDCLASS

 /// <summary>
/// - Adds bank holiday day if it's not in the DB
/// </summary>
/// <remarks>
/// This method is used to add a Bank Holiday from the Managers
/// </remarks>
/// <returns> True ( Added ) / False ( Not Added - Already Existing or Wrong Format )</returns>
CLASS METHOD Bank_HolidayModel:addBankHolidayDay(cDate)
   LOCAL dDate, oData

  IF(Empty(cDate))
   RETURN .F.
  ENDIF

   // Format trimmed date to DB format
   dDate := StoD(DateController():formatRawDate(cDate))
   // Create new bank holiday object
   oData := Bank_HolidayModel():default()
   // Assigning date value to the new bank holiday object
   oData:bank_holiday_date := dDate

   // Check whether date is already in the database
   IF(!Bank_HolidayModel():isBankHolidayDay(dDate))
      // If insertion successful
      IF(Bank_HolidayModel():insert( oData ))
         RETURN .T.
      ENDIF
   ENDIF

RETURN .F.

 /// <summary>
/// - Check if date is a bank holiday day
/// </summary>
/// <remarks>
/// This method is part of the validation of a holiday request
/// </remarks>
/// <returns> True ( Bank Holiday Day) / False ( Not Bank Holiday Day )</returns>
CLASS METHOD Bank_HolidayModel:isBankHolidayDay(dDate)
   LOCAL aBankHolidays, n
   aBankHolidays := Bank_HolidayModel():all("bank_holiday_date")
   FOR n:= 1 TO Len( aBankHolidays )

   IF(dDate == CtoD(DToC(aBankHolidays[n]:bank_holiday_date)))
      RETURN .T.
   ENDIF

   NEXT

RETURN .F.

/// <summary>
/// :open() is basically the only method you need to override to get your model working. To
/// make you model fly you need to:
/// - tell him the dbms connection/session to be used ::bindSession()
/// - tell him the primary key ::setPrimaryKey()
/// - call super class :open to do the initilization.
/// </summary>
///
CLASS METHOD Bank_HolidayModel:open()

  ::bindSession( "hr-vacation" )
  ::setPrimaryKey("bank_holiday_id")

  SUPER
  XppRtFileLogger():info("Bank_HolidayModel:open done")
RETURN


