//-----------------------------------------------------------------
//  Licensed Materials - Property of HCL Technologies                 
//
// HCL Commerce
//
//  (C) Copyright HCL Technologies Limited 1996, 2020                 
//
//-----------------------------------------------------------------

//
//

/** 
 * @fileOverview This file declares services that are used in the store check-out pages.
 */


/** 
 * This file declares services that are used in the store check-out pages.
 * 
 * @class This SBServicesDeclarationJS class defines all the variables and functions for the page(s) that use shipping and billing functionality in the store.
 *
 */
SBServicesDeclarationJS = {
	/** 
	 * This variable stores the ID of the language that the store is currently using.
	 *
	 * @private
	 */
	langId: "-1",
	
	/** 
	 * This variable stores the ID of the current store.
	 *
	 * @private
	 */
	storeId: "",
	
	/** 
	 * This variable stores the ID of the catalog that is used in the store.
	 *
	 * @private
	 */
	catalogId: "",

	/** 
	 * This variable stores the true/false value that indicates if the 'SinglePageCheckout' feature is enabled/disabled.
	 * When it is true, both shipping and billing information are captured in a single page. If it is false, checkout will
	 * be a two step process where shipping is captured in first step and billing in second step.
	 * It is set to true by default.
	 * 
	 * @private
	 */
	singlePageCheckout:true,
	
	/**
	 * This variable stores the value that indicates if an <code>OrderProcessServiceOrderPrepare</code> service call is required.
	 *
	 * @private
	 */
	orderPrepare: false,
	
	
	/**
 	 * Sets the common parameters for this instance.
 	 *
 	 * @param {int} langId The ID of the language used in the store.
 	 * @param {int} storeId The ID of the store.
 	 * @param {catalogId} catalogId The ID of the catalog used in the store.
	 */
	setCommonParameters:function(langId,storeId,catalogId){
			this.langId = langId;
			this.storeId = storeId;
			this.catalogId = catalogId;
	},
	

	/**
	 * Sets the SinglePageCheckout variable to indicate if the 'SinglePageCheckout' feature is enabled or disabled.
	 * 
	 * @param {Boolean} singlePageCheckout. A true/false value that indicates if the 'SinglePageCheckout' feature is enabled.
	 *
	 * @see CheckoutHelperJS.isSinglePageCheckout
	 */
	setSinglePageCheckout:function(singlePageCheckout){
		this.singlePageCheckout = singlePageCheckout;
	},
	
	
	/**
	 * Returns the singlePageCheckout variable that indicates if the 'SinglePageCheckout' feature is enabled/disabled.
	 * 
	 * @returns {Boolean} singlePageCheckout A true/false value that indicates if the 'SinglePageCheckout' feature is
	 * enabled/disabled.
	 *
	 * @see CheckoutHelperJS.setSinglePageCheckout
	 */
	isSinglePageCheckout:function(){
		return this.singlePageCheckout;
	}

}
/*BRAINTREE START*/

/**
  *  Declares an AJAX service that deletes the card in braintree vault
  *
  */
  wcService.declare({
	id: "AjaxRESTDeleteCardFromBraintreeVault",
	actionId: "AjaxRESTDeleteCardFromBraintreeVault",
	url: "AjaxRESTDeleteCardFromBraintreeVault",
	formId: ""
	
	/**
	 * Submits the order with the name of the payment form.
	 *
	 * @param (object) serviceResponse The service response object, which is the JSON object returned by the service invocation.
	 */
	,successHandler: function(serviceResponse) {
		cursor_clear();
		MessageHelper.displayStatusMessage("Deleted card successfully");
		window.location.reload(true);
	}
	
	/**
	 * Displays the error message returned with the service response and hides the progress bar.
	 *
	 * @param (object) serviceResponse The service response object, which is the JSON object returned by the service invocation.
	 */
	,failureHandler: function(serviceResponse) {
		MessageHelper.displayErrorMessage("Please try deleting card after sometime"); //TODO handle messages according to cases
		cursor_clear();
	}

}),


/**
  *  Declares an AJAX service that update shipping address from paypal 
  *
  */
  wcService.declare({
	id: "AjaxRESTUpdateShippingAddressFromPaypalCheckout",
	actionId: "AjaxRESTUpdateShippingAddressFromPaypalCheckout",
	url: "AjaxRESTUpdateShippingAddressFromPaypalCheckout",
	formId: ""
	
	/**
	 * Submits the order with the name of the payment form.
	 *
	 * @param (object) serviceResponse The service response object, which is the JSON object returned by the service invocation.
	 */
	,successHandler: function(serviceResponse) {
		cursor_clear();
		console.log("serviceResponse::"+ serviceResponse.result.updatedAddressId);
		
		var updatedAddressId=serviceResponse.result.updatedAddressId;
		if(updatedAddressId != ""){
			var params=[];
			params["addressId"]= updatedAddressId;
			params["storeId"]= WCParamJS.storeId;
			params["catalogId"] = WCParamJS.catalogId;
			params["langId"] = WCParamJS.langId;;
			params["orderId"] = ".";
			params["calculationUsage"] = "-1,-2,-3,-4,-5,-6,-7";
			params["allocate"] = "***";
			params["backorder"] = "***";
			params["remerge"] = "***";
			params["check"] = "*n";
			params["calculateOrder"] = "1";
			params["requesttype"] ="ajax";
		   
		   wcService.invoke("OrderItemAddressShipMethodUpdate", params);
		}
	}
	
	/**
	 * Displays the error message returned with the service response and hides the progress bar.
	 *
	 * @param (object) serviceResponse The service response object, which is the JSON object returned by the service invocation.
	 */
	,failureHandler: function(serviceResponse) {
		/*if (serviceResponse.errorMessage) {
			MessageHelper.displayErrorMessage(serviceResponse.errorMessage);
		} else {
			if (serviceResponse.errorMessageKey) {
				MessageHelper.displayErrorMessage(serviceResponse.errorMessageKey);
			}
		}*/
		MessageHelper.displayErrorMessage("Please try deleting card after sometime"); //TODO handle messages according to cases
		cursor_clear();
	}

}),

 

/**
  *  Declares an AJAX service that verifies  the saved card in braintree vault
  *
  */
  wcService.declare({
	id: "AjaxRESTVaultedCreditCardVerification",
	actionId: "AjaxRESTVaultedCreditCardVerification",
	url: "AjaxRESTVaultedCreditCardVerification",
	formId: ""
	
	/**
	 * Submits the order with the name of the payment form.
	 *
	 * @param (object) serviceResponse The service response object, which is the JSON object returned by the service invocation.
	 */
	,successHandler: function(serviceResponse) {
		cursor_clear();
		
		if(threeDSecureEnable == 'true'){
			// generate nonce for the token and return
			var nonceOfPayToken = serviceResponse.result.nonce;
			BrainTreePayments.threeDSecureCheck(nonceOfPayToken);
		}
		else{
			//go for transaction authorization
			CheckoutPayments.processCheckout('PaymentForm');
		}
	}
	
	/**
	 * Displays the error message returned with the service response and hides the progress bar.
	 *
	 * @param (object) serviceResponse The service response object, which is the JSON object returned by the service invocation.
	 */
	,failureHandler: function(serviceResponse) {
		MessageHelper.displayErrorMessage("Please Enter correct CVV / verify your billing address"); //TODO handle messages according to cases
		cursor_clear();
	}

}),


/**
  *  Declares an AJAX service that verifies  the saved card in BrainTree vault for mobile payments
  *
  */
  wcService.declare({
	id: "AjaxRESTVaultedCreditCardVerificationForMobilePayments",
	actionId: "AjaxRESTVaultedCreditCardVerificationForMobilePayments",
	url: "AjaxRESTVaultedCreditCardVerification",
	formId: ""
	
	/**
	 * Submits the order with the name of the payment form.
	 *
	 * @param (object) serviceResponse The service response object, which is the JSON object returned by the service invocation.
	 */
	,successHandler: function(serviceResponse) {
		cursor_clear();
		
		if(threeDSecureEnable == 'true'){
			// generate nonce for the token and return
			
			var nonceOfPayToken = serviceResponse.result.nonce;
			BrainTreeMobilePayments.threeDSecureCheck(nonceOfPayToken);
		}
		else{
			//go for transaction authorization
			//CheckoutPayments.processCheckout('PaymentForm');
			document.getElementById("payment_method_form_BrainTree_NewPayments").submit(); 
		}
	}
	
	/**
	 * Displays the error message returned with the service response and hides the progress bar.
	 *
	 * @param (object) serviceResponse The service response object, which is the JSON object returned by the service invocation.
	 */
	,failureHandler: function(serviceResponse) {
		MessageHelper.displayErrorMessage("Please Enter correct CVV / verify your billing address"); //TODO handle messages according to cases
		cursor_clear();
	}

}),
/*BRAINTREE END*/


/**
 * Declares an AJAX service that adds an item to the wish list and delete an item from the shopping cart.
 * @constructor 
 */
wcService.declare({
	id: "AjaxInterestItemAddAndDeleteFromCart",
	actionId: "AjaxInterestItemAddAndDeleteFromCart",
	url: "AjaxInterestItemAdd",
	formId: ""

	/**
	 * Hides the progress bar and deletes the order item from the shopping cart.
	 *
	 * @param (object) serviceResponse The service response object, which is the JSON object returned by the service invocation.
	 */
	,successHandler: function(serviceResponse) {
		cursor_clear();
		CheckoutHelperJS.deleteFromCart(serviceResponse.orderItemId);
	}
	
	/**
	 * Displays the error message returned with the service response and hides the progress bar.
	 *
	 * @param (object) serviceResponse The service response object, which is the JSON object returned by the service invocation.
	 */
	,failureHandler: function(serviceResponse) {
		if (serviceResponse.errorMessage) {
			MessageHelper.displayErrorMessage(serviceResponse.errorMessage);
		} else {
			if (serviceResponse.errorMessageKey) {
				MessageHelper.displayErrorMessage(serviceResponse.errorMessageKey);
			}
		}
		cursor_clear();
	}

}),


/**
 * Declares an AJAX service that updates the shipping address and shipping method for items in the order.
 * @constructor 
 */
wcService.declare({
	id: "OrderItemAddressShipMethodUpdate",
	actionId: "OrderItemAddressShipMethodUpdate",
	url: "AjaxRESTOrderShipInfoUpdate",
	formId: ""
	
	/**
	 * hides all the messages and the progress bar
	 * @param (object) serviceResponse The service response object, which is the
	 * JSON object returned by the service invocation
	 */
	,successHandler: function(serviceResponse) {
		MessageHelper.hideAndClearMessage();
		cursor_clear();
	}
	
	/**
	 * Displays the error message returned with the service response and hides the progress bar.
	 *
	 * @param (object) serviceResponse The service response object, which is the JSON object returned by the service invocation.
	 */
	,failureHandler: function(serviceResponse) {
		if (serviceResponse.errorMessage) {
			MessageHelper.displayErrorMessage(serviceResponse.errorMessage);
		} else {
			if (serviceResponse.errorMessageKey) {
				MessageHelper.displayErrorMessage(serviceResponse.errorMessageKey);
			}
		}
		cursor_clear();
	}

}),

/**
 * Declares an AJAX service that updates the shipping charge type for items in the order.
 * @constructor 
 */
wcService.declare({
	id: "AjaxOrderShipChargeUpdate",
	actionId: "AjaxOrderShipChargeUpdate",
	url: "AjaxShipInfoUpdate",
	formId: ""
	
	/**
	 * hides all the messages and the progress bar
	 * @param (object) serviceResponse The service response object, which is the
	 * JSON object returned by the service invocation
	 */
	,successHandler: function(serviceResponse) {
		/*
		MessageHelper.hideAndClearMessage();
		cursor_clear();
		*/
		var params = [];
		params.orderId = ".";
		params["storeId"] = CheckoutHelperJS.storeId;
		params["catalogId"] = CheckoutHelperJS.catalogId;
		params["langId"] = CheckoutHelperJS.langId;
		wcService.invoke("AjaxPrepareOrderForShipChargeUpdate", params);
	}
	
	/**
	 * Displays the error message returned with the service response and hides the progress bar.
	 *
	 * @param (object) serviceResponse The service response object, which is the JSON object returned by the service invocation.
	 */
	,failureHandler: function(serviceResponse) {
		if (serviceResponse.errorMessage) {
			MessageHelper.displayErrorMessage(serviceResponse.errorMessage);
		} else {
			if (serviceResponse.errorMessageKey) {
				MessageHelper.displayErrorMessage(serviceResponse.errorMessageKey);
			}
		}
		cursor_clear();
	}

}),

/**
 *This service calculates charges, performs inventory actions, and locks the
 *price of the order to indicate that the order can be submitted.
 *A message is displayed after the service call.
 * @constructor
 */
wcService.declare({
	id: "AjaxPrepareOrderForShipChargeUpdate",
	actionId: "AjaxPrepareOrderForShipChargeUpdate",
	url: getAbsoluteURL() + "AjaxRESTOrderPrepare",
	formId: ""
    /**
   * hides all the messages and the progress bar
   * @param (object) serviceResponse The service response object, which is the
   * JSON object returned by the service invocation
   */
	,successHandler: function(serviceResponse) {
		MessageHelper.hideAndClearMessage();
			cursor_clear();
	}

    /**
   * hides all the messages and the progress bar
   * @param (object) serviceResponse The service response object, which is the
   * JSON object returned by the service invocation
   */
	,failureHandler: function(serviceResponse) {

		if (serviceResponse.errorMessage) {
			MessageHelper.displayErrorMessage(serviceResponse.errorMessage);
		} 
		else {
			 if (serviceResponse.errorMessageKey) {
				MessageHelper.displayErrorMessage(serviceResponse.errorMessageKey);
			 }
		}
		cursor_clear();
	}

}),


/**
 * Declares an AJAX service that updates the shipping address and shipping instruction for items in the order.
 * @constructor 
 */
wcService.declare({
	id: "OrderItemAddressShipInstructionsUpdate",
	actionId: "OrderItemAddressShipInstructionsUpdate",
	url: "AjaxRESTOrderShipInfoUpdate",
	formId: ""
	
	/**
	 * Invokes the <code>OrderItemAddressShipInstructionsUpdate1</code> service if shipping instructions were specified, otherwise hides all the messages and the progress bar
	 *
	 * @param (object) serviceResponse The service response object, which is the JSON object returned by the service invocation.
	 */
	,successHandler: function(serviceResponse) {
		var params = [];
		params.orderId = ".";
		params["storeId"] = CheckoutHelperJS.storeId;
		params["catalogId"] = CheckoutHelperJS.catalogId;
		params["langId"] = CheckoutHelperJS.langId;
		params.calculationUsage = "-1,-2,-3,-4,-5,-6,-7";
		params.calculateOrder = "1";
		
		//Check if Shipping Instructions is enabled		
		if(document.getElementById("shipInstructions") != null){
			var shipInstructions = document.getElementById("shipInstructions").value;
			var orderItemId = document.getElementById("orderItem_1").value;				
			
			params["shipInstructions"] = shipInstructions;
			params["orderItemId"] = orderItemId;
			
			wcService.invoke("OrderItemAddressShipInstructionsUpdate1", params);			
		} else {
			MessageHelper.hideAndClearMessage();
			cursor_clear();
		}		
	}
	
	/**
	 * Displays the error message returned with the service response and hides the progress bar.
	 *
	 * @param (object) serviceResponse The service response object, which is the JSON object returned by the service invocation.
	 */
	,failureHandler: function(serviceResponse) {
		if (serviceResponse.errorMessage) {
			MessageHelper.displayErrorMessage(serviceResponse.errorMessage);
		} else {
			if (serviceResponse.errorMessageKey) {
				MessageHelper.displayErrorMessage(serviceResponse.errorMessageKey);
			}
		}
		cursor_clear();
	}

}),


/**
 * Declares an AJAX service that updates the shipping instruction for items in the order.
 * @constructor 
 */
wcService.declare({
	id: "OrderItemAddressShipInstructionsUpdate1",
	actionId: "OrderItemAddressShipInstructionsUpdate1",
	url: "AjaxRESTOrderShipInfoUpdate",
	formId: ""
	
	/**
	 * hides all the messages and the progress bar
	 * @param (object) serviceResponse The service response object, which is the
	 * JSON object returned by the service invocation
	 */
	,successHandler: function(serviceResponse) {
		MessageHelper.hideAndClearMessage();
		cursor_clear();
	}
	
	/**
	 * Displays the error message returned with the service response and hides the progress bar.
	 *
	 * @param (object) serviceResponse The service response object, which is the JSON object returned by the service invocation.
	 */
	,failureHandler: function(serviceResponse) {
		if (serviceResponse.errorMessage) {
			MessageHelper.displayErrorMessage(serviceResponse.errorMessage);
		} else {
			if (serviceResponse.errorMessageKey) {
				MessageHelper.displayErrorMessage(serviceResponse.errorMessageKey);
			}
		}
		cursor_clear();
	}

}),

/**
 * Declares an AJAX service that updates the shipping method for items in the order. This service is used to move all order items to single addressId and shipModeId when a user clicks on the single shipment button.
 * @constructor 
 */
wcService.declare({
	id: "OrderItemAddressShipMethodUpdate1",
	actionId: "OrderItemAddressShipMethodUpdate1",
	url: "AjaxRESTOrderShipInfoUpdate",
	formId: ""
	
	/**
	 * Invokes the <code>OrderChangeServiceShipInfoUpdate</code> service, then redirects the browser to OrderShippingBillingView.
	 *
	 * @param (object) serviceResponse The service response object, which is the JSON object returned by the service invocation.
	 */
	,successHandler: function(serviceResponse) {
		//Store the ids
		var storeId = CheckoutHelperJS.storeId;
		var catalogId = CheckoutHelperJS.catalogId;
		var langId = CheckoutHelperJS.langId;
		var orderId = serviceResponse.orderId;		

		//Obtain the shipmode id for the first order item
		var orderItemId = document.getElementById("orderItem_1").value;	
		var commonShipModeId = document.getElementById("commonShipModeId").value;
		if(commonShipModeId !=null && commonShipModeId!='undefined'){
			var shipModeId = commonShipModeId;
		}else{
			var shipModeId = document.getElementById("MS_ShippingMode_"+orderItemId).value;
		}
		
		var postRefreshHandlerParameters = [];
		var initialURL = "AjaxRESTOrderShipInfoUpdate";
		var urlRequestParams = [];
		urlRequestParams["remerge"] = "***";
		urlRequestParams["check"] = "*n";
		urlRequestParams["allocate"] = "***";
		urlRequestParams["backorder"] = "***";
		urlRequestParams["storeId"] = storeId;
		urlRequestParams["catalogId"] = catalogId;
		urlRequestParams["langId"] = langId;
		urlRequestParams["orderId"] = orderId;
		urlRequestParams["shipModeId"] = shipModeId;
		urlRequestParams["calculationUsage"] = "-1,-2,-3,-4,-5,-6,-7";
		urlRequestParams["calculateOrder"] = "1";
		
		//do not want to pass an empty purchaseorder_id to OrderChangeServiceShipInfoUpdate because it'll cause an failure in OrderFacadeClient.java
		var purchaseorderRef = document.getElementById("purchase_order_number");
		if(purchaseorderRef){
			var purchaseorder_id = purchaseorderRef.value;
			if(purchaseorder_id !=null && purchaseorder_id !='undefined' && purchaseorder_id !=''){
				urlRequestParams["purchaseorder_id"] = purchaseorder_id;
			}
		}
		//checks to see if quick checkout is enabled to display the credit card masked info  by checking the valueFromProfileOrder parameter
		if (valueFromProfileOrderElement = document.getElementsByName("valueFromProfileOrder")[0]&&valueFromProfileOrderElement.value == 'Y') {
			urlRequestParams["quickCheckoutProfileForPayment"] = "true";
		}
		postRefreshHandlerParameters.push({"URL":"OrderShippingBillingView","requestType":"GET", "requestParams":{}}); 
		var service = getCustomServiceForURLChaining(initialURL,postRefreshHandlerParameters,null);
		service.invoke(urlRequestParams);
	}
	
	/**
	 * Displays the error message returned with the service response and hides the progress bar.
	 *
	 * @param (object) serviceResponse The service response object, which is the JSON object returned by the service invocation.
	 */
	,failureHandler: function(serviceResponse) {
		if(serviceResponse.errorMessageKey == '_ERR_INVALID_ADDR'){
			MessageHelper.displayErrorMessage(MessageHelper.messages["ERROR_SWITCH_SINGLE_SHIPMENT"]);
		} else {		 
			if (serviceResponse.errorMessage) {
				MessageHelper.displayErrorMessage(serviceResponse.errorMessage);
			} else {
				if (serviceResponse.errorMessageKey) {
					MessageHelper.displayErrorMessage(serviceResponse.errorMessageKey);
				}
			}
		}
		cursor_clear();
	}
}),

/**
 * Declares an AJAX service that updates the shipping address for items in the order.
 * @constructor
 */
wcService.declare({
	id: "AjaxUpdateOrderItemsAddressId",
	actionId: "AjaxUpdateOrderItemsAddressId",
	url: "AjaxRESTOrderShipInfoUpdate",
	formId: ""
	
	/**
	 * After service was successfully performed, hides all messages and the progress bar. 
	 * Otherwise, routes to shipping and billing page.
	 *
	 * @param (object) serviceResponse The service response object, which is the JSON object returned by the service invocation.
	 */
	,successHandler: function(serviceResponse) {
		MessageHelper.hideAndClearMessage();
		CheckoutHelperJS.orderItemIds = [];
		cursor_clear();
	}
	
	/**
	 * Displays the error message returned with the service response and hides the progress bar.
	 *
	 * @param (object) serviceResponse The service response object, which is the JSON object returned by the service invocation.
	 */
	,failureHandler: function(serviceResponse) {
		if (serviceResponse.errorMessage) {
			MessageHelper.displayErrorMessage(serviceResponse.errorMessage);
		} else {
			if (serviceResponse.errorMessageKey) {
				MessageHelper.displayErrorMessage(serviceResponse.errorMessageKey);
			}
		}
		cursor_clear();
	}
}),


/**
 * Declares an AJAX service that adds a billing address during order check-out.
 * @constructor
 */
wcService.declare({
	id: "AddBillingAddressInCheckOut",
	actionId: "AddBillingAddressInCheckOut",
	url: "AjaxPersonChangeServiceAddressAdd",
	formId: ""
	
	/**
	 * This function renders the area having the context ID contextForMainAndAddressDiv with the specified properties.
	 *
	 * @param (object) serviceResponse The service response object, which is the JSON object returned by the service invocation.
	 */
	,successHandler: function(serviceResponse) {
		cursor_clear();
		wcRenderContext.updateRenderContext('contextForMainAndAddressDiv', {'showArea':'mainContents','hideArea':'editAddressContents'});
		if (this.formId != '' && document.getElementById(this.formId)){
			serviceResponse.addBillingAddressInCheckOutAddressType = document.getElementById(this.formId).addressType.value;
		}
	}
	
	/**
	 * Displays the error message returned with the service response and hides the progress bar.
	 *
	 * @param (object) serviceResponse The service response object, which is the JSON object returned by the service invocation.
	 */
	,failureHandler: function(serviceResponse) {
		if (serviceResponse.errorMessage) {
			MessageHelper.displayErrorMessage(serviceResponse.errorMessage);
		} else {
			if (serviceResponse.errorMessageKey) {
				MessageHelper.displayErrorMessage(serviceResponse.errorMessageKey);
			}
		}
		cursor_clear();
	}
}),

/**
 * This service edits an billing address for the person during checkout. An error message is displayed
 * if the service failed.
 * @constructor
 */
wcService.declare({
	id: "UpdateBillingAddressInCheckout",
	actionId: "UpdateBillingAddressInCheckout",
	url: getAbsoluteURL() + "AjaxPersonChangeServiceAddressUpdate",
	formId: ""

/**
 * hides all the messages and the progress bar
 * @param (object) serviceResponse The service response object, which is the JSON object returned by the service invocation
 * 
 */
	,successHandler: function(serviceResponse) {
		cursor_clear();
		wcRenderContext.updateRenderContext('contextForMainAndAddressDiv', {'showArea':'mainContents','hideArea':'editAddressContents'});
	}
 /**
 * display an error message
 * @param (object) serviceResponse The service response object, which is the
 * JSON object returned by the service invocation
 */
	,failureHandler: function(serviceResponse) {

		if (serviceResponse.errorMessage) {
			MessageHelper.displayErrorMessage(serviceResponse.errorMessage);
		}
		else {
			 if (serviceResponse.errorMessageKey) {
				MessageHelper.displayErrorMessage(serviceResponse.errorMessageKey);
			 }
		}
		cursor_clear();
	}

}),

/**
 * Declares an AJAX service that updates shipping information for order items during check-out.
 * @constructor
 */
wcService.declare({
	id: "OrderShippingInfoUpdate",
	actionId: "OrderShippingInfoUpdate",
	url: "AjaxRESTOrderShipInfoUpdate",
	formId: ""
	
	/**
	 * Clears the progress bar.
	 *
	 * @param (object) serviceResponse The service response object, which is the JSON object returned by the service invocation.
	 */
	,successHandler: function(serviceResponse) {
		cursor_clear();
	}
	
	/**
	 * Displays the error message returned with the service response and hides the progress bar.
	 *
	 * @param (object) serviceResponse The service response object, which is the JSON object returned by the service invocation.
	 */
	,failureHandler: function(serviceResponse) {
		if (serviceResponse.errorMessage) {
			MessageHelper.displayErrorMessage(serviceResponse.errorMessage);
		} else {
			if (serviceResponse.errorMessageKey) {
				MessageHelper.displayErrorMessage(serviceResponse.errorMessageKey);
			}
		}
		cursor_clear();
	}
}),


/**
 * Declares an AJAX service that prepares order information before submitting the order.
 * @constructor
 */
wcService.declare({
	id: "AjaxPrepareOrderBeforeSubmit",
	actionId: "AjaxPrepareOrderBeforeSubmit",
	url: "AjaxRESTOrderPrepare",
	formId: ""
	
	/**
	 * Submits the order with the name of the payment form.
	 *
	 * @param (object) serviceResponse The service response object, which is the JSON object returned by the service invocation.
	 */
	,successHandler: function(serviceResponse) {
		cursor_clear();
		CheckoutPayments.getTotalInJSON("OrderPrepare", 'PaymentForm', false);
	}
	
	/**
	 * Displays the error message returned with the service response and hides the progress bar.
	 *
	 * @param (object) serviceResponse The service response object, which is the JSON object returned by the service invocation.
	 */
	,failureHandler: function(serviceResponse) {
		if (serviceResponse.errorMessage) {
			MessageHelper.displayErrorMessage(serviceResponse.errorMessage);
		} else {
			if (serviceResponse.errorMessageKey) {
				MessageHelper.displayErrorMessage(serviceResponse.errorMessageKey);
			}
		}
		cursor_clear();
	}

}),

/**
 * Declares an AJAX service that prepares order information before submitting the order.
 * @constructor
 */
wcService.declare({
	id: "AjaxPrepareOrderBeforePaymentCapture",
	actionId: "AjaxPrepareOrderBeforePaymentCapture",
	url: "AjaxRESTOrderPrepare",
	formId: ""
	
	/**
	 * Submits the order with the name of the payment form.
	 *
	 * @param (object) serviceResponse The service response object, which is the JSON object returned by the service invocation.
	 */
	,successHandler: function(serviceResponse) {
		CheckoutPayments.setCommonParameters(SBServicesDeclarationJS.langId,SBServicesDeclarationJS.storeId,SBServicesDeclarationJS.catalogId);
		CheckoutPayments.showBillingPage();
		cursor_clear();
	}

	
	/**
	 * Displays the error message returned with the service response and hides the progress bar.
	 *
	 * @param (object) serviceResponse The service response object, which is the JSON object returned by the service invocation.
	 */
	,failureHandler: function(serviceResponse) {
		if (serviceResponse.errorMessage) {
			MessageHelper.displayErrorMessage(serviceResponse.errorMessage);
		} else {
			if (serviceResponse.errorMessageKey) {
				MessageHelper.displayErrorMessage(serviceResponse.errorMessageKey);
			}
		}
		cursor_clear();
	}

}),

/**
 * Declares an AJAX service that sets the address ID for all items in the order.
 * @constructor
 */
wcService.declare({
	id: "AjaxSetAddressIdOfOrderItems",
	actionId: "AjaxSetAddressIdOfOrderItems",
	url: "AjaxRESTOrderShipInfoUpdate",
	formId: ""
	
	/**
	 * Redirects the browser to OrderShippingBillingView
	 * @param (object) serviceResponse The service response object, which is the JSON object returned by the service invocation.
	 */
	,successHandler: function(serviceResponse) {
		var url="OrderShippingBillingView?orderId="+(serviceResponse.orderId?serviceResponse.orderId:".")+"&langId="+serviceResponse.langId+"&storeId="+serviceResponse.storeId+"&catalogId="+serviceResponse.catalogId+"&showRegTag=T";
		document.location.href=appendWcCommonRequestParameters(url);
	}
	
	/**
	 * Displays the error message returned with the service response and hides the progress bar.
	 *
	 * @param (object) serviceResponse The service response object, which is the JSON object returned by the service invocation.
	 */
	,failureHandler: function(serviceResponse) {
		if (serviceResponse.errorMessage) {
			MessageHelper.displayErrorMessage(serviceResponse.errorMessage);
		} else {
			if (serviceResponse.errorMessageKey) {
				MessageHelper.displayErrorMessage(serviceResponse.errorMessageKey);
			}
		}
		document.getElementById("OrderShippingBillingErrorArea").style.display = "block";
		cursor_clear();
	}

}),


/**
 * Declares an AJAX service that sets the shipping mode ID for the order.
 * @constructor
 */
wcService.declare({
	id: "AjaxSetShipModeIdForOrder",
	actionId: "AjaxSetShipModeIdForOrder",
	url: "AjaxRESTOrderShipInfoUpdate",
	formId: ""
	
	/**
	 * Redirects the browser to OrderShippingBillingView.
	 *
	 * @param (object) serviceResponse The service response object, which is the JSON object returned by the service invocation.
	 */
	,successHandler: function(serviceResponse) {
		var url="OrderShippingBillingView?langId="+SBServicesDeclarationJS.langId+"&storeId="+SBServicesDeclarationJS.storeId+"&catalogId="+SBServicesDeclarationJS.catalogId;
		document.location.href=appendWcCommonRequestParameters(url);
	}
	
	/**
	 * Displays the error message returned with the service response and hides the progress bar.
	 * 
	 * @param (object) serviceResponse The service response object, which is the JSON object returned by the service invocation.
	 */
	,failureHandler: function(serviceResponse) {
		if (serviceResponse.errorMessage) {
			MessageHelper.displayErrorMessage(serviceResponse.errorMessage);
		} else {
			if (serviceResponse.errorMessageKey) {
				MessageHelper.displayErrorMessage(serviceResponse.errorMessageKey);
			}
		}
		document.getElementById("OrderShippingBillingErrorArea").style.display = "block";
		cursor_clear();
	}

}),

/**
 * Declares an AJAX service that sets the requested ship date for all items in the order.
 * @constructor
 */
wcService.declare({
	id: "AjaxSetRequestedShipDateForOrder",
	actionId: "AjaxSetRequestedShipDateForOrder",
	url: "AjaxRESTOrderShipInfoUpdate",
	formId: ""
	
	/**
	 * Redirects the browser to OrderShippingBillingView
	 * @param (object) serviceResponse The service response object, which is the JSON object returned by the service invocation.
	 */
	,successHandler: function(serviceResponse) {
		var url = "OrderShippingBillingView?orderId="+(serviceResponse.orderId?serviceResponse.orderId:".")+"&langId="+SBServicesDeclarationJS.langId+"&storeId="+SBServicesDeclarationJS.storeId+"&catalogId="+SBServicesDeclarationJS.catalogId+"&showRegTag=T";
		document.location.href=appendWcCommonRequestParameters(url);
	}
	
	/**
	 * Displays the error message returned with the service response and hides the progress bar.
	 *
	 * @param (object) serviceResponse The service response object, which is the JSON object returned by the service invocation.
	 */
	,failureHandler: function(serviceResponse) {
		if (serviceResponse.errorMessage) {
			MessageHelper.displayErrorMessage(serviceResponse.errorMessage);
		} else {
			if (serviceResponse.errorMessageKey) {
				MessageHelper.displayErrorMessage(serviceResponse.errorMessageKey);
			}
		}
		document.getElementById("OrderShippingBillingErrorArea").style.display = "block";
		cursor_clear();
	}

}),


/**
* This service adds a shipping and billing address during order check out. An error message is displayed if the service failed.
* @constructor
*/
wcService.declare({
	id: "AjaxAddShippingAndBillingAddressForPersonDuringCheckout",
	actionId: "AjaxAddShippingAndBillingAddressForPersonDuringCheckout",
	url: getAbsoluteURL() + "AjaxPersonChangeServiceAddressAdd",
	formId: ""

/**
* Hides all the messages and the progress bar
* @param (object) serviceResponse The service response object, which is the JSON object returned by the service invocation.
*/
	,successHandler: function(serviceResponse) {
		if (this.formId != ""){
			serviceResponse.originalServiceId = document.getElementById(this.formId).originalServiceId.value;
		}
		MessageHelper.hideAndClearMessage();
		cursor_clear();
	}

/**
* Displays an error message in case of failure.
* @param (object) serviceResponse The service response object, which is the JSON object returned by the service invocation.
*/
	,failureHandler: function(serviceResponse) {

		if (serviceResponse.errorMessage) {
			MessageHelper.displayErrorMessage(serviceResponse.errorMessage);
		} 
		else {
			 if (serviceResponse.errorMessageKey) {
				MessageHelper.displayErrorMessage(serviceResponse.errorMessageKey);
			 }
		}
		cursor_clear();
	}

}),
/**
* This service updates a shipping and billing address during order check out. An error message is displayed if the service failed.
* @constructor
*/
wcService.declare({
	id: "AjaxUpdateShippingAndBillingAddressForPersonDuringCheckout",
	actionId: "AjaxUpdateShippingAndBillingAddressForPersonDuringCheckout",
	url: getAbsoluteURL() + "AjaxPersonChangeServiceAddressUpdate",
	formId: ""

/**
* Hides all the messages and the progress bar
* @param (object) serviceResponse The service response object, which is the JSON object returned by the service invocation.
*/
	,successHandler: function(serviceResponse) {
		if (this.formId != ""){
			serviceResponse.originalServiceId = document.getElementById(this.formId).originalServiceId.value;
		}
		MessageHelper.hideAndClearMessage();
		cursor_clear();
	}

/**
* Displays an error message in case of failure.
* @param (object) serviceResponse The service response object, which is the JSON object returned by the service invocation.
*/
	,failureHandler: function(serviceResponse) {

		if (serviceResponse.errorMessage) {
			MessageHelper.displayErrorMessage(serviceResponse.errorMessage);
		} 
		else {
			 if (serviceResponse.errorMessageKey) {
				MessageHelper.displayErrorMessage(serviceResponse.errorMessageKey);
			 }
		}
		cursor_clear();
	}

}),
/**
* Declares an AJAX service that deletes payment instructions from the current order.
* @constructor
*/
wcService.declare({
	id: "AjaxDeletePaymentInstructionFromThisOrder",
	actionId: "AjaxDeletePaymentInstructionFromThisOrder",
	url: "AjaxRESTOrderPIDelete",
	formId: ""
	
	/**
	 * Removes piId from payment objects and payment forms on the page, clears the progress bar.
	 * Invokes the AjaxPrepareOrderBeforeProceedingToSummary service to prepare order information.
	 * @param (object) serviceResponse The service response object, which is the JSON object returned by the service invocation.
	 */
	,successHandler: function(serviceResponse) {
		var paymentObj = CheckoutPayments.retrievePaymentObject(serviceResponse["paymentAreaNumber"]);
		if (typeof(paymentObj) != "undefined") {
			paymentObj['piId'] = "";
		}
		cursor_clear();
		if (CheckoutPayments.getPaymentsToDelete().length < 1) {
			cursor_clear();
			if(CheckoutPayments.getPaymentsToAdd().length > 0){
				CheckoutPayments.addPaymentInstructions();
			}else if(CheckoutPayments.getPaymentsToUpdate().length > 0){
				CheckoutPayments.updatePaymentInstructions();
			}else{
				if(!submitRequest()){
					return;
				}   		
				cursor_wait();
				CheckoutPayments.setCommonParameters(SBServicesDeclarationJS.langId,SBServicesDeclarationJS.storeId,SBServicesDeclarationJS.catalogId);
				CheckoutPayments.showSummaryPage();
				cursor_clear();
			}
		} else {
			CheckoutPayments.deletePaymentInstructions();
		}
	}
	
	/**
	 * Resets the array object that contains existing payment objects to delete.
	 * Displays the error message returned with the service response and hides the progress bar.
	 * @param (object) serviceResponse The service response object, which is the JSON object returned by the service invocation.
	 */
	,failureHandler: function(serviceResponse) {
		CheckoutPayments.paymentsToDelete = new Array();
		if (serviceResponse.errorMessage) {
			MessageHelper.displayErrorMessage(serviceResponse.errorMessage);
		} else {
			if (serviceResponse.errorMessageKey) {
				MessageHelper.displayErrorMessage(serviceResponse.errorMessageKey);
			}
		}
		cursor_clear();
	}

}),


/**
* Declares an AJAX service that adds a payment instruction to the current order.
* @constructor
*/
wcService.declare({
	id: "AjaxAddPaymentInstructionToThisOrder",
	actionId: "AjaxAddPaymentInstructionToThisOrder",
	url: "AjaxRESTOrderPIAdd",
	formId: ""
	
	/**
	 * Resets the array object that contains payment objects to add. Verifies if there is any payment instruction that needs to be updated.
	 * If there is no payment instruction that needs to be updated, direct the browser to the order summary page.
	 * @param (object) serviceResponse The service response object, which is the JSON object returned by the service invocation.
	 */
	,successHandler: function(serviceResponse) {
		cursor_clear();
		if (CheckoutPayments.getPaymentsToAdd().length < 1) {
			if(CheckoutPayments.getPaymentsToUpdate().length > 0){
				CheckoutPayments.updatePaymentInstructions();
			}else{
				if(!submitRequest()){
					return;
				}   		
				cursor_wait();			
				CheckoutPayments.setCommonParameters(SBServicesDeclarationJS.langId,SBServicesDeclarationJS.storeId,SBServicesDeclarationJS.catalogId);
				CheckoutPayments.showSummaryPage();
				cursor_clear();
			}
		} else {
			CheckoutPayments.addPaymentInstructions();
		}
	}
	
	/**
	 * Resets the array object that contains existing payment objects to add.
	 * Displays the error message returned with the service response and hides the progress bar.
	 * @param (object) serviceResponse The service response object, which is the JSON object returned by the service invocation.
	 */
	,failureHandler: function(serviceResponse) {
		CheckoutPayments.paymentsToAdd = new Array();
		if (serviceResponse.errorMessage) {
			MessageHelper.displayErrorMessage(serviceResponse.errorMessage);
		} else {
			if (serviceResponse.errorMessageKey) {
				MessageHelper.displayErrorMessage(serviceResponse.errorMessageKey);
			}
		}
		cursor_clear();
		//Payment type promotion: If add payment object failed, then if the number of payment methods is 1, call the service to associate an unbounded payment method with the order.
		if(supportPaymentTypePromotions && CheckoutPayments.numberOfPaymentMethods == 1){
			CheckoutPayments.addNewUnboundPaymentInstruction();
        }
	}

}),

/**
* Declares an AJAX service that updates payment instructions in the current order.
* @constructor
*/
wcService.declare({
	id: "AjaxUpdatePaymentInstructionInThisOrder",
	actionId: "AjaxUpdatePaymentInstructionInThisOrder",
	url: "AjaxRESTOrderPIUpdate",
	formId: ""
	
	/**
	 * Clears the progress bar, verifies if there is any more payment instruction that needs to be updated.
	 * If there is no more payment instruction that needs to be updated, direct the browser to the order summary page.
	 * @param (object) serviceResponse The service response object, which is the JSON object returned by the service invocation.
	 */
	,successHandler: function(serviceResponse) {
		cursor_clear();
		if(CheckoutPayments.getPaymentsToUpdate().length < 1){
			if(!submitRequest()){
				return;
			}   		
			cursor_wait();
			
			CheckoutPayments.setCommonParameters(SBServicesDeclarationJS.langId,SBServicesDeclarationJS.storeId,SBServicesDeclarationJS.catalogId);
			CheckoutPayments.showSummaryPage();
			cursor_clear();
		}else{
			CheckoutPayments.updatePaymentInstructions();
		}
	}
	
	/**
	 * Resets the array object that contains existing payment objects to update.
	 * Displays the error message returned with the service response and hides the progress bar.
	 * @param (object) serviceResponse The service response object, which is the JSON object returned by the service invocation.
	 */
	,failureHandler: function(serviceResponse) {
		CheckoutPayments.paymentsToUpdate = new Array();
		if (serviceResponse.errorMessage) {
			MessageHelper.displayErrorMessage(serviceResponse.errorMessage);
		} else {
			if (serviceResponse.errorMessageKey) {
				MessageHelper.displayErrorMessage(serviceResponse.errorMessageKey);
			}
		}
		cursor_clear();
	}
}),	 

/**
 * Payment type promotion - START
 */
 
/**
* Declares an AJAX service that adds an unbounded payment instruction to the current order.
* @constructor
*/
wcService.declare({
	id: "AjaxAddUnboundPaymentInstructionToThisOrder",
	actionId: "AjaxAddUnboundPaymentInstructionToThisOrder",
	url: "AjaxRESTOrderPIAdd",
	formId: ""
	
	/**
	 * Sets the piId of payment object 1 to the returned piId from the service
	 * call and updates its action to re-add, so that its correctly handled by
	 * the client logic of associating actions to payment objects. Invokes the
	 * AjaxPrepareOrderForPaymentSubmit service to prepare order information.
	 * 
	 * @param (object)
	 *            serviceResponse The service response object, which is the JSON
	 *            object returned by the service invocation.
	 */
	 ,successHandler: function(serviceResponse) { 
		cursor_clear();
		
		CheckoutPayments.setPaymentFormPiId(1, serviceResponse.paymentInstruction[0].piId);		 
		CheckoutPayments.paymentObjects[1]['piId'] = serviceResponse.paymentInstruction[0].piId;
		CheckoutPayments.paymentObjects[1]['action'] = 're-add'; 
		 
		var params = [];
		params.orderId = serviceResponse.orderId;
		params["storeId"] = CheckoutHelperJS.storeId;
		params["catalogId"] = CheckoutHelperJS.catalogId;
		params["langId"] = CheckoutHelperJS.langId;
		cursor_wait();
		wcService.invoke("AjaxPrepareOrderForPaymentSubmit", params);		 
 	 }
	/**
	 * Displays the error message returned with the service response and hides the progress bar.
	 * @param (object) serviceResponse The service response object, which is the JSON object returned by the service invocation.
	 */
	,failureHandler: function(serviceResponse) {		
		if (serviceResponse.errorMessage) {
			MessageHelper.displayErrorMessage(serviceResponse.errorMessage);
		} else {
			if (serviceResponse.errorMessageKey) {
				MessageHelper.displayErrorMessage(serviceResponse.errorMessageKey);
			}
		}
		cursor_clear();
	}	
}),
 	 
/**
* Declares an AJAX service that deletes an unbounded payment instruction from the current order.
* @constructor
*/
wcService.declare({
	id: "AjaxDeleteUnboundPaymentInstructionFromThisOrder",
	actionId: "AjaxDeleteUnboundPaymentInstructionFromThisOrder",
	url: "AjaxRESTOrderPIDelete",
	formId: ""
	
	/**
	 * The piId of all payment objects is set to empty string, the
	 * action is set to 'add' or empty string depends on whether the 
	 * payment object is in the scope of <code>numberOfPaymentMethods</code>,
	 * so that they are correctly handled by the client logic of associating 
	 * actions to payment objects. Invokes addNewUnboundPaymentInstruction
	 * if isSinglePaymentType return true. Else, it
	 * calls the AjaxPrepareOrderForPaymentSubmit service to prepare order
	 * information.
	 * 
	 * @param (object)
	 *            serviceResponse The service response object, which is the JSON
	 *            object returned by the service invocation.
	 */
	,successHandler: function(serviceResponse) {
		cursor_clear();	
		for(var i = 1; i < CheckoutPayments.paymentObjects.length; i++){
			// In order for adding new dummy instruction to calculate payment type promotion, 
			// all payment instructions (dummy or non-dummy) were deleted at this point.
			//
			// We also need to clear the card number (the number are shown in: ******1111), 
			// since the corresponding non-dummy instruction for paymentObjects[i]['piId'] is deleted.
			if($("#account1_" + i).length ){
				CheckoutPayments.removeCreditCardNumberAndCVV(i, true, true);
				CheckoutHelperJS.paymentDataDirty(i, true);
			}
			CheckoutPayments.setPaymentFormPiId(i,'');
			CheckoutPayments.paymentObjects[i]['piId'] = '';
			if (i > CheckoutPayments.numberOfPaymentMethods){
				CheckoutPayments.paymentObjects[i]['action'] = ''; 
			} else {
				CheckoutPayments.paymentObjects[i]['action'] = 'add'; 
			}
		}
		if(CheckoutPayments.isSinglePaymentType()){
			//Add new unbound instruction if is single payment type
			CheckoutPayments.addNewUnboundPaymentInstruction();
		} else {
			 var params = [];
			 params.orderId = serviceResponse.orderId;
			 params["storeId"] = CheckoutHelperJS.storeId;
			 params["catalogId"] = CheckoutHelperJS.catalogId;
			 params["langId"] = CheckoutHelperJS.langId;
			 cursor_wait();
			 wcService.invoke("AjaxPrepareOrderForPaymentSubmit", params);	
		}	
	}		
	/**
	 * Displays the error message returned with the service response and hides the progress bar.
	 * @param (object) serviceResponse The service response object, which is the JSON object returned by the service invocation.
	 */
	,failureHandler: function(serviceResponse) {		
		if (serviceResponse.errorMessage) {
			MessageHelper.displayErrorMessage(serviceResponse.errorMessage);
		} else {
			if (serviceResponse.errorMessageKey) {
				MessageHelper.displayErrorMessage(serviceResponse.errorMessageKey);
			}
		}
		cursor_clear();
	}
}),

/**
* Declares an AJAX service that prepares order information before submitting the order.
* @constructor
*/
wcService.declare({
	id: "AjaxPrepareOrderForPaymentSubmit",
	actionId: "AjaxPrepareOrderForPaymentSubmit",
	url: "AjaxRESTOrderPrepare",
	formId: ""
	
	/**
	 * If required, sets payment objects 2 and above to null. Triggers the
	 * calculation of order total and payment amounts.
	 * 
	 * @param (object)
	 *            serviceResponse The service response object, which is the JSON
	 *            object returned by the service invocation.
	 */
	,successHandler: function(serviceResponse) {
		cursor_clear();
		
		/**
		 * We want to update the total and load the payment snippets
		 */
		CheckoutPayments.getTotalInJSON("loadPaymentSnippet", "PaymentForm", true);		
	}
	
	/**
	 * Displays the error message returned with the service response and hides the progress bar.
	 * @param (object) serviceResponse The service response object, which is the JSON object returned by the service invocation.
	 */
	,failureHandler: function(serviceResponse) {
		if (serviceResponse.errorMessage) {
			MessageHelper.displayErrorMessage(serviceResponse.errorMessage);
		} else {
			if (serviceResponse.errorMessageKey) {
				MessageHelper.displayErrorMessage(serviceResponse.errorMessageKey);
			}
		}
		cursor_clear();
	}
})
