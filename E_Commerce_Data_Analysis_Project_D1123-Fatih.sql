

--DAwSQL Session -8 

--E-Commerce Project Solution
create database eCommerceData




--1. Join all the tables and create a new table called combined_table. (market_fact, cust_dimen, orders_dimen, prod_dimen, shipping_dimen)
--T�m tablolar� birle�tirin ve combined_table olarak isimlendirin. 

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
--Maksimum sipari� say�s�na sahip ilk 3 m��teriyi bulun.

select  top 3 [Cust_id], count(distinct ord_id) Top_3_Max_Order
from combined_table
group by [Cust_id]
order by Top_3_Max_Order desc




--/////////////////////////////////



--3.Create a new column at combined_table as DaysTakenForDelivery that contains the date difference of Order_Date and Ship_Date.
--Use "ALTER TABLE", "UPDATE" etc.
/*Combined_table'da, Order_Date ve Ship_Date tarih fark�n� i�eren, DaysTakenForDelivery olarak yeni bir s�tun olu�turun.
--"DE���T�RME TABLOSU", "G�NCELLEME" vb. kullan�n*/

--S�tun olu�turma.
alter table combined_table add DaysTakenForDelivery int

--S�tun i�ini istenen bilgilerle doldurma. 
update combined_table set DaysTakenForDelivery = datediff(day,Order_Date,Ship_Date) 

-- Sonucu kontrol
select Ord_id, Order_Date,Ship_Date, DaysTakenForDelivery 
from combined_table
order by Ord_id


--////////////////////////////////////


--4. Find the customer whose order took the maximum time to get delivered.
--Use "MAX" or "TOP"
/*--4. Sipari�inin teslim edilmesi i�in maksimum s�reyi alan m��teriyi bulun.
--"MAX" veya "TOP" kullan�n*/

--Tabloyu genel g�relim. 
select * 
from combined_table

--sipari� verip sipari�ini en ge� alan m��teri ve teslim s�resi
select top 1 Ord_id, Cust_id, Customer_Name,Order_Date, Ship_Date, DaysTakenForDelivery
from combined_table
order by DaysTakenForDelivery desc

--sipari� verip sipari�ini en ge� alan m��teri ve teslim s�resi (Sadece S�re G�r�lmek �stenirse)
select top 1  DaysTakenForDelivery
from combined_table
order by DaysTakenForDelivery desc

--////////////////////////////////



--5. Count the total number of unique customers in January and
--how many of them came back every month over the entire year in 2011
--You can use date functions and subqueries
/*--5. Ocak ay�ndaki toplam benzersiz m��teri say�s�n� ve
2011'de t�m y�l boyunca her ay ka� tanesinin geri geldi�ini say�n.
--Tarih fonksiyonlar�n� ve alt sorgular� kullanabilirsiniz.*/
select * 
from combined_table

--A_2011 ocak ay�nda sipari� veren m��teriler(tekrars�z m��teri). 
select distinct Cust_id
from combined_table
where Order_Date between '2011-01-01' and '2011-01-31'--YEAR(Order_Date)= 2011 and MONTH (Order_Date)=01
--order by Order_Date asc;

--B_sipari�lerin sipari� tarihine g�re ay ay gruplanmas�(tekrarl� m��teriler dahil)

select  Month(Order_Date) Kac�nc�_Ay, count(Cust_id) Musteri_Say�s� 
from combined_table

where Order_Date like '2011%'--Order_Date between '2011-01-01' and '2011-12-31'
group by Month(Order_Date)
order by Month(Order_Date)

--B_sipari�lerin sipari� tarihine g�re ve unique m��terilerin  ay ay gruplanarak say�lmas�

select  Month(Order_Date) Kac�nc�_Ay,count(distinct Cust_id) Musteri_Say�s� 
from combined_table

where Order_Date like '2011%'--Order_Date between '2011-01-01' and '2011-12-31'
group by Month(Order_Date)

/*Yapmak istedi�im A ile son B yi kesi�tirmek. Burada kullan�lan iki tablo(combined_table) ayn� gibi olsada
A'n�n i�indeki Cust_id leri B'nin i�indekileri kesi�tirmek laz�mm��. */
--C_2011 ocak ay�nda sipari� veren m��terilerin di�er 2011 aylar� i�inde sipari� vermesi bilgileri.

select  Month(Order_Date) Kac�nc�_Ay, count(distinct Cust_id) Tekrar_Gelen_M��teri_Say�s�
from combined_table A

where 
EXISTS(
select distinct Cust_id
from combined_table B
where A.Cust_id= b.Cust_id and Order_Date between '2011-01-01' and '2011-01-31' --YEAR(Order_Date)= 2011 and MONTH (Order_Date)=01			
)and Order_Date like '2011%'--Order_Date between '2011-01-01' and '2011-12-31' --YEAR(Order_Date)= 2011 (bu k�sm� eklemez isek t�m y�llar geliyor)
group by Month(Order_Date) 




--////////////////////////////////////////////

/*
6. write a query to return for each user acording to the time elapsed
between the first purchasing and the third purchasing, 
in ascending order by Customer ID
Use "MIN" with Window Functions*/
/*
6. ilk sat�n alma ile ���nc� sat�n alma aras�nda ge�en s�reye g�re
her kullan�c� i�in iade edilecek bir sorgu yazabilir,
M��teri Kimli�ine g�re artan s�rada
Pencere ��levleriyle "MIN" kullan�n
*/

--tabloya genel bakal�m. 
select *--Order_ID , Cust_id , Order_Date, Ship_Date
from combined_table
order by Cust_id

-- Order_date e cust_id ye g�re over i�lemi ile gruplad�k. min ald�k.
select	Cust_id, ord_id, Order_DATE,
		MIN (Order_DATE) over (partition by cust_id) First_ord_date,
		DENSE_RANK () over (partition by cust_id order by Order_date) frequent_number --ka� defa sirpari� tekrarlanm��.
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
7. Hem 11. �r�n� hem de 14. �r�n� sat�n alan m��terileri d�nd�ren bir sorgu yaz�n,
ve bu �r�nlerin t�m m��teriler taraf�ndan sat�n al�nan toplam �r�n say�s�na oran�.
CASE �fadesi, CTE, CAST ve/veya Toplama ��levlerini Kullan�n
*/

--14. inci �r�n alan Cust_id ler.
select cust_id
from combined_table
where prod_id = 'Prod_14'

--11. inci �r�n alan Cust_id ler.
select cust_id
from combined_table
where prod_id = 'Prod_11'


--Hem 11. �r�n� hem de 14. �r�n� sat�n alan m��teriler

(select cust_id
from combined_table
where prod_id = 'Prod_14')
INTERSECT
(select cust_id
from combined_table
where prod_id = 'Prod_11')


-- �nceki  �r�nlerin t�m m��teriler taraf�ndan sat�n al�nan toplam �r�n say�s�na oran�.


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
1. M��terilerin ziyaret g�nl�klerini ayl�k olarak tutan bir g�r�n�m olu�turun. (Her log i�in �� alan tutulur: Cust_id, Year, Month)
Bu t�r tarih fonksiyonlar�n� kullan�n. Daha sonra ihtiya� duyabilece�iniz s�tunlar� �a��rmay� unutmay�n.
*/
create view monthly_logs as

select cust_id,
          year(order_date) as Years,
		  month(Order_Date) as Months,
		  Order_Date
		  
from dbo.combined_table


--//////////////////////////////////



--2.Create a �view� that keeps the number of monthly visits by users. (Show separately all months from the beginning  business)
--Don't forget to call up columns you might need later.
/*
2.Kullan�c�lar�n ayl�k ziyaretlerinin say�s�n� tutan bir "g�r�n�m" olu�turun. (�� ba�lang�c�ndan itibaren t�m aylar� ayr� ayr� g�sterin)
Daha sonra ihtiya� duyabilece�iniz s�tunlar� �a��rmay� unutmay�n.
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
3. M��terilerin her ziyareti i�in, ziyaretin bir sonraki ay�n� ayr� bir s�tun olarak olu�turun.
"DENSE_RANK" fonksiyonunu kullanarak aylar� s�ralayabilirsiniz.
daha sonra yukar�da yapt���n�z s�ray� kullanarak her ay i�in bir sonraki ay� g�steren yeni bir s�tun olu�turun. ("KUR�UN" i�levini kullan�n.)
Daha sonra ihtiya� duyabilece�iniz s�tunlar� �a��rmay� unutmay�n.
*/







--/////////////////////////////////



--4. Calculate monthly time gap between two consecutive visits by each customer.
--Don't forget to call up columns you might need later.
/*
4. Her m��teri taraf�ndan iki ard���k ziyaret aras�ndaki ayl�k zaman aral���n� hesaplay�n.
Daha sonra ihtiya� duyabilece�iniz s�tunlar� �a��rmay� unutmay�n.
*/

d





--///////////////////////////////////


--5.Categorise customers using average time gaps. Choose the most fitted labeling model for you.
--For example: 
--Labeled as �churn� if the customer hasn't made another purchase for the months since they made their first purchase.
--Labeled as �regular� if the customer has made a purchase every month.
--Etc.
/*
5.Ortalama zaman bo�luklar�n� kullanarak m��terileri kategorilere ay�r�n. Size en uygun etiketleme modelini se�in.
�rne�in:
M��teri, ilk sat�n al�m�ndan bu yana aylar boyunca ba�ka bir sat�n alma i�lemi yapmad�ysa, "kay�p" olarak etiketlenir.
M��teri her ay bir sat�n alma i�lemi yapt�ysa "d�zenli" olarak etiketlenir.
Vb.
*/








--/////////////////////////////////////




--MONTH-WISE RETENT�ON RATE


--Find month-by-month customer retention rate  since the start of the business.
/*
--��in ba�lang�c�ndan bu yana ayl�k m��teri elde tutma oran�n� bulun.
*/


--1. Find the number of customers retained month-wise. (You can use time gaps)
--Use Time Gaps
/*
1. Ay baz�nda elde tutulan m��teri say�s�n� bulun. (Zaman bo�luklar�n� kullanabilirsiniz)
--Zaman Bo�luklar�n� Kullan�n
*/





--//////////////////////


--2. Calculate the month-wise retention rate.

--Basic formula: o	Month-Wise Retention Rate = 1.0 * Number of Customers Retained in The Current Month / Total Number of Customers in the Current Month

--It is easier to divide the operations into parts rather than in a single ad-hoc query. It is recommended to use View. 
--You can also use CTE or Subquery if you want.

--You should pay attention to the join type and join columns between your views or tables.

/*
---2. Ay baz�nda elde tutma oran�n� hesaplay�n.

--Temel form�l: o Ay Baz�nda Elde Tutma Oran� = 1.0 * ��inde Bulunulan Ayda Elde Tutulan M��teri Say�s� / ��inde Bulunan Aydaki Toplam M��teri Say�s�

--��lemleri tek bir ge�ici sorgu yerine par�alara b�lmek daha kolayd�r. G�r�n�m'� kullanman�z �nerilir.
--�sterseniz CTE veya Alt Sorgu da kullanabilirsiniz.

--G�r�n�mleriniz veya tablolar�n�z aras�nda birle�tirme t�r�ne ve birle�tirme s�tunlar�na dikkat etmelisiniz.
*/







---///////////////////////////////////
--Good luck!