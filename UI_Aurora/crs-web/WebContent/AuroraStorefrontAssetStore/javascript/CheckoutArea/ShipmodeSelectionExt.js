//-----------------------------------------------------------------
//  Licensed Materials - Property of HCL Technologies                 
//
// HCL Commerce
//
//  (C) Copyright HCL Technologies Limited 1996, 2020                 
//
//-----------------------------------------------------------------

/**
 * @fileOverview This javascript handles different actions to perform after shopper selects to proceed with checkout.
 * In summary, user can have different logon status and user can select different shopping option (buy online or 
 * pick up at store). 
 * A user can have the following logon status:
 * 1. Shopper is a guest user
 * 2. Shopper has a commerce account but is not yet logged on (and would like to log on before user proceeds with
 *    shopping flow)
 * 3. Shopper is already logged on
 * In addition, user can select different shipping options:
 * 1. Shop online
 * 2. Pick up at store
 * Every logon status/shipping selection combination as mentioned above will be handled in this javascript
 */

ShipmodeSelectionExtJS = {	
	/** language id used by the store, default to -1 (English) */
	langId: "-1",
	/** store id of the store */
	storeId: "",
	/** catalog id of the store */
	catalogId: "",		
	/** indicates if BOPIS feauture is enabled or not */
	BOPISEnabled: false,
	/** Order item ID of an order item in the current order. This is needed for RESTOrderItemUpdate to call DoInventoryActionCmd to get fulfillment center ID **/
	orderItemId : "",
	
	/**
	* Indicates if "Pick up in store" shipping option is selected by shopper
	*/
	isPickUpInStore: function() {
		var shipType = this.getShipTypeValue();
		if (shipType == "pickUp") {
			return true;
		} else {
			return false;
		}
	},
	
	/**
	* Gets the shipType value from the document.BOPIS_FORM form.
	*/
	getShipTypeValue: function() {
		if (document.BOPIS_FORM != undefined){	
			for (var i=0; i < document.BOPIS_FORM.shipType.length; i++) {
			   if (document.BOPIS_FORM.shipType[i].checked) {
				  return document.BOPIS_FORM.shipType[i].value;
				  }
			   }
		}  
	},

	/**
	 * This function retrieves the shipment type value for the current order from the cookie.  If no shipment type value for the 
	 * current order is found in the cookie, empty string is returned.
	 *
	 * @param {String} orderId The order ID.
	 * 
	 * @returns {String} The shipment type value.
	 *
	 */
	getShipTypeValueFromCookieForOrder:function(orderId) {
		var shipTypeValueOrderId = getCookie("WC_shipTypeValueOrderId");
		if (shipTypeValueOrderId == orderId) {
			var shipTypeValue = getCookie("WC_shipTypeValue");
			return shipTypeValue;
		} else {
			return "";
		}
	},

	/**
	 * This function adds or updates the shipment type value for the current order to the cookie.
	 *
	 * @param {String} value The new pick up store ID. 
	 * @param {String} orderId The order ID.
	 *
	 */
	setShipTypeValueToCookieForOrder:function(value, orderId) {
		var newShipTypeValue = value;
		if (newShipTypeValue != null && newShipTypeValue != "undefined" && newShipTypeValue != "") {
			var shipTypeValueOrderId = getCookie("WC_shipTypeValueOrderId");
			if (shipTypeValueOrderId != orderId) {
				setCookie("WC_shipTypeValueOrderId", null, {expires: -1});
				setCookie("WC_shipTypeValueOrderId", orderId, {path: "/", domain: cookieDomain});
			}
			var currentShipTypeValue = this.getShipTypeValueFromCookieForOrder(orderId);
			if (newShipTypeValue != currentShipTypeValue) {
				setCookie("WC_shipTypeValue", null, {expires: -1});
				setCookie("WC_shipTypeValue", newShipTypeValue, {path: "/", domain: cookieDomain});
			}
		}
		//select the proper options that are saved in context
		if (newShipTypeValue == "pickUp") {
			if (document.getElementById("scheduling_options")) {
				document.getElementById("scheduling_options").style.display="none";
				setCookie("WC_recurringOrder_"+orderId, "false", {path: "/", domain: cookieDomain});
				if (document.getElementById("recurringOrder")) {
					document.getElementById("recurringOrder").checked = false;
				}
				this.hideShowNonRecurringOrderMsg(orderId);
			}
			/*BRAINTREE START*/ 
			document.getElementById("paypalCheckoutInCart").style.display="none";
			/*BRAINTREE END*/ 
		} else if (newShipTypeValue == "shopOnline") {
			if (document.getElementById("scheduling_options")) {
				document.getElementById("scheduling_options").style.display="block";
				this.hideShowNonRecurringOrderMsg(orderId);
			}
			/*BRAINTREE START*/ 
			document.getElementById("paypalCheckoutInCart").style.display="grid";
			/*BRAINTREE END*/ 
		}
	},

	/**
	 * This function select the proper shipmode in the shopping cart page that is saved in the cookie.
	 *
	 * @param {String} orderId The order identifier of the current shopping cart. 
	 *
	 */
	displaySavedShipmentTypeForOrder:function(orderId) {
		var shipTypeValueOrderId = getCookie("WC_shipTypeValueOrderId");
		if (shipTypeValueOrderId != orderId) {
			setCookie("WC_shipTypeValueOrderId", null, {expires: -1});
			setCookie("WC_shipTypeValue", null, {expires: -1});
		} else {
			var currentShipTypeValue = this.getShipTypeValueFromCookieForOrder(orderId);
				
			//select the proper shipmode that is saved in context
			if (currentShipTypeValue == "pickUp") {
				if(document.getElementById("shipTypePickUp").disabled == false){
						document.getElementById("shipTypePickUp").checked = true;
						if (document.getElementById("scheduling_options")) {
							document.getElementById("scheduling_options").style.display="none";
							setCookie("WC_recurringOrder_"+orderId, "false", {path: "/", domain: cookieDomain});
							if (document.getElementById("recurringOrder")) {
								document.getElementById("recurringOrder").checked = false;
							}
						}/*BRAINTREE START*/ 
						document.getElementById("paypalCheckoutInCart").style.display="none";
						/*BRAINTREE END*/ 
				}else{
						document.getElementById("shipTypeOnline").checked = true;
						if (document.getElementById("scheduling_options")) {
							document.getElementById("scheduling_options").style.display="block";
						}
						this.setShipTypeValueToCookieForOrder("shopOnline", orderId);
						/*BRAINTREE START*/ 
						document.getElementById("paypalCheckoutInCart").style.display="block";
						/*BRAINTREE END*/ 
				}
			} else if (currentShipTypeValue == "shopOnline") {
				document.getElementById("shipTypeOnline").checked = true;
				if (document.getElementById("scheduling_options")) {
					document.getElementById("scheduling_options").style.display="block";
				}
				/*BRAINTREE START*/ 
				document.getElementById("paypalCheckoutInCart").style.display="grid";
				/*BRAINTREE END*/ 
			}
		}
		this.hideShowNonRecurringOrderMsg(orderId,true);
	},

	/**
	 * This function is used to show all the cues to the shopper when in the shopping cart page. It shows messages for the following:
	 * - guest shopper attempting to checkout a recurring order
	 * - it flags non recurring items when attempting to checkout as a recurring order
	 *
	 * @param {String} orderId 			The order identifier of the current shopping cart. 
	 * @param {String} fromPageLoad Tells if this function is called on a page load, which does not need the error message to show.
	 */
	hideShowNonRecurringOrderMsg:function(orderId,fromPageLoad) {
		if ( (document.getElementById("recurringOrder") && document.getElementById("recurringOrder").checked && document.getElementById("shipTypeOnline") && document.getElementById("shipTypeOnline").checked) ||
					(document.getElementById("recurringOrder") && document.getElementById("recurringOrder").checked && document.getElementById("shipTypeOnline") == null)) {
			setCookie("WC_recurringOrder_"+orderId, "true", {path: "/", domain: cookieDomain});
		} else {
			setCookie("WC_recurringOrder_"+orderId, "false", {path: "/", domain: cookieDomain});
		}
		
		if (document.getElementById("nonRecurringOrderItems") && document.getElementById("nonRecurringOrderItems").value != "") {
			if (document.getElementById("nonRecurringOrderItemsCount") && document.getElementById("numOrderItemsInOrder")) {
				var totalItems = document.getElementById("numOrderItemsInOrder").value;
				var totalNonRecurringItems = document.getElementById("nonRecurringOrderItemsCount").value;
				if (totalItems == totalNonRecurringItems) {
					if (document.getElementById("scheduling_options")) {
						document.getElementById("scheduling_options").style.display = "none";
						setCookie("WC_recurringOrder_"+orderId, "false", {path: "/", domain: cookieDomain});
						if (document.getElementById("recurringOrder")) {
							document.getElementById("recurringOrder").checked = false;
						}
						return;
					}// else if (document.getElementById("scheduling_options") && document.getElementById("shipTypeOnline") && document.getElementById("shipTypeOnline").checked) {
					//	document.getElementById("scheduling_options").style.display = "block";
					//}
				}
			}
			var orderItemIds = document.getElementById("nonRecurringOrderItems").value;
			var orderItemIdArray = orderItemIds.split(",");
			for(var i=0; i<orderItemIdArray.length; i++){
				if (document.getElementById("nonRecurringItem_"+orderItemIdArray[i])) {
					if ( (document.getElementById("recurringOrder") && document.getElementById("recurringOrder").checked && document.getElementById("shipTypeOnline") && document.getElementById("shipTypeOnline").checked) ||
								(document.getElementById("recurringOrder") && document.getElementById("recurringOrder").checked && document.getElementById("shipTypeOnline") == null)) {
						document.getElementById("nonRecurringItem_"+orderItemIdArray[i]).style.display = "block";
					} else {
						document.getElementById("nonRecurringItem_"+orderItemIdArray[i]).style.display = "none";
					}
				}
			}
			if ( (document.getElementById("recurringOrder") && document.getElementById("recurringOrder").checked && document.getElementById("shipTypeOnline") && document.getElementById("shipTypeOnline").checked && !fromPageLoad) ||
						(document.getElementById("recurringOrder") && document.getElementById("recurringOrder").checked && document.getElementById("shipTypeOnline") == null && !fromPageLoad)) {
				MessageHelper.displayErrorMessage(MessageHelper.messages["RECURRINGORDER_ERROR"]);
			}
		}
	},

	/** 
	* Constructs the next URL to call when user is already signed on 
	* 3 scenarios to handle:
	* 	1. Registered user selects to shop online -> goes to the shipping and billing page
	* 	2. Registered user selects to pick up in store - 2 variations:
	*		2a. User has not yet selected a physical store (WC_physicalStores cookie is empty) -> 
	*				Goes to store selection page
	*		2b. User has selected at least one store (WC_physicalStore cookie is not empty) ->
	*				Updates shipmode then goes to shipping and billing page
	* @param {String} billingShippingPageURLForOnline The URL to the billing and shipping page of the online checkout path
	* @param (String) physicalStoreSelectionURL The URL to the physical store selection page of the pick up in store checkout path
	*/
	registeredUserContinue: function(billingShippingPageURLForOnline, physicalStoreSelectionURL) {

		if(CheckoutHelperJS.getFieldDirtyFlag()){
			MessageHelper.displayErrorMessage(MessageHelper.messages["ERROR_UPDATE_FIRST_SHOPPING_CART"]);
			return;
		}
    	
		//For handling multiple clicks
		if(!submitRequest()){
			return;
		}	
		
		/*
		// deletePaymentInstructionsURL is never used anywhere in this function. Comment it out for now.
		var deletePaymentInstructionsURL = "";
		var paymentInstructionIds = document.getElementById("existingPaymentInstructionId").value;
		if(paymentInstructionIds != "") {
			var paymentInstructionsArray = paymentInstructionIds.split(",");
			deletePaymentInstructionsURL = "RESTOrderPIDelete?";
			for (var i=0; i<paymentInstructionsArray.length; i++) {
				if (i!=0) {
					deletePaymentInstructionsURL = deletePaymentInstructionsURL + "&";
				}
				deletePaymentInstructionsURL = deletePaymentInstructionsURL + "piId=" + paymentInstructionsArray[i];
			}
			deletePaymentInstructionsURL = deletePaymentInstructionsURL + "&URL=";
		} */
		
		if (this.isBOPISEnabled() && this.isPickUpInStore()) {
			document.location.href = appendWcCommonRequestParameters(physicalStoreSelectionURL);
		} else {
			//need to pass in orderItemId here for RESTOrderItemUpdate so it will call DoInventoryActionCmd to get fulfillment center ID
			var nextLink = 'RESTOrderItemUpdate?remerge=***&check=*n&allocate=***&backorder=***&calculationUsage=-1,-2,-3,-4,-5,-6,-7&calculateOrder=1&orderItemId='+this.orderItemId +'&errorViewName=AjaxOrderItemDisplayView'+'&orderId=.&URL=';
			//document.location.href = appendWcCommonRequestParameters(nextLink + billingShippingPageURLForOnline);
	
			var postRefreshHandlerParameters = [];
			var initialURL = "AjaxRESTOrderItemUpdate";
			var urlRequestParams = [];
			urlRequestParams["remerge"] = "***";
			urlRequestParams["check"] = "*n";
			urlRequestParams["allocate"] = "***";
			urlRequestParams["backorder"] = "***";
			urlRequestParams["calculationUsage"] = "-1,-2,-3,-4,-5,-6,-7";
			urlRequestParams["calculateOrder"] = "1";
			urlRequestParams["orderItemId"] = this.orderItemId;
			urlRequestParams["orderId"] = ".";
			urlRequestParams["storeId"] = this.storeId;
			//JR60345: explicit checkout scenario
			urlRequestParams["isCheckout"] = "true";

			postRefreshHandlerParameters.push({"URL":billingShippingPageURLForOnline,"requestType":"GET", "requestParams":{}}); 
			var service = getCustomServiceForURLChaining(initialURL,postRefreshHandlerParameters,null);
			service.invoke(urlRequestParams);
		}

	},

	/**
	* Constructs the next URL to call when user is not signed on and selected to continue checkout with 
	* guest user mode
	* 3 scenarios to handle:
	* 	1. Guest user selects to shop online -> goes to the shipping and billing page
	* 	2. Guest user selects to pick up in store - 2 variations:
	*		2a. User has not yet selected a physical store (WC_physicalStores cookie is empty) -> 
	*				Goes to store selection page
	*		2b. User has selected at least one store (WC_physicalStore cookie is not empty) ->
	*				Updates shipmode then goes to shipping and billing page
	* @param {String} billingShippingPageURLForOnline The URL to the billing and shipping page of the online checkout path
	* @param (String) physicalStoreSelectionURL The URL to the physical store selection page of the pick up in store checkout path
	*/
	guestShopperContinue: function(billingShippingPageURLForOnline, physicalStoreSelectionURL) {

		if(CheckoutHelperJS.getFieldDirtyFlag()){
			MessageHelper.displayErrorMessage(MessageHelper.messages["ERROR_UPDATE_FIRST_SHOPPING_CART"]);
			return;
		}
		
		//For handling multiple clicks
		if(!submitRequest()){
			return;
		}
		
		var postRefreshHandlerParameters = [];
		if (this.isBOPISEnabled() && this.isPickUpInStore()) {
			var paymentInstructionIds = $("#existingPaymentInstructionId").val();
			if (paymentInstructionIds != "") {	
				var paymentInstructionsArray = paymentInstructionIds.split(",");
				for (var i = 1; i < paymentInstructionsArray.length; i++) {
					// Chain subsequent PI Delete calls. REST API can delete only one piId at a time. Hence these requests needs to be chained.
					postRefreshHandlerParameters.push({"URL":"AjaxRESTOrderPIDelete", "requestParams":{"piId":paymentInstructionsArray[i]}});
				}
				postRefreshHandlerParameters.push({"URL":physicalStoreSelectionURL,"requestType":"GET"});

				// Initial request to PIDelete
				var params = [];
				params["piId"] = paymentInstructionsArray[0];
				var service = getCustomServiceForURLChaining("AjaxRESTOrderPIDelete",postRefreshHandlerParameters,null);
					service.invoke(params);
			} else {
				// No piId to delete. Just redirect to physicalStoreSelectionURL
				document.location.href = physicalStoreSelectionURL;
			}
		} else {
			//need to pass in orderItemId here for RESTOrderItemUpdate so it will call DoInventoryActionCmd to get fulfillment center ID
			var params = [];
			params["remerge"] = "***";
			params["check"] = "*n";
			params["allocate"] = "***";
			params["backorder"] = "***";
			params["calculationUsage"] = "-1,-2,-3,-4,-5,-6,-7";
			params["calculateOrder"] = "1";
			params["orderItemId"] = this.orderItemId;
			params["orderId"] = ".";
			params["storeId"] = this.storeId;

			var postRefreshHandlerParameters = [];
			postRefreshHandlerParameters.push({"URL":billingShippingPageURLForOnline, "requestType":"GET", "requestParams":{"guestChkout":"1"}});
			var service = getCustomServiceForURLChaining("AjaxRESTOrderItemUpdate",postRefreshHandlerParameters,null);
			service.invoke(params);
		}
	},

	/**
	* Constructs the next URL to call when user is not signed on and selected to sign in before checkout
	* 3 scenarios to handle:
	* 	1. User selects to shop online -> invokes logon URL
	* 	2. User selects to pick up in store - 2 variations:
	*		2a. User has not yet selected a physical store (WC_physicalStores cookie is empty) -> 
	*				After logon URL, go to the store selection page
	* 	2b. User has selected at least one store (WC_physicalStore cookie is not empty) ->
	*				Updates shipmode then invokes logon URL	
	* @param {String} logonURL URL to perform user logon 
	* @param {String} orderMoveURL URL to call order move after user has logged on
	* @param {String} billingShippingPageURLForOnline The URL to the billing and shipping page of the online checkout path
	* @param (String) physicalStoreSelectionURL The URL to the physical store selection page of the pick up in store checkout path
	*/
	guestShopperLogon: function(logonURL, billingShippingPageURLForOnline, physicalStoreSelectionURL) {
		if(CheckoutHelperJS.getFieldDirtyFlag()){
			MessageHelper.displayErrorMessage(MessageHelper.messages["ERROR_UPDATE_FIRST_SHOPPING_CART"]);
			return;
		}
		
		//var completeOrderMoveURL = orderMoveURL;
		var afterLogonURL = "";
		
		if (this.isBOPISEnabled() && this.isPickUpInStore()) {
			afterLogonURL = physicalStoreSelectionURL;
		} else {
			afterLogonURL = billingShippingPageURLForOnline;
		}
		
		// change URL of logon link
		// when mergeCart = true is passed to LogonURL command, logonCmd will merge the cart + does order calculate using MigrateUserEntriesCmdImpl.
		// So no need to explicitly call OrderItemMove and OrderCacluate commands again.
		// completeOrderMoveURL = completeOrderMoveURL + "&URL=RESTOrderCalculate%3FURL=" + afterLogonURL + "&calculationUsageId=-1&calculationUsageId=-2&calculationUsageId=-7";
		document.AjaxLogon.URL.value = afterLogonURL; // Got to next view directly. 
		document.location.href = logonURL;
	},
	 	
	/** 
	* Function to call when Quick Checkout button is pressed
	* 2 scenarios to handle:
	*   1. User selects to shop online -> proceed to call CheckoutHelperJS.updateCartWithCheckoutProfile
	*   2. User selects to pick up in store -> display error message to indicate quick checkout option is only
	*      available with online shopping option
	* @param {String} quickOrderId order id of this order
	*/
	updateCartWithQuickCheckoutProfile: function(quickOrderId) {
		if (this.isBOPISEnabled() && this.isPickUpInStore()) {
			MessageHelper.displayErrorMessage(MessageHelper.messages["message_QUICK_CHKOUT_ERR"]);
		} else {
			if(CheckoutHelperJS.getFieldDirtyFlag()){
				MessageHelper.displayErrorMessage(MessageHelper.messages["ERROR_UPDATE_FIRST_SHOPPING_CART"]);
				return;
			}
			CheckoutHelperJS.setCommonParameters(this.langId, this.storeId, this.catalogId);
			CheckoutHelperJS.updateCartWithQuickCheckoutProfile(quickOrderId);	
		}
	},
	
	/** 
	* Sets common parameters used by this javascript object
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
	* Sets orderItemId used by this javascript object
	* @param {String} orderItemId OrderItemId to use
	*/
	setOrderItemId:function(orderItemId){
		this.orderItemId = orderItemId;
	},
		
	/**
	* sets to tell if BOPIS feature is enabled
	* @param {boolean} flag Contains value of true or false
	*/
	setBOPISEnabled:function(flag){
		this.BOPISEnabled = flag;
	},
	
	/**
	* indicates if BOPIS feature is enabled
	*/
	isBOPISEnabled:function(){
		return this.BOPISEnabled;
	},
	
	/**
	* This function is called by the CheckoutStoreSelection.jsp "Next" button. It's job is to decide if it should go to
	* the next page. If there are no missing information it submits the call to the server to save the pick up location
	* for all the order items and then goes to the next page.
	* @param {Object} form The form that contains the order items and that need to be submitted 
	*/
	submitStoreSelectionForm:function(form) {
		var phyStoreId = PhysicalStoreCookieJSStore.getPickUpStoreIdFromCookie();

		if (phyStoreId != null && phyStoreId != "") {
			form["physicalStoreId"].value = phyStoreId;
			processAndSubmitForm(form);
		} else {
			if(document.getElementById("storeSelection_NextButton") != null){
				MessageHelper.formErrorHandleClient(document.getElementById("storeSelection_NextButton"), MessageHelper.messages["message_NO_STORE"]);
			}else{
				MessageHelper.displayErrorMessage(MessageHelper.messages["message_NO_STORE"]);
			}
		}
	},
	
	/**
	* This function is called by the CheckoutPayInStore.jsp "Next" button. It's job is to decide if it should go to
	* the next page. If the action is to use "PayInStore" then it directly goes to next page, otherwise it does 
	* validation on the address form and if there are no missing information it submits the call to the server to 
	* create the address and then goes to the next page.
	* 
	* @param {String} formName Name of the form that contains the address and need to be submitted 
	* @param {String} stateDivName Name of the div that has the "state" field
	* @param {String} hasValidAddresses boolean indicating if the user has at least one valid address for checkout purposes
	*/
	submitAddressForm:function(formName, stateDivName, hasValidAddresses) {
		var form = document.forms[formName];
		if (stateDivName != "") {
			AddressHelper.setStateDivName(stateDivName);
		}
		
		var payInStore = false;
		if ($("#payInStorePaymentOption").is(':checked')) {
			payInStore = true;
		}
		
		var postRefreshHandlerParameters = [];
		var urlRequestParams = [];


		/* Chain of URLs that can be invoked are:
		*  AjaxPersonChangeServiceAddressAdd - ($(form).attr("action") )
		*  AjaxRESTOrderPIDelete - (If more than one piId is present, then this action is repeated as many times as piIds present
		*  AjaxRESTOrderItemUpdate
		*  DOMOrderShippingBillingView
		*  In worst case scenario, chained URLs will be: (Assuming maximum 3 piIds are present)
		*	AjaxPersonChangeServiceAddressAdd,AjaxRESTOrderPIDelete,AjaxRESTOrderPIDelete,AjaxRESTOrderPIDelete,AjaxRESTOrderItemUpdate,DOMOrderShippingBillingView
		*  In best case scenario, chained URLs will be: (Assuming shopper has valid address and no piIDs)
		*   AjaxRESTOrderItemUpdate,DOMOrderShippingBillingView
		*/
		if (hasValidAddresses) {
			var initialURL = null;
			var formId = null;
		}
		else if (AddressHelper.validateAddressForm(form)) {
			var initialURL = $(form).attr("action");
			var formId = form.id;
		}

		var paymentInstructionIds = $("#existingPaymentInstructionId").val();
		if (paymentInstructionIds != "") {
			var paymentInstructionsArray = paymentInstructionIds.split(",");
			if(initialURL == null){
				var initialURL = "AjaxRESTOrderPIDelete";
				urlRequestParams["piId"] = paymentInstructionsArray[0];
			} else {
				postRefreshHandlerParameters.push({"URL":"AjaxRESTOrderPIDelete", "requestParams":{"piId":paymentInstructionsArray[0]}});
			}

			for (var i = 1; i < paymentInstructionsArray.length; i++) {
				// Chain subsequent PI Delete calls. REST API can delete only one piId at a time. Hence these requests needs to be chained.
				postRefreshHandlerParameters.push({"URL":"AjaxRESTOrderPIDelete", "requestParams":{"piId":paymentInstructionsArray[i]}});
			}
		}

		var orderItemUpdateParams = [];
		orderItemUpdateParams["remerge"] = "***";
		orderItemUpdateParams["check"] = "*n";
		orderItemUpdateParams["allocate"] = "***";
		orderItemUpdateParams["backorder"] = "***";
		orderItemUpdateParams["calculationUsage"] = "-1,-2,-3,-4,-5,-6,-7";
		orderItemUpdateParams["calculateOrder"] = "1";
		orderItemUpdateParams["orderItemId"] = this.orderItemId;
		orderItemUpdateParams["orderId"] = ".";
		orderItemUpdateParams["storeId"] = this.storeId;

		if(initialURL == null ){
			initialURL = "AjaxRESTOrderItemUpdate"; // Best case scenario defined above.
			urlRequestParams = orderItemUpdateParams;
		} else {
			postRefreshHandlerParameters.push({"URL":"AjaxRESTOrderItemUpdate", "requestParams":orderItemUpdateParams});
		}
		postRefreshHandlerParameters.push({"URL":"DOMOrderShippingBillingView","requestType":"GET", "requestParams":{"payInStore":payInStore}}); 
		var service = getCustomServiceForURLChaining(initialURL,postRefreshHandlerParameters,formId);
		service.invoke(urlRequestParams);
	}
}	
