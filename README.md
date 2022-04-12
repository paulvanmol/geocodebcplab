# Geocode Customs Offices TAXUD

Here is an example of using a Geocoding API from SAS to geocode specific addresses. 
SAS DS2 has a HTTP package that allows you to perform WebQueries using address information as input. 
This information is then send as a text search address to a Geocode API.
The geoapify is free to use up to 3000 requests. 
After that you should have a subscription: https://www.geoapify.com/geocoding-api

The JSON Respons is then parsed to retrieve Latitude and Longitude of the address. 
- bcplab.txt contains the addresses that need to be geocoded, it creates the inputDSN for the geocoding process
- ds2geocode.sas contains the code that reads bcplab.txt and then applies the geocoding api to create an ouputDSN with geocoded results
- geocodebcplab.flw is a SAS Studio Flow that can be used to run the ds2geocode.sas program
- BCP_LAB_GEOCODED_REPORT.TXT contains the report definition for SAS Visual Analytics (Viya 2020) 
- (use CTRL+ALT+P to open the report debugger and import the report definition)
- bcp_lab_geocoded.sas7bdat is the dataset with 12 geocoded customs offices. You can use it as an input to a Visual Analytics Report. 
- Create new Geography Data Items using latitude and longitude from the dataset.
