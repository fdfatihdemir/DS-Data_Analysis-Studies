

--DAwSQL Session -8 

--E-Commerce Project Solution
create database eCommerceData




--1. Join all the tables and create a new table called combined_table. (market_fact, cust_dimen, orders_dimen, prod_dimen, shipping_dimen)
--Tüm tablolarý birleþtirin ve combined_table olarak isimlendirin. 

select * 
from dbo.market_fact a
join cust_dimen b on a.Cust_id = b.Cust_id
join dbo.orders_dimen c on c.Ord_id = a.Ord_id
join dbo.prod_dimen d on d.Prod_id = a.Prod_id
join dbo.shipping_dimen e on e.Ship_id = a.Ship_id


select a.Ord_id,a.Prod_id,a.Ship_id,a.Cust_id,a.Sales,a.Discount, a.Order_Quantity,
 a.Product_Base_Margin, b.Customer_Name,b.Province,b.Region,b.Customer_Segment,
 c.Order_Date,c.Order_Priority,d.Product_Category,d.Product_Sub_Category,e.Ship_Date,e.Ship_Mode,e.Order_ID into combined_table
from dbo.market_fact a
join cust_dimen b on a.Cust_id = b.Cust_id
join dbo.orders_dimen c on c.Ord_id = a.Ord_id
join dbo.prod_dimen d on d.Prod_id = a.Prod_id
join dbo.shipping_dimen e on e.Ship_id = a.Ship_id

select * from combined_table




--///////////////////////


--2. Find the top 3 customers who have the maximum count of orders.
--Maksimum sipariþ sayýsýna sahip ilk 3 müþteriyi bulun.

select  top 3 [Cust_id], count(distinct ord_id) Top_3_Max_Order
from combined_table
group by [Cust_id]
order by Top_3_Max_Order desc




--/////////////////////////////////



--3.Create a new column at combined_table as DaysTakenForDelivery that contains the date difference of Order_Date and Ship_Date.
--Use "ALTER TABLE", "UPDATE" etc.
/*Combined_table'da, Order_Date ve Ship_Date tarih farkýný içeren, DaysTakenForDelivery olarak yeni bir sütun oluþturun.
--"DEÐÝÞTÝRME TABLOSU", "GÜNCELLEME" vb. kullanýn*/

--Sütun oluþturma.
alter table combined_table add DaysTakenForDelivery int

--Sütun içini istenen bilgilerle doldurma. 
update combined_table set DaysTakenForDelivery = datediff(day,Order_Date,Ship_Date) 

-- Sonucu kontrol
select Ord_id, Order_Date,Ship_Date, DaysTakenForDelivery 
from combined_table
order by Ord_id


--////////////////////////////////////


--4. Find the customer whose order took the maximum time to get delivered.
--Use "MAX" or "TOP"
/*--4. Sipariþinin teslim edilmesi için maksimum süreyi alan müþteriyi bulun.
--"MAX" veya "TOP" kullanýn*/

--Tabloyu genel görelim. 
select * 
from combined_table

--sipariþ verip sipariþini en geç alan müþteri ve teslim süresi
select top 1 Ord_id, Cust_id, Customer_Name,Order_Date, Ship_Date, DaysTakenForDelivery
from combined_table
order by DaysTakenForDelivery desc

--sipariþ verip sipariþini en geç alan müþteri ve teslim süresi (Sadece Süre Görülmek Ýstenirse)
select top 1  DaysTakenForDelivery
from combined_table
order by DaysTakenForDelivery desc

--////////////////////////////////



--5. Count the total number of unique customers in January and
--how many of them came back every month over the entire year in 2011
--You can use date functions and subqueries
/*--5. Ocak ayýndaki toplam benzersiz müþteri sayýsýný ve
2011'de tüm yýl boyunca her ay kaç tanesinin geri geldiðini sayýn.
--Tarih fonksiyonlarýný ve alt sorgularý kullanabilirsiniz.*/
select * 
from combined_table

--A_2011 ocak ayýnda sipariþ veren müþteriler(tekrarsýz müþteri). 
select distinct Cust_id
from combined_table
where Order_Date between '2011-01-01' and '2011-01-31'--YEAR(Order_Date)= 2011 and MONTH (Order_Date)=01
--order by Order_Date asc;

--B_sipariþlerin sipariþ tarihine göre ay ay gruplanmasý(tekrarlý müþteriler dahil)

select  Month(Order_Date) Kacýncý_Ay, count(Cust_id) Musteri_Sayýsý 
from combined_table

where Order_Date like '2011%'--Order_Date between '2011-01-01' and '2011-12-31'
group by Month(Order_Date)
order by Month(Order_Date)

--B_sipariþlerin sipariþ tarihine göre ve unique müþterilerin  ay ay gruplanarak sayýlmasý

select  Month(Order_Date) Kacýncý_Ay,count(distinct Cust_id) Musteri_Sayýsý 
from combined_table

where Order_Date like '2011%'--Order_Date between '2011-01-01' and '2011-12-31'
group by Month(Order_Date)

/*Yapmak istediðim A ile son B yi kesiþtirmek. Burada kullanýlan iki tablo(combined_table) ayný gibi olsada
A'nýn içindeki Cust_id leri B'nin içindekileri kesiþtirmek lazýmmýþ. */
--C_2011 ocak ayýnda sipariþ veren müþterilerin diðer 2011 aylarý içinde sipariþ vermesi bilgileri.

select  Month(Order_Date) Kacýncý_Ay, count(distinct Cust_id) Tekrar_Gelen_Müþteri_Sayýsý
from combined_table A

where 
EXISTS(
select distinct Cust_id
from combined_table B
where A.Cust_id= b.Cust_id and Order_Date between '2011-01-01' and '2011-01-31' --YEAR(Order_Date)= 2011 and MONTH (Order_Date)=01			
)and Order_Date like '2011%'--Order_Date between '2011-01-01' and '2011-12-31' --YEAR(Order_Date)= 2011 (bu kýsmý eklemez isek tüm yýllar geliyor)
group by Month(Order_Date) 




--////////////////////////////////////////////

/*
6. write a query to return for each user acording to the time elapsed
between the first purchasing and the third purchasing, 
in ascending order by Customer ID
Use "MIN" with Window Functions*/
/*
6. ilk satýn alma ile üçüncü satýn alma arasýnda geçen süreye göre
her kullanýcý için iade edilecek bir sorgu yazabilir,
Müþteri Kimliðine göre artan sýrada
Pencere Ýþlevleriyle "MIN" kullanýn
*/

--tabloya genel bakalým. 
select *--Order_ID , Cust_id , Order_Date, Ship_Date
from combined_table
order by Cust_id

-- Order_date e cust_id ye göre over iþlemi ile grupladýk. min aldýk.
select	Cust_id, ord_id, Order_DATE,
		MIN (Order_DATE) over (partition by cust_id) First_ord_date,
		DENSE_RANK () over (partition by cust_id order by Order_date) frequent_number --kaç defa sirpariþ tekrarlanmýþ.
from	combined_table
----------------------------------------------------

select distinct Cust_id, order_date, frequent_number,First_ord_date,
DATEDIFF(day, First_ord_date, order_date) time_between_purchase
from
(
select	Cust_id, ord_id, Order_DATE,
		MIN (Order_DATE) over (partition by cust_id) First_ord_date,
		DENSE_RANK () over (partition by cust_id order by Order_date) frequent_number
from	combined_table
) A
where frequent_number = 3


--//////////////////////////////////////

--7. Write a query that returns customers who purchased both product 11 and product 14, 
--as well as the ratio of these products to the total number of products purchased by all customers.
--Use CASE Expression, CTE, CAST and/or Aggregate Functions
/*
7. Hem 11. ürünü hem de 14. ürünü satýn alan müþterileri döndüren bir sorgu yazýn,
ve bu ürünlerin tüm müþteriler tarafýndan satýn alýnan toplam ürün sayýsýna oraný.
CASE Ýfadesi, CTE, CAST ve/veya Toplama Ýþlevlerini Kullanýn
*/

--14. inci ürün alan Cust_id ler.
select cust_id
from combined_table
where prod_id = 'Prod_14'

--11. inci ürün alan Cust_id ler.
select cust_id
from combined_table
where prod_id = 'Prod_11'


--Hem 11. ürünü hem de 14. ürünü satýn alan müþteriler

(select cust_id
from combined_table
where prod_id = 'Prod_14')
INTERSECT
(select cust_id
from combined_table
where prod_id = 'Prod_11')


-- Önceki  ürünlerin tüm müþteriler tarafýndan satýn alýnan toplam ürün sayýsýna oraný.


select (
(select count(*)
from combined_table
where prod_id = 'Prod_11') + (select count(*)
from combined_table
where prod_id = 'Prod_14')) / ((select count(*) from combined_table) * 1.0)



--/////////////////



--CUSTOMER SEGMENTATION



--1. Create a view that keeps visit logs of customers on a monthly basis. (For each log, three field is kept: Cust_id, Year, Month)
--Use such date functions. Don't forget to call up columns you might need later.
/*
1. Müþterilerin ziyaret günlüklerini aylýk olarak tutan bir görünüm oluþturun. (Her log için üç alan tutulur: Cust_id, Year, Month)
Bu tür tarih fonksiyonlarýný kullanýn. Daha sonra ihtiyaç duyabileceðiniz sütunlarý çaðýrmayý unutmayýn.
*/
create view monthly_logs as

select cust_id,
          year(order_date) as Years,
		  month(Order_Date) as Months,
		  Order_Date
		  
from dbo.combined_table


--//////////////////////////////////



--2.Create a “view” that keeps the number of monthly visits by users. (Show separately all months from the beginning  business)
--Don't forget to call up columns you might need later.
/*
2.Kullanýcýlarýn aylýk ziyaretlerinin sayýsýný tutan bir "görünüm" oluþturun. (Ýþ baþlangýcýndan itibaren tüm aylarý ayrý ayrý gösterin)
Daha sonra ihtiyaç duyabileceðiniz sütunlarý çaðýrmayý unutmayýn.
*/
create view month_visits as

select cust_id ,Years,Months,count(*) num

from dbo.monthly_logs
group by cust_id,Years,Months




--//////////////////////////////////


--3. For each visit of customers, create the next month of the visit as a separate column.
--You can order the months using "DENSE_RANK" function.
--then create a new column for each month showing the next month using the order you have made above. (use "LEAD" function.)
--Don't forget to call up columns you might need later.
/*
3. Müþterilerin her ziyareti için, ziyaretin bir sonraki ayýný ayrý bir sütun olarak oluþturun.
"DENSE_RANK" fonksiyonunu kullanarak aylarý sýralayabilirsiniz.
daha sonra yukarýda yaptýðýnýz sýrayý kullanarak her ay için bir sonraki ayý gösteren yeni bir sütun oluþturun. ("KURÞUN" iþlevini kullanýn.)
Daha sonra ihtiyaç duyabileceðiniz sütunlarý çaðýrmayý unutmayýn.
*/







--/////////////////////////////////



--4. Calculate monthly time gap between two consecutive visits by each customer.
--Don't forget to call up columns you might need later.
/*
4. Her müþteri tarafýndan iki ardýþýk ziyaret arasýndaki aylýk zaman aralýðýný hesaplayýn.
Daha sonra ihtiyaç duyabileceðiniz sütunlarý çaðýrmayý unutmayýn.
*/

d





--///////////////////////////////////


--5.Categorise customers using average time gaps. Choose the most fitted labeling model for you.
--For example: 
--Labeled as “churn” if the customer hasn't made another purchase for the months since they made their first purchase.
--Labeled as “regular” if the customer has made a purchase every month.
--Etc.
/*
5.Ortalama zaman boþluklarýný kullanarak müþterileri kategorilere ayýrýn. Size en uygun etiketleme modelini seçin.
Örneðin:
Müþteri, ilk satýn alýmýndan bu yana aylar boyunca baþka bir satýn alma iþlemi yapmadýysa, "kayýp" olarak etiketlenir.
Müþteri her ay bir satýn alma iþlemi yaptýysa "düzenli" olarak etiketlenir.
Vb.
*/








--/////////////////////////////////////




--MONTH-WISE RETENTÝON RATE


--Find month-by-month customer retention rate  since the start of the business.
/*
--Ýþin baþlangýcýndan bu yana aylýk müþteri elde tutma oranýný bulun.
*/


--1. Find the number of customers retained month-wise. (You can use time gaps)
--Use Time Gaps
/*
1. Ay bazýnda elde tutulan müþteri sayýsýný bulun. (Zaman boþluklarýný kullanabilirsiniz)
--Zaman Boþluklarýný Kullanýn
*/





--//////////////////////


--2. Calculate the month-wise retention rate.

--Basic formula: o	Month-Wise Retention Rate = 1.0 * Number of Customers Retained in The Current Month / Total Number of Customers in the Current Month

--It is easier to divide the operations into parts rather than in a single ad-hoc query. It is recommended to use View. 
--You can also use CTE or Subquery if you want.

--You should pay attention to the join type and join columns between your views or tables.

/*
---2. Ay bazýnda elde tutma oranýný hesaplayýn.

--Temel formül: o Ay Bazýnda Elde Tutma Oraný = 1.0 * Ýçinde Bulunulan Ayda Elde Tutulan Müþteri Sayýsý / Ýçinde Bulunan Aydaki Toplam Müþteri Sayýsý

--Ýþlemleri tek bir geçici sorgu yerine parçalara bölmek daha kolaydýr. Görünüm'ü kullanmanýz önerilir.
--Ýsterseniz CTE veya Alt Sorgu da kullanabilirsiniz.

--Görünümleriniz veya tablolarýnýz arasýnda birleþtirme türüne ve birleþtirme sütunlarýna dikkat etmelisiniz.
*/







---///////////////////////////////////
--Good luck!