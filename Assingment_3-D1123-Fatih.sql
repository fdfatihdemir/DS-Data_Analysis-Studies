-------------------SQL ASSINGMENT-3 ------------------
---1. **Conversion Rate**
--Below you see a table of the actions of customers visiting the website by clicking 
--on two different types of advertisements given by an E-Commerce company.
--Write a query to return the conversion rate for each Advertisement type.

-- 1.** Dönüþüm Oraný**
--(Aþaðýda, bir E-Ticaret þirketi tarafýndan verilen iki farklý reklam türüne týklayarak web 
--sitesini ziyaret eden müþterilerin eylemlerinin bir tablosunu görüyorsunuz. 
--Her bir Reklam türü için dönüþüm oranýný döndürecek bir sorgu yazýn.)


---a.	Create above table (Actions) and insert values,
----Yukarýdaki tabloyu (Eylemler) oluþturun ve deðerleri ekleyin,

create database Advertisement

create table actions
(
		Visitor_ID int identity (1,1) primary key,
		Adv_Type varchar (50) not null,
		Action_Table varchar (50) not null
);

INSERT actions VALUES
 ('A',  'Left')
,('A' , 'Order')
,('B' , 'Left')
,('A' , 'Order')
,('A' , 'Review')
,('A' , 'Left')
,('B' , 'Left')
,('B' , 'Order')
,('B' , 'Review')
,('A' , 'Review')

TRUNCATE TABLE actions;  --Tablo içindeki verileri siler.


select *     --(tablodaki verilere göz atmak için)
from actions



--b.	Retrieve count of total Actions and Orders for each Advertisement Type, 
---(Her Reklam Türü için toplam Ýþlem ve Emir sayýsýný alma)

---Adv_Type tablosuna göre group by yapýyoruz. Action_Table da 'Order'a eþit olanlarý sayýyoruz. 
---Saydýðýmýz deðerleri Total Action olarak yeni bir column da gösteriyoruz. 

select  Adv_Type, count(Action_Table) Total_Action    
from actions 
where Action_Table= 'Order'
group by Adv_Type;

select Adv_Type, count(Action_Table) total
from actions 
group by Adv_Type



----c.	Calculate Orders (Conversion) rates for each Advertisement Type by dividing 
--by total count of actions casting as float by multiplying by 1.0. 
--(Her bir Reklam Türü için Sipariþ (Dönüþüm) oranlarýný, --
--1.0 ile çarparak deðiþken olarak gösterilen toplam eylem sayýsýna bölerek hesaplayýn.)

----BU SORUYU YAPAMADIM--- ÇOK UÐRAÞTIM OLMADI :( ---
--------------------------
select *
from actions
-----------------------------


select * 
from Total_Action
full outer join total on Total_Action.Adv_Type=total.Adv_Type


----------------------------------------------
select * 
from (select  Adv_Type, count(Action_Table) Total_Action    
from actions 
where Action_Table= 'Order'
group by Adv_Type) A

full outer join (select Adv_Type, count(Action_Table) total
from actions 
group by Adv_Type) B
on Total_Action.Adv_Type=total.Adv_Type

-----------------------------------------------
select A.Adv_Type,A.Total_Action,B.total
from (select  Adv_Type, count(Action_Table) Total_Action    
from actions 
where Action_Table= 'Order'
group by Adv_Type) A

full outer join (select Adv_Type, count(Action_Table) total
from actions 
group by Adv_Type) B
on Total_Action.Adv_Type=total.Adv_Type


----------------------------------------------


select A.Adv_Type,A.Total_Action,B.total
from (select  Adv_Type, count(Action_Table) Total_Action    
from actions 
where Action_Table= 'Order'
group by Adv_Type) A

left join (select Adv_Type, count(Action_Table) total
from actions 
group by Adv_Type) B
on Total_Action.Adv_Type=total.Adv_Type

-----------------------------------------------

select count(Action_Table) total
from actions 
where Action_Table = 'Order' and Adv_Type= 'A'
group by Adv_Type

select count(Action_Table) total
from actions 
where Action_Table = 'Order' and Adv_Type = 'B'





-----------------------------------



select  AA.Adv_Type , (BB.total/(CC.total_Action*1.0) Conversion_Rate
from actions AA
		 join (select  Adv_Type, count(Action_Table) Total_Action    
		from actions 
		where Action_Table= 'Order'
		group by Adv_Type) BB	

		on AA.Adv_Type=BB.Adv_Type

		join(select Adv_Type, count(Action_Table) total
		from actions 
		group by Adv_Type) CC

		on AA.Adv_Type=CC.Adv_Type




