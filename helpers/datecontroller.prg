//////////////////////////////////////////////////////////////////////
///
/// <summary>
/// Date Controller class provides methods needed for converting string
/// dates from one format to another used through the application
/// </summary>
///
///
/// <remarks>
/// - Uses xbase++ built-in library function only
/// </remarks>
///
///
/// <copyright>
/// Mihail Yonchev. (c) 2019. All rights reserved.
/// </copyright>
///
//////////////////////////////////////////////////////////////////////

CLASS DateController
  PROTECTED:

  EXPORTED:
  // Returns formatted date ready for passing to DB
  CLASS METHOD formatRawDate()
  // Returns a string date in the format: DD/Month/YYYY from DB for displaying in UI
  CLASS METHOD formatDbDate()
  CLASS METHOD getDifferenceBetweenTwoDates()
  CLASS METHOD dbDateToJsDate()
  CLASS METHOD countWeekendDays()
  CLASS METHOD isWeekendDay()
ENDCLASS

 /// <summary>
/// - Check if a date is a weekend day
/// </summary>
/// <remarks>
/// This method
/// </remarks>
/// <returns> True ( Weekend Day) / False ( Not Weekend Day )</returns>
CLASS METHOD DateController:isWeekendDay(dDate)
  IF(DoW(dDate) == 1 .OR. DoW(dDate) == 7)
      RETURN .T.
   ENDIF
RETURN .F.

 /// <summary>
/// - Counts number of weekend days between two dates
/// </summary>
/// <remarks>
/// This method is used for sending a new holiday request
/// </remarks>
/// <returns> number of weekend days between two dates</returns>
CLASS METHOD DateController:countWeekendDays(cStartDateRaw, cEndDateRaw)
 LOCAL nWeekendDays, buffer, cStartDateFormatted, cEndDateFormatted, FLAG

 nWeekendDays := 0
 buffer := ""
 buffer := SubStr(cStartDateRaw,4,2) + "/"  + SubStr(cStartDateRaw,1,2) + "/"+ SubStr(cStartDateRaw,7,4)
 cStartDateFormatted := CtoD(buffer)
 buffer := SubStr(cEndDateRaw,4,2) + "/"  + SubStr(cEndDateRaw,1,2) + "/"+ SubStr(cEndDateRaw,7,4)
 cEndDateFormatted :=  CtoD(buffer)


 IF(Empty(cStartDateFormatted) .OR. Empty(cEndDateFormatted) )
   RETURN 0
 ENDIF

 FLAG := .T.

 // Check if first day is a holiday day
IF(DateController():isWeekendDay(cStartDateFormatted))
   // Increment holiday days
   nWeekendDays++
ELSEIF(Bank_HolidayModel():isBankHolidayDay(cStartDateFormatted))
   nWeekendDays++
ENDIF
// Do while start date equal end date
DO WHILE FLAG
   IF(!(cStartDateFormatted == cEndDateFormatted))
   // Get next day
   cStartDateFormatted := cStartDateFormatted + 1
   // Check wheter is a holiday day

   IF(DateController():isWeekendDay(cStartDateFormatted))
      nWeekendDays++
   ELSEIF(Bank_HolidayModel():isBankHolidayDay(cStartDateFormatted))
      nWeekendDays++
   ENDIF

   ELSE
   FLAG := .F.
ENDIF

ENDDO
RETURN nWeekendDays

/// <summary>
/// - Returns the difference in days between two dates
/// </summary>
/// <remarks>
/// This method is used for 'Timeline View Calendar' to pass the date value
/// from DB to JS React Component
/// </remarks>
/// <returns> String Date in JS Format </returns>
CLASS METHOD DateController:dbDateToJsDate( cDbDate )
LOCAL jsDate
jsDate := SubStr(cDbDate,5,2)+ '/' + SubStr(cDbDate,7,2) + '/' + SubStr(cDbDate,0,4)
RETURN jsDate

   /// <summary>
/// - Returns the difference in days between two dates
/// </summary>
/// <remarks>
/// This method is part of the validation for a holiday request.
/// It returns 1 if the two days are the same hence this day will be a
/// day off for the employee
/// </remarks>
/// <returns> Number of days difference between the two dates </returns>
CLASS METHOD DateController:getDifferenceBetweenTwoDates(cStartDateRaw,cEndDateRaw)
   LOCAL  cStartDateFormatted, cEndDateFormatted, nDifferenceBetweenDates
   nDifferenceBetweenDates := 1
   // Format requested start date
   cStartDateFormatted := DateController():formatRawDate(cStartDateRaw)
   // Format requested end date
   cEndDateFormatted := DateController():formatRawDate(cEndDateRaw)
   IF(cStartDateFormatted == cEndDateFormatted )
      RETURN 1
   ENDIF
   // Calculate days between two dates
   nDifferenceBetweenDates := nDifferenceBetweenDates + (SToD(cEndDateFormatted) - SToD(cStartDateFormatted))
RETURN nDifferenceBetweenDates

   /// <summary>
/// Returns formatted date ready for passing to DB
/// </summary>
/// <remarks>
/// </remarks>
/// <returns> String date in the format the database requires </returns>
CLASS METHOD DateController:formatRawDate( cDateRaw )
   LOCAL cDateFormatted, cYear, cMonth, cDay
   cYear := SubStr(StrTran(cDateRaw, "/", "" ), 5,4)
   cDay :=  SubStr(StrTran(cDateRaw, "/", "" ), 0, 2)
   cMonth := SubStr(StrTran(cDateRaw, "/", "" ),3,2)
   cDateFormatted := cYear + cDay + cMonth

RETURN cDateFormatted

   /// <summary>
/// // Returns a string date in the format: DD/Month/YYYY from DB for displaying in UI
/// </summary>
/// <remarks>
/// </remarks>
/// <returns> String date in the format: DD/Month/YYYY </returns>
CLASS METHOD DateController:formatDbDate( dDate )
   LOCAL cUiDate, cDay, cMonth, cYear, cDate
   IF(Empty(DtoS(dDate)))
      RETURN NIL
   ENDIF
   cDate := DtoC(dDate)

   cDay := SubStr(cDate,0,2)
   cMonth := SubStr(cDate,4,2)
   cYear := SubStr(cDate,7,4)
      DO CASE
      CASE cMonth == "01"
         cMonth := "Jan"

      CASE cMonth == "02"
         cMonth := "Feb"

      CASE cMonth == "03"
         cMonth := "Mar"

      CASE cMonth == "04"
         cMonth := "Apr"

      CASE cMonth == "05"
         cMonth := "May"

      CASE cMonth == "06"
         cMonth := "Jun"

      CASE cMonth == "07"
         cMonth := "Jul"

      CASE cMonth == "08"
         cMonth := "Aug"

      CASE cMonth == "09"
         cMonth := "Sept"

      CASE cMonth == "10"
         cMonth := "Oct"

      CASE cMonth == "11"
         cMonth := "Nov"

      CASE cMonth == "12"
         cMonth := "Dec"
      ENDCASE

      cUiDate := cDay + "." + cMonth + "." + cYear

RETURN cUiDate

