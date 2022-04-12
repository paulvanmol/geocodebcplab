/******************************************************************/
/*Geocode Customs Offices stored in a dataset                     */
/*Using geoapify API (free up to 3000 requests)                   */
/*Author: Paul Van Mol                                            */
/*Parameters:                                                     */
/*Path: directory where geocoded data is written to               */
/*APIKEY: apikey with which you can make the api calls            */
/*InputDSN: Input dataset (incase you want to use oracle table)   */
/*OutputDSN: Output Dataset with geocoded address information     */
/*Modified: 12APR2022                                             */
/******************************************************************/

%let path=c:\workshop\git\geocodebcp\geocodebcplab;
%let path=/greenmonthly-export/ssemonthly/homes/paul.van.mol@sas.com/geocodebcplab;
%let apikey=ad5571ba69a84878b0a0f43d8e338ed4;
%let inputdsn=bcplab.bcp_lab; 
%let outputdsn=bcplab.bcp_lab_geocoded;

/*Reading bcplab address information from a ; delimited csv file*/
libname bcplab "&path"; 
filename bcplab "&path/bcplab.txt" encoding='utf-8'; 
data bcplab.bcp_lab; 
infile bcplab dlm=';' dsd; 
input bcp_name:$32. country_name :$32. country_2_CHAR:$2. POSTAL_CODE: $20. CITY :$50.
STREET_AND_NUMBER :$50. REFNO :$8.; 
run; 

   
/*
http://blogs.sas.com/content/sastraining/2015/01/17/jedi-sas-tricks-ds2-apis-get-the-data-you-are-looking-for/
*/

/*For Testing geoapi*/

proc ds2 ;
    data _null_;
        dcl package logger putlog();
        dcl varchar(32767) character set utf8 url response;
        method GetResponse(varchar(32767) url);
            dcl integer i rc;
            dcl package http webQuery();
            /* create a GET call to the API*/
            webQuery.createGetMethod(url);
            /* execute the GET */
            webQuery.executeMethod();
            /* retrieve the response body as a string */
            webQuery.getResponseBodyAsString(response, rc);
        end;
        method run();
		    /* GET: obtain information for one address (Person 1) */
            url='https://api.geoapify.com/v1/geocode/search?text=38%20Upper%20Montagu%20Street%2C%20Westminster%20W1H%201LJ%2C%20United%20Kingdom&apiKey=ad5571ba69a84878b0a0f43d8e338ed4';
            GetResponse(url);
            put;
            putlog.log('N', URL);
            putlog.log('N', Response);
            put;

		
        end;
    enddata;
    run;
quit;

proc ds2 ;
    data &outputdsn /overwrite=yes;
	  dcl package logger putlog();
      dcl varchar(32767) character set utf8 url response;
	  dcl double latitude longitude; 
	  dcl varchar(30) location_type; 
	  dcl varchar(100) street housenumber; 
      drop url response;
     
      
      method GetResponse(varchar(32767) url);
         dcl integer rc;
         dcl package http webQuery();
         /* create a GET call to the API*/
         webQuery.createGetMethod(url);
         /* execute the GET */
         webQuery.executeMethod();
         /* retrieve the response body as a string */
         webQuery.getResponseBodyAsString(response, rc);
      end;
      method run();
 		 dcl integer poslon poslat numloc;
		 dcl varchar(100) country_lookup ;
         dcl varchar(32767) text;
		 dcl varchar(100) apikey; 
		 apikey=%tslit(&apikey); 
		 set &inputdsn; 
		 /*check if house number is found*/
		 numloc=anydigit(street_and_number); 
		 if numloc>0 then street=substr(street_and_number,1,numloc-1); 
		 if numloc>0 then housenumber=substr(street_and_number,numloc);
         /*check location type: country, city, postcode, street, amenity*/
		 if street ne ' ' and numloc>0 then location_type='amenity'; 
         else if street ne ' ' and numloc=0 then location_type='street'; 
		 else if street =' ' and postal_code ne ' ' then location_type='postcode'; 
		 else if city ne ' ' then location_type='city'; 
		 else if city =' ' and country_name ne ' ' then location_type='country'; 
 
	/*correct swedish customs office in Norway*/
		 
		if substr(postal_code,1,1)='N' then country_lookup='Norway';
		else country_lookup=country_name; 

	  /*Structured Address Search with name, street, housenumber, postcode, city, country */
	  /* text=cats(street_and_number,',',city,postal_code,',', country_name);
         url=cats('https://api.geoapify.com/v1/geocode/search?name=',bcp_name,
					'street=',street,
					'housenumber=',housenumber,
					'postcode=',postal_code,
					'city=',city,
					'country=',country_name,
					'&apiKey=',apikey);*/
      /*Free Text Search for address*/
		 text=cats(street_and_number,',',city,' ',postal_code,',', country_lookup);
         url=cats('https://api.geoapify.com/v1/geocode/search?text=',text,'&apiKey=',apikey);
            GetResponse(url);
			put;
            putlog.log('N', URL);
            putlog.log('N', Response);
            put;
	/*Extract Latitude and Longitude from Response*/
            do;
			   poslon=find(Response,'"lon":'); 
			   longitude=scan(substr(Response,poslon+6,poslon+12-poslon+6),1,','); 
			   poslat=find(Response,'"lat":'); 
			   latitude=scan(substr(Response,poslat+6,poslat+12-poslat+6),1,',');
              
            end;
         
      end;
   enddata;
   run;
quit;
/*show the results*/
proc fedsql;
select *
   from bcplab.BCP_LAB_GEOCODED
   ;
quit;
