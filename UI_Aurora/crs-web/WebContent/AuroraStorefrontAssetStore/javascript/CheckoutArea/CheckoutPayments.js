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

/**
* @fileOverview This JavaScript file contains functions used by the payment section of the checkout pages.
*/

//declare the namespace if it does not already exist
if (CheckoutPayments == null || typeof(CheckoutPayments) != "object") {
	var CheckoutPayments = new Object();
}

CheckoutPayments = {
	/** used to hold error messages for any error encountered */
	errorMessages: {},

	/** indicates the number of payment methods a shopper has selected to use from the shipping and billing page, default to 1 */
	numberOfPaymentMethods: 1,

	/** language ID to be used, default to -1 (English) */
	langId: "-1",

	/** store ID to be used */
	storeId: "",

	/** catalog ID to be used */
	catalogId: "",

	/** indicates if the shipping information on the checkout page has been changed */
	dirtyFlag: false,

	/** locale code to be passed to jQuery functions */
	jQlocale: "",

	/** This constant is the standard number of payment methods supported during order check out. */
	maxNumberOfPaymentMethodsSupported: 3,

	/** Stores all payment objects on the shipping & billing page. */
	paymentObjects: new Array(),

	/** Stores the payment instructions that should be deleted from the order. */
	paymentsToDelete: new Array(),

	/** Stores the payment instructions that should be added to the order. */
	paymentsToAdd: new Array(),

	/** Stores the payment instructions that should be updated in the order. */
	paymentsToUpdate: new Array(),

	/** Keeps track of the previous number of payment methods selected by the user. */
	prevNumberOfPaymentMethods: 1,

	/** The Purchase Order Number entered */
	purchaseOrderNumber: "",

	/** This flag indicates whether billing address dropdown box should be refreshed on change of the payment method.*/
	paymentSpecificAddress: false,

	/** This flag indicates whether quick checkout is enabled*/
	quickCheckoutProfileForPaymentFlag: false,

	/** Keep track of which payment method selection was changed */
	currentPaymentMethodChanged: 1,

	/**
	* Sets the jQlocale variable to be used by jQuery functions
	* @param {String} locale Locale to be set
	*/
	setLocale: function (locale) {
		this.jQlocale = locale;
	},

	/**
	* Sets the quickCheckoutProfileForPaymentFlag variable to be used to display masked credit card info.
	* @param {String} flag to be set true or false
	*/
	setQuickCheckoutProfileForPaymentFlag: function (flag) {
		this.quickCheckoutProfileForPaymentFlag = flag;
	},

	/**
	* This function is used to initialize the error messages object with all the required error messages.
	* @param {String} key The key used to access this error message.
	* @param {String} msg The error message in the correct language.
	*/
	setErrorMessage:function(key, msg) {
		this.errorMessages[key] = msg;
	},

	/**
	* Sets common parameters used by this JavaScript object
	* @param {String} langId language ID to use
	* @param {String} storeId store ID to use
	* @param {String} catalog Catalog ID to use
	*/
	setCommonParameters:function(langId,storeId,catalogId){
		this.langId = langId;
		this.storeId = storeId;
		this.catalogId = catalogId;
	},

	/**
	* This function checks to see how many payments are selected and decides if the number of payment indicator
	* should be shown or not.
	* Initially, the indicator is hidden because there's only 1 payment.
	* If there are more payments methods, the indicator is turned on.
	* @param {String} numPayments number of payments to set
	*/
	setNumPaymentIndicator:function(numPayments) {
		var payment2 = document.getElementById('paymentSection2');

		if (payment2.style.display=='block') {
			//if paymentSection2 is shown, that means there are more than one payment methods. Show all indicators
			for (i=1; i<numPayments; i++){
				var div = document.getElementById('paymentHeading'+i);
				div.style.display="block";
			}
		}else {
			//there's only 1 payment method. Hide the indicators
			document.getElementById('paymentHeading1').style.display="none";
		}
	},

	/**
	* This function displays (unhides) the number of payment methods specified. The pre-requisite is
	* that the payment sections	are named as the prefix that is passed in.
	* Look for the HTML elements named as the prefix passed	in and the number of payment methods required.
	* The rest are disabled.
	* @param {String} totalPaymentMethods The total number of payment methods blocks.
	* @param {String} numberOfPaymentMethodsField The number of payment method block to show.
	* @param {String} divNamePrefix The name of the root HTML element that contains each payment method block.
	*/
	setNumberOfPaymentMethods:function(totalPaymentMethods,numberOfPaymentMethodsField,divNamePrefix) {
		this.numberOfPaymentMethods = numberOfPaymentMethodsField.value;
		for (i=1; i<=totalPaymentMethods; i++) {
			var divNode = document.getElementById(divNamePrefix+i);
			if (divNode != undefined) {
				if (i<=numberOfPaymentMethodsField.value) {
					divNode.style.display = "block";
				} else {
					divNode.style.display = "none";
				}
			}
		}
		var orderTotal = document.getElementById("OrderTotalAmount").value;
		this.updateAmountFields(orderTotal);
		this.setNumPaymentIndicator(numberOfPaymentMethodsField.value);
	},

	/**
	* Clears all payment data for a specified form
	* @param {String} paymentFormName Name of the payment form to be cleared
	*/
	clearPaymentFormData:function(paymentFormName) {
		if (this.getValue(paymentFormName,"cc_brand") !== " ") {
			paymentFormName["cc_brand"].value = " ";
		}
		if (this.getValue(paymentFormName,"cc_cvc") !== " ") {
			paymentFormName["cc_cvc"].value = " ";
		}
		if (this.getValue(paymentFormName,"account") !== " ") {
			paymentFormName["account"].value = " ";
		}
		if (this.getValue(paymentFormName,"payment_token") !== " ") {
			paymentFormName["payment_token"].value = " ";
		}
		if (this.getValue(paymentFormName,"expire_month") !== " ") {
			paymentFormName["expire_month"].value = " ";
		}
		if (this.getValue(paymentFormName,"expire_year") !== " ") {
			paymentFormName["expire_year"].value = " ";
		}
		if (this.getValue(paymentFormName,"check_routing_number") !== " ") {
			paymentFormName["check_routing_number"].value = " ";
		}
		if (this.getValue(paymentFormName,"checkingAccountNumber") !== " ") {
			paymentFormName["checkingAccountNumber"].value = " ";
		}
		if (this.getValue(paymentFormName,"checkRoutingNumber") !== " ") {
			paymentFormName["checkRoutingNumber"].value = " ";
		}
		if (this.getValue(paymentFormName,"numberOfInstallments") !== " ") {
			paymentFormName["numberOfInstallments"].value = " ";
		}
	},

	/**
	* This function sets the context to the selected payment method so that the controller loads
	* the desired struts action.
	* Sets the specific payment block context to the selected payment method. The controller has
	* the mapping of what struts action to load for each payment method.
	* @param {String} paymentMethodSelectBox The identifier of the selected payment method.
	* @param {String} paymentAreaNumber The payment block that this payment method applies to.
	*/
	loadPaymentSnippet:function(paymentMethodSelectBox, paymentAreaNumber){
		// before updating context, clear previous form data
		var formObj = document.forms['PaymentForm'+paymentAreaNumber];
		this.clearPaymentFormData(formObj);

		var selectBoxValueArray = paymentMethodSelectBox.value.split("_");
		var paymentMethodName = selectBoxValueArray[0];
		var paymentTCId = '';
		if(selectBoxValueArray[1] != null){
			paymentTCId = selectBoxValueArray[1];
		}

		if(this.paymentSpecificAddress){
			wcRenderContext.getRenderContextProperties("billingAddressDropDownBoxContext")["payment"+paymentAreaNumber] = paymentMethodName;
			wcRenderContext.getRenderContextProperties("billingAddressDropDownBoxContext")["paymentTCId" + paymentAreaNumber] = paymentTCId;
			wcRenderContext.updateRenderContext("billingAddressDropDownBoxContext");
		}
		MessageHelper.hideAndClearMessage();
		var currentTotal = 0;
		for(var i = 1; i < paymentAreaNumber; i++){
			var formName = document.forms["PaymentForm"+i];
			if (formName.piAmount != null && formName.piAmount.value != "" && !isNaN(formName.piAmount.value)){
				currentTotal = (currentTotal) * (1) + (formName.piAmount.value) * (1);
			}
		}

		var contextPropertyName = "payment" + paymentAreaNumber;
		var buyerOrgDN = formObj.buyerOrgDN.value;
		var orderId = formObj.orderId.value;
		var piAmount = formObj.piAmount.value;
		var params = {};
		params[contextPropertyName] = paymentMethodName;
		params["paymentTCId" + paymentAreaNumber] = paymentTCId;
		params["currentPaymentArea"] = paymentAreaNumber;
		params["payMethodId"] = paymentMethodName;
		params["currentTotal"] = currentTotal;
		params["paymentTCId"] = paymentTCId;
		params["buyerOrgDN"] = buyerOrgDN;
		params["orderId"] = orderId;
		params["piAmount"] = piAmount;
		wcRenderContext.updateRenderContext("paymentContext", params);

		var currentForm = document.forms["PaymentForm"+paymentAreaNumber];
		if (paymentMethodName == "PayInStore") {
			//need to hide the billing address id
			var billingDiv = document.getElementById("billingAddressSelectBoxArea_"+paymentAreaNumber);
			billingDiv.style.display = "none";
			if (currentForm["billing_address_id"]) {
				currentForm.billing_address_id.value = "";
			}
		} else {
			var billingDiv = document.getElementById("billingAddressSelectBoxArea_"+paymentAreaNumber);
			billingDiv.style.display = "block";
			if (currentForm["billing_address_id"] == "") {
				currentForm.billing_address_id.value = "-1";
			}
		}
	},

	/**
	* Loads the payment snippet
	* @param {String} paymentMethodSelectBox The identifier of the selected payment method.
	* @param {String} paymentNumber The payment block that this payment method applies to.
	*
	*/
	loadPaymentSnippetLocally:function(paymentMethodSelectBox, paymentNumber){
		var selectBoxValueArray = paymentMethodSelectBox.value.split("_");
		var selectedPayMethod = selectBoxValueArray[0];
		var selectedDivContents ="";

		// save the current display amount and hidden amount of this payment form
		var thisPaymentAmount = "";
		var thisPaymentDisplayAmount = "";
		var thisForm = document.forms["PaymentForm"+paymentNumber];
		if (thisForm.piAmount != null && thisForm.piAmount.value != "" && !isNaN(thisForm.piAmount.value)){
			thisPaymentAmount = thisForm.piAmount.value;
		}
		if (thisForm.piAmount_display != null && thisForm.piAmount_display.value != "" && !isNaN(thisForm.piAmount_display.value)){
			thisPaymentDisplayAmount = thisForm.piAmount_display.value;
		}

		if(selectBoxValueArray[1] != null){
			var paymentTCId = selectBoxValueArray[1];
			selectedDivContents = $("#PIInfo_Div_"+selectedPayMethod+"_"+paymentNumber + "_" + paymentTCId).html();
		}else{
			selectedDivContents = $("#PIInfo_Div_"+selectedPayMethod+"_"+paymentNumber).html();
		}

		var divNode = document.getElementById("paymentFormDiv"+paymentNumber);
		divNode.html(selectedDivContents);

		// retrieve previously saved display amount and hidden amount of this payment form
		if (thisPaymentAmount != "") {
			thisForm.piAmount.value = thisPaymentAmount;
		}
		if (thisPaymentDisplayAmount != "") {
			thisForm.piAmount_display.value = thisPaymentDisplayAmount;
		}

		//Now set the amount field in the selected payment option with the remaining amount..
		var orderTotal = document.getElementById("OrderTotalAmount").value;
		this.updateAmountFields(orderTotal);
	},

	/**
	* This function processes the current shopping cart. The sequence of operations are:
	* 1. If its a non-ajax checkout, see if shopper has changed anything in current page. If so, alert shopper
	* to update these changes before starting checkout process.
	* 2. Check if its a singlePageCheckout or Traditional Checkout.
	* 2A. If Traditional Checkout, then call OrderPrepare Service and then display the BillingPage, by calling
	* showBillingPage() method
	* 2B. If SinglePageCheckout, then delete existing payment methods, add the new payment methods, call
	* OrderPrepare service and finally call showSummaryPage() method to display the OrderSummaryPage.
	* @param {String} ipFormName Name of the payment form containing payment data
	* @param {Boolean} skipOrderPrepare Indicates if Order Prepare process should be skipped. It defaults to false, if no value is passed.
	*/
	processCheckout:function(piFormName, skipOrderPrepare) {
		if (CheckoutHelperJS.isSinglePageCheckout() && !this.validatePaymentTotals(piFormName)) {
			return;
		}

		if (skipOrderPrepare == undefined || skipOrderPrepare == null){
			skipOrderPrepare = false;
		}

		if(CheckoutHelperJS.checkForDirtyFlag()){
			return;
		}

		if (CheckoutHelperJS.getShipmentTypeId() == "1") {
			if (document.getElementById("requestShippingDateCheckbox") != null) {

				// Validate input and create error message tooltip when there's error
				var jsDate = $("#requestedShippingDate");
				if(!jsDate.ValidationTextbox("validationAndErrorHandler")) {
					jsDate.focus();
					return;
				}
			}

		} else {
			var totalItemsDiv = document.getElementById("totalNumberOfItems");
			if (totalItemsDiv != null) {
				for (var i = 0; i < totalItemsDiv.value; i++) {
	
					var orderItemIdDiv = document.getElementById("orderItem_"+(i+1));
					if (orderItemIdDiv != null) {
						// Order items are being shown, so check shipping date
						var orderItemId = orderItemIdDiv.value;
					
						var requestShippingDateCheckbox = $("#MS_requestShippingDateCheckbox_" + orderItemId)[0];
		
						if (requestShippingDateCheckbox != null){
		
							var jsDate = $("#MS_requestedShippingDate_" + orderItemId);
							if(!jsDate.ValidationTextbox("validationAndErrorHandler")) {
								jsDate.focus();
								return;
							}
						}
					}
				}
			}
		}

		//Validate schedule orders or recurring orders section before allowing checkout. Only one of these
		//two features may be enable at a time.
		//1. schedule order fields are mandatory if either field is selected otherwise is a normal order
		//2. recurring order fields are always mandatory
		if(document.getElementById("scheduleOrderInputSection") != null){
			var scheduleOrderFrequencyObj = document.getElementById("ScheduleOrderFrequency");
			var scheduleOrderStartDateObj = $("#ScheduleOrderStartDate");
			var isRecurringOrderMandatory = document.getElementById("makeRecurringOrderMandatory");
			if((scheduleOrderFrequencyObj.value == "undefined" && scheduleOrderStartDateObj.val() != null) ||
						(isRecurringOrderMandatory && isRecurringOrderMandatory.value == "true" && scheduleOrderFrequencyObj.value == "undefined")){
				MessageHelper.formErrorHandleClient(scheduleOrderFrequencyObj.id, MessageHelper.messages["SCHEDULE_ORDER_MISSING_FREQUENCY"]);
				return;
			}
			if(scheduleOrderFrequencyObj.value != "undefined" && scheduleOrderStartDateObj.val() == null){
				MessageHelper.formErrorHandleClient(scheduleOrderStartDateObj[0].id, MessageHelper.messages["SCHEDULE_ORDER_MISSING_START_DATE"]);
				return;
			}
			if(!CheckoutHelperJS.validateDate(scheduleOrderStartDateObj, 'ScheduleOrderStartDate')){
				return;
			}
		}

		// The following code snippet is used to drop the paymentTermConditionId (if there is one) in the constructed payMethodId value before adding the payment instructions
		var numberOfPaymentMethodsRef = document.getElementById("numberOfPaymentMethods");
		if(numberOfPaymentMethodsRef){
			var paymentMethodsCount = numberOfPaymentMethodsRef.value;
			for(var i=1; i<=paymentMethodsCount; i++){
				var currentPaymentForm = document.forms[piFormName + i];
				//we don't need this block for "PayInStore" flow
				if (currentPaymentForm['payMethodId'].type == "select-one") {
					for(var j=0; j<currentPaymentForm['payMethodId'].options.length; j++){
						var payMethodId = currentPaymentForm['payMethodId'].options[j].value.split('_')[0];
						currentPaymentForm['payMethodId'].options[j].value = payMethodId;
					}
				}
			}
		}
		if(!skipOrderPrepare && !CheckoutHelperJS.isSinglePageCheckout()){
			//Call service to PrepareOrder and then show the billingPage....
			var params = [];
			params["storeId"] = this.storeId;
			params["catalogId"] = this.catalogId;
			params["langId"] = this.langId;
			params.orderId		= ".";
			if(!submitRequest()){
				return;
			}
			cursor_wait();
			wcService.invoke('AjaxPrepareOrderBeforePaymentCapture',params);
			return;
		}
		else{
			//SinglePageCheckout feature enabled.. So billing information is captured on the same page.. Delete existing
			//billing info, Validate and add these new billing info...
			if(skipOrderPrepare){
				this.processPIAndCheckout(piFormName,skipOrderPrepare);
			} else {
				var params = [];
				params["storeId"] = this.storeId;
				params["catalogId"] = this.catalogId;
				params["langId"] = this.langId;
				if(!submitRequest()){
					return;
				}
				cursor_wait();
				wcService.invoke('AjaxPrepareOrderBeforeSubmit', params);
			}
		}
	},

	/**
	* This function examines all payment instructions to find out which one(s) needs to be deleted, added or updated, then calls the corresponding AJAX service to process them.
	* Once all payment instructions are processed successfully, the current shopping cart is submitted.
	* @param {String} ipFormName Name of the payment form containing payment data
	* @param {Boolean} skipOrderPrepare Indicates if Order Prepare process should be skipped. It defaults to false, if no value is passed.
	*/
	processPIAndCheckout:function(piFormName, skipOrderPrepare) {
		if (skipOrderPrepare == undefined || skipOrderPrepare == null){
			skipOrderPrepare = false;
		} else if (skipOrderPrepare == 'true' || skipOrderPrepare == 'false'){
			//If skipOrderPrepare is passed in as a string instead of boolean from a service response
			//Cast the value back to a boolean before further processing
			skipOrderPrepare = (skipOrderPrepare === 'true');
		}

		if (this.checkValidPaymentInstructions(piFormName)){
			var formName = document.forms[piFormName + '1'];
			if(this.getValue(formName,"valueFromProfileOrder") == "Y") {
				this.setQuickCheckoutProfileForPaymentFlag("true");

				// Only the first payment method could be from the quick checkout profile. If it is, then re-add the payment instruction (PI).
				// This fixes the problem where a standard PI has already been registered with the order and the user now chooses quick checkout profile to check out without further modifying the payment.
				this.updatePaymentObject(1, "account");
			}

			var maxNumberOfPaymentMethodsSupported = parseInt(this.maxNumberOfPaymentMethodsSupported);

			for(var i=1; i<=maxNumberOfPaymentMethodsSupported; i++){
				var paymentObj = this.retrievePaymentObject(i);
				if(paymentObj != null){
					if((paymentObj['action'] == 'delete' || paymentObj['action'] == 're-add') && paymentObj['piId'] != ""){
						this.setPaymentsToDelete(i);
					}
					if(paymentObj['action'] == 'add' || paymentObj['action'] == 're-add'){
						this.setPaymentsToAdd(i);
					}
					if(paymentObj['action'] == 'update' && paymentObj['piId'] != ""){
						this.setPaymentsToUpdate(i);
					}
				}
			}
			if(this.getPaymentsToDelete().length > 0){
				this.deletePaymentInstructions();
			}else if(this.getPaymentsToAdd().length > 0){
				this.addPaymentInstructions();
			}else if(this.getPaymentsToUpdate().length > 0){
				this.updatePaymentInstructions();
			}else{
				CheckoutPayments.setCommonParameters(SBServicesDeclarationJS.langId,SBServicesDeclarationJS.storeId,SBServicesDeclarationJS.catalogId);
				CheckoutPayments.showSummaryPage();
				cursor_clear();
			}
			CheckoutHelperJS.setFieldDirtyFlag(false);
		}
	},

	/**
	* Determines the URL of the order summary page and invokes the page
	*/
	showSummaryPage:function(){
		if(document.getElementById("scheduleOrderInputSection") != null){
			CheckoutHelperJS.prepareOrderSchedule();
		}

		var po_id = encodeURIComponent(this.purchaseOrderNumber);
		var url = '';
		if(CheckoutHelperJS.getShipmentTypeId() == "1"){
			url = "SingleShipmentOrderSummaryView?langId="+this.langId+"&storeId="+this.storeId+"&catalogId="+this.catalogId+"&purchaseorder_id="+po_id+"&quickCheckoutProfileForPayment="+this.quickCheckoutProfileForPaymentFlag;
			document.location.href = appendWcCommonRequestParameters(url);
		}
		else {
			url = "MultipleShipmentOrderSummaryView?langId="+this.langId+"&storeId="+this.storeId+"&catalogId="+this.catalogId+"&purchaseorder_id="+po_id+"&quickCheckoutProfileForPayment="+this.quickCheckoutProfileForPaymentFlag;
			document.location.href = appendWcCommonRequestParameters(url);
		}
	},

	showBillingPage:function(){
		document.location.href = appendWcCommonRequestParameters("OrderBillingView?langId="+this.langId+"&storeId="+this.storeId+"&catalogId="+this.catalogId+"&forceShipmentType="+CheckoutHelperJS.getShipmentTypeId());
	},

	/**
	* Populates payment data
	* @param {String} formName Name of the payment form to be populated
	* @param {Object} params Object containing payment data
	* @retrun {Object} params Object holding payment data
	*/
	/*BRAINTREE START */ 
	populateProtocolData:function(formName,params){
		params = this.updateParamObject(params,"storeId",this.getValue(formName,"storeId"),true);
		params = this.updateParamObject(params,"payment_token",this.getValue(formName,"payment_token"),true);
		params = this.updateParamObject(params,"catalogId",this.getValue(formName,"catalogId"),true);
		params = this.updateParamObject(params,"langId",this.getValue(formName,"langId"),true);
		params = this.updateParamObject(params,"valueFromProfileOrder",this.getValue(formName,"valueFromProfileOrder"),true);
		params = this.updateParamObject(params,"valueFromPaymentTC",this.getValue(formName,"valueFromPaymentTC"),true);
		params = this.updateParamObject(params,"paymentTCId",this.getValue(formName,"paymentTCId"),true);
		/* removed payMethodId param and added below with conditions. code is below*/
		params = this.updateParamObject(params,"piAmount",this.getValue(formName,"piAmount"),true);
		params = this.updateParamObject(params,"billing_address_id",this.getValue(formName,"billing_address_id"),true);
		params = this.updateParamObject(params,"cc_brand",this.getValue(formName,"cc_brand"),true);
		params = this.updateParamObject(params,"cc_cvc",this.getValue(formName,"cc_cvc"),true);

		params = this.updateParamObject(params,"account",this.getValue(formName,"account"),true);
		params = this.updateParamObject(params,"expire_month",this.getValue(formName,"expire_month"),true);
		params = this.updateParamObject(params,"expire_year",this.getValue(formName,"expire_year"),true);

		params = this.updateParamObject(params,"check_routing_number",this.getValue(formName,"check_routing_number"),true);
		params = this.updateParamObject(params,"checkingAccountNumber",this.getValue(formName,"checkingAccountNumber"),true);
		params = this.updateParamObject(params,"checkRoutingNumber",this.getValue(formName,"checkRoutingNumber"),true);
		params = this.updateParamObject(params,"requesttype","ajax",true);
		if(formName.authToken){
			params = this.updateParamObject(params,"authToken",this.getValue(formName,"authToken"),true);
		}
		
		var fromSavedPayment = this.getValue(formName,"fromSavedPaymentFlag");
		var payType = this.getValue(formName,"pay_type");
		var PaymentMethodIdValue = this.getValue(formName,"payMethodId");
		
		if(payType == "PayPalCredit" && fromSavedPayment == "false")
			PaymentMethodIdValue = "ZPayPalCredit" ;
		if(fromSavedPayment == "true")
			PaymentMethodIdValue = this.getValue(formName,"PaymentMethodId");
		
		params = this.updateParamObject(params,"payMethodId",PaymentMethodIdValue,true);
		params = this.updateParamObject(params,"3Dsecure_nonce",this.getValue(formName,"3Dsecure_nonce"),true);
		params = this.updateParamObject(params,"pay_type",payType,true);
		params = this.updateParamObject(params,"pay_nonce",this.getValue(formName,"pay_nonce"),true);
		params = this.updateParamObject(params,"pay_token",this.getValue(formName,"pay_token"),true);
		params = this.updateParamObject(params,"cvv_nonce",this.getValue(formName,"cvv_nonce"),true);
		params = this.updateParamObject(params,"fromSavedPaymentFlag",fromSavedPayment,true);
		params = this.updateParamObject(params,"deviceSessionId",this.getValue(formName,"deviceSessionId"),true);
		params = this.updateParamObject(params,"fraudMerchantId",this.getValue(formName,"fraudMerchantId"),true);
		params = this.updateParamObject(params,"PayPalEmailId",this.getValue(formName,"PayPalEmailId"),true);
		//displayCardsFlag fetch this from jsp variable
		if(document.getElementById("saveCardCheckBox") == null){
			params = this.updateParamObject(params,"save_card",false,true);
		}
		else{
			params = this.updateParamObject(params,"save_card",document.getElementById("saveCardCheckBox").checked,true);
		}
		/*BRAINTREE END*/
		return params;
	},

	/**
	* Populates payment data based on a specified array of fields.
	* @param {DOM Object} formName The payment form that contains input data.
	* @param {Array} params The array object that contains payment data.
	* @param {Array} arrayFields The array object containing the specified input fields that this function should populate data for.
	* @retrun {Array} params Array holding payment data.
	*/
	populateProtocolDataForGivenFields:function(formName,params,arrayFields){
		for(var i=0; i<arrayFields.length; i++){
			var field = arrayFields[i];
			params = this.updateParamObject(params,field,this.getValue(formName,field),true);
		}
		params = this.updateParamObject(params,"requesttype","ajax",true);
		return params;
	},

	/**
	* Gets the text value of a particular 'selectBox' from the form
	* @param {String} formName Name of the payment form
	* @param {String} fieldName Name of the filed to get value from
	* @return {String} the selected text of the field
	*/
	getSelected: function(formName,fieldName)
	{
		if (formName[fieldName] != null){
			var selObj = formName[fieldName];

			var selIndex = selObj.selectedIndex;
			  //in case index/selected option not found, return blank
			return (selIndex !== -1 ) ? selObj.options[selIndex].text : "";
		}
		else{
			return "";
		}
	},

	/**
	* Gets the value of a particular field in the form
	* @param {String} formName Name of the payment form
	* @param {String} fieldName Name of the filed to get value from
	* @return {String} value of the field
	*/
	getValue:function(formName,fieldName){
		if (formName[fieldName] != null)
			return formName[fieldName].value;
		else return " ";
	},

	/**
	* This function trims the spaces from the passed in word.
	* Delete all pre and trailing spaces around the word.
	* @param {String} inword The word to trim.
	* @return {String} Word with leading and trailing spaces trimmed
	*/
	trim:function(inword)
	{
	   word = inword.toString();
	   var i=0;
	   var j=word.length-1;
	   while(word.charAt(i) == " ") i++;
	   while(word.charAt(j) == " ") j=j-1;
	   if (i > j) {
			return word.substring(i,i);
		} else {
			return word.substring(i,j+1);
		}
	},

	/**
	* This function verifies that all the characters in the word are numbers.
	* This function is used to verify if a word is made up of all numbers.
	* @param {String} word The prefix used for the payment blocks.
	* @return {Boolean} False if word is not a number. True if word is a number.
	*/
	isNumber:function(word)
	{
		var numbers="0123456789";
		var word=this.trim(word);
		for (var i=0; i < word.length; i++)
		{
			if (numbers.indexOf(word.charAt(i)) == -1)
			return false;
		}
		return true;
	},

	/**
	* Make sure all changes to the hidden piAmount are synchronized with the piAmount_display
	* and formatted to the current locale
	* This function will check whether the hidden piAmount field has been updated by other
	* services or calculations etc, if so, format the value and copy it over to the
	* piAmount_display field
	* @param {String} paymentAreaNumber The payment area number to check the amount for.
	*/
	formatAmountDisplayForLocale:function(paymentAreaNumber) {
		//Take the hidden payment amount and format it to the current locale
		var paymentAmount = document.getElementById("piAmount_"+paymentAreaNumber);
		var paymentAmount_display = document.getElementById("piAmount_"+paymentAreaNumber+"_display");

		if(this.jQlocale == 'ar_EG')
		{
			var formattedPaymentAmountValue = Utils.formatNumber(paymentAmount.value, {
				maximumFractionDigits: 2,
				minimumFractionDigits: 2
			});
		}
		else
		{
			if (this.jQlocale.indexOf('zh') === 0 || this.jQlocale.indexOf('ja') === 0 || this.jQlocale.indexOf('ko') === 0) {
				// Add trailing 0 only if necessary.  Only useful for double-byte languages
				var formattedPaymentAmountValue = Utils.formatNumber(paymentAmount.value, {
 					locale: this.jQlocale,
 					maximumFractionDigits: 1
 				});
			}
			else {
				// Always add 2 trailing 0.  Only useful for single-byte languages
				var formattedPaymentAmountValue = Utils.formatNumber(paymentAmount.value, {
 					locale: this.jQlocale,
 					minimumFractionDigits: 2,
 					maximumFractionDigits: 2
 				});
			}
		}

		//If the displayed payment amount is different from the hidden payment amount
		//Synchronize the display payment amount according to the hidden payment amount
		if(paymentAmount_display.value != formattedPaymentAmountValue || this.jQlocale == 'ar_EG'){
			paymentAmount_display.value = formattedPaymentAmountValue;
		}
	},

	/**
	* This function verifies that the amount is valid.
	* This function will check that the amount field is not	empty, and is not negative and that
	* is numeric.
	* @param {String} formNamePrefix The prefix used for the payment blocks.
	* @param {String} paymentAreaNumber The payment area number to check the amount for.
	* @return {Boolean} False if amount is not valid. True if amount is valid.
	*/
	validateAmount:function(formNamePrefix, paymentAreaNumber) {
		//verify the field amount entered is a number
		var formName = document.forms[formNamePrefix+paymentAreaNumber];

		//Take the displayed payment amount, parse it back to a number
		// First trim leading and trailing spaces
		formName.piAmount_display.value = formName.piAmount_display.value.replace(/^\s+|\s+$/g,"");
		formName.piAmount_display.value = formName.piAmount_display.value.replace(/\xa0/g,'');
		var valueToParse = formName.piAmount_display.value;

		if(this.jQlocale == 'ar_EG')
		{
			valueToParse = valueToParse.replace(',','');
			var parsedAmountValue = Utils.formatNumber(valueToParse, {maximumFractionDigits: 2, minimumFractionDigits: 2});
		}
		else
		{
			var parsedAmountValue = Utils.parseNumber(valueToParse);
		}

		//If the displayed payment amount and the hidden payment amount are different
		//Synchronize the 2 fields according to the displayed payment amount
		if(parsedAmountValue != formName.piAmount.value){
			formName.piAmount.value = parsedAmountValue;
		}

		if (formName.piAmount != null && formName.piAmount.value == "") {
			MessageHelper.formErrorHandleClient(formName.piAmount_display,this.errorMessages["EDPPaymentMethods_NO_AMOUNT"]);
			return false;
		} else if (formName.piAmount != null && parseFloat(formName.piAmount.value) < 0){
			MessageHelper.formErrorHandleClient(formName.piAmount_display,this.errorMessages["EDPPaymentMethods_AMOUNT_LT_ZERO"]);
			return false;
		} else if (formName.piAmount != null && isNaN(formName.piAmount.value)) {
			MessageHelper.formErrorHandleClient(formName.piAmount_display,this.errorMessages["EDPPaymentMethods_AMOUNT_NAN"]);
			return false;
		}


		//amount total is correct. Save it in the context so that we can retrieve it when user changes payment method
		var params = {};
		params["paymentAreaAmount"+paymentAreaNumber] = parsedAmountValue;
		wcRenderContext.updateRenderContext("paymentContext", params);

		return true;

	},

	/**
	* This function submits the current shopping cart once all the payment instructions are added successfully.
	* This function will add all the payment instructions first with AJAX calls and then calls the order
	* processing service.
	* @param {String} formNamePrefix The prefix used for the payment blocks.
	* @retrun {Boolean} True if sum of payment amounts is equal to the order total. False if sum of payment amounts does not equal order total.
	*/
	validatePaymentTotals:function(formNamePrefix) {
		//verify that all payment amounts sum up to the order total
		var runningTotal = parseFloat(0.0);
		var orderTotal = document.getElementById("OrderTotalAmount").value;
		for (var i=1; i<=this.numberOfPaymentMethods; i++) {
			var formName = document.forms[formNamePrefix+i];

			if (this.validateAmount(formNamePrefix, i)) {
				runningTotal = runningTotal + parseFloat(formName.piAmount.value);
				var temp = runningTotal.toFixed(2);
				runningTotal = parseFloat(temp);
			} else {
				return false;
			}
		}
		if (runningTotal == orderTotal) {
			return true;
		} else {
			var element = (document.getElementsByName("piAmount_display"))[0]; // get the Amount field of the first payment method
			if (runningTotal < orderTotal) {
				MessageHelper.formErrorHandleClient(element, this.errorMessages["EDPPaymentMethods_CANNOT_RECONCILE_PAYMENT_AMT"]);
				return false;
			} else if (runningTotal > orderTotal) {
				MessageHelper.formErrorHandleClient(element, this.errorMessages["EDPPaymentMethods_PAYMENT_AMOUNT_LARGER_THAN_ORDER_AMOUNT"]);
				return false;
			} else {
				MessageHelper.formErrorHandleClient(element, this.errorMessages["EDPPaymentMethods_PAYMENT_AMOUNT_PROBLEM"]);
				return false;
			}
		}
	},

	/**
	* This function validates the billing address details to make sure that they are not empty.
	* @param {String} formNamePrefix The prefix used for the payment blocks.
	* @return {Boolean} True if all fields are validated without error. False if an error has encountered.
	*/
	isBillingAddressValid:function(formNamePrefix) {
		for (var i=1; i<=this.numberOfPaymentMethods; i++) {
			var formName = document.forms[formNamePrefix+i];
			var billing_address_isValid = formName.billing_address_isValid;
			if (billing_address_isValid) {
				if (billing_address_isValid.value == "false") {
					return false;
				}
			}
		}
		return true;
	},

	/**
	* This function validates all mandatory fields in the payment section are not empty.
	* This function makes sure all fields are valid before calling order services.
	* @param {String} formNamePrefix The prefix used for the payment blocks.
	* @return {Boolean} True if all fields are validated without error. False if an error has encountered.
	*/
	checkValidPaymentInstructions:function(formNamePrefix) {
		for (var i=1; i<=this.numberOfPaymentMethods; i++) {
			var formName = document.forms[formNamePrefix+i];
			var mandatoryFields = " ";
			if(formName["mandatoryFields_"+i] != null){
				mandatoryFields = formName["mandatoryFields_"+i].value;
			}
			var purchaseOrderForm = document.forms["purchaseOrderNumberInfo"];
			if (purchaseOrderForm) {
				this.purchaseOrderNumber = purchaseOrderForm.purchase_order_number.value;
				if(purchaseOrderForm.purchaseOrderNumberRequired.value == 'true' && purchaseOrderForm.purchase_order_number.value == ""){
					MessageHelper.formErrorHandleClient(purchaseOrderForm.purchase_order_number,this.errorMessages["ERROR_PONumberEmpty"]);
					return false;
				}
				else if(!MessageHelper.isValidUTF8length(purchaseOrderForm.purchase_order_number.value, 128)){
					MessageHelper.formErrorHandleClient(purchaseOrderForm.purchase_order_number,this.errorMessages["ERROR_PONumberTooLong"]);
					return false;
				}
			}
			if (formName.payMethodId.type == "select-one") {
				if (formName.payMethodId.options[formName.payMethodId.options.selectedIndex].value == "empty") {
					MessageHelper.formErrorHandleClient(formName.payMethodId,this.errorMessages["EDPPaymentMethods_NO_PAYMENT_SELECTED"]);
					return false;
				}
			}
			/* All the visa, masterCard and Amex  pages will have account1 field which will be filled by user and one more hidden field by name
			account...
			1. If its a quickcheckout profile and data is valid (!dirty) then copy the value of unmaskedAccount field into hidden account field
			2. If its not a quickcheckout or if data is dirty, then copy the value entered by user (account1 into hidden field account */
			//Its not a quick checkout..so just assign value of account1 to account..
			if(CheckoutHelperJS.isPaymentDataDirty(i)){
				if(document.getElementById("account_"+i) != null){
					document.getElementById("account_"+i).value = document.getElementById("account1_"+i).value;
				}
			}

			if (document.getElementById("expire_month_"+i) != null || document.getElementById("expire_year_"+i) != null) {
				var now = new Date(formName.curr_year.value,formName.curr_month.value - 1,formName.curr_date.value);
				var lastday = 1;
				var lastmonth = 1;

				if (document.getElementById("expire_month_"+i) != null) {
					lastmonth = new Number(document.getElementById("expire_month_"+i).value) + 1;
					if (lastmonth > 13) {
						lastmonth = 1;
					}
				}

				var expiry = 2000;
				if (document.getElementById("expire_year_"+i) != null) {
					expiry = new Date(document.getElementById("expire_year_"+i).value,lastmonth - 1,lastday);
				}
			}

			//Start validations...
			if (formName.piAmount != null && parseFloat(formName.piAmount.value) < 0){
				MessageHelper.formErrorHandleClient(formName.piAmount_display,this.errorMessages["EDPPaymentMethods_AMOUNT_LT_ZERO"]);
				return false;
			// account is checked for StandardAmex, StandardMasterCard, StandardVisa, StandardLOC and StandardCheck
			} else if (mandatoryFields.indexOf("account_"+i) != -1 && document.getElementById("account_"+i) != null && document.getElementById("account_"+i).value == "" ) {
				MessageHelper.displayErrorMessage(this.errorMessages["EDPPaymentMethods_NO_ACCOUNT_NUMBER"]);
				return false;
			// expiry date can be checked for credit cards StandardAmex, StandardMasterCard and StandardVisa
			} else if ((mandatoryFields.indexOf("expire_month_"+i) != -1 && mandatoryFields.indexOf("expire_year_"+i) != -1 && document.getElementById("expire_month_"+i) != null && document.getElementById("expire_year_"+i) != null)
					&& now >= expiry) {
				MessageHelper.displayErrorMessage(this.errorMessages["EDPPaymentMethods_INVALID_EXPIRY_DATE"]);
				return false;
			} else if (formName.piAmount != null && formName.piAmount.value == "") {
				MessageHelper.formErrorHandleClient(formName.piAmount_display,this.errorMessages["EDPPaymentMethods_NO_AMOUNT"]);
				return false;
			} else if (formName.piAmount != null && isNaN(formName.piAmount.value)) {
				MessageHelper.formErrorHandleClient(formName.piAmount_display,this.errorMessages["EDPPaymentMethods_AMOUNT_NAN"]);
				return false;
			} else if (mandatoryFields.indexOf("check_routing_number_"+i) != -1 && document.getElementById("check_routing_number_"+i) != null && document.getElementById("check_routing_number_"+i).value == "") {
				MessageHelper.displayErrorMessage(this.errorMessages["EDPPaymentMethods_NO_ROUTING_NUMBER"]);
				return false;
			}
			else if (mandatoryFields.indexOf("CheckAccount_"+i) != -1 && document.getElementById("CheckAccount_"+i) != null && document.getElementById("CheckAccount_"+i).value == "") {
				MessageHelper.displayErrorMessage(this.errorMessages["EDPPaymentMethods_NO_BANK_ACCOUNT_NO"]);
				return false;
			}
			else if (mandatoryFields.indexOf("billing_address_id") != -1 && formName.billing_address_id != null && (formName.billing_address_id.value == "" || formName.billing_address_id.value == "-1")) {
				MessageHelper.displayErrorMessage(this.errorMessages["EDPPaymentMethods_NO_BILLING_ADDRESS"]);
				return false;
			} else if (CheckoutHelperJS.isPaymentDataDirty(i) && mandatoryFields.indexOf("cc_cvc_"+i) != -1 && document.getElementById("cc_cvc_"+i) != null && this.trim(document.getElementById("cc_cvc_"+i).value)!= null && this.trim(document.getElementById("cc_cvc_"+i).value)!= ""){
				if (!this.isNumber(document.getElementById("cc_cvc_"+i).value)) {
					MessageHelper.displayErrorMessage(this.errorMessages["EDPPaymentMethods_CVV_NOT_NUMERIC"]);
					return false;
				}
			}
		}

		if (!this.isBillingAddressValid(formNamePrefix)) {
			MessageHelper.displayErrorMessage(this.errorMessages["EDPPaymentMethods_BILLING_ADDRESS_INVALID"]);
			return false;
		}

		if (!CheckoutHelperJS.isSinglePageCheckout() && !this.validatePaymentTotals(formNamePrefix)) {
			return false;
		}
		return true;
	},

	/**
	* Updates existingPiId element of the payment form passed in
	* @param {String} piFormName Form name of the payment form
	* @param {String} piId
	*/
	updateExistingPiId:function(piFormName,piId){
		if(piFormName != null){
			var formName = document.forms[piFormName+1];
			formName.existingPiId.value = piId;
		}
	},

	/**
	* This function updates the given params object with Key value pair.
	* If the toArray value is true, It creates an Array for duplicate entries. Else, It overwrites the old value.
	* It is useful while making a service call which excepts few paramters of type array
	* @param {Object} params array holding parameters
	* @param {String} key Key to store and retrieve the parameter
	* @param {String} value	Value of the parameter
	* @param {Boolean} toArray If true, creates an Array for duplicate entries. If false, does not creat an
	* Array for duplicate entries. It overwrites the old value.
	* @return	{Object} params A JavaScript Object having key - value pair.
	*/
	updateParamObject:function(params, key, value, toArray, index){
	   if(params == null){
		   params = [];
	   }

	   if(params[key] != null && toArray)
	   {
			if($.isArray(params[key]))
			{
				//3rd time onwards
				if(index != null && index != "")
				{
					//overwrite the old value at specified index
					 params[key][index] = value;
				}
				else
				{
					params[key].push(value);
				 }
			}
			else
			{
				 //2nd time
				 var tmpValue = params[key];
				 params[key] = [];
				 params[key].push(tmpValue);
				 params[key].push(value);
			}
	   }
	   else
	   {
			//1st time
		   if(index != null && index != "" && index != -1)
		   {
			  //overwrite the old value at specified index
			  params[key+"_"+index] = value;
		   }
		   else if(index == -1)
		   {
			  var i = 1;
			  while(params[key + "_" + i] != null)
			  {
				   i++;
			  }
			  params[key + "_" + i] = value;
		   }
		   else
		   {
			  params[key] = value;
			}
	   }
	   return params;
	 },

	/**
	* Save the selected address in billingAddressDropDownBoxContext,so that we can reselect this when the billing address
	* drop down box is refreshed. Billing address drop down box is refreshed on create New billing address action.
	* @param {String} actionType Type of action to be performed (e.g. edit)
	* @param {String} paymentArea The payment area number for this function to work on.
	*/
	saveBillingAddressDropDownBoxContextProperties:function(actionType,paymentArea){
		for(var i = 1; i < 4; i++){
			var form = document.forms["PaymentForm"+i];
			if(form) {
				if(form.billing_address_id != null){
					var selectedBillingAddress = form.billing_address_id.value;
					if (actionType == 'create' && paymentArea == i) {
						//creating a new address here. make selectedBillingAddress to -1 to indicated that the payment area needs to be refreshed later
						selectedBillingAddress = "-1";
					}
					wcRenderContext.getRenderContextProperties("billingAddressDropDownBoxContext")["billingAddress"+i] = selectedBillingAddress;
				}
			} else if(form == null && i > 1) {
				//do nothing it is fine
			} else {
				return;
			}
		}

		if(actionType == 'edit'){
			//If its edit, then set the billingAddress property to -1 for all the billing address select boxes, which has edited address selected.
			//so that the new addressId is selected...
			//Otherwise we would have saved old addressId and this old addressId doesnt exist anymore, since addressId changes on edit..
			var form = document.forms["PaymentForm"+paymentArea];
			if (form) {
				var selectedBillingAddress = form.billing_address_id.value;
				for(var i = 1; i < 4; i++){
					var form1 = document.forms["PaymentForm"+i];
					if (form1) {
						var selectedBillingAddress1 = form1.billing_address_id.value;
						if(selectedBillingAddress1 == selectedBillingAddress){
							wcRenderContext.getRenderContextProperties("billingAddressDropDownBoxContext")["billingAddress"+i] = "-1";
						}
					}
				}
			}
		}
	},

	/**
	* helper function to create a new billing address
	* @param {String} paymentAreaNumber The payment area number for this function to work on.
	* @param {String} addressType Value to pass to createAddress function. Address type of the address to be created.
	*/
	createBillingAddress:function(paymentAreaNumber,addressType){
		this.saveBillingAddressDropDownBoxContextProperties('create',paymentAreaNumber);
		CheckoutHelperJS.createAddress(-1,addressType);
	},

	/**
	* Displays detail information of the billing address
	* @param {String} addressSelectBox HTML dropdown box that contains billing address selection
	* @param {String} paymentAreaNumber The payment area number for this function to work on.
	* @param {String} addressType Value to pass to createAddress function. Address type of the address to be created.
	*/
	displayBillingAddressDetails:function(addressSelectBox,paymentAreaNumber,addressType){
		if(addressSelectBox.value != -1){
			document.getElementById("selectedAddressId_"+paymentAreaNumber).value = addressSelectBox.value;
		}

		//Also save the selected address in billingAddressDropDownBoxContext,so that we can reselect this when the billing address
		//drop down box is refreshed...Billing address drop down box is refreshed on create New billing address action...
		this.saveBillingAddressDropDownBoxContextProperties('create','-1');

		if(addressSelectBox.value != -1){
			//Display selected address details..
			var addressKey = "billingAddress" + paymentAreaNumber;
			wcRenderContext.updateRenderContext('billingAddressDropDownBoxContext', {addressKey:addressSelectBox.value, 'areaNumber':paymentAreaNumber});
		}

	},
	/**
	 * returns the current total of the order in a JSON object.
	 * @param {String} operation Identifies where this method is being called from, to determine the processing after.
	 * @param {String} ipFormName Name of the payment form containing payment data
	 * @param {Boolean} skipOrderPrepare Indicates if Order Prepare process should be skipped.
	 */
	getTotalInJSON: function (operation, piFormName, skipOrderPrepare) {
		var parameters = {};
		parameters.operation = operation;
		parameters.piFormName = piFormName;
		parameters.skipOrderPrepare = skipOrderPrepare;
		parameters.storeId = this.storeId;
		parameters.catalogId = this.catalogId;
		parameters.langId = this.langId;
		var url = appendWcCommonRequestParameters("orderTotalAsJSON");
		wcTopic.publish("ajaxRequestInitiated");
		$.ajax({
				url: url,
				method: "POST",
				dataType: "json",
				data: parameters,
				context: this,
				success: CheckoutPayments.updateAmountFieldsWithTotalInJSON,
				error: function(jqXHR, textStatus, error) {
					console.debug("error - inside CheckoutPayments.getTotalInJSON()");
					console.debug(error);
					wcTopic.publish("ajaxRequestCompleted");
				}
		});
	},

	/**
	 * This is helper function for updateAmountFields. It retrieves the total from a JSON object and passes it to updateAmountFields.
	 * @param {Object} The data returned from $.ajax, formatted according to the dataType parameter or the dataFilter callback function, if specified
	 * @param {String} A string describing the status of the $.ajax call
	 * @param {Object} The jqXHR (in jQuery 1.4.x, XMLHttpRequest) object from $.ajax
	 */
	updateAmountFieldsWithTotalInJSON:function(data, textStatus, jqXHR){
		if (data != null && data != undefined) {
			 CheckoutPayments.updateAmountFields(data.orderTotal, data.operation, data.piFormName,data.skipOrderPrepare );
		}
		wcTopic.publish("ajaxRequestCompleted");
	},

	/**
	* This functions calculates payment amount value of each payment area
	* @param {String} updatedTotal The grand total of the order
	* @param {String} operation Identifies where this method is being called from, to determine the processing after.
	* @param {String} ipFormName Name of the payment form containing payment data
	* @param {String} skipOrderPrepare Indicates if Order Prepare process should be skipped.
	*/
	updateAmountFields:function(updatedTotal, operation, piFormName, skipOrderPrepare){
		var totalPayments = 0;
		var formName;
		var currentTotal = 0.0;
		this.numberOfPaymentMethods = document.getElementById("numberOfPaymentMethods").value;
		if(document.getElementById("OrderTotalAmount") != null){
			document.getElementById("OrderTotalAmount").value = updatedTotal;
		}
		if(this.numberOfPaymentMethods == 1){
			formName = document.forms["PaymentForm1"];
			if (formName.piAmount != null && formName.piAmount.value != "" && !isNaN(formName.piAmount.value)){
				formName.piAmount.value = updatedTotal;
				formName.piAmount_display.value = updatedTotal;
				this.formatAmountDisplayForLocale("1");
				if(this.retrievePaymentObject(1) != null){
					this.updatePaymentObject(1, 'piAmount');
				}
			}
			if(operation != undefined && operation == 'OrderPrepare'){
				this.processPIAndCheckout(piFormName,skipOrderPrepare);
			} else if ((operation != undefined && operation == 'loadPaymentSnippet') || supportPaymentTypePromotions) {
				if (this.currentPaymentMethodChanged) {
					this.loadPaymentSnippet(document.getElementById("payMethodId_" + this.currentPaymentMethodChanged), this.currentPaymentMethodChanged);
					this.updatePaymentObject(this.currentPaymentMethodChanged, 'payMethodId');
				}
			}

			return;
		}

		for (var i=1; i<=this.numberOfPaymentMethods; i++) {
			formName = document.forms["PaymentForm"+i];
			if (formName.piAmount != null && formName.piAmount.value != "" && !isNaN(formName.piAmount.value)){
				currentTotal = (currentTotal) * (1) + (formName.piAmount.value) * (1);
			}
		}

		var difference = updatedTotal - currentTotal;
		difference = Math.round(difference*100)/100;

		if(difference > 0){
			//So difference is > 0.. order total is increased.. add this to last payment..
			var j = this.numberOfPaymentMethods;
			formName = document.forms["PaymentForm"+j];
			if (formName.piAmount != null && formName.piAmount.value != "" && !isNaN(formName.piAmount.value)){
				formName.piAmount.value = parseFloat(formName.piAmount.value) + parseFloat(difference);
				formName.piAmount_display.value = formName.piAmount.value;
				this.formatAmountDisplayForLocale(j);
				if(this.retrievePaymentObject(j) != null){
					this.updatePaymentObject(j, 'piAmount');
				}
			}
		}
		else{
			//The order total is decreased..remove it from last payment..if last payment goes negative, then set it to 0 and remove remaining from last but one...and so on..
			difference = difference * -1;
			for(var k = this.numberOfPaymentMethods; k > 0; k--){
				formName = document.forms["PaymentForm"+k];
				if (formName.piAmount != null && formName.piAmount.value != "" && !isNaN(formName.piAmount.value)){
					if(formName.piAmount.value > difference){
						var t = formName.piAmount.value - difference;
						formName.piAmount.value = Math.round(t*100)/100;
						formName.piAmount_display.value = formName.piAmount.value;
						this.formatAmountDisplayForLocale(k);
						if(this.retrievePaymentObject(k) != null){
							this.updatePaymentObject(k, 'piAmount');
						}
						difference = 0;
						break;
					}
					else{
						//Set this payment to 0 and decrease the difference...
						difference = difference - formName.piAmount.value;
						formName.piAmount.value = 0;
						if(this.retrievePaymentObject(k) != null){
							this.updatePaymentObject(k, 'piAmount');
						}
						this.formatAmountDisplayForLocale(k);
					}
				}
			}
		}
		if(operation != undefined && operation == 'OrderPrepare'){
			this.processPIAndCheckout(piFormName,skipOrderPrepare);
		} else if (operation != undefined && operation == 'loadPaymentSnippet') {
			if (this.currentPaymentMethodChanged ) {
				this.loadPaymentSnippet(document.getElementById("payMethodId_" + this.currentPaymentMethodChanged), this.currentPaymentMethodChanged);
				this.updatePaymentObject(this.currentPaymentMethodChanged, 'payMethodId');
			}
		}
	},


	/**
	 * Removes the credit card number and the security code from the given payment area.
	 * @param {Integer} paymentAreaNumber The payment area number.
	 * @param {Boolean} removeCardNumber A true or false value to indicate if the credit card number should be removed from the payment form.
	 * @param {Boolean} removeCVV A true or false value to indicate if the credit card security code should be removed from the payment form.
	 */
	removeCreditCardNumberAndCVV: function(paymentAreaNumber, removeCardNumber, removeCVV){
		if(!CheckoutHelperJS.isPaymentDataDirty(paymentAreaNumber)){
			if(removeCardNumber){
				if(document.forms["PaymentForm" + paymentAreaNumber].valueFromProfileOrder == null || document.forms["PaymentForm" + paymentAreaNumber].valueFromProfileOrder.value != 'Y'){
					if($("#account1_" + paymentAreaNumber).length){
						$("#account1_" + paymentAreaNumber).val("");
					}
				}
			}
			if(removeCVV){
				if($("#cc_cvc_" + paymentAreaNumber).length){
					$("#cc_cvc_" + paymentAreaNumber).val("");
				}
			}
		}
	},

	/**
	 * Initializes the payment area dirty flags when the order shipping & billing page is loaded.
	 */
	initializePaymentAreaDataDirtyFlags: function(){
		CheckoutHelperJS.dataDirty[1] = false;
		CheckoutHelperJS.dataDirty[2] = false;
		CheckoutHelperJS.dataDirty[3] = false;
	},

	/**
	 * Initializes the master payment objects array when the order shipping & billing page is loaded.
	 */
	initializeOverallPaymentObjects: function(){
		this.prevNumberOfPaymentMethods = document.getElementById('numberOfPaymentMethods').value;
		this.numberOfPaymentMethods = parseInt($("#numberOfPaymentMethods").val());
		var maxNumberOfPaymentMethodsSupported = parseInt(this.maxNumberOfPaymentMethodsSupported);

		for(var i=1; i<=maxNumberOfPaymentMethodsSupported; i++){
			this.initializePaymentObject(i);
		}

		var piIds = document.forms["PaymentForm1"].existingPiId.value;
		var unboundpiIds = null;
		if (document.forms["PaymentForm1"].unboundPiId) {
			unboundpiIds = document.forms["PaymentForm1"].unboundPiId.value;
			if(unboundpiIds != null && unboundpiIds != ""){
				var unboundpiArray = unboundpiIds.split(",");
			}
		}
		if(piIds != null && piIds != ""){
			var piArray = piIds.split(",");
			for(var i=0; i<piArray.length; i++){
				var paymentObjIndex = i+1;
				this.retrievePaymentObject(paymentObjIndex)['piId'] = piArray[i];
				document.forms["PaymentForm" + (paymentObjIndex)].piId.value = piArray[i];
				if(paymentObjIndex > this.numberOfPaymentMethods){
					// If regular payment instructions had already been registered with the order, then user goes back to the shopping cart page and chooses quick checkout,
					// and since only the payment defined in quick checkout profile would be displayed on the shipping & billing page, then the rest of payments that have been registered with the order need to be deleted.
					this.retrievePaymentObject(paymentObjIndex)['action'] = 'delete';
				}
				if(supportPaymentTypePromotions && unboundpiIds != null && unboundpiIds != ""){
					for(var j=0; j<unboundpiArray.length; j++){
						if (this.retrievePaymentObject(paymentObjIndex)['piId'] == unboundpiArray[j]) {
							this.retrievePaymentObject(paymentObjIndex)['action'] = 're-add';
							break;
						}
						}
				}
			}
		}else{
			this.retrievePaymentObject(1)['action'] = 'add';
		}
		// does quick checkout profile or payInStore qualify for payment type promotion?
		if(supportPaymentTypePromotions && 
				(this.getValue(document.forms['PaymentForm1'],"valueFromProfileOrder") == "Y" || this.getValue(document.forms['PaymentForm1'],"payMethodId") == "PayInStore"
					)){
			if(requestSubmitted){
				// 'requestSubmitted' will be set to false upon whole page loaded, listen to value change of 'requestSubmitted'
				this['updatePaymentTypePromotionForProfileCheckoutHandler'] = wcTopic.subscribe("requestSubmittedChanged", function(isRequestSubmitted) {
					if (!isRequestSubmitted ) {
						CheckoutPayments['updatePaymentTypePromotionForProfileCheckoutHandler'].remove();
						CheckoutPayments.updateUnboundPaymentToOrder();
					}
				});
			} else {
				this.updateUnboundPaymentToOrder();
			}
		}
	},

	/**
	 * Initializes a payment object for the given payment area.
	 * @param {Integer} paymentAreaNum The payment area number.
	 */
	initializePaymentObject: function(paymentAreaNum){
		var paymentObj = new Array();
		paymentObj['piId'] = "";
		paymentObj['action'] = "";
		paymentObj['fields'] = new Array();
		paymentObj['options'] = "";
		this.storePaymentObject(paymentAreaNum, paymentObj);
	},

	/**
	 * Stores the given payment object and its payment area number into the master payment objects array.
	 * @param {Integer} paymentAreaNum The payment area number.
	 * @param {Object} payObj The payment object to store.
	 */
	storePaymentObject: function(paymentAreaNum, payObj){
		this.paymentObjects[paymentAreaNum] = payObj;
	},

	/**
	 * Retrieves payment object associated with the given payment area number from the master payment objects array.
	 * @param {Integer} paymentAreaNum The payment area number.
	 * @return {Object} paymentObject The payment object associated with the given area number.
	 */
	retrievePaymentObject: function(paymentAreaNum){
		return this.paymentObjects[paymentAreaNum];
	},

	/**
	 * Updates the properties in a payment object.
	 * @param {Integer} paymentAreaNum The payment area number.
	 * @param {String} field The field that was changed by a user on the page.
	 */
	updatePaymentObject: function(paymentAreaNum, field){
		var paymentObj = this.retrievePaymentObject(paymentAreaNum);

		if(paymentObj != null){
			console.debug(field + " was changed.");
			if(paymentObj['piId'] == ''){
				paymentObj['action'] = 'add';
				console.debug("The action property in the payment object associated with payment area " + paymentAreaNum + " was updated to 'add'.");
			}else{
				if(field == 'piAmount' && paymentObj['action'] != 'add' && paymentObj['action'] != 'delete' && paymentObj['action'] != 're-add'){
					/*BRAINTREE START*/
					if(paymentObj['action'] == '')
						paymentObj['action'] = 're-add';
					else
						paymentObj['action'] = 'update';
					/*BRAINTREE END*/
					console.debug("The action property in the payment object associated with payment area " + paymentAreaNum + " was updated to 'update'.");
				}else{
					// For changes in fields other than piAmount, the existing payment instruction needs to be deleted first, then a new payment instruction will be created.
					paymentObj['action'] = 're-add';
					console.debug("The action property in the payment object associated with payment area " + paymentAreaNum + " was updated to 're-add'.");
				}
			}

			if(field == 'piAmount'){
				var thisFieldExists = false;
				for(var i=0; i< paymentObj['fields'].length; i++){
					if(paymentObj['fields'][i] == field){
						thisFieldExists = true;
						break;
					}
				}
				if(!thisFieldExists){
					paymentObj['fields'].push(field);
				}
			}
		}else{
			console.debug("CheckoutPayemnts.updatePaymentObject -- payment object not found.");
		}
	},

	/**
	 * Stores the payment area number of the payment instruction that needs to be deleted.
	 * @param {Integer} paymentAreaNumber The payment area number of a payment instruction.
	 */
	setPaymentsToDelete: function(paymentAreaNumber){
		this.paymentsToDelete.push(paymentAreaNumber);
	},

	/**
	 * Retrieves the array containing the payment area numbers of all payment instructions that need to be deleted.
	 * @return {Array} paymentsToDelete The array that contains the payment area numbers.
	 */
	getPaymentsToDelete: function(){
		return this.paymentsToDelete;
	},

	/**
	 * Stores the payment area number of the payment instruction that needs to be added.
	 * @param {Integer} paymentAreaNumber The payment area number of a payment instruction.
	 */
	setPaymentsToAdd: function(paymentAreaNumber){
		this.paymentsToAdd.push(paymentAreaNumber);
	},

	/**
	 * Retrieves the array containing the payment area numbers of all payment instructions that need to be added.
	 * @return {Array} paymentsToDelete The array that contains the payment area numbers.
	 */
	getPaymentsToAdd: function(){
		return this.paymentsToAdd;
	},

	/**
	 * Stores the payment area number of the payment instruction that needs to be added.
	 * @param {Integer} paymentAreaNumber The payment area number of a payment instruction.
	 */
	setPaymentsToUpdate: function(paymentAreaNumber){
		this.paymentsToUpdate.push(paymentAreaNumber);
	},

	/**
	 * Retrieves the array containing the payment area numbers of all payment instructions that need to be added.
	 * @return {Array} paymentsToDelete The array that contains the payment area numbers.
	 */
	getPaymentsToUpdate: function(){
		return this.paymentsToUpdate;
	},


	/**
	 * Deletes payment instruction(s) from the current order.
	 */
	deletePaymentInstructions: function(){
		var params = [];
		params["piId"] = new Array();
		if (this.getPaymentsToDelete().length > 0) {
			var paymentAreaNumber = this.getPaymentsToDelete().pop();
			params["piId"].push(document.forms["PaymentForm" + paymentAreaNumber].piId.value);
			params["storeId"] = this.storeId;
			params["catalogId"] = this.catalogId;
			params["paymentAreaNumber"] = paymentAreaNumber;
			params["langId"] = this.langId;
			if(document.forms["PaymentForm1"].authToken != null){
				params["authToken"] = document.forms["PaymentForm1"].authToken.value;
			}
			params.orderId = ".";
		}
		if(!submitRequest()){
			return;
		}
		cursor_wait();
		wcService.invoke('AjaxDeletePaymentInstructionFromThisOrder',params);
	},

	/**
	 * Adds payment instruction(s) to the current order.
	 */
	addPaymentInstructions: function(){
		var params = [];
		if(this.getPaymentsToAdd().length > 0) {
			var paymentAreaNumber = this.getPaymentsToAdd().pop();
			var form = document.forms["PaymentForm" + paymentAreaNumber];
			params = this.populateProtocolData(form,params);
		}
		if(!submitRequest()){
			return;
		}
		cursor_wait();
		wcService.invoke('AjaxAddPaymentInstructionToThisOrder',params);
	},

	/**
	 * Updates payment instruction(s) in the current order.
	 */
	updatePaymentInstructions: function(){
		var params = [];
		if(this.getPaymentsToUpdate().length > 0){
			var paymentAreaNumber = this.getPaymentsToUpdate().pop();
			var form = document.forms["PaymentForm" + paymentAreaNumber];
			var paymentObj = this.retrievePaymentObject(paymentAreaNumber);
			paymentObj['fields'].push('storeId');
			paymentObj['fields'].push('catalogId');
			paymentObj['fields'].push('langId');
			paymentObj['fields'].push('piId');
			paymentObj['fields'].push('payMethodId');
			paymentObj['fields'].push('authToken');
			paymentObj['fields'].push('orderId');
			document.forms["PaymentForm" + paymentAreaNumber].paymentDataEditable.value = false;
			paymentObj['fields'].push('paymentDataEditable');

			params = this.populateProtocolDataForGivenFields(form,params,paymentObj['fields']);
		}
		if(!submitRequest()){
			return;
		}
		cursor_wait();
		wcService.invoke('AjaxUpdatePaymentInstructionInThisOrder',params);
	},

	/**
	 * Updates the payment objects on the page when the number of payment methods is changed by a user.
	 * @param {Object} numberOfPaymentMethodsField The select drop-down object on the page that contains the number of payment methods.
	 */
	reinitializePaymentObjects: function(numberOfPaymentMethodsField){
		//Payment type promotion: call the updateUnboundPaymentToOrder() function
		if(supportPaymentTypePromotions){
			this.updateUnboundPaymentToOrder();
		}

		var currentNumberOfPaymentMethods = parseInt(numberOfPaymentMethodsField.value);
		var prevNumberOfPaymentMethods = parseInt(this.prevNumberOfPaymentMethods);
		var maxNumberOfPaymentMethodsSupported = parseInt(this.maxNumberOfPaymentMethodsSupported);
		if(currentNumberOfPaymentMethods < prevNumberOfPaymentMethods){
			for(var i=currentNumberOfPaymentMethods+1; i<=maxNumberOfPaymentMethodsSupported; i++){
				var paymentObj = this.retrievePaymentObject(i);
				if(paymentObj['piId'] == ''){
					paymentObj['action'] = '';
				}else{
					paymentObj['action'] = 'delete';
					console.debug("The action in the payment object associated with payment area " + i + " was updated to 'delete'.");
				}
			}
		}else if(currentNumberOfPaymentMethods > prevNumberOfPaymentMethods){
			for(var i=prevNumberOfPaymentMethods+1; i<=maxNumberOfPaymentMethodsSupported; i++){
				var paymentObj = this.retrievePaymentObject(i);
				if (paymentObj['piId'] != '') {
					// payment object has a piId, so it exists in the database and is not really a new payment object
					if (i > currentNumberOfPaymentMethods && i <=maxNumberOfPaymentMethodsSupported) {
						// delete any payment objects that exist beyond the current number of payment methods
						paymentObj['action'] == 'delete';
						console.debug("The action in the payment object associated with payment area " + i + " was updated to 'delete'.");
					}
					else {
						// re-add any payment objects that exist within the current number of payment methods
						paymentObj['action'] == 're-add';
						console.debug("The action in the payment object associated with payment area " + i + " was updated to 're-add'.");
					}
				}
				else {
					// payment object does not have a piId, so it really is a new payment object
					this.initializePaymentObject(i);
					console.debug("A new payment object was initialized to be associated with payment area " + i + ".");
				}

			}
		}
		this.prevNumberOfPaymentMethods = currentNumberOfPaymentMethods;
	},

	/**
	 * Payment type promotion - START
	 */

	/**
	 * Sets the value of the piId parameter in PaymentForm1 to the passed value.
	 * @param {Integer} piId The piId to set in PaymentForm.
	 * @param {Integer} paymentArea The payment area number for the Payment form.
	 */
	setPaymentFormPiId: function(paymentArea,piId){
	   var formObj = document.forms['PaymentForm'+ paymentArea];
	   if (formObj){
		   //payInStore only have 1 form
		   formObj["piId"].value = piId;
	   }
	},

	/**
	 * Adds or removes an unbounded payment to/from the current order.
	 * An unbound payment is a dummy/temporary payment instruction added to
	 * an order without any of its protocol data information.
	 *
	 * The function is invoked when numberOfPaymentMethods or payment method is chosen/changed.
	 * The function works in following way:
	 * 1. the method try to delete all payment instructions and clear all payment objects first
	 * 2. upon the deletion of existing payment instructions, a new dummy payment instruction
	 * 	  will be added if <code>isSinglePaymentType</code> return <code>true</code>, the function
	 *	  <code>addNewUnboundPaymentInstruction</code> will be invoked. See also
	 *	  <code>AjaxDeleteUnboundPaymentInstructionFromThisOrder</code> for detail.
	 * 3. if <code>isSinglePaymentType</code> return <code>false</code>, leave the order without
	 *    any payment instruction.
	 * 4. upon adding or deleting of payment instruction. The service
	 *    <code>AjaxPrepareOrderForPaymentSubmit</code> will be invoked to determine if
	 *    the order qualify for payment type promotion.
	 */
	updateUnboundPaymentToOrder: function(paymentMethodChanged){
		this.currentPaymentMethodChanged = paymentMethodChanged;
		 var form1 = document.forms["PaymentForm1"];
		 var piIdForm1 = this.getValue(form1, "piId");
			 // If payment methods existed already, delete it.
		 if(piIdForm1 != null && piIdForm1 != ""){
			var params = [];
			params.storeId = this.storeId;
			params.catalogId = this.catalogId;
			params.langId = this.langId;
			params.orderId = ".";
			params.piId = "";
			if(!submitRequest()){
				 return;
			}
			cursor_wait();
			wcService.invoke('AjaxDeleteUnboundPaymentInstructionFromThisOrder', params);
		 } else if (this.isSinglePaymentType()) {
			this.addNewUnboundPaymentInstruction();
		 } else if (paymentMethodChanged ){
			this.loadPaymentSnippet(document.getElementById("payMethodId_" + paymentMethodChanged), paymentMethodChanged);
			this.updatePaymentObject(paymentMethodChanged, 'payMethodId');
		 }
	},

	/**
	 * Adds a new unbounded payment method to the order. An unbound payment is a
	 * dummy/temporary payment instruction added to an order without any of its
	 * protocol data information. Only add unbounded payment method when all
	 * selected payment types are same.
	 */
	addNewUnboundPaymentInstruction: function(){
	   var form = document.forms["PaymentForm1"];
	   var params = [];
	   params.storeId = this.storeId;
	   params.catalogId = this.catalogId;
	   params.langId = this.langId;
	   if(document.forms["PaymentForm1"].authToken != null){
			params["authToken"] = document.forms["PaymentForm1"].authToken.value;
	   }

	   params["payMethodId"] = this.getValue(form,"payMethodId",true);
	   params["unbound"] = true;

	   if(params["payMethodId"] != "empty" && params["payMethodId"] != ""){
		  if(!submitRequest()){
			return;
		  }
		  cursor_wait();
		  wcService.invoke('AjaxAddUnboundPaymentInstructionToThisOrder', params);
	   }

   },

   /**
	 * Check whether the all selected payment types are same or not
	 * @return {boolean} true if selected payment types are same, false otherwise
	 */
   isSinglePaymentType: function() {
		var form = document.forms["PaymentForm1"];
		var fistFormPayType = this.getValue(form,"payMethodId");
		var isSinglePaymentType = fistFormPayType != "empty" && fistFormPayType != "";
		for (var i = 2; isSinglePaymentType && i <= this.numberOfPaymentMethods; i++) {
			var currentPaymentForm = document.forms["PaymentForm" + i];
			var currntPayType = this.getValue(currentPaymentForm,"payMethodId")
			isSinglePaymentType = currntPayType == fistFormPayType;
		}
		return isSinglePaymentType;
   }
  /**
   * Payment type promotion - END
   */
}
