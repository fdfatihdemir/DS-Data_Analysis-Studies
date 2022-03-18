           /* ASSINGMENT-4*/

/* Discount Effects

Generate a report including product IDs and discount effects on whether the increase 

in the discount rate positively impacts the number of orders for the products.

In this assignment, you are expected to generate a solution using SQL with a logical approach. */

/* ÝNDÝRÝM ORANLARININ SÝPARÝS SAYILARINA ETKÝLERÝ*/

/*Ýndirim oranýndaki artýþýn ürünler için sipariþ sayýsýný olumlu etkileyip etkilemediðine dair ürün kimliklerini 

ve indirim etkilerini içeren bir rapor oluþturun.

Bu ödevde mantýksal bir yaklaþýmla SQL kullanarak bir çözüm üretmeniz beklenmektedir.*/


SELECT product_id, discount, sum(quantity) count_005
FROM sale.order_item a
WHERE  discount=0.05
GROUP BY product_id, discount
ORDER BY product_id

SELECT product_id, discount, sum(quantity) count_007
FROM sale.order_item a
WHERE  discount=0.07
GROUP BY product_id, discount
ORDER BY product_id

SELECT product_id, discount, sum(quantity) count_010
FROM sale.order_item a
WHERE  discount=0.10
GROUP BY product_id, discount
ORDER BY product_id

SELECT product_id, discount, sum(quantity) count_020
FROM sale.order_item a
WHERE  discount=0.20
GROUP BY product_id, discount
ORDER BY product_id






SELECT DISTINCT  a.product_id, 
CASE
    WHEN (d.total10_20-c.total5_7) < 0 THEN 'Negative'
    WHEN (d.total10_20-c.total5_7) > 0 THEN 'Positive'
    ELSE 'Neutral'
END AS Discount_Effect
FROM sale.order_item a 
join sale.orders b
ON a.order_id=b.order_id
join (	SELECT a.product_id, (count_005+count_007) total5_7
FROM (
      SELECT product_id, discount, SUM(quantity) count_005
      FROM sale.order_item a, sale.orders b
	  WHERE a.order_id=b.order_id 
	  and discount=0.05
	  GROUP BY product_id, discount) a
join (
	 SELECT product_id, discount, SUM(quantity) count_007
	 FROM sale.order_item a, sale.orders b
	 WHERE a.order_id=b.order_id 
	 and discount=0.07
	 GROUP BY product_id, discount) b
	 ON  a.product_id=b.product_id ) c
ON a.product_id=c.product_id
join(	
     SELECT a.product_id, (count_010+count_020) total10_20
	 FROM (
	 SELECT product_id, discount, SUM(quantity) count_010
	 FROM sale.order_item a, sale.orders b
	 WHERE a.order_id=b.order_id 
	 and discount=0.10
	 GROUP BY product_id, discount) a
join (
	 SELECT product_id, discount, SUM(quantity) count_020
	 FROM sale.order_item a, sale.orders b
	 WHERE a.order_id=b.order_id 
	 and discount=0.20
	 GROUP BY product_id, discount) b
	 ON  a.product_id=b.product_id ) d
ON a.product_id=d.product_id
ORDER BY a.product_id