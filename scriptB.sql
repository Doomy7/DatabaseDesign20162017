drop database if exists projectA;
create database projectA;
use projectA;

-- CREATE SCHEMA TABLES

create table customer (
	customer_id varchar(9),
	birth_date date,
	afm varchar(9),
	PRIMARY KEY (customer_id)
);

create table contract (
	contract_id varchar(14),
	signature_date date,
	limit_amount decimal(10,2),
	contract_type varchar(17),
	customer_id varchar(9),
	PRIMARY KEY (contract_id),
	FOREIGN KEY (customer_id) REFERENCES customer (customer_id)
);

create table account (
	account_id varchar(15),
	starting_date date,
	status varchar(13),
	product_code varchar(4),
	contract_id varchar(14),
	PRIMARY KEY (account_id),
	FOREIGN KEY (contract_id) REFERENCES contract (contract_id)
);

create table collateral (
	collateral_id varchar(10),
	collateral_type int,
	collateral_amount decimal(10,2),
	collateral_end date,
	collateral_relation_type int,
	customer_id varchar(9),
	contract_id varchar(14),
	account_id varchar(15),
	PRIMARY KEY (collateral_id),
	FOREIGN KEY (customer_id) REFERENCES customer (customer_id),
	FOREIGN KEY (contract_id) REFERENCES contract (contract_id),
	FOREIGN KEY (account_id) REFERENCES account (account_id)
);

create table real_estate (
	real_estate_id varchar(10),
	appreciation_value decimal(10,2),
	appreciation_date date,
	property_type int,
	collateral_id varchar(10),
	PRIMARY KEY (real_estate_id),
	FOREIGN KEY (collateral_id) REFERENCES collateral (collateral_id)
);

create table balance (
	account_id varchar(15),
	balance_value decimal(10,2),
	balance_date date,
	balance_type varchar(8),
	FOREIGN KEY (account_id) REFERENCES account (account_id)
);

-- CREATE TEMPORARY DATA LOAD TABLES

create table dat_table (
	customer_id varchar(9),
	birth_date date,
	afm varchar(9),
	contract_id varchar(14),
	signature_date date,
	limit_amount decimal(10,2),
	contract_type varchar(17),
	account_id varchar(15),
	starting_date date,
	status varchar(13),
	product_code varchar(4),
	collateral_id varchar(10),
	collateral_type int,
	collateral_amount decimal(10,2),
	collateral_end date,
	collateral_relation_type int,
	real_estate_id varchar(10),
	appreciation_value decimal(10,2),
	appreciation_date date,
	property_type int
);

create table bal_table (
	customer_id varchar(9),
	birth_date date,
	afm varchar(9),
	contract_id varchar(14),
	signature_date date,
	limit_amount decimal(10,2),
	contract_type varchar(17),
	account_id varchar(15),
	starting_date date,
	status varchar(13),
	product_code varchar(4),
	balance_value decimal(10,2),
	balance_date date,
	balance_type varchar(8)
);


load data local infile 'C:/Data/dat.txt'
into table dat_table 
fields terminated by '@' 
lines terminated by '\r\n'
ignore 1 rows
(customer_id, @var1, afm, contract_id, @var2, limit_amount, contract_type, account_id, @var3, 
status, product_code, collateral_id, collateral_type, collateral_amount, @var4, collateral_relation_type, 
real_estate_id, appreciation_value, @var5, property_type)
set
birth_date = STR_TO_DATE(@var1, '%d/%m/%Y'),
signature_date = STR_TO_DATE(@var2, '%d/%m/%Y'),
starting_date = STR_TO_DATE(@var3, '%d/%m/%Y'),
collateral_end = STR_TO_DATE(@var4, '%d/%m/%Y'),
appreciation_date = STR_TO_DATE(@var5, '%d/%m/%Y');

load data local infile 'C:/Data/bal.txt'
into table bal_table 
fields terminated by '@' 
lines terminated by '\r\n'
ignore 1 rows
(customer_id, @var1, afm, contract_id, @var2, limit_amount, contract_type, account_id, @var3, status, product_code, balance_value, @var4, balance_type)
set
birth_date = STR_TO_DATE(@var1, '%d/%m/%Y'),
signature_date = STR_TO_DATE(@var2, '%d/%m/%Y'),
starting_date = STR_TO_DATE(@var3, '%d/%m/%Y'),
balance_date = STR_TO_DATE(@var4, '%d/%m/%Y');

-- LOAD DATA FROM IMPORT TABLE TO SCHEMA TABLES

insert into customer
select distinct customer_id, birth_date, AFM
from dat_table;

insert into contract
select distinct contract_id, signature_date, limit_amount, contract_type, customer_id
from dat_table;

insert into account
select distinct account_id, starting_date, status, product_code,  contract_id
from dat_table;

insert into collateral
select distinct collateral_id, collateral_type, collateral_amount, 
collateral_end, collateral_relation_type, 
case when collateral_relation_type=1 then
customer_id end, 
case when collateral_relation_type=2 then
contract_id end,
case when collateral_relation_type=3 then
account_id end 
from dat_table;

insert into real_estate
select distinct real_estate_id, appreciation_value, appreciation_date, property_type, collateral_id
from dat_table
where real_estate_id is not null;

insert into balance
select distinct account_id, balance_value, balance_date, balance_type
from bal_table;

-- DROP IMPORT TABLES
drop table dat_table;
drop table bal_table;
-- =======================================================================================================


-- CREATE TEMPORARY DATA LOAD TABLES

create table dat_table2 (
	customer_id varchar(9),
	birth_date date,
	afm varchar(9),
	contract_id varchar(14),
	signature_date date,
	limit_amount decimal(10,2),
	contract_type varchar(17),
	account_id varchar(15),
	starting_date date,
	status varchar(13),
	product_code varchar(4),
	collateral_id varchar(10),
	collateral_type int,
	collateral_amount decimal(10,2),
	collateral_end date,
	collateral_relation_type int,
	real_estate_id varchar(10),
	appreciation_value decimal(10,2),
	appreciation_date date,
	property_type int
);

create table bal_table2 (
	customer_id varchar(9),
	birth_date date,
	afm varchar(9),
	contract_id varchar(14),
	signature_date date,
	limit_amount decimal(10,2),
	contract_type varchar(17),
	account_id varchar(15),
	starting_date date,
	status varchar(13),
	product_code varchar(4),
	balance_value decimal(10,2),
	balance_date date,
	balance_type varchar(8)
);


load data local infile 'C:/Data/dat2.txt'
into table dat_table2 
fields terminated by '@' 
lines terminated by '\r\n'
ignore 1 rows
(customer_id, @var1, afm, contract_id, @var2, limit_amount, contract_type, account_id, @var3,
 status, product_code, collateral_id, collateral_type, collateral_amount, @var4, collateral_relation_type, 
 real_estate_id, appreciation_value, @var5, property_type)
set
birth_date = STR_TO_DATE(@var1, '%d/%m/%Y'),
signature_date = STR_TO_DATE(@var2, '%d/%m/%Y'),
starting_date = STR_TO_DATE(@var3, '%d/%m/%Y'),
collateral_end = STR_TO_DATE(@var4, '%d/%m/%Y'),
appreciation_date = STR_TO_DATE(@var5, '%d/%m/%Y');

load data local infile 'C:/Data/bal2.txt'
into table bal_table2
fields terminated by '@' 
lines terminated by '\r\n'
ignore 1 rows
(customer_id, @var1, afm, contract_id, @var2, limit_amount, contract_type, account_id, @var3, status, product_code, balance_value, @var4, balance_type)
set
birth_date = STR_TO_DATE(@var1, '%d/%m/%Y'),
signature_date = STR_TO_DATE(@var2, '%d/%m/%Y'),
starting_date = STR_TO_DATE(@var3, '%d/%m/%Y'),
balance_date = STR_TO_DATE(@var4, '%d/%m/%Y');


-- INDEXES
 create unique index balanceIndex
 using btree
 on balance(account_id,balance_type,balance_value,balance_date);

-- create index balanceIndex
-- using btree
-- on balance(account_id,balance_type,balance_value,balance_date);

 create index collateralIndex 
 using btree
 on collateral(collateral_relation_type);


-- LOAD DATA FROM IMPORT TABLE TO SCHEMA TABLES

insert into customer
select distinct customer_id, birth_date, AFM
from dat_table2;

insert into contract
select distinct contract_id, signature_date, limit_amount, contract_type, customer_id
from dat_table2;

insert into account
select distinct account_id, starting_date, status, product_code, contract_id
from dat_table2;

insert into collateral
select distinct collateral_id, collateral_type, collateral_amount, 
collateral_end, collateral_relation_type, 
case when collateral_relation_type=1 then
customer_id end, 
case when collateral_relation_type=2 then
contract_id end,
case when collateral_relation_type=3 then
account_id end 
from dat_table2;

insert into real_estate
select distinct real_estate_id, appreciation_value, appreciation_date, property_type, collateral_id
from dat_table2
where real_estate_id is not null;

insert into balance
select distinct account_id, balance_value, balance_date, balance_type
from bal_table2;

-- DROP IMPORT TABLES
drop table dat_table2;
drop table bal_table2;

-- QUERY 1 (best perfomance)
 Select SQL_NO_CACHE count(Selection2.account_id) from
 	(Select collateral.account_id, sum(collateral_amount) as sumcom, Selection1.maxbal from collateral use index (collateralIndex),
 		(Select account_id, max(balance_value) as maxbal from balance
 		where balance_type = 'Capital'
 		group by account_id) as Selection1
 	where Selection1.account_id = collateral.account_id
 	and collateral_relation_type = '3'
 	group by collateral.account_id) as Selection2
 where Selection2.maxbal > sumcom;
 
-- QUERY 1 (better perfomance)
-- Select SQL_NO_CACHE count(colac) as sumacc from
--	(Select sum(collateral_amount) as sumcol, account_id as colac from collateral
--	where collateral_relation_type = '3'
--	group by colac) as selection1,
--	(Select account_id as balac , max(balance_value) as balance_value from balance 
--	where balance_type = 'Capital'
--    group by account_id) as selection2 
-- where selection1.colac = selection2.balac 
-- and selection2.balance_value > selection1.sumcol;
     
-- QUERY 1 (worst perfomance)
-- Select SQL_NO_CACHE count(Selection2.account_id) from
--  (Select balance.account_id, Selection1.sumcom , max(balance_value) as maxbal from balance,
--  	(Select sum(collateral_amount) as sumcom, account_id from collateral
--     	where collateral_relation_type = '3'
-- 		group by account_id) as Selection1
-- 	where balance.account_id = Selection1.account_id
-- 	and balance_type = 'Capital'
-- 	group by balance.account_id) as Selection2
-- where Selection2.maxbal > sumcom;

-- QUERY 2
Select SQL_NO_CACHE avg(balance_value) from balance,
	(Select max(balance_date) maxDate,account_id from balance 
	where balance_date - Date('2006-01-01') <= 0
	and balance_type = 'Capital'
	group by account_id) as selection1
where balance.balance_date = selection1.maxDate
and balance.account_id = selection1.account_id
and balance.balance_type = 'Capital';

-- QUERY 3 (SIMPLE)
Select SQL_NO_CACHE count(distinct collateral_id) from 
	(Select collateral_id,account.account_id as accnid from collateral use index (collateralIndex),account,contract,customer
	where collateral_relation_type = '2'
	and collateral.contract_id = account.contract_id
    and account.contract_id = contract.contract_id
	and contract.customer_id = customer.customer_id
	and collateral_amount > 1000000
	and YEAR(curdate()) - YEAR(customer.birth_date) > 60) as Selection1,
    (Select max(balance_value) as maxbal, account_id from balance
	where balance_type = 'Capital'
    group by account_id) as Selection2
where Selection1.accnid = Selection2.account_id
and Selection2.maxbal <= 500000;

-- QUERY 3 (DIFFICULT)
Select SQL_NO_CACHE count(collateral_id) from
	(Select collateral_id,collateral.contract_id as colconid from collateral,contract,customer
	where collateral_relation_type = '2'
	and collateral.contract_id = contract.contract_id
	and contract.customer_id = customer.customer_id
	and collateral_amount > 1000000
	and YEAR(curdate()) - YEAR(customer.birth_date) > 60) as Selection1,
	(Select sum(Selection3.maxbal) as sumcon,Selection3.acccon from
		(Select max(balance_value) as maxbal,account.contract_id as acccon from balance,account
		where balance_type = 'Capital' 
		and balance.account_id = account.account_id
		group by account.account_id) as Selection3
	group by Selection3.acccon) as Selection2
where Selection1.colconid = Selection2.acccon
and Selection2.sumcon <= 500000;

-- QUERY 4
Select SQL_NO_CACHE count(distinct account_id) from(
	Select max(balance_value) as balance_value,account_id from balance 
    where balance_type = 'Interest'
	group by account_id) as selection1,
    (Select collateral.collateral_id,collateral.account_id as collaccid from collateral,real_estate 
	where collateral_relation_type = '3'
	and collateral_type = '1'
	and collateral.collateral_id = real_estate.collateral_id
	and real_estate.appreciation_value > 100000) as selection2
where selection1.balance_value <= 10000
and selection1.account_id = selection2.collaccid;