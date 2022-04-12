%let path=c:\workshop\git\geocodebcp\geocodebcplab;
%let apikey=ad5571ba69a84878b0a0f43d8e338ed4;
%let inputdsn=bcplab.bcp_lab; 
%let outputdsn=bcplab.bcp_lab_geocoded;

/*Reading bcplab address information from a ; delimited csv file*/
libname bcplab "&path"; 
filename bcplab "&path\bcplab.txt" encoding='utf-8'; 
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
 		 dcl integer poslon poslat;
         dcl varchar(32767) text;
		 dcl varchar(100) apikey; 
		 apikey=%tslit(&apikey); 
		 set &inputdsn; 
		 text=catx(' ',street_and_number,city,postal_code, country_name);
        
            url=cats('https://api.geoapify.com/v1/geocode/search?text=',text,'&apiKey=',apikey);
            GetResponse(url);
			put;
            putlog.log('N', URL);
            putlog.log('N', Response);
            put;
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

proc fedsql;
select *
   from bcplab.BCP_LAB_GEOCODED
   ;
quit;
