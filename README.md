# Alaska Software Internship :clipboard:	
This report details about my Summer Internship for `Alaska Software` via `V&U LTD`.

*Started Project:*  1 Jun 2019

*Finished Project:* 16 July 2019

*Project Evaluation:* 16-18 July 2019

## General Description
*HR Vacation* is a web-based application used by employees and managers in a company to easy manage their holidays.

### Business Case for the Product
This product is designed to help companies keeping track of requested and approved vacancy days as well as to manage the vacation requests and approval process.


   <p align="center">
      
   <img src="https://user-images.githubusercontent.com/45242072/63298575-700cee00-c2dc-11e9-86de-afdee31ed174.png" alt="Hr Vacation Home Page" width="820" height="500">
      
   </p>

## Product Overview
**Programming Languages:** *xBase++*, *PostgreSQL* ,*Javascript*, *CSS*, *Bootstrap*

**Overall Approach:** 
- All the logic is implemented aside from the *.cxp* pages to the *Account Management / Business layers* to keep the code clean,tidy and organized.  
- Whenever I added business logic to the helper, I have written the appropriate unit test for it.
- The styling is written in *CSS*  and *Bootstrap*, the folders are composed in the  <a href="https://sass-guidelin.es/#the-7-1-pattern" target="_blank">*7-1 SASS pattern*</a> and the <a href="https://en.bem.info/methodology/" target="_blank">*BEM Notation*</a> is used for the classes to be easily converted to *SASS*  if the project continues to grow.
- Data is stored in *hr-vacation database*.

### User Characteristics
There is two roles in the system:
1. **Manager**
   - Can see a list of approved holidays both in list view and graphical view.
   - Can see a list of requested holidays and approve or reject a request.
   - Can manipulate employees (*add/edit/delete*).
   - Can add/retrack a new holiday request.
2. **Regular Employee**
   - Can see a list of his requested holidays.
   - Can add/retrack a new holiday request.

### Product Functions
The product have the following pages and functuonalties:
1. **Login Screen**
   - The user can enter his credentials to login into the system.
   - The credentials are validated toward the information saved in the database.
   - The password hash is calculated using a specific salted string, stored in the database.
   - The user can request a password reset. A new password is generated and sent to the user per email.
   - The new password hash is calculated.

        <img src="https://user-images.githubusercontent.com/45242072/63299599-d6930b80-c2de-11e9-8da4-83329d318b9e.png" alt="Hr Vacation Login Screen" >
      

   
   

2. **Main Page**
   - According to the role of the user main page is loading in employee or manager view.
   - The user have way to change his current password.
   - The user can log out of the system.

        <img src="https://user-images.githubusercontent.com/45242072/63302344-87040e00-c2e5-11e9-9f39-e81ca8a15335.gif" alt="Hr Vacation Main Page" >

3. **Employee, Manager - Holidays Overview**
   - The user sees all the requests he did make for a holiday with indicated status of the request.
   - The user can retrack back a request with is still in status requested.

        <img src="https://user-images.githubusercontent.com/45242072/63301823-2fb16e00-c2e4-11e9-88aa-37726892f4bd.gif" alt="Hr Vacation Holidays Overview Screen" >
        
4. **Employee, Manager - Holiday Request**
   - The user have a way to enter first and last day as well as descriptive reason for the requested holiday.
   - The requested days are validated, toward the total number of vacation days the employee may use per year.
   - When calculating the requested days, the weekend and bank holidays are taken into account.

        <img src="https://user-images.githubusercontent.com/45242072/63301597-9e41fc00-c2e3-11e9-8208-c47495334582.gif" alt="Hr Vacation Holiday Request Screen" >
        
5. **Manager - Holiday Requests Overview**
   - The user sees a list of the requested holidays and can accept or reject them.
   - The user have an option to see if there is any overlapping approved requests for a pending request.
   - There is restriction that managers are not allowed to approve their own holiday requests.
 
 
        <img src="https://user-images.githubusercontent.com/45242072/63301976-9f275d80-c2e4-11e9-975b-55684014ed8a.gif" alt="Hr Vacation Holiday Requests Overview" >
        
6. **Manager - Company Holiday Calendar**
   - The user is requested to enter filter criteria for visualization and to select the type of view to be displayed.
   - By defaut the time range is set to one month period.
   - If *list view* is selected, the user sees a table of the approved holidays, sorted by start date.
   - If *graphical view* is selected, the information is displayed as timeline view ( *Implemented with React JS* ).

        ![holiday-calendar](https://user-images.githubusercontent.com/45242072/63301220-af3e3d80-c2e2-11e9-8295-4c6cebfd8e01.gif)
        
7. **Manager - Manage Employees**
   - The user sees a list of existing employees and can edit their data or delete an employee.
   - The user can add new employees by entering their name, role (manager or employee), number of vacation days per year, email adress and a password to use the system.
   - A random PasswordSalt value is generated for every data record.
   - The password hash will be calculated using the salted string.
   - There is pattern set to every input field.
 
        <img src="https://user-images.githubusercontent.com/45242072/63302106-f7f6f600-c2e4-11e9-935c-25780c1692fc.gif" alt="Hr Vacation Manage Employees Screen" >
         
8. **Manager - Bank Holidays**
   - The manager sees a list of bank holidays and can manipulate them *(add/edit/delete)*.

        <img src="https://user-images.githubusercontent.com/45242072/63302197-2d034880-c2e5-11e9-8c6a-2f524dcdfde3.gif" alt="Hr Vacation  Bank Holidays Screen" >
      
### Data validation 
The used controls ensure that the entered data is of a proper type.

Data validation on the *Request Holiday* page is done upon saving *(Sending request)*:
- The start date must be a future date.
- The end date should be a date, later than the start date.
- The total amount of requested days plus the amount of all the previous vacation days for the year are not exceeding the number of vacation days per year for the employee.

### Dependencies and Assumptions
The application requires to be installed on a server, which runs the web application. The functuonality of the product assumes that there is always at least one manager in the company structure.

### How to run locally
1. [Setup IIS](https://support.microsoft.com/en-us/help/323972/how-to-set-up-your-first-iis-web-site "IIS") and see [xBase++ installation video](https://youtu.be/G3e_btI7oSU "xBase++ installation video").
2.  Install Xbase++
3. Install [PostgreSQL](https://www.postgresql.org/ "PostgreSQL")
4.  Install [PG Admin](https://www.pgadmin.org/ "PG Admin") *(Or alternative)*
5. Setup hr-vacation database using the model from the *setup* folder
6. Edit the *Site root*, opening the *project.xpj* file to your project folder location.
7. Open the project via the Xbase++ IDE, build it and then run it
