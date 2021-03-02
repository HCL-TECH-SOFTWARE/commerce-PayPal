# PayPal Installation Instructions

## Integrating PayPal plugin to HCL Commerce V9.1.x

Follow the below steps to integrate PayPal on HCL Commerce  
  * Copy files to projects
  * Import HCLBrainTreePaymentPlugin to RAD
  * Setup instructions on RAD
  * Execute scripts on CMD prompt
  * Additional Details
  
  
  **Copy files to projects**
 
    * Project - WC  
       Location: WC/lib  
       File: braintree-java-2.83.0.jar

       Location: WC/xml/config/payments/epd/groups/default  
       Folders: ZApplePayOnlineConfiguration, ZBrainTreeOnlineConfiguration, ZGooglePayOnlineConfiguration,  
                ZPayPalOnlineConfiguration, ZVenmoOnlineConfiguration

       Merge the tags between <!--BRAINTREE START--> and <!--BRAINTREE END--> to files in the location below  
       Location: WC/xml/config/payments/edp/groups/default  
       Files: PaymentMappings.xml, PaymentMethodConfigurations.xml, RefundMappings.xml, RefundMethodMappings.xml

       Location: WC/xml/config/payments/ppc/plugins  
       Folder: HCLBrainTreePaymentPlugin

       Merge the tags between <!--BRAINTREE START--> and <!--BRAINTREE END--> to files in the location below  
       Location: WC/xml/config/payments/ppc/plugins  
       File: PaymentSystemPluginMapping.xml

    * Project - WebSphereCommerceServerExtensionsData   
       Location: WebSphereCommerceServerExtensionsData/ejbModule/com   
       Folder: hcl

    * Project - WebSphereCommerceServerExtensionsLogic  
       Location: WebSphereCommerceServerExtensionsLogic/src/com   
       Folder: hcl

    * Project - Stores   
       Location: Stores/src  
       Folder: Emerald  
       Note: Policy name must be unique. Eg: BT_PayPal is set in BrainTreeConfig.properties.
       Change the folder name and store id to AuroraESite for Aurora.

       Merge the tags between <!--BRAINTREE START--> and <!--BRAINTREE END--> to files in the location below  
       Location: Stores/WebContent/WEB-INF  
       File: Struts-config-ext.xml

    * Project - Rest  
       Location: Rest/WebContent/WEB-INF/config  
       File: resources-ext.properties

    * Project - DataLoad  
       Location: DataLoad  
       Folders: sql, acp

       The policy names must always be unique. Update the policy names before executing them in the database.  
       File: BrianTree.sql  

       Copy file to the below location  
       Location: <Instal Dir>/xml/policies/xml  
       File: DataLoad/acp/BrainTreeAccessControlPolicies.xml

 **Import HCLBrainTreePaymentPlugin to RAD**   
 Import EJB jar file and select HCLBrainTreePaymentPlugin.jar. 
 Select checkbox "Add project to an EAR" and EAR project name: WC  
 
 **Setup instructions on RAD**   
 Once the HCLBrainTreePaymentPlugin is imported, go to Properties->Java Build Path  
 On Projects tab, Add WebSphereCommerceServerExtensionsData  
 On Libraries tab, Add JARs braintree-java-2.83.0.jar from WC/lib and Payments-Plugin.jar from WC  

 On the WebSphereCommerceServerExtensionsLogic, go to Properties->Java Build Path  
 On Projects tab, Add HCLBrainTreePaymentsPlugin  
 On Libraries tab, Add JARs braintree-java-2.83.0.jar from WC/lib and Enablement-BaseComponentLogic.jar from WC  

 Configure BrainTreeConfiguration.properties  

 On the servers tab, right-click on the server. click on "Clean".

 A dialog box appears with the message: "Are you sure you want to clean all published projects?".  
 Click OK. The above steps will clean and publish with the new payments plugin.

 **Execute scripts on CMD prompt**   
 Before starting command prompt, verify/update DB details <Install Dir>/dataload/acpload/wc-dataload-env.xml  
 Start command prompt, cd <Install Dir> (cd C:/WCDE_V9/bin)  
 Execute, acpload.bat C:\WCDE_V9\xml\policies\xml\BraintreeAccessControlPolicies.xml  
 Provide the database password when prompted.  
  
 **Note:** Restart the HCL Commerce server if changes aren't reflected.
 
 **Additonal Instructions**   
 For screenshots and additional information please read PayPal_Installation_Guide.docx
