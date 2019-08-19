//////////////////////////////////////////////////////////////////////
///
/// <summary>
/// Default test group.
/// </summary>
///
///
/// <remarks>
/// Test methods shall have a prefix ignore or test, the runner
/// executes all methods with the name prefix test and does ignore
/// those with the name prefix ignore. However the statistics always
/// inform you about how many tests are currently ignored.
/// In the event you need to establish an order between your tests
/// simple impl. a config method and use addTest()
/// </remarks>
///
///
/// <copyright>
/// Alaska Software Inc. (c) 2018. All rights reserved.
/// </copyright>
///
//////////////////////////////////////////////////////////////////////
#include "..\..\.assets\xpp-unit\unit-test.ch"

// TODO: add your libraries here
#pragma library("accountmgmt.lib")

/// <summary>
/// Testgroup for all tests of public interfaces of User Service.
/// </summary>
CLASS UsersGroup FROM GenericTestGroup
 PROTECTED:
 VAR Data
 EXPORTED:
   METHOD setup()
   METHOD testUsersInit()
   METHOD testUsersSearchById()
   METHOD testUsersSearchByName()
ENDCLASS

/// <summary>
/// This is a function by design so we can reuse that code w/o inheritance
/// the concept is know as mixin in OOP theory.
/// </summary>
/// <remarks>
/// Passing SELF as first parameter is a part of the pattern to show this
/// is a mixing and to give the code access to the instance.
/// </remarks>
FUNCTION _createUser(oSelf, nId, cName,cUid ,cHash ,cImage )
  LOCAL oD := DataObject():new()
  UNUSED(oSelf)
  oD:id       := nId
  oD:fullname := cName
  oD:user     := cUid
  oD:pwd      := cHash
  oD:img      := cImage
RETURN oD

/// <summary>
/// Since we need some data in all our tests we create it in the setup
/// so it is available for all test executions
/// </summary>
METHOD UsersGroup:setup()
  SUPER
  ::Data := {}
  AAdd(::Data, _createUser(SELF, 1,"No1Name","No1UID",Char2Hash("No1UID"),"No1Image") )
  AAdd(::Data, _createUser(SELF, 2,"No2Name","No2UID",Char2Hash("No2UID"),"No2Image") )
RETURN


METHOD UsersGroup:testUsersInit()
  LOCAL oUserService

  CHECK_EQUAL( 2, Len( ::Data) )
  oUserService := UserSvc():new( ::Data )
  CHECK_EQUAL( 2, oUserService:getUserCount() )
RETURN self


METHOD UsersGroup:testUsersSearchById()
  LOCAL oUserService
  LOCAL oUser

  oUserService := UserSvc():new( ::Data )
  CHECK_EQUAL( 2, oUserService:getUserCount() )

  oUser := oUserService:getById( 1 )
  CHECK_OBJECT_TYPE( oUser )
  CHECK_INT_EQUAL( 1, oUser:id )
RETURN self


METHOD UsersGroup:testUsersSearchByName()
  LOCAL oUserService
  LOCAL oUser

  oUserService := UserSvc():new( ::Data )
  CHECK_EQUAL( 2, oUserService:getUserCount() )

  oUser := oUserService:getByName( "No1UID" )
  CHECK_OBJECT_TYPE( oUser )
  CHECK_INT_EQUAL( 1, oUser:id )
RETURN self


