create schema final;

select * from dim_drug_brand;
select * from dim_drug_details;
select * from dim_member;
select * from fact_drug_insurance;

# Setting Primary Key

alter table dim_drug_brand
add primary key (drug_brand_generic_code);

alter table dim_drug_details
add primary key (drug_ndc);

alter table dim_member
add primary key (member_id);

alter table fact_drug_insurance
add primary key (id);

# Setting foreign keys

alter table fact_drug_insurance
add foreign key fact_drug_member_id_fk (member_id)
references dim_member(member_id)
on update cascade
on delete restrict;

alter table fact_drug_insurance
add foreign key fact_drug_generic_fk (drug_brand_generic_code)
references dim_drug_brand (drug_brand_generic_code)
on update cascade
on delete cascade;

alter table fact_drug_insurance
add foreign key fact_drug_ndc_fk (drug_ndc)
references dim_drug_details (drug_ndc)
on delete restrict
on update cascade;

# Queries

select drug_name, count(fill_date) as no_of_prescriptions
from dim_drug_details
join fact_drug_insurance
on dim_drug_details.drug_ndc  = fact_drug_insurance.drug_ndc
group by drug_name
having	drug_name = 'Ambien';

select count(fill_date), count(distinct fact_drug_insurance.member_id),sum(copay),sum(insurancepaid),
case 
when member_age > 65 then '65+'
when member_age < 64 then '<65'
end as age
from dim_member
join fact_drug_insurance
on dim_member.member_id = fact_drug_insurance.member_id
group by age;

update `fact_drug_insurance` set `fill_date` = STR_TO_DATE( `fill_date`, '%d-%m-%Y');

create table table1 as
select fact_drug_insurance.member_id,member_first_name, member_last_name, drug_name,fill_date,insurancepaid
from dim_member
join fact_drug_insurance
on dim_member.member_id = fact_drug_insurance.member_id
join dim_drug_details
on dim_drug_details.drug_ndc = fact_drug_insurance.drug_ndc
order by fact_drug_insurance.member_id,fill_date desc ;

create table table2 as
select member_id,member_first_name,member_last_name,drug_name,fill_date,insurancepaid,row_number() over(partition by member_id) 
as flag from table1 ;
select * from table2 where flag = 1;






