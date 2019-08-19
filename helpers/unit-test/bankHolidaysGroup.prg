//////////////////////////////////////////////////////////////////////
///
/// <summary>
///
/// </summary>
///
///
/// <remarks>
///  'bankHolidays.prg' test group
/// </remarks>
///
///
/// <copyright>
/// &COPYRIGHT
/// </copyright>
///
//////////////////////////////////////////////////////////////////////
#include "pgdbe.ch"
#include "..\..\.assets\xpp-unit\unit-test.ch"
#pragma library("accountmgmt.lib")

CLASS BankHolidaysGroup FROM GenericTestGroup
 EXPORTED:
   METHOD ignoreTearDownBankHoliday()

   METHOD testIsBankHoliday()
   METHOD testAddBankHoliday()

ENDCLASS

METHOD BankHolidaysGroup:testAddBankHoliday()
 // Set Up
 LOCAL result, sampleRawDate, sampleDbDate
 sampleRawDate = "01/01/2019"
 sampleDbDate:= "20190101"



 result := .F.

 ::ignoreTearDownBankHoliday(sampleDbDate)
 IF(Bank_HolidayModel():addBankHolidayDay( sampleRawDate ))

   // Check if is bank holiday
    IF(Bank_HolidayModel():isBankHolidayDay(CToD(sampleRawDate)))
      result := .T.
    ENDIF
 ENDIF

 ::ignoreTearDownBankHoliday(sampleDbDate)

 // Verify
CHECK_TRUE(result)

RETURN self


METHOD BankHolidaysGroup:testIsBankHoliday()
 // Set Up
 LOCAL oData, result, sampleDate, sampleId
 sampleDate:= CToD("26/04/1986")
 // Fix because just '-1' does not work
 sampleId := 2 - 1
 result := .F.

 // Exercise
 // Create a new bank holiday
 oData := Bank_HolidayModel():default()
 oData:bank_holiday_date := sampleDate
 oData:bank_holiday_id := sampleId
 IF(Bank_HolidayModel():insert( oData ))
    IF(Bank_HolidayModel():isBankHolidayDay(sampleDate))
      result := .T.
    ENDIF
 ENDIF

Bank_HolidayModel():delete( sampleId )

// Verify
CHECK_EQUAL(result, .T.)

RETURN self



METHOD BankHolidaysGroup:ignoreTearDownBankHoliday(cDate)

  LOCAL cStmt, oStmt, oSession

  cStmt := "DELETE FROM bank_holiday bh"
  cStmt += " where bh.bank_holiday_date = " + "'" + cDate + "'"
  oSession := AccountMgmt():getSession()

  oStmt := DacSqlStatement(oSession):fromChar( cStmt )
  oStmt:build()
  oStmt:execute()

RETURN




