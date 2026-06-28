

create table customers (
    customer_id serial primary key,
    full_name varchar(100) not null,
    email varchar(100) unique not null,
    balance numeric(10,2) default 0
);

create table products (
    product_id serial primary key,
    product_name varchar(100) not null,
    price numeric(10,2) not null,
    stock_quantity int not null
);

create table orders (
    order_id serial primary key,
    customer_id int references customers(customer_id),
    order_date timestamp default current_timestamp,
    total_amount numeric(10,2) default 0
);

create table order_items (
    order_item_id serial primary key,
    order_id int references orders(order_id),
    product_id int references products(product_id),
    quantity int not null,
    price numeric(10,2) not null
);

create table order_log (
    log_id serial primary key,
    order_id int,
    customer_id int,
    action varchar(50),
    log_date timestamp default current_timestamp
);


create or replace function public.calculate_order_total(p_order_id int)
returns numeric
language plpgsql
as $$
declare
    total_sum numeric;
begin
    select coalesce(sum(quantity * price), 0)
	into total_sum
	from public.order_items o
	where o.order_id = p_order_id;
    return total_sum;
end;
$$;


create or replace procedure public.create_order(p_customer_id int)
language plpgsql
as $$
begin
	if not exists (
		select c.customer_id
		from public.customers c
		where c.customer_id = p_customer_id
)
		then raise exception 'Customer does not exist';
	end if;

	insert into public.orders(customer_id, order_date, total_amount)
	values (p_customer_id, now(), 0);
end;
$$;

create or replace procedure public.add_product_to_order(
    p_order_id int,
    p_product_id int,
    p_quantity int
)
language plpgsql
as $$
declare
	p_price numeric;
	in_stock int;
begin
	if p_quantity <= 0
		then raise exception 'Quantity can not be zero or lower';
	end if;

	if not exists (
		select p.product_id
		from public.products p
		where p.product_id = p_product_id)
		then raise exception 'Product not found';
	end if;

	select p.price, p.stock_quantity
	into p_price, in_stock
	from public.products p
	where product_id = p_product_id;

	if p_quantity > in_stock
		then raise exception 'Not enough product in stock';
	end if;	

	insert into public.order_items(order_id, product_id, quantity, price)
	values (p_order_id, p_product_id, p_quantity, p_price);

	update public.products
	set stock_quantity = stock_quantity - p_quantity
	where product_id = p_product_id;
end;
$$;

create or replace function public.update_order_total()
returns trigger
language plpgsql
as $$
begin
    if tg_op = 'DELETE' then
        update public.orders
        set total_amount = public.calculate_order_total(old.order_id)
        where order_id = old.order_id;
    else
        update public.orders
        set total_amount = public.calculate_order_total(new.order_id)
        where order_id = new.order_id;
    end if;
    return null;
end;
$$;

create trigger trg_update_order_total
after insert or update or delete
on public.order_items
for each row
execute function public.update_order_total();

create or replace function public.order_log_create()
returns trigger
language plpgsql
as $$
begin 
	insert into public.order_log(order_id, customer_id, action, log_date)
	values (new.order_id, new.customer_id, 'created', now());
	return new;
end;
$$;

create trigger trg_order_log
after insert
on public.orders
for each row
execute function public.order_log_create();

insert into customers(full_name, email, balance)
values ('Hello Kitty', 'hello.kitty@mail.com', 250);


insert into products(product_name, price, stock_quantity)
values ('Headphones', 100, 5);


call public.create_order(5);
call public.create_order(6);

call public.add_product_to_order(1, 4, 3);
call public.add_product_to_order(1, 7, 3);
call public.add_product_to_order(3, 6, 7);
call public.add_product_to_order(2, 2, 0);
call public.add_product_to_order(5, 6, 2);

select * from orders;
select * from order_items;
select * from products;
select * from order_log;



