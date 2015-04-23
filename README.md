# oracle_spatial_cluster_test
*A test case to evaluate the effectiveness of various spatial clustering techniques for Oracle Spatial*

First **setup.sql** was used to create a PARCELS table.  This was populated with 2.8 million polygons. 
Setup.sql then contains the statements to create a further 4 tables clustered in different ways:
* PARCELS_RANDOM
* PARCELS_BASE_DATE
* PARCELS_RTREE
* PARCELS_HILBERT

Spatial indexes are created for the 4 tables. 

A GeoServer layer was then created for each table, using a simple SLD style. 

**generate_random_wms_requests.sql** was used to generated 1,000 random window extents, saved out to a CSV file **sample_map_windows.csv**

JMeter was used to run the requests to GeoServer, configured using **Cluster_Load_Test_WMS_requests_to_GeoServer.jmx**

The results are in **Test_Results.xlsx**
