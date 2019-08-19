//////////////////////////////////////////////////////////////////////
///
/// <summary>
/// </summary>
///
///
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

CLASS DateControllerGroup FROM GenericTestGroup

EXPORTED:
   METHOD testFormatRawDate()
   METHOD testFormatDbDate()
   METHOD testGetDifferenceBetweenTwoDates()
   METHOD testDbDateToJsDate()
   METHOD testCountWeekendDays()
   METHOD testIsWeekendDayWithWeekendDate()
   METHOD testIsWeekendDayWithWeekDate()

ENDCLASS

METHOD DateControllerGroup:testDbDateToJsDate()
   // Set up
   LOCAL cDate, cExpectedOutput, cActualOutput

   cDate := "20190101"
   cExpectedOutput := "01/01/2019"

   // Exercise
   cActualOutput := DateController():dbDateToJsDate( cDate )


   // Verify
   CHECK_EQUAL(cExpectedOutput, cActualOutput)
RETURN self

METHOD DateControllerGroup:testFormatDbDate()
   // Set up
   LOCAL cDate, cExpectedOutput, cActualOutput

   cDate := CtoD("01/01/2019")
   cExpectedOutput := "01.Jan.2019"

   // Exercise
   cActualOutput := DateController():formatDbDate( cDate )


   // Verify
   CHECK_EQUAL(cExpectedOutput, cActualOutput)
RETURN self
METHOD DateControllerGroup:testGetDifferenceBetweenTwoDates()
   // Set up
   LOCAL cStartDate, cEndDate, nExpectedDifference, nActualDifference

   // Dates with 2 weekend days between them
   cStartDate := "06/03/2019"
   cEndDate := "06/10/2019"
   nExpectedDifference := 8

   // Exercise
   nActualDifference := DateController():getDifferenceBetweenTwoDates(cStartDate, cEndDate)


   // Verify
   CHECK_EQUAL(nExpectedDifference, nActualDifference)
RETURN self

METHOD DateControllerGroup:testFormatRawDate()
   // Set up
   LOCAL rawDate, cOutputDateFormat, cExpectedOutputDateFormat
   rawDate := "01/02/2019"
   cExpectedOutputDateFormat := "20190102"

   // Exercise
   cOutputDateFormat := DateController():formatRawDate(rawDate)

   // Verify
   CHECK_EQUAL(cExpectedOutputDateFormat,cOutputDateFormat)

   //
RETURN self

METHOD DateControllerGroup:testCountWeekendDays()
   // Set up
   LOCAL cStartDate, cEndDate, nExpectedWeekendDays, nActualWeekendDays

   // Dates with 2 weekend days between them
   cStartDate := "03/06/2019"
   cEndDate := "10/06/2019"
   nExpectedWeekendDays := 2

   // Exercise
   nActualWeekendDays := DateController():countWeekendDays(cStartDate, cEndDate)

   CHECK_EQUAL(nExpectedWeekendDays, nActualWeekendDays)
RETURN self

METHOD DateControllerGroup:testIsWeekendDayWithWeekDate()
   // Set up
   LOCAL lResult, dDate
   dDate := StoD("02/12/2019")
   lResult := .F.
   // Exercise
   IF(DateController():isWeekendDay(dDate))
      lResult := .T.
   ENDIF

   CHECK_FALSE(lResult)

RETURN self

METHOD DateControllerGroup:testIsWeekendDayWithWeekendDate()
   // Set up
   LOCAL lResult, dDate
   dDate := StoD("01/12/2019")
   lResult := .F.
   // Exercise
   IF(DateController():isWeekendDay(dDate))
      lResult := .T.
   ENDIF

   CHECK_TRUE(lResult)

RETURN self
