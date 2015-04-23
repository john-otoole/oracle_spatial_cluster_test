spool C:\WorkArea\ClusterLoadTest\sample_map_windows.csv
 
DECLARE
  l_min_width number := 200;
  l_max_width number := 600;
  l_min_x NUMBER := 600000;
  l_min_y NUMBER := 699000;
  l_max_x NUMBER := 691000 - l_max_width;
  l_max_y NUMBER := 790000 - l_max_width;
	l_rows NUMBER := 2000;
  l_xl NUMBER;
  l_yl NUMBER;
  l_xh NUMBER;
  l_yh NUMBER; 
  l_width NUMBER;
BEGIN
 
	FOR i IN 1..l_rows
	LOOP
		l_width := ROUND(dbms_random.value(l_min_width,l_max_width));
		l_xl := ROUND(dbms_random.value(l_min_x,l_max_x));
		l_yl := ROUND(dbms_random.value(l_min_y,l_max_y));   
		l_xh := l_xl + l_width;
		l_yh := l_yl + l_width;                 
		dbms_output.put_line(l_xl || ',' || l_yl || ',' || l_xh || ',' || l_yh);               
	END LOOP;
 
END;
/
spool off
