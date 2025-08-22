create database eticaret;

create schema sales;

create table sales."customer"(
customer_id int,
primary key(customer_id)
);

create table sales."invoice"(
invoice_no bigint primary key,
invoice_date timestamp ,
customer_id int,
foreign key(customer_id) references sales."customer"(customer_id)
);

create table sales."product"(
product_id serial primary key,
product varchar(200)  not null,
product_color varchar(200)  not null,
CONSTRAINT unique_product UNIQUE(product, product_color)
);

create table sales."sold_product" (
    invoice_no BIGINT,
    product_id BIGINT,
    quantity INT,
    unit_price NUMERIC(20,10),
    PRIMARY KEY (invoice_no, product_id),
    FOREIGN KEY (invoice_no) REFERENCES sales."invoice"(invoice_no),
    FOREIGN KEY (product_id) REFERENCES sales."product"(product_id)
);


CREATE TEMP TABLE tmp_customer (
    invoice_no bigint,
    customer_id bigint,
    invoice_date date,
    quantity INT,
    unit_price NUMERIC(20,10),
    product varchar(200),
    product_color varchar(200)
);

select* from sales."customer" 
select*from sales.product
select* from sales.sold_product

select * from tmp_customer;

drop table tmp_customer

/copy "tmp_customer"
from '/home/ipek/Bussiness_data.csv'
delimiter','
csv header

SELECT COUNT(customer_id) AS toplam_musteri
FROM sales.customer;

insert into sales."sold_product"(invoice_no,quantity,unit_price)
select invoice_no,quantity,unit_price
from tmp_customer

--------------------------------------------------------------
SELECT invoice_no, product_id,quantity,unit_price, COUNT(*)
FROM sales."sold_product"
WHERE product_id IS NOT NULL
GROUP BY invoice_no, product_id,quantity,unit_price
HAVING COUNT(*) > 1;


---------------------------------------------------Q2

------a. Aylık net satış tutarı ve satış adeti
--Index:
--Btree Index:B-tree indeksleme, büyük veri bloklarını, her düğümün artan sırada anahtarlar içerecek şekilde sıralama işlemidir

create index index_invoice_date on sales."invoice"(invoice_date);

create view sales.total_amount_by_month as
 select 
 date_trunc('month',i.invoice_date) months,
 sum(sp.quantity*sp.unit_price) as total_amount
 from sales."sold_product" sp
 join sales."invoice" i
  on sp.invoice_no=i.invoice_no
 group by date_trunc('month',i.invoice_date )
 order by date_trunc('month',i.invoice_date ) 
 
 select * from sales.total_amount_by_month
 
 
 
 ------b. Satış tutarı en çok olan 20 müşterinin kaç kere alışveriş yaptığı ve bu alışverişlerin ortalama tutarları
 create index index_maxamount_by_customer on sales."sold_product"(quantity,unit_price)
 
 create index index_customer_id on sales."customer"(customer_id)
 
 create view sales.maxamount_by_customer as
  select
    c.customer_id,
    sum(sp.quantity*sp.unit_price) as total_amount,
    count(i.invoice_no ) as shopping_number_by_invoice,
    sum(sp.quantity*sp.unit_price)/count(i.invoice_no ) as average_cost  --fatura üzerine düşen ortalama tutar
 from sales."sold_product" sp
 join sales."invoice" i 
  on sp.invoice_no=i.invoice_no
 join sales."customer" c
  on i.customer_id = c.customer_id
  group by c.customer_id 
  order by sum(sp.quantity*sp.unit_price)desc
 limit 20;  
 
 select * from sales.maxamount_by_customer
 
 ------c. Satış adeti en çok olan 40 müşterinin kaç kere alışveriş yaptığı ve bu alışverişlerin ortalama tutarları
 
 create view sales.maxquantity_by_customer as
 select 
 c.customer_id,
 sum(sp.quantity) as total_quantity,
 count(i.invoice_no ) as shopping_time,
 sum(sp.quantity) /count(i.invoice_no ) as avg_quantity_in_shopping,
 sum(sp.quantity*sp.unit_price)/sum(sp.quantity) as avg_unit_price
 from sales."sold_product" sp
 join sales."invoice" i
  on sp.invoice_no=i.invoice_no 
 join sales."customer" c
 on c.customer_id=i.customer_id 
 group by c.customer_id 
 order by sum(sp.quantity) desc
 limit 40;

 select * from sales.maxquantity_by_customer
 ---------d. En çok net satış tutarına ulaşılan ay içerisindeki toplam satış adeti
create view sales.total_qnt_best_month as 
 select sum(sp.quantity) as total_quantity
 from sales."sold_product" sp 
 join sales."invoice" i 
  on sp.invoice_no = i.invoice_no
where date_trunc('month', i.invoice_date) =( 
select 
   date_trunc('month',i.invoice_date) months
   from sales."sold_product" sp
   join sales."invoice" i
   on sp.invoice_no=i.invoice_no
   group by date_trunc('month',i.invoice_date )
   order by sum(sp.quantity*sp.unit_price) desc
   limit 1
 );
   
   select * from sales.total_qnt_best_month;
   

-----e1.2)Hangi ürünün en çok sattığı ve satış adeti aylık olarak**ekstra
   create view sales.monthly_view_for_best_quantity as
select date_trunc('month',i.invoice_date) as months,
sum(sp.quantity) ,p.product ,p.product_color
from   sales."product" p 
join sales."sold_product" sp
 on sp.product_id=p.product_id 
join sales."invoice" i
 on sp.invoice_no =i.invoice_no 
where p.product_id=(
select 
    p.product_id
from sales."sold_product" sp
join sales."product" p 
    on sp.product_id = p.product_id
group by p.product_id 
order by sum(sp.quantity) desc
limit 1
)
group by date_trunc('month',i.invoice_date),p.product,p.product_color
order by months;

  select * from sales.monthly_view_for_best_quantity 
   
-------e. Hangi ürün grubunun en çok sattığı ve satış adeti aylık olarak
 --ürün grubu** 
  
 create  view sales.monthly_top_selling_product_group as
  select
    date_trunc('month', i.invoice_date) as months,
    p.product as product_group,
    sum(sp.quantity) as total_quantity
from sales."sold_product" sp
join sales."product" p 
    on sp.product_id = p.product_id
join sales."invoice" i 
    on sp.invoice_no = i.invoice_no
where p.product = (
    select p2.product
    from sales."sold_product" sp2
    join sales."product" p2 
        on sp2.product_id = p2.product_id
    group by p2.product
    order by sum(sp2.quantity) desc
    limit 1
)
group by months, p.product
order by months;

select * from sales.monthly_top_selling_product_group;


 -----------f. Ürün gruplarının aylık satış performansları

create view sales.monthly_product_group as
select 
  TO_CHAR(date_trunc('month',i.invoice_date), 'YYYY-MM') as month,
  p.product as product_group,
  sum(sp.quantity) as total_quantity,
  sum(sp.quantity*sp.unit_price) as total_sales_amount
from 
sales."sold_product" sp
join sales."product" p 
    on sp.product_id = p.product_id
join sales."invoice" i 
 on sp.invoice_no = i.invoice_no
group by month, p.product
order by month, p.product;

select * from sales.monthly_product_group;
-----------g. Satışı yapılan ceketlerin içinden en çok satılan renk bilgisi


select p.product,p.product_color,sum(sp.quantity )
from sales."product" p
join sales."sold_product" sp
on sp.product_id =p.product_id 
where p.product ='CEKET'
group by  p.product,p.product_color
order by  sum(sp.quantity ) desc
limit 1;


-----------h. Satışı yapılan t-shirtlerden en çok satılan rengin aylık satış adetleri ve tutarları
select date_trunc('month',i.invoice_date ) months,
sum(sp.quantity ) as total_quantity ,
sum(sp.quantity *sp.unit_price ) total_price,
p.product ,p.product_color 
from sales."sold_product" sp
join sales."invoice" i
on i.invoice_no =sp.invoice_no 
join sales."product" p
on p.product_id=sp.product_id 
where  p.product_id =(select p.product_id 
from sales."product" p
join sales."sold_product" sp
on sp.product_id =p.product_id 
join sales."invoice" i 
 on sp.invoice_no = i.invoice_no
where p.product ='T-SHIRT'
group by  p.product_id
order by  sum(sp.quantity ) desc
limit 1 )
group by months,p.product,p.product_color 


------------i. Ocak ayında günlük yürüyen toplam net satış tutarı ve adeti


select
    date_trunc('day', i.invoice_date)as day,
    sum(sp.quantity ) as total_quantity,
    sum(sp.quantity * sp.unit_price) as  total_price
from 
    sales."sold_product" sp
join 
    sales."invoice" i on i.invoice_no = sp.invoice_no
where
    i.invoice_date between '2024-01-01 00:00:00' and '2024-01-31 23:59:59'
group by 
    DATE_TRUNC('day', i.invoice_date)
order by
    day;


----------j. Mart ayında en çok satış tutarı yapılan gününü önceki ve sonraki günlere göre değişim yüzdesi

----Common Table Expression
with max_daily_sale as (
    select date_trunc('day', i.invoice_date) as day,
           sum(sp.quantity * sp.unit_price) as total_price
    from sales."sold_product" sp
    join sales."invoice" i ON i.invoice_no = sp.invoice_no
    where i.invoice_date between '2024-03-01 00:00:00' and '2024-03-30 23:59:59'
    group by date_trunc('day', i.invoice_date)
    order by total_price desc
    limit 1
),
daily_sale as (
    select date_trunc('day', i.invoice_date) as day,
           sum(sp.quantity * sp.unit_price) as total_price
    from sales."sold_product" sp
    join sales."invoice" i ON i.invoice_no = sp.invoice_no
    where i.invoice_date between '2024-03-01 00:00:00' and '2024-03-30 23:59:59'
    group by date_trunc('day', i.invoice_date)
)
select 
    'Max Day' as day_type, 
    mds.day, 
    mds.total_price,
    ((mds.total_price - ds_prev.total_price) / ds_prev.total_price) * 100 as previous_days_percn,
    ((mds.total_price - ds_next.total_price) / ds_next.total_price) * 100 as next_days_percn
from max_daily_sale mds
left join daily_sale ds_prev on ds_prev.day = mds.day - interval '1 day'
left join daily_sale ds_next on ds_next.day = mds.day + interval '1 day';


--------------------------------------------------------------------------------------------
SELECT 
    DATE_TRUNC('day', i.invoice_date) AS sale_day,
    SUM(sp.quantity * sp.unit_price) AS total_price
FROM sales."sold_product" sp
JOIN sales."invoice" i 
    ON i.invoice_no = sp.invoice_no
WHERE i.invoice_date BETWEEN '2024-03-01' AND '2024-03-31'
GROUP BY DATE_TRUNC('day', i.invoice_date)
ORDER BY sale_day;

ALTER TABLE sales."sold_product"
ADD COLUMN sold_product_id SERIAL PRIMARY KEY;


