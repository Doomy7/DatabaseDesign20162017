#DROP IF EXISTS
drop database if exists dbdesign2017;
#CREATE
create database dbdesign2017;
#USE
use dbdesign2017;

#CREATE dat TABLE======================================================================================
create table Collateral
(
	customer_id varchar(10),
    birthdate date,
    afm int(10),
    contract_id varchar(15),
    signature_date date,
    limit_amount int(6),
    contract_type varchar(30),
    account_id varchar(20),
    starting_date date,
    status_ varchar(25),
    product_code int(5),
    collateral_id varchar(10),
    collateral_type int(2),
    collateral_amount int(10),
    collateral_end date,
    collateral_relation_type int(2),
    real_estate_id varchar(10),
    appreciation_value int(7),
    appreciation_date date,
    property_type int(2)
);

#CREATE Balance TABLE======================================================================================
create table Balance
(
	
	customer_id varchar(10),
    birthdate date,
    afm int(10),
    contract_id varchar(15),
    signature_date date,
    limit_amount int(6),
    contract_type varchar(30),
    account_id varchar(20),
    starting_date date,
    status_ varchar(25),
    product_code int(5),
    balance_value int(8),
    balance_date date,
    balance_type varchar(12)

);

#CREATE Customer TABLE======================================================================================
create table Customer
(
	customer_id int(10),
    birthdate date,
    afm int(10),
    primary key (customer_id)
    
);

#CREATE Contract TABLE======================================================================================
create table Contract
(
    contract_id varchar(15),
    signature_date date,
    limit_amount int(6),
    contract_type varchar(30),
    customer_id int(10),
    primary key (contract_id),
    foreign key (customer_id) references Customer(customer_id)
    
);

#CREATE Account_ TABLE======================================================================================
create table Account_
(
	account_id varchar(20),
    starting_date date,
    status_ varchar(25),
    product_code int(5),
	contract_id varchar(15),
    primary key (account_id),
    foreign key (contract_id) references Contract(contract_id)
);

#CREATE Real_estate TABLE===================================================================================
create table Real_estate
(
	real_estate_id varchar(10),
    appreciation_value int(7),
    appreciation_date date,
    property_type int(2),
    primary key (real_estate_id)
    
);

#LOAD INTO Balance==========================================================================================
load data local infile 'C://Data/bal.txt'
into table Balance
fields terminated by '@'
lines terminated by '\r\n'
ignore 1 lines(
	customer_id,@birthdate,afm,contract_id,@signature_date,limit_amount, contract_type,
    account_id,@starting_date,status_,product_code,balance_value,@balance_date,balance_type)
set
birthdate = STR_TO_DATE(@birthdate,'%d/%m/%Y'),
signature_date = STR_TO_DATE(@signature_date,'%d/%m/%Y'),
starting_date = STR_TO_DATE(@starting_date,'%d/%m/%Y'),
balance_date = STR_TO_DATE(@balance_date,'%d/%m/%Y');

#LOAD INTO dat=============================================================================================
load data local infile 'C://Data/dat.txt' 
into table Collateral
fields terminated by '@'
lines terminated by '\r\n'
ignore 1 lines(
	customer_id,@birthdate,afm,contract_id,@signature_date,limit_amount,contract_type,
    account_id,@starting_date,status_,product_code,collateral_id,collateral_type,
    collateral_amount,@collateral_end,collateral_relation_type,real_estate_id,appreciation_value,
    @appreciation_date,property_type)
set
birthdate = STR_TO_DATE(@birthdate,'%d/%m/%Y'),
signature_date = STR_TO_DATE(@signature_date,'%d/%m/%Y'),
starting_date = STR_TO_DATE(@starting_date,'%d/%m/%Y'),
collateral_end = STR_TO_DATE(@collateral_end,'%d/%m/%Y'),
appreciation_date = STR_TO_DATE(@appreciation_date,'%d/%m/%Y');

#INSERT Customer============================================================================================
insert into Customer (customer_id,birthdate,afm)
select distinct customer_id,birthdate,afm
from Collateral;

#INSERT Contract============================================================================================
insert into Contract(contract_id,signature_date,limit_amount,contract_type,customer_id)
select distinct contract_id,signature_date,limit_amount,contract_type,customer_id
from Collateral;

#INSERT Account_============================================================================================
insert into Account_(account_id,starting_date,status_,product_code,contract_id)
select distinct account_id,starting_date,status_,product_code,contract_id
from Collateral;

#INSERT Real_estate=========================================================================================
insert into Real_estate(real_estate_id,appreciation_value,appreciation_date,property_type)
select distinct real_estate_id,appreciation_value,appreciation_date,property_type
from Collateral
where real_estate_id is not null;

#ALTER Collateral==========================================================================================
alter table Collateral drop column customer_id, drop column birthdate, drop column  afm, drop column  contract_id,
				drop column signature_date, drop column  limit_amount, drop column  contract_type,
				drop column starting_date, drop column  status_, drop column  product_code,
                drop column appreciation_value, drop column appreciation_date, drop column property_type;

alter table Collateral add primary key (collateral_id);
alter table Collateral add foreign key (account_id) references Account_(account_id);
alter table Collateral add foreign key (real_estate_id) references Real_estate(real_estate_id);

#ALTER Balance=============================================================================================
alter table Balance drop column customer_id, drop column birthdate, drop column  afm, drop column  contract_id,
				drop column signature_date, drop column  limit_amount, drop column  contract_type,
				drop column  starting_date, drop column  status_, drop column  product_code;

alter table Balance add primary key (account_id,balance_date,balance_type);
alter table Balance add foreign key (account_id) references Account_(account_id);





#QUERY 1
Select count(distinct Customer.customer_id) from Contract,Customer
		where (Year(Contract.signature_date) - Year(Customer.birthdate)) < 19
        and Customer.customer_id = Contract.customer_id; 


#QUERY 2
Select count(distinct Customer.customer_id) from Customer,Contract,Collateral,Real_estate,Account_
where Real_estate.property_type = 1 and
	Collateral.collateral_relation_type = 1 and
    Collateral.collateral_type = 1 and
    Real_estate.real_estate_id = Collateral.real_estate_id and
    Collateral.account_id = Account_.account_id and
    Account_.contract_id = Contract.contract_id and
	Contract.customer_id = Customer.customer_id and
    (Year(curdate()) - Year(Customer.birthdate)) > 60;

#QUERY 3 
select count(distinct Customer.customer_id) from Account_,Contract,Customer,Balance bal1
join (Select account_id,max(balance_date) as maxbd from Balance
		where balance_type = 'Capital'
		group by account_id) bal2
	on bal2.account_id = bal1.account_id and bal2.maxbd = bal1.balance_date
    where balance_type = 'Capital' and balance_value > 1000000
    and bal1.account_id = Account_.account_id
    and Account_.contract_id = Contract.contract_id
    and Contract.customer_id = Customer.customer_id;

#QUERY 4
Select account_id,count(collateral_id),sum(collateral_amount) from Collateral
group by account_id;