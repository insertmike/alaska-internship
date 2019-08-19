--- NOTE:
--- Since PostgreSQL columns/tables are all case sensitive it is required to use the
--- "name" notation to ensure proper name matching. To avoid all that it is by
--- convention so that all symbols with PostgreSQL are lower case and words are separated
--- with a underscore.

---
-- Precondition for script, have the following execute or
-- have a hr-vacation database created with the PgAdmin UI
--
-- CREATE DATABASE "hr-vacation" WITH TEMPLATE = template0 ENCODING = 'UTF8';
-- ALTER DATABASE "hr-vacation" OWNER TO postgres;

SET client_encoding = 'UTF8';

-- clean up tables legacy ones
DROP TABLE IF EXISTS public.bank_holidays;
DROP TABLE IF EXISTS public.employee_holidays;
DROP TABLE IF EXISTS public.employees;
-- clean up tables this
DROP TABLE IF EXISTS public.bank_holiday;
DROP TABLE IF EXISTS public.employee_holiday;
DROP TABLE IF EXISTS public.employee;

--
-- Name: BankHoliday; Type: TABLE; Schema: public; Owner: postgres
--
CREATE TABLE public.bank_holiday (
    bank_holiday_id serial NOT NULL,
    bank_holiday_date date
);
ALTER TABLE public.bank_holiday OWNER TO postgres;

--
-- Name: EmployeeHoliday; Type: TABLE; Schema: public; Owner: postgres
--
CREATE TABLE public.employee_holiday (
    employee_holiday_id serial NOT NULL,
    employee_id integer,
    start_date date,
    end_date date,
    reason character varying,
    resolution smallint,
    used_days smallint
);

ALTER TABLE public.employee_holiday OWNER TO postgres;

--
-- Dependencies: 200
-- Name: COLUMN "EmployeeHoliday"."Resolution"; Type: COMMENT; Schema: public; Owner: postgres
--
COMMENT ON COLUMN public.employee_holiday.resolution IS 'Values: 0 - Requested; -1 - Rejected; 1 - Approved';


--
-- TOC entry 196 (class 1259 OID 16385)
-- Name: Employees; Type: TABLE; Schema: public; Owner: postgres
CREATE TABLE public.employee (
    employee_id serial NOT NULL,
    employee_name character varying(50),
    email character varying(50),
    password_hash character(64),
    password_salt character(8),
    employee_role integer,
    holidays_per_year smallint,
    last_update date
);

ALTER TABLE public.employee OWNER TO postgres;
COMMENT ON COLUMN public.employee.password_hash IS 'Is the SHA265 hash of the users password with the salt as a leading char sequence. hash is always fixed in size';
COMMENT ON COLUMN public.employee.password_salt IS 'a random character sequence, use as password prefix before hash is calculated';
COMMENT ON COLUMN public.employee.employee_name IS 'Is a full name used for display, while email is used for authentification';
COMMENT ON COLUMN public.employee.employee_role IS 'Hardcoded values: 2 - Manager; 1 - Employee (in the future will be FK to UserRoles table)';


--
-- TOC entry 2044 (class 2606 OID 24609)
-- Name: BankHolidays PK_BankHolidayID; Type: CONSTRAINT; Schema: public; Owner: postgres
--
ALTER TABLE ONLY public.bank_holiday
    ADD CONSTRAINT "PK_bank_holiday_id" PRIMARY KEY (bank_holiday_id);


--
-- TOC entry 2046 (class 2606 OID 24611)
-- Name: EmployeeHolidays PK_EmployeeHolidayID; Type: CONSTRAINT; Schema: public; Owner: postgres
--
ALTER TABLE ONLY public.employee_holiday
    ADD CONSTRAINT "PK_employee_holiday_id" PRIMARY KEY (employee_holiday_id);


--
-- TOC entry 2042 (class 2606 OID 24607)
-- Name: Employee PK_EmployeeID; Type: CONSTRAINT; Schema: public; Owner: postgres
--
ALTER TABLE ONLY public.employee
    ADD CONSTRAINT "PK_employee_id" PRIMARY KEY (employee_id);


--
-- TOC entry 2047 (class 2606 OID 24612)
-- Name: EmployeeHolidays FK_Employees_EmployeeID; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--
ALTER TABLE ONLY public.employee_holiday
    ADD CONSTRAINT "FK_employee_employee_id" FOREIGN KEY (employee_id) REFERENCES employees(employee_id);

