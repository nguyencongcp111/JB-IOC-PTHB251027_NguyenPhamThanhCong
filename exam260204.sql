create table customer (
	customer_id varchar(5) not null primary key,
	customer_full_name varchar(100) not null,
	customer_email varchar(100) not null unique,
	customer_phone varchar(15) not null,
	customer_address varchar(255) not null
);

create table room (
	room_id varchar(5) not null primary key,
	room_type varchar(50) not null,
	room_price decimal(10,2) not null,
	room_status varchar(20) not null,
	room_area decimal not null
);

create table booking(
	booking_id serial primary key,
	customer_id varchar references customer(customer_id),
	room_id varchar references room(room_id),
	check_in_date date not null,
	check_out_date date not null,
	total_amount decimal (10,2)
);

create table payment(
	payment_id serial primary key,
	booking_id int references booking(booking_id),
	payment_method varchar(50) not null,
	payment_date date not null,
	payment_amount decimal (10,2) not null
);

insert into customer (customer_id, customer_full_name, customer_email, customer_phone, customer_address)
values
('C001','Nguyen Anh Tu','tu.nguyen@example.com',0912345678,'Hanoi, Vietnam'),
('C002','Tran Thi Mai','mai.tran@example.com',0923456789,'Ho Chi Minh, Vietnam'),
('C003','Le Minh Hoang','hoang.le@example.com',0934567890,'Danang, Vietnam'),
('C004','Pham Hoang Nam','nam.pham@example.com',0945678901,'Hue, Vietnam'),
('C005','Vu Minh Thu','thu.vu@example.com',0956789012,'Hai Phong, Vietnam');

insert into room (room_id, room_type, room_price, room_status, room_area)
values
('R001', 'Single', 100.0, 'Available', 25),
('R002', 'Double', 150.0, 'Booked', 40),
('R003', 'Suite', 250.0, 'Available', 60),
('R004', 'Single', 120.0, 'Booked', 30),
('R005', 'Double', 160.0, 'Available', 35);

insert into booking (customer_id, room_id, check_in_date, check_out_date, total_amount)
values
('C001','R001','2025-03-01','2025-03-05',400.0),
('C002','R002','2025-03-02','2025-03-06',600.0),
('C003','R003','2025-03-03','2025-03-07',1000.0),
('C004','R004','2025-03-04','2025-03-08',480.0),
('C005','R005','2025-03-05','2025-03-09',800.0);

insert into payment (booking_id, payment_method, payment_date, payment_amount)
values
(1,'Cash','2025-03-05',400.0),
(2,'Credit Card','2025-03-06',600.0),
(3,'Bank Transfer','2025-03-07',1000.0),
(4,'Cash','2025-03-08',480.0),
(5,'Credit Card','2025-03-09',800.0);



/*Viết câu lệnh UPDATE để cập nhật lại total_amount trong bảng Booking theo công thức: 
total_amount = room_price * (số ngày lưu trú).*/

update booking b 
set total_amount = r.room_price * (b.check_out_date - b.check_in_date)
from room r
where b.room_id = r.room_id and b.check_in_date < current_date and r.room_status = 'Booked';

/*Viết câu lệnh DELETE để xóa các thanh toán trong bảng Payment nếu:
  - Phương thức thanh toán (payment_method) là "Cash".
  - Và tổng tiền thanh toán (payment_amount) nhỏ hơn 500.*/

delete from payment where payment_method = 'Cash' and payment_amount < 500;

/*Lấy thông tin khách hàng gồm 
mã khách hàng, họ tên, email, số điện thoại và địa chỉ 
được sắp xếp theo họ tên khách hàng tăng dần.*/

select * from customer order by customer_full_name asc;

/*Lấy thông tin các phòng khách sạn 
gồm mã phòng, loại phòng, giá phòng và diện tích phòng, 
sắp xếp theo giá phòng giảm dần.*/

select room_id, room_type, room_price, room_area from room 
order by room_price desc;

/*Lấy thông tin khách hàng và phòng khách sạn đã đặt, gồm 
mã khách hàng, họ tên khách hàng, mã phòng, ngày nhận phòng và ngày trả phòng.*/

select c.customer_id, c.customer_full_name, b.room_id, b.check_in_date, b.check_out_date 
from booking b
join customer c on b.customer_id = c.customer_id;

/*Lấy danh sách khách hàng và tổng tiền đã thanh toán khi đặt phòng, 
gồm mã khách hàng, họ tên khách hàng, phương thức thanh toán 
và số tiền thanh toán, sắp xếp theo số tiền thanh toán giảm dần.*/\

select c.customer_id, c.customer_full_name, p.payment_method, p.payment_amount
from payment p
join booking b on p.booking_id = b.booking_id
join customer c on b.customer_id = c.customer_id;

/*Lấy thông tin khách hàng 
từ vị trí thứ 2 đến thứ 4 trong bảng Customer được sắp xếp theo tên khách hàng.
*/

select * from customer order by customer_full_name
offset 1 limit 3;

/*Lấy danh sách khách hàng đã đặt ít nhất 2 phòng 
và có tổng số tiền thanh toán trên 1000, 
gồm mã khách hàng, họ tên khách hàng và số lượng phòng đã đặt. */

select c.customer_id, c.customer_full_name, count(b.room_id), sum(payment_amount)
from booking b
join customer c on b.customer_id = c.customer_id
join payment p on b.booking_id = p.booking_id
group by c.customer_id, c.customer_full_name
having count(b.room_id) >= 2 and sum(payment_amount) > 1000;

/* Lấy danh sách các phòng có tổng số tiền thanh toán dưới 1000 
và có ít nhất 3 khách hàng đặt, gồm mã phòng, loại phòng, giá phòng 
và tổng số tiền thanh toán.*/

select r.room_id, r.room_type, r.room_price, sum(p.payment_amount), count(b.customer_id)
from booking b
join payment p on b.booking_id = p.booking_id
join room r on b.room_id = r.room_id
group by r.room_id, r.room_type, r.room_price
having count(b.customer_id) >=3 and sum(payment_amount) < 1000

/*Lấy danh sách các khách hàng có tổng số tiền thanh toán lớn hơn 1000, 
gồm mã khách hàng, họ tên khách hàng, mã phòng, tổng số tiền thanh toán.*/

select c.customer_id, c.customer_full_name, b.room_id, p.payment_amount
from payment p
join booking b on p.booking_id = b.booking_id
join customer c on b.customer_id = c.customer_id
where p.payment_amount > 1000;

/*Lấy danh sách các khách hàng Mmã KH, Họ tên, Email, SĐT) 
có họ tên chứa chữ "Minh" hoặc địa chỉ (address) ở "Hanoi". 
Sắp xếp kết quả theo họ tên tăng dần.*/

select * from customer 
where customer_full_name ilike '%Minh%' or customer_address ilike '%Hanoi%'
order by customer_full_name asc;

/*Lấy danh sách tất cả các phòng (Mã phòng, Loại phòng, Giá), 
sắp xếp theo giá phòng giảm dần. Hiển thị 5 phòng tiếp theo sau 5 phòng đầu tiên 
(tức là lấy kết quả của trang thứ 2, biết mỗi trang có 5 phòng).*/

select room_id, room_type, room_price from room
order by room_price desc
offset 5 limit 5;

/*Hãy tạo một view để lấy thông tin các phòng và khách hàng đã đặt, 
với điều kiện ngày nhận phòng nhỏ hơn ngày 2025-03-10. 
Cần hiển thị các thông tin sau: 
Mã phòng, Loại phòng, Mã khách hàng, họ tên khách hàng*/

create view v_room_customer_info as (
select r.room_id, r.room_type, c.customer_id, c.customer_full_name 
from booking b
join room r on b.room_id = r.room_id
join customer c on b.customer_id = c.customer_id
where b.check_in_date < '2025-03-10'
);

/*Hãy tạo một view để lấy thông tin khách hàng và phòng đã đặt, 
với điều kiện diện tích phòng lớn hơn 30 m². 
Cần hiển thị các thông tin sau: 
Mã khách hàng, Họ tên khách hàng, Mã phòng, Diện tích phòng*/

create view v_room_area as (
select c.customer_id, c.customer_full_name, r.room_id, r.room_area
from booking b
join room r on b.room_id = r.room_id
join customer c on b.customer_id = c.customer_id
where r.room_area > 30
);

/*Hãy tạo một trigger check_insert_booking 
để kiểm tra dữ liệu mối khi chèn vào bảng Booking. 
Kiểm tra nếu ngày đặt phòng mà sau ngày trả phòng 
thì thông báo lỗi với nội dung 
“Ngày đặt phòng không thể sau ngày trả phòng được !” 
và hủy thao tác chèn dữ liệu vào bảng.*/

create or replace function fn_check_insert_booking()
returns trigger as $$
begin
	if (tg_op = 'INSERT') then
		if (new.check_in_date > new.check_out_date) then
			raise exception 'Ngày đặt phòng không thể sau ngày trả phòng được !';
		end if;
	end if;
	return new;
end;
$$ language plpgsql;

create trigger check_insert_booking
before insert on booking
for each row
execute function fn_check_insert_booking();

-- Thử trigger --
insert into booking (customer_id, room_id, check_in_date, check_out_date, total_amount)
values
('C001','R001','2025-04-09','2025-04-05',400.0);

/*Hãy tạo một trigger có tên là update_room_status_on_booking 
để tự động cập nhật trạng thái phòng thành "Booked" khi một phòng được đặt 
(khi có bản ghi được INSERT vào bảng Booking).*/

create or replace function fn_update_room_status_on_booking()
returns trigger as $$
declare
	present_room_status varchar;
begin
	if (tg_op = 'INSERT') then
		select room_status into present_room_status from room
		where room_id = new.room_id;
		if not found then
			raise exception 'Không có phòng!';
		end if;

		if present_room_status = 'Booked' then
			raise exception 'Phòng đã được đặt trước đó!';
		else
			update room set room_status = 'Booked'
			where room_id = new.room_id;
		end if;
		
	end if;
	return new;
end;
$$ language plpgsql;

create trigger update_room_status_on_booking
after insert on booking
for each row
execute function fn_update_room_status_on_booking();

-- Thử trigger --
insert into booking (customer_id, room_id, check_in_date, check_out_date, total_amount)
values
('C006','R001','2025-03-31','2025-04-05',400.0);

/*Viết store procedure có tên add_customer 
để thêm mới một khách hàng với đầy đủ các thông tin cần thiết.*/

create or replace procedure add_customer(
	new_customer_id varchar,
	new_customer_full_name varchar,
	new_customer_email varchar,
	new_customer_phone varchar,
	new_customer_address varchar
)
as $$
begin
	insert into customer (customer_id, customer_full_name, customer_email, customer_phone, customer_address)
	values
	(new_customer_id,
	new_customer_full_name,
	new_customer_email,
	new_customer_phone,
	new_customer_address);
end;
$$ language plpgsql;

-- Thử Procedure --

call add_customer('C006','Do Dang Huy','huy.dodang@example.com','0999119919','Hanoi, Vietnam');

/*Hãy tạo một Stored Procedure  có tên là add_payment 
để thực hiện việc thêm một thanh toán mới cho một lần đặt phòng.*/

create or replace procedure add_payment(
	new_booking_id int, new_payment_method varchar, new_payment_date date, new_payment_amount decimal
)
as $$
begin
	insert into payment (booking_id, payment_method, payment_date, payment_amount)
	values
	(new_booking_id, new_payment_method, new_payment_date, new_payment_amount);
end;
$$ language plpgsql;

-- Thử Procedure --

call add_payment
(23,'Bank_Transfer','2025-04-05',400.0);