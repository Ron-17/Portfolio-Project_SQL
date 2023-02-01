drop table if exists goldusers_signup;
CREATE TABLE goldusers_signup(userid integer,gold_signup_date date); 

INSERT INTO goldusers_signup(userid,gold_signup_date) 
 VALUES (1,'09-22-2017'),
(3,'04-21-2017');

drop table if exists users;
CREATE TABLE users(userid integer,signup_date date); 

INSERT INTO users(userid,signup_date) 
 VALUES (1,'09-02-2014'),
(2,'01-15-2015'),
(3,'04-11-2014');

drop table if exists sales;
CREATE TABLE sales(userid integer,created_date date,product_id integer); 

INSERT INTO sales(userid,created_date,product_id) 
 VALUES (1,'04-19-2017',2),
(3,'12-18-2019',1),
(2,'07-20-2020',3),
(1,'10-23-2019',2),
(1,'03-19-2018',3),
(3,'12-20-2016',2),
(1,'11-09-2016',1),
(1,'05-20-2016',3),
(2,'09-24-2017',1),
(1,'03-11-2017',2),
(1,'03-11-2016',1),
(3,'11-10-2016',1),
(3,'12-07-2017',2),
(3,'12-15-2016',2),
(2,'11-08-2017',2),
(2,'09-10-2018',3);


drop table if exists product;
CREATE TABLE product(product_id integer,product_name text,price integer); 

INSERT INTO product(product_id,product_name,price) 
 VALUES
(1,'p1',980),
(2,'p2',870),
(3,'p3',330);


select * from sales;
select * from product;
select * from goldusers_signup;
select * from users;



select sales.userid,sum(product.price) from sales inner join product on sales.product_id=product.product_id group by sales.userid; 





with a as(select sales.userid,product.product_name,rank()over(partition by sales.userid order by sales.created_date) as rnk from sales inner join product on sales.product_id=product.product_id)

select * from a;



with b as(select sales.userid,product.product_ID,sum(product.price) as amount from sales inner join product on sales.product_id=product.product_id group by sales.userid,product.product_ID)


select distinct userid,first_value(product_ID) over(partition by userid order by amount) from b;




select * from(select *,rank()over(partition by userid order by created_date)as rnk from(select sales.*,goldusers_signup. gold_signup_date from sales inner join goldusers_signup on sales.userid=goldusers_signup.userid and sales.created_date>goldusers_signup.gold_signup_date)A)B where B.rnk=1;

/*select * from(select *,rank()over(partition by userid order by created_date desc)as rnk from(select sales.*,goldusers_signup. gold_signup_date from sales inner join goldusers_signup on sales.userid=goldusers_signup.userid and sales.created_date<goldusers_signup.gold_signup_date)A)B where B.rnk=1;*/



with d as(select sales.userid,product.product_id,sum(product.price) as amount from sales inner join product on sales.product_id=product.product_id group by sales.userid,product.product_id)


select product_id,sum(case when product_id=1 then amount/5 when product_id=2 then amount/10 else amount/20 end) as points from d group by product_id;






with g as(select sales.*,goldusers_signup. gold_signup_date from sales inner join goldusers_signup on sales.userid=goldusers_signup.userid and sales.created_date>goldusers_signup.gold_signup_date and DATEDIFF(year,goldusers_signup.gold_signup_date,sales.created_date)<=1)

select g.*,product.price from g inner join product on g.product_id=product.product_id;



with h as(select sales.*,goldusers_signup. gold_signup_date from sales left join goldusers_signup on sales.userid=goldusers_signup.userid and sales.created_date>goldusers_signup.gold_signup_date)


select *,case when gold_signup_date is NULL then 0  else rank()over(partition by userid order by created_date) end as rnk from h;






