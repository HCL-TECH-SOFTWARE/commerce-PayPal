/**
*==================================================
Copyright [2021] [HCL Technologies]

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*==================================================
**/
INSERT INTO policy (POLICY_ID,POLICYNAME,POLICYTYPE_ID,STOREENT_ID,PROPERTIES,STARTTIME,ENDTIME,OPTCOUNTER) 
VALUES ( (select max(POLICY_ID)+1 from policy),'BT_CreditCard','Payment',11,'attrPageName=StandardBrainTree&paymentConfigurationId=default&display=true&compatibleMode=false',null,null,1);
INSERT INTO policydesc (POLICY_ID,LANGUAGE_ID,DESCRIPTION,LONGDESCRIPTION,TIMECREATED,TIMEUPDATED,OPTCOUNTER) 
VALUES (( select POLICY_ID from policy where policyname = 'BT_CreditCard' ), -1 ,'CreditCard','CreditCard',{ts '2018-09-27 01:00:00.001000'},{ts '2018-09-27 01:30:00.001000'},1);
INSERT INTO POLICYCMD (POLICY_ID,BUSINESSCMDCLASS,PROPERTIES,OPTCOUNTER) VALUES (( select POLICY_ID from policy where policyname = 'BT_CreditCard' ),'com.ibm.commerce.payment.actions.commands.DoPaymentActionsPolicyCmdImpl',null,1);
INSERT INTO POLICYCMD (POLICY_ID,BUSINESSCMDCLASS,PROPERTIES,OPTCOUNTER) VALUES (( select POLICY_ID from policy where policyname = 'BT_CreditCard' ),'com.ibm.commerce.payment.actions.commands.EditPaymentInstructionPolicyCmdImpl',null,1);
INSERT INTO POLICYCMD (POLICY_ID,BUSINESSCMDCLASS,PROPERTIES,OPTCOUNTER) VALUES (( select POLICY_ID from policy where policyname = 'BT_CreditCard' ),'com.ibm.commerce.payment.actions.commands.QueryPaymentsInfoPolicyCmdImpl',null,1);

INSERT INTO policy (POLICY_ID,POLICYNAME,POLICYTYPE_ID,STOREENT_ID,PROPERTIES,STARTTIME,ENDTIME,OPTCOUNTER) 
VALUES ((select max(POLICY_ID)+1 from policy),'BT_PayPal','Payment',11,'attrPageName=StandardPayPal&paymentConfigurationId=default&display=true&compatibleMode=false',null,null,1);
INSERT INTO policydesc (POLICY_ID,LANGUAGE_ID,DESCRIPTION,LONGDESCRIPTION,TIMECREATED,TIMEUPDATED,OPTCOUNTER) 
VALUES (( select POLICY_ID from policy where policyname = 'BT_PayPal' ), -1 ,'PayPal','PayPal',{ts '2018-09-27 01:00:00.001000'},{ts '2018-09-27 01:30:00.001000'},1);
INSERT INTO POLICYCMD (POLICY_ID,BUSINESSCMDCLASS,PROPERTIES,OPTCOUNTER) VALUES ((select POLICY_ID from policy where policyname = 'BT_PayPal'),'com.ibm.commerce.payment.actions.commands.DoPaymentActionsPolicyCmdImpl',null,1);
INSERT INTO POLICYCMD (POLICY_ID,BUSINESSCMDCLASS,PROPERTIES,OPTCOUNTER) VALUES ((select POLICY_ID from policy where policyname = 'BT_PayPal'),'com.ibm.commerce.payment.actions.commands.EditPaymentInstructionPolicyCmdImpl',null,1);
INSERT INTO POLICYCMD (POLICY_ID,BUSINESSCMDCLASS,PROPERTIES,OPTCOUNTER) VALUES ((select POLICY_ID from policy where policyname = 'BT_PayPal'),'com.ibm.commerce.payment.actions.commands.QueryPaymentsInfoPolicyCmdImpl',null,1);

INSERT INTO policy (POLICY_ID,POLICYNAME,POLICYTYPE_ID,STOREENT_ID,PROPERTIES,STARTTIME,ENDTIME,OPTCOUNTER) 
VALUES ((select max(POLICY_ID)+1 from policy),'BT_PayPalCredit','Payment',11,'attrPageName=StandardPayPal&paymentConfigurationId=default&display=true&compatibleMode=false',null,null,1);
INSERT INTO policydesc (POLICY_ID,LANGUAGE_ID,DESCRIPTION,LONGDESCRIPTION,TIMECREATED,TIMEUPDATED,OPTCOUNTER) 
VALUES ((select POLICY_ID from policy where policyname = 'BT_PayPalCredit'), -1 ,'PayPal Credit','PayPal Credit',{ts '2018-09-27 01:00:00.001000'},{ts '2018-09-27 01:30:00.001000'},1);
INSERT INTO POLICYCMD (POLICY_ID,BUSINESSCMDCLASS,PROPERTIES,OPTCOUNTER) VALUES ((select POLICY_ID from policy where policyname = 'BT_PayPalCredit'),'com.ibm.commerce.payment.actions.commands.DoPaymentActionsPolicyCmdImpl',null,1);
INSERT INTO POLICYCMD (POLICY_ID,BUSINESSCMDCLASS,PROPERTIES,OPTCOUNTER) VALUES ((select POLICY_ID from policy where policyname = 'BT_PayPalCredit'),'com.ibm.commerce.payment.actions.commands.EditPaymentInstructionPolicyCmdImpl',null,1);
INSERT INTO POLICYCMD (POLICY_ID,BUSINESSCMDCLASS,PROPERTIES,OPTCOUNTER) VALUES ((select POLICY_ID from policy where policyname = 'BT_PayPalCredit'),'com.ibm.commerce.payment.actions.commands.QueryPaymentsInfoPolicyCmdImpl',null,1);

INSERT INTO policy (POLICY_ID,POLICYNAME,POLICYTYPE_ID,STOREENT_ID,PROPERTIES,STARTTIME,ENDTIME,OPTCOUNTER) 
VALUES ((select max(POLICY_ID)+1 from policy),'BT_GooglePay','Payment',11,'attrPageName=StandardGooglePay&paymentConfigurationId=default&display=true&compatibleMode=false',null,null,1);
INSERT INTO policydesc (POLICY_ID,LANGUAGE_ID,DESCRIPTION,LONGDESCRIPTION,TIMECREATED,TIMEUPDATED,OPTCOUNTER) 
VALUES ((select POLICY_ID from policy where policyname = 'BT_GooglePay'), -1 ,'GooglePay','GooglePay',{ts '2018-10-2 01:00:00.001000'},{ts '2018-10-2 01:30:00.001000'},1);
INSERT INTO POLICYCMD (POLICY_ID,BUSINESSCMDCLASS,PROPERTIES,OPTCOUNTER) VALUES ((select POLICY_ID from policy where policyname = 'BT_GooglePay'),'com.ibm.commerce.payment.actions.commands.DoPaymentActionsPolicyCmdImpl',null,1);
INSERT INTO POLICYCMD (POLICY_ID,BUSINESSCMDCLASS,PROPERTIES,OPTCOUNTER) VALUES ((select POLICY_ID from policy where policyname = 'BT_GooglePay'),'com.ibm.commerce.payment.actions.commands.EditPaymentInstructionPolicyCmdImpl',null,1);
INSERT INTO POLICYCMD (POLICY_ID,BUSINESSCMDCLASS,PROPERTIES,OPTCOUNTER) VALUES ((select POLICY_ID from policy where policyname = 'BT_GooglePay'),'com.ibm.commerce.payment.actions.commands.QueryPaymentsInfoPolicyCmdImpl',null,1);

INSERT INTO policy (POLICY_ID,POLICYNAME,POLICYTYPE_ID,STOREENT_ID,PROPERTIES,STARTTIME,ENDTIME,OPTCOUNTER) 
VALUES ((select max(POLICY_ID)+1 from policy),'BT_Venmo','Payment',11,'attrPageName=StandardVenmo&paymentConfigurationId=default&display=true&compatibleMode=false',null,null,1);
INSERT INTO policydesc (POLICY_ID,LANGUAGE_ID,DESCRIPTION,LONGDESCRIPTION,TIMECREATED,TIMEUPDATED,OPTCOUNTER) 
VALUES ((select POLICY_ID from policy where policyname = 'BT_Venmo'), -1 ,'Venmo','Venmo',{ts '2018-10-2 01:00:00.001000'},{ts '2018-10-2 01:30:00.001000'},1);
INSERT INTO POLICYCMD (POLICY_ID,BUSINESSCMDCLASS,PROPERTIES,OPTCOUNTER) VALUES ((select POLICY_ID from policy where policyname = 'BT_Venmo'),'com.ibm.commerce.payment.actions.commands.DoPaymentActionsPolicyCmdImpl',null,1);
INSERT INTO POLICYCMD (POLICY_ID,BUSINESSCMDCLASS,PROPERTIES,OPTCOUNTER) VALUES ((select POLICY_ID from policy where policyname = 'BT_Venmo'),'com.ibm.commerce.payment.actions.commands.EditPaymentInstructionPolicyCmdImpl',null,1);
INSERT INTO POLICYCMD (POLICY_ID,BUSINESSCMDCLASS,PROPERTIES,OPTCOUNTER) VALUES ((select POLICY_ID from policy where policyname = 'BT_Venmo'),'com.ibm.commerce.payment.actions.commands.QueryPaymentsInfoPolicyCmdImpl',null,1);


INSERT INTO policy (POLICY_ID,POLICYNAME,POLICYTYPE_ID,STOREENT_ID,PROPERTIES,STARTTIME,ENDTIME,OPTCOUNTER) 
VALUES ((select max(POLICY_ID)+1 from policy),'BT_ApplePay','Payment',11,'attrPageName=StandardApplePay&paymentConfigurationId=default&display=true&compatibleMode=false',null,null,1);
INSERT INTO policydesc (POLICY_ID,LANGUAGE_ID,DESCRIPTION,LONGDESCRIPTION,TIMECREATED,TIMEUPDATED,OPTCOUNTER) 
VALUES ((select POLICY_ID from policy where policyname = 'BT_ApplePay'), -1 ,'ApplePay','ApplePay',{ts '2018-10-2 01:00:00.001000'},{ts '2018-10-2 01:30:00.001000'},1);
INSERT INTO POLICYCMD (POLICY_ID,BUSINESSCMDCLASS,PROPERTIES,OPTCOUNTER) VALUES ((select POLICY_ID from policy where policyname = 'BT_ApplePay'),'com.ibm.commerce.payment.actions.commands.DoPaymentActionsPolicyCmdImpl',null,1);
INSERT INTO POLICYCMD (POLICY_ID,BUSINESSCMDCLASS,PROPERTIES,OPTCOUNTER) VALUES ((select POLICY_ID from policy where policyname = 'BT_ApplePay'),'com.ibm.commerce.payment.actions.commands.EditPaymentInstructionPolicyCmdImpl',null,1);
INSERT INTO POLICYCMD (POLICY_ID,BUSINESSCMDCLASS,PROPERTIES,OPTCOUNTER) VALUES ((select POLICY_ID from policy where policyname = 'BT_ApplePay'),'com.ibm.commerce.payment.actions.commands.QueryPaymentsInfoPolicyCmdImpl',null,1);

#Savepayments table
CREATE TABLE X_SAVEDPAYMENTS (X_SAVEDPAYMENTS_ID BIGINT NOT NULL, MEMBER_ID BIGINT NOT NULL,STORE_ID INTEGER,  STATUS VARCHAR(16), PAYMENT_TYPE VARCHAR(64) NOT NULL, PAYMENT_ACCOUNT VARCHAR(256) NOT NULL, EXPIRY_DATE VARCHAR(16) ,PAYMENT_TOKEN VARCHAR(512) NOT NULL ,MARK_FOR_DELETE SMALLINT DEFAULT 0 ,MARK_FOR_DELETE_DATE TIMESTAMP ,ADDED_IN_PI_AUTH SMALLINT DEFAULT 0 ,  ADDED_IN_AUTH SMALLINT DEFAULT 0 , ADDED_IN_AUTH_DATE TIMESTAMP,MARK_AS_PROCESSED SMALLINT DEFAULT 0,PAYMENT_METHOD_ID VARCHAR(256) NULL, OPTCOUNTER SMALLINT, PRIMARY KEY (X_SAVEDPAYMENTS_ID));
#keys table
INSERT INTO KEYS VALUES ((select max(keys_id)+1 from keys), 'x_savedpayments','x_savedpayments_id',10000,500,0,2147483647,0,1048576,1);

#cmdreg
update cmdreg set classname= 'com.hcl.commerce.edp.commands.HCLExtPIAddCmdImpl' where interfacename = 'com.ibm.commerce.edp.commands.PIAddCmd'

#schcmd schedule HCLDeletePaymentDetailsOfBTVaultCmd job command
INSERT INTO SCHCMD (SCHCMD_ID, STOREENT_ID, PATHINFO) VALUES (( select max(SCHCMD_ID)+1 from SCHCMD ), 0, 'HCLDeletePaymentDetailsOfBTVaultCmd');
