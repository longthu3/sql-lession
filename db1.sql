--create table course

create table if not exists course (
	id BIGSERIAL primary key not null,
	name varchar(50) not null,
	price float not null,
	detail text,
	teacher_id int not null,
	active bit,
	created_at TIMESTAMP with TIME zone default CURRENT_TIMESTAMP,
	updated_at TIMESTAMP with TIME zone default CURRENT_TIMESTAMP,
	foreign key (teacher_id) references teacher(id)
);

create table if not exists teacher(
	id BiGSERIAL primary key not null,
	name varchar(50) not null,
	bio text null,
	created_at TIMESTAMP with TIME zone default CURRENT_TIMESTAMP,
	updated_at TIMESTAMP with TIME zone default CURRENT_TIMESTAMP
);

select * from course c 

select * from teacher 

create or replace procedure rename_column(new_name varchar, column_name varchar, table_name varchar)
language plpgsql
as $$
begin
	if column_name = '' or new_name = '' or table_name = '' then 
		raise exception 'must be fill all field';
	else
		execute format('ALTER TABLE %I RENAME COLUMN %I to %I', table_name, column_name, new_name);
		execute format('ALTER TABLE %I ALTER COLUMN %I SET NOT NULL', table_name, new_name);
	end if;
end;
$$;

-- call the procedure
call rename_column('content', 'hehe', 'course');





