SET application_name TO 'dont log';
SELECT 'dont log';
SET application_name TO 'goodApp_for_test';
SELECT 'goodApp_for_test';
SET application_name TO 'goodApp1';
--logged
SELECT 'goodApp1';
SET application_name TO 'goodApp2';
--logged
SELECT 'goodApp2';
SET application_name TO 'goodApp';
--logged
SELECT 'goodApp';
SET application_name TO 'ThatsagoodApp';
--logged
SELECT 'ThatsagoodApp';
