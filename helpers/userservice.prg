//////////////////////////////////////////////////////////////////////
///
/// <summary>
/// Encapsulates user related business logic and users the EmployeeModel
/// to access Employee data from the dbms.
/// </summary>
///
///
/// <remarks>
/// We are using data objects as transporter between layers. This allows us to have
/// no datatypes between the boundaries of the different tiers of the application.
/// </remarks>
///
///
/// <copyright>
/// Alaska Software Inc. && Mihail Yonchev (c) 2018-2019. All rights reserved.
/// </copyright>
///
//////////////////////////////////////////////////////////////////////

#include "asinet.ch"

#define CRLF  Chr(13)+Chr(10)

CLASS UserService
  PROTECTED:
  CLASS METHOD resetPasswordHelper()
  // Generates random salt given a number ( length )
  CLASS METHOD generateSalt()
  // Inserts three random numbers in a given string
  CLASS METHOD insertThreeRandNum()
  CLASS METHOD updateEmpPassword()
  CLASS METHOD sendPassword()
  CLASS METHOD changePasswordHelper()

  EXPORTED:
  CLASS METHOD isValidEmail()
  CLASS METHOD getUserRole()
  CLASS METHOD verifyPassword()
  CLASS METHOD getByEMail()
  CLASS METHOD getById()
  CLASS METHOD resetPassword()
  CLASS METHOD changePassword()

  CLASS METHOD isManager()
  CLASS METHOD isRegularEmployee()
  CLASS METHOD getUserPanelRef()
ENDCLASS


/// ------ PROTECTED METHODS ------



/// <summary>
/// - Updates given employee password if the current password hashes match
/// </summary>
/// <remarks>
/// This method is helper for changeEmpPassword()
/// </remarks>
/// <returns> True ( Updated ) / False ( Failed to update ) </returns>
CLASS METHOD UserService:changePasswordHelper(cEmail,cCurrPass, cNewPass)
   // Set up
   LOCAL oUser
   // Find employee by email
    oUser := UserService():getByEMail( cEmail )
   // Check if is valid email address
   IF(Empty(oUser))
      RETURN .F.
   ENDIF
   // Verify current password
   IF(.NOT.UserService():verifyPassword( oUser, cCurrPass ))
      RETURN .F.
   ENDIF
   // Update with new password
   IF(UserService():updateEmpPassword(cEmail, cNewPass))
      RETURN .T.
   ENDIF

RETURN .F.

/// <summary>
/// Sends new passed password parameter to passed employee email
/// </summary>
/// <remarks>
/// This method is part of resetPassword()
/// </remarks>
/// <returns> True ( Updated ) / False ( Failed to update ) </returns>
CLASS METHOD UserService:sendPassword( cEmail , cPassword)
      // THIS IMPLEMENTATION IS REMOVED FOR THE PUBLIC VERSION
      // IT IS INTENDED AND WORKS SERVER-SIDE HENCE THERE IS
      // PRIVATE INFORMATION INCLUDED
RETURN .F.

/// <summary>
/// Updates given employee password
/// </summary>
/// <remarks>
/// This method is part of resetPassword()
/// </remarks>
/// <returns> True ( Updated ) / False ( Failed to update ) </returns>
CLASS METHOD UserService:updateEmpPassword(cEmail, cPassword)
  LOCAL oData, nEmpId
  oData := EmployeeModel():findBy( "email", cEmail )
  IF(!Empty(oData))

    nEmpId := oData:employee_id
    oData:password      := cPassword
    EmployeeModel():update( nEmpId, oData )

    RETURN .T.
  ENDIF
RETURN .F.

/// <summary>
/// Inserts three random digits in a given character string
/// </summary>
/// <remarks>
/// This method is part of resetPassword()
/// </remarks>
/// <returns> New character string with numbers at random positions </returns>
CLASS METHOD UserService:insertThreeRandNum( cText )
LOCAL n, randIndex, randNum
   FOR n:=1 TO 3
      randIndex := RandomInt( 0,Len(cText ))
      randNum := Var2Char(RandomInt( 0,9 ))
      cText := Stuff(cText, randIndex, 0, randNum)
   NEXT

RETURN cText

/// <summary>
/// Generates a n character salt from the A-Za-z alphabet.
/// </summary>
///
CLASS METHOD UserService:generateSalt( nLen )
  LOCAL n
  LOCAL cSalt

  cSalt := ""
  FOR n:=1 TO nLen
    cSalt += Chr( IIF(RandomInt(0,1)==1,RandomInt(Asc('A'),Asc('Z')),RandomInt(Asc('a'),Asc('z'))) )
  NEXT n
RETURN cSalt


/// <summary>
/// - Helper function, which calls all necessary methods for
///   resetting a password for a user
/// </summary>
/// <remarks>
/// This is done all inside a helper method in order to mutate
/// the implementation from the user.
/// </remarks>
/// <returns>
/// .T. (Successful) / .F. (Failure)
/// </returns>
CLASS METHOD UserService:resetPasswordHelper( cEmail )
     LOCAL cNewPassword, lPassVerifier
     // Generate random 8 characters
     cNewPassword :=  ::generateSalt(5)
     // Stuff random number at random position
     cNewPassword :=  ::insertThreeRandNum( cNewPassword )
     // Update Password
     lPassVerifier := ::updateEmpPassword(cEmail, cNewPassword)
     IF(lPassVerifier)
         // Send new Password
         lPassVerifier := ::sendPassword( cEmail , cNewPassword)
     ENDIF
     IF(lPassVerifier)
      RETURN .T.
     ENDIF

RETURN .F.


/// ------ EXPORTED METHODS ------

///
/// /// <summary>
///  Based on current user role, returns reference link to his panel
/// </summary>
/// <remarks>
///  This function is used for go back buttons
/// </remarks>
/// <returns> cRef ( Panel Reference Link ) / cRef ( Login Page Reference Link ) </returns>
CLASS METHOD UserService:getUserPanelRef()
  LOCAL oUser, cRef, nEmpId,cUserRole

  oUser := AccountMgmt():getCurrentUser()
  nEmpId := oUser:employee_id
  cUserRole := ::getUserRole(nEmpId)

  // Edge case value, if no user logged in
  cRef := "/login.cxp"

  IF(cUserRole == "Regular Employee")
     cRef := "/employee-panel.cxp"
     RETURN cRef
  ENDIF

  IF(cUserRole == "Manager")
    cRef := "/manager-panel.cxp"
    RETURN cRef
  ENDIF

RETURN cRef

///
/// /// <summary>
///  Calls helper function to change password of an employee
/// </summary>
/// <remarks>
///  This function is used by the user to change his password
/// </remarks>
/// <returns> True ( Changed ) / False ( Failed to change ) </returns>
CLASS METHOD UserService:changePassword(cEmail,cCurrPassword, cNewPassword)
   // Pass data to the helper method
   IF(UserService():changePasswordHelper(cEmail,cCurrPassword, cNewPassword))
      RETURN .T.
   ENDIF

RETURN .F.

///
/// <summary>
/// Resets password for a given emp email with a random generated one
/// This method only calls its helper
/// </summary>
/// <remarks>
///  This function is used by the user to reset his password
/// <returns> True ( Reset ) / False  ( Failed to reset ) </returns>
CLASS METHOD UserService:resetPassword( cEmail )
   LOCAL lPassVerifier
   // Email valid (exist in db) check
   IF(.NOT.UserService():isValidEmail( cEmail ))
      RETURN .F.
   ELSE
      lPassVerifier := UserService():resetPasswordHelper( cEmail )
      IF(lPassVerifier)
         RETURN .T.
      ENDIF
   ENDIF
RETURN .F.

/// <summary>
/// - Returns .T. if there is 'Regular Employee' logged in otherwise .F.
/// </summary>
/// <remarks>
/// This is used as init on every function requiring 'Regular Employee' session to be
/// rendered
/// </remarks>
/// <returns> .T. / .F. </returns>
CLASS METHOD UserService:isRegularEmployee()
   LOCAL oUser, nEmpId, cUserRoleCurrent, cUserRoleExpected
   oUser := AccountMgmt():getCurrentUser()
   // Active Session Check
   IF(!Empty(oUser))
      nEmpId := oUser:employee_id
      cUserRoleCurrent := UserService():getUserRole(nEmpId)
      cUserRoleExpected := "Regular Employee"
      IF(cUserRoleCurrent == cUserRoleExpected)
         RETURN .T.
      ENDIF
   ENDIF                       *
RETURN .F.

/// <summary>
/// - Returns .T. if there is 'Manager' logged in otherwise .F.
/// </summary>
/// <remarks>
/// This is used as init on every function requiring 'Manager' session to be
/// rendered
/// </remarks>
/// <returns> .T. / .F. </returns>
CLASS METHOD UserService:isManager()
   LOCAL oUser, nEmpId, cUserRoleCurrent, cUserRoleExpected
   oUser := AccountMgmt():getCurrentUser()
   // Active Session Check
   IF(!Empty(oUser))
      nEmpId := oUser:employee_id
      cUserRoleCurrent := UserService():getUserRole(nEmpId)
      cUserRoleExpected := "Manager"
      IF(cUserRoleCurrent == cUserRoleExpected)
         RETURN .T.
      ENDIF
   ENDIF                       *
RETURN .F.
/// <summary>
/// - Returns employee role represented in string format
/// </summary>
/// <remarks>
/// </remarks>
/// <returns>
///   - For Role: '1' - 'Regular Employee'
///   - For Role: '2' - 'Manager'
///   - Otherwise: NIL
/// </returns>
CLASS METHOD UserService:getUserRole(nEmpId)
 LOCAL cEmpRole, nEmpRole, oUser
 oUser := EmployeeModel():findBy( "employee_id", nEmpId )
 IF(!Empty(oUser))
   nEmpRole := oUser:employee_role
   IF(nEmpRole == 1)
      cEmpRole = "Regular Employee"
      RETURN cEmpRole
   ELSEIF(nEmpRole == 2)
      cEmpRole = "Manager"
      RETURN cEmpRole
   ENDIF
 ENDIF
RETURN NIL

/// <summary>
/// - Check if given email is valid ( exists in db )
/// </summary>
/// <returns> True ( Valid ) / False ( Invalid ) </returns>
CLASS METHOD UserService:isValidEmail( cEmail )
   LOCAL oData
   // Check if is valid email address
   oData := UserService():getByEMail( cEmail )
   IF(Empty(oData))
      RETURN .F.
   ENDIF
RETURN .T.

/// <summary>
/// Search by given email
/// </summary>
/// <returns>NIL or data object</returns>
CLASS METHOD UserService:getByEMail( cEMail )
  LOCAL oData

  oData := EmployeeModel():findBy( "email", cEMail )
  IF(Empty(oData))
    RETURN NIL
  ENDIF
  oData:id := oData:employee_id
RETURN oData

/// <summary>
/// Search by given employee_id (primary key)
/// </summary>
/// <returns>NIL or data object</returns>
CLASS METHOD UserService:getById( cId )
RETURN EmployeeModel():findBy( "employee_id", cId )


/// <summary>
/// Verifies if password is valid, it does that by comparing the
/// salted password hashes.
/// </summary>
/// <see ref="https://en.wikipedia.org/wiki/Salt_(cryptography)"/>
/// <returns>true/false</returns>
CLASS METHOD UserService:verifyPassword( oUser, cPassword )
  LOCAL cPwdHash

  IF(Empty(oUser))
    RETURN NIL
  ENDIF

  cPwdHash := oUser:password_salt + AllTrim(cPassword)
  cPwdHash := Char2Hash( cPwdHash, 256 )

  IF( cPwdHash == oUser:password_hash )
    RETURN .T.
  ENDIF
RETURN .F.


