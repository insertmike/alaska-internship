//////////////////////////////////////////////////////////////////////
///
/// <summary>
/// Account mgmt. controller provides interfaces related to the user
/// account such as authentication may also manage the user profile
/// as well as user roles lateron.
/// </summary>
///
///
/// <remarks>
/// - Uses user service for busines logic
/// - Since this is a controller it mediates between the UI and the Logc
/// - Implements the IAppLifecycle Interface :onStartup()/:onSHutdown() which are executed
///   automatically at web applicaton startup / shutdown.
/// - Use the GetApplication():activeView to determine active CXP page
/// </remarks>
///
///
/// <copyright>
/// Alaska Software Inc. && Mihail Yonchev (c) 2019. All rights reserved.
/// </copyright>
///
//////////////////////////////////////////////////////////////////////
#include "memvar.ch"
#pragma library("cxpcore10.lib")

CLASS AccountMgmt FROM IAppLifecycle
  CLASS VAR CurrentUser  // current user logged in
  CLASS VAR Session      // service instance we are using
  EXPORTED:

  CLASS METHOD onStartup()
  CLASS METHOD onShutdown()

  CLASS METHOD login()
  CLASS METHOD logout()

  CLASS METHOD isLoggedIn()
  CLASS METHOD getCurrentUser()
  CLASS METHOD getSession()    

ENDCLASS



CLASS METHOD AccountMgmt:onStartup()
  LOCAL oConCfg
  LOCAL cConStr
  LOCAL oSession

  XppRtFileLogger():info( "implicit execution of AccountMgmt:onStartup" )

  DbeLoad("pgdbe.dll")

  // ensure user service has data
  IF GetApplication():isDerivedFrom("CxpApplication")
     oConCfg := GetApplication():config:connection
  ELSE
     oConCfg := XMLConfigLoad("application.config"):config:connection
  ENDIF

  cConStr := "DBE=pgdbe;"
  cConStr += "SERVER="+oConCfg:Server+";"
  cConStr += "DB="+oConCfg:database+";"
  cConStr += "UID="+oConCfg:uid+";"
  cConStr += "PWD="+oConCfg:pwd+";"

  oSession := DacSession():new( cConStr, ,oConCfg:name )
  IF(!oSession:isConnected())
     XppRtFileLogger():error( "Connection failed for("+cConStr+") error("+oSession:getLastMessage()+")" )
  ELSE
     XppRtFileLogger():info( "Connection to("+oConCfg:database+") successfull" )
  ENDIF
 ::Session := oSession
RETURN SELF

CLASS METHOD AccountMgmt:getSession()
RETURN ::Session

CLASS METHOD AccountMgmt:onShutdown()
  // TBD
RETURN SELF

CLASS METHOD AccountMgmt:login(cEMail, cPassword)
  LOCAL oUser
  LOCAL oPage

  IF ValType(cEMail)!="C" .OR. ValType(cPassword)!="C"
    RETURN "email or password required"
  ENDIF

  IF(::isLoggedIn())
    ::logout()
  ENDIF

#define USR_PWD_INV "email or password invalid"
  oUser := UserService():getByEMail( cEMail )
  IF(Empty(oUser))
    XppRtFileLogger():info("AccountMgmt:login: email not found:"+Var2Char(cEMail))
    RETURN USR_PWD_INV
  ENDIF
  XppRtFileLogger():info("AccountMgmt-User:"+Var2JSON(oUser))

  // we compare hashs not plaintext
  IF UserService():verifyPassword( oUser, cPassword )
    ::CurrentUser         := oUser

    oPage := GetApplication():activeView
    oPage:Session:uid    := oUser:id
    RETURN NIL
  ENDIF
  XppRtFileLogger():info("AccountMgmt:login: pwd hash no match")
RETURN USR_PWD_INV


CLASS METHOD AccountMgmt:logout()
  LOCAL oPage

  IF(!::isLoggedIn())
    RETURN NIL
  ENDIF

  // reset session state by clearing the session value uid
  ::CurrentUser   := NIL

  oPage := GetApplication():activeView
  oPage:Session:uid    := NIL
RETURN SELF


CLASS METHOD AccountMgmt:isLoggedIn()
RETURN !Empty(GetApplication():activeView:Session:uid)

CLASS METHOD AccountMgmt:getCurrentUser()
  LOCAL oPage
  LOCAL oUser

  IF(!::isLoggedIn())
    RETURN NIL
  ENDIF

  IF(!Empty(::CurrentUser))
    RETURN ::CurrentUser
  ENDIF

  oPage := GetApplication():activeView
  oUser := UserService():getById( oPage:Session:uid )
RETURN oUser

