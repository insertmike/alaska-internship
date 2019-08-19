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
///
/// </copyright>
///
//////////////////////////////////////////////////////////////////////
#include "dac.ch"
#pragma library("alaska-software.model-framework.lib")

CLASS DateModel
   PROTECTED:
   VAR nDay, nMonth, nYear
   VAR monthDays


   EXPORTED:
   CLASS METHOD sayHi
   CLASS METHOD init
ENDCLASS


CLASS METHOD DateModel:init(nDay, nMonth, nYear)
   monthDays := {31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31}

RETURN
/// <summary>
/// :open() is basically the only method you need to override to get your model working. To
/// make you model fly you need to:
/// - tell him the dbms connection/session to be used ::bindSession()
/// - tell him the primary key ::setPrimaryKey()
/// - call super class :open to do the initilization.
/// </summary>
///
CLASS METHOD DateModel:sayHi()

RETURN nMonthDays[1]


