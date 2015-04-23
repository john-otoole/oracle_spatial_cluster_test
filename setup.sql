
--
-- Create a starting table
--
create table parcels (
	id            integer,
	created_date  date,
	x             number,
	y             number,
	val1          varchar2(20),
	val2          varchar2(100),
	val3          varchar2(200),
	geometry      mdsys.sdo_geometry,
	hilbert_key   number);

--	
-- Populate the Parcels table with 2.8 million polygons.
-- The input polygons have real "created_date" values that reflect when 
-- the data was captured.  We can order by this "created_date" to simulate 
-- the natural clusting of the data in the original table.
--

-- Add some sample string data to pad the rows to make it more realistic
update /*+ PARALLEL */ parcels set 
	val1 = lpad('x',20,'x'), 
	val2 = lpad('y',100,'y'), 
	val3 = lpad('z',200,'z');
commit;

-- Create a simple function to get the first ordinate from the input geometry.
-- We'll use this to set the XY which will be the basis of the cluster key.
-- This will be faster then getting the geometry centroid
create or replace function get_start(in_geometry sdo_geometry) 
	return sdo_geometry
as
begin
	return sdo_geometry(2001, in_geometry.sdo_srid, sdo_point_type(in_geometry.sdo_ordinates(1), in_geometry.sdo_ordinates(2), null), null, null);
end;
/

alter table parcels parallel;

update /*+ PARALLEL */ parcels p set 
  x = get_start(geometry).sdo_point.x,
  y = get_start(geometry).sdo_point.y;
commit;

-- Now set the hilbert_key using the sdo_pc_pkg.hilbert_xy2d function
update /*+ PARALLEL */ parcels set 
	hilbert_key = sdo_pc_pkg.hilbert_xy2d(power(2,31), x, y);
commit;

-- Set up metadata and spatial index
delete from user_sdo_geom_metadata where table_name = 'PARCELS';
insert into user_sdo_geom_metadata values ('PARCELS','GEOMETRY',  
	mdsys.sdo_dim_array(
		mdsys.sdo_dim_element('X', 400000, 800000, 0.0005), 
		mdsys.sdo_dim_element('Y', 500000, 1000000, 0.0005),	
		mdsys.sdo_dim_element('Z', -100, 1100, 0.0005)			
), 2157);
commit;
drop index parcels_spind;
create index parcels_spind on parcels(geometry) indextype is mdsys.spatial_index;

-- As a worst case scenario, create a table that is randomly ordered
create table parcels_random as (
	select * from (
		select id, created_date, val1, val2, val3, x, y, geometry	
		from parcels
		order by dbms_random.random));
		
-- Create a table ordered by CREATED_DATE
create table parcels_base_date as (
	select * from (
		select id, created_date, val1, val2, val3, x, y, geometry	
		from parcels
		order by created_date));

-- Create a table ordered by HILBERT_KEY
create table parcels_hilbert as (
	select * from (
		select id, created_date, val1, val2, val3, x, y, geometry	
		from parcels
		order by hilbert_key));

-- Create a table ordered by the RTree
create table parcels_rtree as (
	select id, created_date, val1, val2, val3, x, y, geometry	
	from parcels
	where sdo_filter(geometry, 
		sdo_geometry(2003, 2157, null, sdo_elem_info_array(1, 1003, 3), 
			sdo_ordinate_array(400000, 500000, 800000, 1000000))) = 'TRUE');

-- Now setup metadata and spatial index for each of the tables			
delete from user_sdo_geom_metadata where table_name = 'PARCELS_RANDOM';
insert into user_sdo_geom_metadata values ('PARCELS_RANDOM','GEOMETRY',  
	mdsys.sdo_dim_array(
		mdsys.sdo_dim_element('X', 400000, 800000, 0.0005), 
		mdsys.sdo_dim_element('Y', 500000, 1000000, 0.0005),	
		mdsys.sdo_dim_element('Z', -100, 1100, 0.0005)			
), 2157);
commit;
drop index parcels_random_spind;
create index parcels_random_spind on parcels_random(geometry) indextype is mdsys.spatial_index;

delete from user_sdo_geom_metadata where table_name = 'PARCELS_BASE_DATE';
insert into user_sdo_geom_metadata values ('PARCELS_BASE_DATE','GEOMETRY',  
	mdsys.sdo_dim_array(
		mdsys.sdo_dim_element('X', 400000, 800000, 0.0005), 
		mdsys.sdo_dim_element('Y', 500000, 1000000, 0.0005),	
		mdsys.sdo_dim_element('Z', -100, 1100, 0.0005)			
), 2157);
commit;
drop index parcels_base_date_spind;
create index parcels_base_date_spind on parcels_base_date(geometry) indextype is mdsys.spatial_index;


delete from user_sdo_geom_metadata where table_name = 'PARCELS_HILBERT';
insert into user_sdo_geom_metadata values ('PARCELS_HILBERT','GEOMETRY',  
	mdsys.sdo_dim_array(
		mdsys.sdo_dim_element('X', 400000, 800000, 0.0005), 
		mdsys.sdo_dim_element('Y', 500000, 1000000, 0.0005),	
		mdsys.sdo_dim_element('Z', -100, 1100, 0.0005)			
), 2157);
commit;
drop index parcels_hilbert_spind;
create index parcels_hilbert_spind on parcels_hilbert(geometry) indextype is mdsys.spatial_index;
		

delete from user_sdo_geom_metadata where table_name = 'PARCELS_RTREE';
insert into user_sdo_geom_metadata values ('PARCELS_RTREE','GEOMETRY',  
	mdsys.sdo_dim_array(
		mdsys.sdo_dim_element('X', 400000, 800000, 0.0005), 
		mdsys.sdo_dim_element('Y', 500000, 1000000, 0.0005),	
		mdsys.sdo_dim_element('Z', -100, 1100, 0.0005)			
), 2157);
commit;
drop index parcels_rtree_spind;
create index parcels_rtree_spind on parcels_rtree(geometry) indextype is mdsys.spatial_index;
