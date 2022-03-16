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
* @fileOverview This JavaScript file contains functions used by the payment section of the checkout pages for braintree mobile paymnets.
*/

//declare the namespace if it does not already exist
if (BrainTreeMobilePayments == null || typeof(BrainTreeMobilePayments) != "object") {
	var BrainTreeMobilePayments = new Object();
}
BrainTreeMobilePayments = {
	
		/** used to hold error messages for any error encountered */
		errorMessages: {},
		
		/**
		* This function is used to initialize the error messages object with all the required error messages.
		* @param {String} key The key used to access this error message.
		* @param {String} msg The error message in the correct language.
		*/
		setErrorMessage:function(key, msg) {
			this.errorMessages[key] = msg;
		},
		/**
		 * To display credit card hosted fields, in mobile pages
		 */
		creditCardPayment:function(clientToken){
			// if already iframe exists,we are clearing it
				document.getElementById("card-number").innerHTML = "";
				document.getElementById("cvv").innerHTML = "";
				document.getElementById("expiration-date").innerHTML = "";
			braintree.client.create({
				 authorization: clientToken
				 }).then( function(clientInstance) {
							
							//device data
								if(advancedFraudTools == "true"){
										
										braintree.dataCollector.create({
											client: clientInstance,
											kount: true
										  }).then(function( dataCollectorInstance) {
											  
											var deviceData = JSON.parse(dataCollectorInstance.deviceData);
											document.querySelector('#deviceSessionId').value = deviceData.device_session_id;
											document.querySelector('#fraudMerchantId').value = deviceData.fraud_merchant_id;
										  }).catch(function (err){
												console.error("device data error for creditcard  is",err);
												MessageHelper.displayErrorMessage(BrainTreeMobilePayments.errorMessages["BT_GENERIC_DEVICE_DATA_ERROR"]);
												  return;
												
											});
								}

							//hosted fields
							braintree.hostedFields.create({
							client: clientInstance,
							styles: {
								'input': {
								   'font-size': '14px'
																			
								},
								'input.invalid': {
								   'color': 'red'
								},
								'input.valid': {
								   'color': 'green'
								}
							},
							fields: {
								number: {
									selector: '#card-number',
									border: '1px solid #333'
								},
								cvv: {
									selector: '#cvv'
								},
								expirationDate: {
									selector: '#expiration-date'
								}
							}
													          
						}).then(function (hostedFieldsInstance) {
								
								$("#payment_method_BrainTree_CreditCard").css("display", "block");
								var keyforInst="inst_creditCard";
								instances_BT[keyforInst]=hostedFieldsInstance;
								console.log("hostedFieldsInstance",hostedFieldsInstance);
								
							}).catch( function (hostedFieldsErr){
							console.error("hostedFieldsErr:",hostedFieldsErr);
							var hostedFieldsErrMsg="";
							if(hostedFieldsErr){
								$("#hostedFieldsErrorMessage").css("display", "block"); 
								switch (hostedFieldsErr.code) {
									case 'HOSTED_FIELDS_TIMEOUT':
										hostedFieldsErrMsg= "Please try placing order after sometime"; //unknown error .
										//Occurs when Hosted Fields does not finish setting up within 60 seconds.
										 break;
									case 'HOSTED_FIELDS_INVALID_FIELD_KEY':
										 hostedFieldsErrMsg= "Please try placing order after sometime"; //merchnat error
										 break;
									case 'HOSTED_FIELDS_INVALID_FIELD_SELECTOR':
										hostedFieldsErrMsg= "Please try placing order after sometime"; //merchnat error
										break;
									case 'HOSTED_FIELDS_FIELD_DUPLICATE_IFRAME':  
										hostedFieldsErrMsg= "Please try placing order after sometime"; //merchnat error
										break;
									case 'HOSTED_FIELDS_FIELD_PROPERTY_INVALID':
										hostedFieldsErrMsg= "Please try placing order after sometime"; //merchnat error
										break;  
									default:
										hostedFieldsErrMsg= "Please try placing order after sometime"; //merchnat error 
								}
								hostedFieldsErrMsg= BrainTreeMobilePayments.errorMessages["BT_HOSTEDFIELDS_ERROR"];
							}
							document.getElementById("hostedFieldsErrorMessage").innerHTML=hostedFieldsErrMsg;
							return;
					
					});
			}).catch( function(clientErr) {
				console.error("clientErr:",clientErr);
				if(clientErr){
					$("#hostedFieldsWrapper").css("display", "none"); //if error occurs don't display wrapper							          	
					MessageHelper.displayErrorMessage(BrainTreeMobilePayments.errorMessages["BT_GENERIC_CLIENT_TOKEN_ERROR"]);		
					cursor_clear();
				}
				return;
			 });
		},
		/**
		 * To display google pay button in mobile page
		 */
		googlePayPayment:function(clientToken , paymentEnv){
			var paymentsClient = new google.payments.api.PaymentsClient({
			  environment: paymentEnv // Or 'PRODUCTION'
			});

			braintree.client.create({
			  authorization: clientToken
			}).then( function (clientInstance) {
			 

						if(advancedFraudTools == "true"){
						// device data
									braintree.dataCollector.create({
										client: clientInstance,
										kount: true
									  }).then(function( dataCollectorInstance) {
										var deviceData = JSON.parse(dataCollectorInstance.deviceData);
										document.querySelector('#deviceSessionId').value = deviceData.device_session_id;
										document.querySelector('#fraudMerchantId').value = deviceData.fraud_merchant_id;
										
									  }).catch(function (err){
											
											console.error("device data error for GooglePay is",err);
											MessageHelper.displayErrorMessage(BrainTreeMobilePayments.errorMessages["BT_GENERIC_DEVICE_DATA_ERROR"]);
											  return;
											
										});
						}
			

			braintree.googlePayment.create({
				client: clientInstance
			  }).then(function (googlePaymentInstance) {
			   paymentsClient.isReadyToPay({
				  allowedPaymentMethods: ["CARD", "TOKENIZED_CARD"] //googlePaymentInstance.createPaymentDataRequest().allowedPaymentMethods
				}).then(function(response) {
				 if (response.result) {
					//assigning the  googlePaymentInstance to a var.
					$("#payment_method_BrainTree_GooglePay").css("display", "block"); //TODO payment should be opened only when instance is created
					var keyForInst="googlePay";
					gPayPaymentsClient_BT[keyForInst]=paymentsClient;
					instances_BT[keyForInst]=googlePaymentInstance;
					
				  }
				}).catch(function (err) {
				  
				 MessageHelper.displayErrorMessage(BrainTreeMobilePayments.errorMessages["BT_GOOGLEPAY_RESPONSE_FAILED_ERROR"]);	
				  console.error("err when response failed:",err);
				});
			  }).catch(function(googlePaymentErr){
				console.error("googlePaymentError:",googlePaymentErr);
				 MessageHelper.displayErrorMessage(BrainTreeMobilePayments.errorMessages["BT_GOOGLEPAY_PAYMENT_ERROR"]);	
			  });
			
			}).catch(function(clienterr){
				console.error("clienterror:",clienterr);
				
				MessageHelper.displayErrorMessage(BrainTreeMobilePayments.errorMessages["BT_GENERIC_CLIENT_TOKEN_ERROR"]);	
				return;
			});
		},
		
		/**
		 * to display paypal button  in mobile page
		 */
		payPalPayment:function(payPalDivId,paypalCreditbutton,clientToken,isPickUpAt,amountval,userType,isPaypalCreditEnableFlag,isMultiCapEnable,shippingAddressSelected,flow,intent, environment)
				{
					//if already iframe exists,we are clearing it
					document.getElementById(payPalDivId).innerHTML = "";

					if(isPaypalCreditEnableFlag == 'true')
						document.getElementById(paypalCreditbutton).innerHTML = "";

					$(".paypalCheckoutdiv").css("display", "block");

					var client_token=clientToken;
					
					var enableShippingAddressFlag = true;
					var shippingAddressEditableFlag = true;
					var createPayPalPayment = {};
					var shippingAddressOverrideValues = {};
					
					var isPickUpInStoreFlag = isPickUpAt;
					
					if(isPickUpInStoreFlag || isMultipleShipping){
						enableShippingAddressFlag = false;
						shippingAddressEditableFlag = false;
					}else{
						
							var lastName=shippingAddressSelected[0].lastName;
							var	recipientNameCmrce=shippingAddressSelected[0].firstName+" "+shippingAddressSelected[0].lastName;
							var	line1Cmrce= shippingAddressSelected[0].addressLine[0];
							var line2Cmrce = shippingAddressSelected[0].addressLine[1];
							var	cityCmrce= shippingAddressSelected[0].city;
							var	stateCmrce= shippingAddressSelected[0].state;  
							var	countryCodeCmrce= shippingAddressSelected[0].country;                                                                                                
							var	postalCodeCmrce=shippingAddressSelected[0].zipCode;
							var	phoneNumber = shippingAddressSelected[0].phone1;
						

						shippingAddressOverrideValues["recipientName"]= recipientNameCmrce;
						shippingAddressOverrideValues["line1"]= line1Cmrce;
						shippingAddressOverrideValues["city"]= cityCmrce;
						shippingAddressOverrideValues["state"]= stateCmrce;
						shippingAddressOverrideValues["countryCode"]= countryCodeCmrce;
						shippingAddressOverrideValues["postalCode"]= postalCodeCmrce;
						if(line2Cmrce != null && line2Cmrce != "" )
							shippingAddressOverrideValues["line2"]= line2Cmrce;
						if(phoneNumber != null && phoneNumber != "" )
							shippingAddressOverrideValues["phone"]= phoneNumber;

						createPayPalPayment["shippingAddressOverride"] = shippingAddressOverrideValues ;
					}
					
					createPayPalPayment["flow"]= "checkout";
					if(isMultiCapEnable == 'true')
						createPayPalPayment["flow"] = "vault";
					createPayPalPayment["amount"]= amountval;
					createPayPalPayment["currency"]= WCParamJS.commandContextCurrency ;
					createPayPalPayment["enableShippingAddress"]= enableShippingAddressFlag;
					createPayPalPayment["shippingAddressEditable"]= shippingAddressEditableFlag;
					
					// Create a client.
					braintree.client.create({
					  authorization : client_token 
					}).then( function (clientInstance) {


						if(advancedFraudTools == "true"){
						// device data
									braintree.dataCollector.create({
										client: clientInstance,
										kount: true
									  }).then(function( dataCollectorInstance) {
										var deviceData = JSON.parse(dataCollectorInstance.deviceData);
										document.querySelector('#deviceSessionId').value = deviceData.device_session_id;
										document.querySelector('#fraudMerchantId').value = deviceData.fraud_merchant_id;
										

									  }).catch(function (err){
											
											console.error("device data error for paypal is",err);
											MessageHelper.displayErrorMessage(BrainTreeMobilePayments.errorMessages["BT_GENERIC_DEVICE_DATA_ERROR"]);
											  return;
											
										});
						}
					
						// Create a PayPal Checkout component.
						  braintree.paypalCheckout.create({
							client: clientInstance
						  }).then(function ( paypalCheckoutInstance ) {
							  
							  // Set up PayPal with the checkout.js library
							 $("#payment_method_BrainTree_PayPal").css("display", "block");
							paypal.Button.render({
								env: environment, // Or 'sandbox'
								commit: true, // This will add the transaction amount to the PayPal button
								payment: function () {
									return paypalCheckoutInstance.createPayment(createPayPalPayment);
								  },

								  onAuthorize: function (data, actions) {
									return paypalCheckoutInstance.tokenizePayment(data, function (err, payload) {
									 
									 BrainTreeMobilePayments.processPayPalResponseFromOrdBilling(isPickUpInStoreFlag , isMultipleShipping,payload,false );
									});
								  },
								  onCancel: function (data) {
									console.log('checkout.js payment cancelled', JSON.stringify(data, 0, 2)); 
									//MessageHelper.displayErrorMessage(BrainTreeMobilePayments.errorMessages["BT_PAYPAL_ONCANCEL"]);	
									return;
								  },
								  onError: function (err) {
									
									console.error('checkout.js error', err); 
									MessageHelper.displayErrorMessage(BrainTreeMobilePayments.errorMessages["BT_PAYPAL_ONERROR"]);	
									return;
								  }
									}, '#'+payPalDivId).then(function () {
									  // The PayPal button will be rendered in an html element with the id
									  // `paypal-button`. This function will be called when the PayPal button
									  // is set up and ready to be used.
									});

								//paypal credit 
							if(isPaypalCreditEnableFlag == 'true'){
								paypal.Button.render({
								env: environment, // Or 'sandbox'
								commit: true, // This will add the transaction amount to the PayPal button
								style: {
										label: 'credit'
									  },
								payment: function () {
									return paypalCheckoutInstance.createPayment(createPayPalPayment);
								  },

								  onAuthorize: function (data, actions) {
									return paypalCheckoutInstance.tokenizePayment(data, function (err, payload) {
									  // Submit `payload.nonce` to your server
									 BrainTreeMobilePayments.processPayPalResponseFromOrdBilling(isPickUpInStoreFlag , isMultipleShipping,payload,true );
									
									});
								  },
								  onCancel: function (data) {
									console.log('checkout.js payment cancelled for paypalcredit', JSON.stringify(data, 0, 2)); 
									//MessageHelper.displayErrorMessage(BrainTreeMobilePayments.errorMessages["BT_PAYPAL_ONCANCEL"]);	
									return;
								  },
								  onError: function (err) {
									
									console.error('checkout.js error for paypalcredit', err); 
									MessageHelper.displayErrorMessage(BrainTreeMobilePayments.errorMessages["BT_PAYPAL_ONERROR"]);	
									return;
								  }
									}, '#'+paypalCreditbutton).then(function () {
									  // The PayPal button will be rendered in an html element with the id
									  // `paypal-button`. This function will be called when the PayPal button
									  // is set up and ready to be used.
									});
								}
						  }).catch(function(paypalCheckoutErr){
								
								console.error("PsyPal checkout error",paypalCheckoutErr);	
								MessageHelper.displayErrorMessage(BrainTreeMobilePayments.errorMessages["BT_PAYPAL_CHECKOUTERROR"]);	
								return;
						  });
						  
					}).catch(function(clientErr){
						console.error("clientError:",clientErr); 
						MessageHelper.displayErrorMessage(BrainTreeMobilePayments.errorMessages["BT_GENERIC_CLIENT_TOKEN_ERROR"]);	
						cursor_clear();
						return;
						
					});
				
			},
	/**
	 * to process the paypal response in mobile page
	 */
processPayPalResponseFromOrdBilling: function(isPickUpInStoreFlag , isMultipleShipping,payload,isPaypalCredit ){

		if( !isPickUpInStoreFlag && !isMultipleShipping ){
			BrainTreePayments.updateShippingAddressFromPaypal(payload ,"S" );
		  }
		
		document.getElementById("pay_nonce").value=payload.nonce;
		document.getElementById("pay_type").value = payload.type;
		if(isPaypalCredit){
			document.getElementById("pay_type").value= "PayPalCredit";
			document.getElementById("payMethodId_BT").value = "ZPayPalCredit";
		}else{
			document.getElementById("payMethodId_BT").value =document.getElementById("payment_method").value; 
		}
		document.querySelector('#PayPalEmailId').value = payload.details.email;
		
		

		document.getElementById("fromSavedPaymentFlag").value = "false";
		
		if(document.getElementById("savePaymentCheckBox")!=null){//for guest user,doesn't have option to save payment
			if(document.getElementById("savePaymentCheckBox").checked==true){
				document.getElementById("save_card").value =  "true";
				}
				}
		document.getElementById("payment_method_form_BrainTree_NewPayments").submit();	
},
/**
 * To handle Venmo payment in mobile page
 */
venmoPayment:function(clientToken,venmoButton){
						// Create a client.
									braintree.client.create({
									  authorization: clientToken  
									}).then(function (clientInstance) {
									  // You may need to polyfill Promise
									  // if used on older browsers that
									  // do not natively support it.

										// devicedata
										if(advancedFraudTools == "true"){
											// device data
											braintree.dataCollector.create({
												client: clientInstance,
												kount: true
											  }).then(function( dataCollectorInstance) {
												var deviceData = JSON.parse(dataCollectorInstance.deviceData);
												document.querySelector('#deviceSessionId').value = deviceData.device_session_id;
												document.querySelector('#fraudMerchantId').value = deviceData.fraud_merchant_id;
											  }).catch(function (err){
													console.error("device data error for paypal is",err);
													MessageHelper.displayErrorMessage(BrainTreeMobilePayments.errorMessages["BT_GENERIC_DEVICE_DATA_ERROR"]);
													  return;
													
												});
										}

									  return Promise.all([
										braintree.dataCollector.create({
										  client: clientInstance,
										  paypal: true
										}),
										braintree.venmo.create({
										  client: clientInstance,
										  // Add allowNewBrowserTab: false if your checkout page does not support
										  // relaunching in a new tab when returning from the Venmo app. This can
										  // be omitted otherwise.
										  allowNewBrowserTab: false
										})
									  ]);
									}).then(function (results) {
									  var dataCollectorInstance = results[0];
									  var venmoInstance = results[1];

									  console.log('Got device data:', dataCollectorInstance.deviceData);
									  
									  // Verify browser support before proceeding.
									 if (!venmoInstance.isBrowserSupported()) {
										console.log('Browser does not support Venmo');
										MessageHelper.displayErrorMessage(BrainTreeMobilePayments.errorMessages["BT_VENMO_BROWSER_NOT_SUPPORTED"]);
										return;
									  }
									 
									  displayVenmoButton(venmoInstance);
									
									  // Check if tokenization results already exist. This occurs when your
									  // checkout page is relaunched in a new tab. This step can be omitted
									  // if allowNewBrowserTab is false.
									  if (venmoInstance.hasTokenizationResult()) {
										venmoInstance.tokenize().then(handleVenmoSuccess).catch(handleVenmoError);
									  }
									});

									function displayVenmoButton(venmoInstance) {
									  $("#payment_method_BrainTree_Venmo").css("display", "block");

									 // Assumes that venmoButton is initially display: none.
									  venmoButton.style.display = 'block';
						
									  venmoButton.addEventListener('click', function () {
										venmoButton.disabled = true;

										venmoInstance.tokenize().then(handleVenmoSuccess).catch(handleVenmoError);
									  });
									}

									function handleVenmoError(err) {
									  if (err.code === 'VENMO_CANCELED') {
										console.log('App is not available or user aborted payment flow');
										MessageHelper.displayErrorMessage(BrainTreeMobilePayments.errorMessages["BT_VENMO_ERROR_VENMO_CANCELLED"]);
										
										
									  } else if (err.code === 'VENMO_APP_CANCELED') {
										console.log('User canceled payment flow');
										MessageHelper.displayErrorMessage(BrainTreeMobilePayments.errorMessages["BT_VENMO_ERROR_VENMO_APP_CANCELLED"]);
									  } else {
										console.error('An error occurred:', err.message);
										MessageHelper.displayErrorMessage(BrainTreeMobilePayments.errorMessages["BT_VENMO_ERROR_GENERIC"]);	
									  }
									  console.error("venmo error:",err);
									  return;
									}

									function handleVenmoSuccess(payload) {
									  // Send the payment method nonce to your server
									
									  console.log('Got a payment method nonce:', payload.nonce);
									  // Display the Venmo username in your checkout UI.
									  console.log('Venmo user:', payload.details.username);
										
										document.getElementById("payMethodId_BT").value =document.getElementById("payment_method").value; //"ZVenmo";
										 document.getElementById("pay_nonce").value = payload.nonce;//"fake-venmo-account-nonce";
										  document.getElementById("pay_type").value =payload.type; // document.getElementById("payment_method").value;
										  document.getElementById("fromSavedPaymentFlag").value = "false";
										  document.getElementById("save_card").value =  "false";
										document.getElementById("payment_method_form_BrainTree_NewPayments").submit();
										
										
									}
			},
			/**
			 *  Genrating payload object and consuming it  on submit of credit card for mobile page
			 */
	creditCardOnSubmit:function(inst){
		var fromSavedPaymentFlag=document.getElementById("fromSavedPaymentFlag").value ;
		inst.tokenize(function (tokenizeErr, payload) {
							
							console.error("tokenizeErr:",tokenizeErr)
			 				 if (tokenizeErr) {
			   					 var tokenizeErrMsg="";
								 switch (tokenizeErr.code) {
			      					case 'HOSTED_FIELDS_FIELDS_EMPTY':
			       						 console.error('All fields are empty! Please fill out the form.');
										 tokenizeErrMsg=BrainTreeMobilePayments.errorMessages["BT_HOSTEDFIELDS_EMPTY"];
			        					 break;
			    				  	case 'HOSTED_FIELDS_FIELDS_INVALID':
			       						 console.error('Some fields are invalid:', tokenizeErr.details.invalidFieldKeys);
										 tokenizeErrMsg=BrainTreeMobilePayments.errorMessages["BT_HOSTEDFIELDS_INVALID"];
			        					 break;
			      					case 'HOSTED_FIELDS_TOKENIZATION_FAIL_ON_DUPLICATE':
			        					 console.error('This payment method already exists in your vault.');
										 tokenizeErrMsg=BrainTreeMobilePayments.errorMessages["BT_HOSTEDFIELDS_TOKENIZATION_FAIL_ON_DUPLICATE"];
			        					break;
						      		case 'HOSTED_FIELDS_TOKENIZATION_CVV_VERIFICATION_FAILED':
						        		console.error('CVV did not pass verification');
										tokenizeErrMsg=BrainTreeMobilePayments.errorMessages["BT_HOSTEDFIELDS_TOKENIZATION_CVV_VERIFICATION_FAILED"];
										break;
								      case 'HOSTED_FIELDS_FAILED_TOKENIZATION':
								       console.error('Tokenization failed server side. Is the card valid?');
									  tokenizeErrMsg=BrainTreeMobilePayments.errorMessages["BT_HOSTEDFIELDS_FAILED_TOKENIZATION"];
								        break;
								      case 'HOSTED_FIELDS_TOKENIZATION_NETWORK_ERROR':
								        console.error('Network error occurred when tokenizing.');
										tokenizeErrMsg=BrainTreeMobilePayments.errorMessages["BT_HOSTEDFIELDS_NETWORK_ERROR"];
								        break;	
								      default:
								        console.error('Something bad happened!', tokenizeErr);
										tokenizeErrMsg= BrainTreeMobilePayments.errorMessages["BT_HOSTEDFIELDS_DEFAULT_ERROR"];
								   }
										var errorMessageField = "hostedFieldsErrorMessage";

										if(fromSavedPaymentFlag == "true"){
											errorMessageField = "CVVhostedFieldsErrorMessage";
											
											if(tokenizeErr.code == 'HOSTED_FIELDS_FIELDS_EMPTY'){
											tokenizeErrMsg = BrainTreeMobilePayments.errorMessages["BT_CVV_FIELD_EMPTY"];
											}
											else if(tokenizeErr.code == 'HOSTED_FIELDS_FIELDS_INVALID'){
												tokenizeErrMsg = BrainTreeMobilePayments.errorMessages["BT_CVV_FIELD_INVALID"];
											}
										}
										
										$("#"+errorMessageField).css("display", "block");
										document.getElementById(errorMessageField).innerHTML=tokenizeErrMsg;
										

								} else {
										
										// for saved payments
										if(fromSavedPaymentFlag == "true"){
											document.querySelector('#cvv_nonce').value = payload.nonce;
											
											//do card verification and do 3dsecure check if property is enabled in properties file
											var params = [];
											params["storeId"] = WCParamJS.storeId;
											params["catalogId"] = WCParamJS.catalogId;
											params["langId"] = WCParamJS.langId;
											params["pay_token"]=document.querySelector('#pay_token').value;
											params["cvv_nonce"]=document.querySelector('#cvv_nonce').value;
											params["payment_method_id"]=document.querySelector('#payMethodId_BT').value;
											params["device_session_id"]=document.querySelector('#deviceSessionId').value; 
											params["fraud_merchant_id"]=document.querySelector('#fraudMerchantId').value;
											wcService.invoke('AjaxRESTVaultedCreditCardVerificationForMobilePayments', params);
											
											
										}else{ //for new payments
											
											document.getElementById("payMethodId_BT").value =document.getElementById("payment_method").value; //"ZVenmo";
											 document.getElementById("pay_nonce").value =  payload.nonce;
										 	 document.getElementById("pay_type").value = payload.details.cardType;
										 	 document.getElementById("account").value ="**************"+payload.details.lastTwo;
										  	document.getElementById("fromSavedPaymentFlag").value = "false";
											
											if(document.getElementById("saveCardCheckBox")!=null){
												if(document.getElementById("saveCardCheckBox").checked == true){
													document.getElementById("save_card").value = "true";
												}
											}
											var paynonce=payload.nonce;
											if(threeDSecureEnable == 'true')
												BrainTreeMobilePayments.threeDSecureCheck(paynonce);
											else
												document.getElementById("payment_method_form_BrainTree_NewPayments").submit();
										}
										
									}
			  			 });
	},
	/**
	 * on click of google pay button in mobile page
	 */
	googlePayOnClick:function(amount){
		var googlePayInstance=instances_BT["googlePay"];
		var paymentsClient=gPayPaymentsClient_BT["googlePay"];
		var paymentDataRequest = googlePayInstance.createPaymentDataRequest({
						//merchantId: googlePayPaymentMerchantId, //not needed for sandbox testing
						transactionInfo: {
						  currencyCode: WCParamJS.commandContextCurrency,
						  totalPriceStatus: 'FINAL',
						  totalPrice: amount
						},
						cardRequirements: {
						  // We recommend collecting billing address information, at minimum
						  // billing postal code, and passing that billing postal code with all
						  // Google Pay transactions as a best practice
						  billingAddressRequired: true
						}
					  });
					  paymentsClient.loadPaymentData(paymentDataRequest).then(function(paymentData) {
						  
						googlePayInstance.parseResponse(paymentData, function (err, result) {
						  if (err) {
							console.error("err parsing::",err);
							MessageHelper.displayErrorMessage(BrainTreeMobilePayments.errorMessages["BT_GOOGLEPAY_PARSING_ERROR"]);	
							
							return ;
						  }
						  // Send result.nonce to your server
							
							document.querySelector('#pay_nonce').value = result.nonce;
							document.querySelector('#pay_type').value = result.type;
							document.getElementById("payMethodId_BT").value =document.getElementById("payment_method").value; 
							document.getElementById("fromSavedPaymentFlag").value = "false";
							document.getElementById("save_card").value =  "false";
							document.getElementById("payment_method_form_BrainTree_NewPayments").submit(); 
										
								
						});
					  }).catch(function (err) {
						MessageHelper.displayErrorMessage(BrainTreeMobilePayments.errorMessages["BT_GOOGLEPAY_ERROR_AT_LOADPAYMENTDATA"]);	
						console.error("error when loadPaymentData is failed:",err);
						return;
					  });
					  
	},
	/**
	 * to display the selected saved payment in mobile page
	 */
	displaySelectedPayment:function(clientToken,listInfo){
		
		//close  new payments that are open
		 var paymentMethod = document.getElementById("payment_method");
		  document.getElementById("payment_method").value="";
		$("#payment_method_BrainTree_Venmo").css("display", "none");
		$("#payment_method_BrainTree_CreditCard").css("display", "none");
		$("#payment_method_BrainTree_GooglePay").css("display", "none");
		$("#payment_method_BrainTree_PayPal").css("display", "none");
		$("#payment_method_BrainTree_ApplePay").css("display", "none");
		
		var continueCheckoutBtnId = document.getElementById("continueCheckoutBtn");
		continueCheckoutBtnId.classList.remove("btn-disabled-BT");
		
		
		
		var savedCardsList = document.getElementById("savedCardsList");
			var selectedCardpayToken = savedCardsList.options[savedCardsList.selectedIndex].value;

			//appending values in div and dispaying the div
			var parsedListInfo=JSON.parse(listInfo);
			
			if(selectedCardpayToken!=""){
				for(i=0;i<parsedListInfo.length;i++)
				{
					var cardToken=parsedListInfo[i].payTokenId;
					
					if(cardToken==selectedCardpayToken){
						var cardInfo=parsedListInfo[i];
 
							// if selected payment is paypal
							if(cardInfo.cardType=="PayPalAccount" || cardInfo.cardType=="PayPalCredit"){
								
								
								document.getElementById("paymentAccountMail").innerHTML=cardInfo.maskedCreditCardNumber;
								document.querySelector('#pay_token').value = cardToken;
								document.querySelector('#pay_type').value = cardInfo.cardType;
								document.querySelector('#payMethodId_BT').value = "ZPayPal"; //get this from table
								if(cardInfo.cardType=="PayPalCredit"){
									document.querySelector('#payMethodId_BT').value = "ZPayPalCredit"; //get this from table
								}
								$("#showSavedCard").css("display", "block");
								$("#deleteCard").css("display", "block");
								$("#savedPaymentInfo").css("display", "block");
								$("#savedCreditCardInfo").css("display", "none");
									
								
							}else{ // is selected payment is card, (because  we are giving option to user to save only PayPal and Card)
								var cardNum=cardInfo.maskedCreditCardNumber;
								var expiryDate=cardInfo.expirationDate;
								
								// adding the data to the div
								document.getElementById("maskedcardNumber").innerHTML=cardNum;
								document.getElementById("expiryDate").innerHTML=expiryDate;

								$("#showSavedCard").css("display", "block");
								$("#deleteCard").css("display", "block");
								$("#savedCreditCardInfo").css("display", "block");
								$("#savedPaymentInfo").css("display", "none");
								document.getElementById("onlyCvv").innerHTML = "";
								this.displayCVV(clientToken);
								//assigning values to hidden params, which are passed to PIAdd execution
								document.querySelector('#pay_token').value = cardToken;
								document.querySelector('#account').value = cardInfo.maskedCreditCardNumber;
								document.querySelector('#pay_type').value = cardInfo.cardType;
								document.querySelector('#payMethodId_BT').value = "ZCreditCard"; //get this from table
							}

								document.querySelector('#fromSavedPaymentFlag').value = "true"; 
					}
				}
			}
			else
			{
				$("#showSavedCard").css("display", "none");	
			}
		
	},
	/**
	 *to display CVV field when selected saved card is displayed 
	 */
	displayCVV:function(clientToken){
		braintree.client.create({
								 authorization: clientToken
								 }).then( function(clientInstance) {
											
										// device data	
										if(advancedFraudTools == "true"){
											
											braintree.dataCollector.create({
													client: clientInstance,
													kount: true
												  }).then(function(dataCollectorInstance) {
													var deviceData = JSON.parse(dataCollectorInstance.deviceData);
													document.querySelector('#deviceSessionId').value = deviceData.device_session_id;
													document.querySelector('#fraudMerchantId').value = deviceData.fraud_merchant_id;
													
												  }).catch(function (err){
														console.error(" device data error for displaying CVV field  :",err);
														MessageHelper.displayErrorMessage(BrainTreeMobilePayments.errorMessages["BT_GENERIC_DEVICE_DATA_ERROR"]);		
														  return;
														
												});
										}
											
											
											//hosted fields
											braintree.hostedFields.create({
											client: clientInstance,
											styles: {
												'input': {
												   'font-size': '14px'
																							
												},
												'input.invalid': {
												   'color': 'red'
												},
												'input.valid': {
												   'color': 'green'
												}
											},
											fields: {
												
												cvv: {
													selector: '#onlyCvv'
												}
												
											}
																			  
											}).then(function (hostedFieldsInstance) {
																				 
												var keyforInst="cvvInst";
												instances_BT[keyforInst]=hostedFieldsInstance;
												console.log("hostedFieldsInstance"+hostedFieldsInstance);
												console.log(hostedFieldsInstance);
											}).catch( function (hostedFieldsErr){
												
												console.error("hostedFieldsErr:",hostedFieldsErr);
												var hostedFieldsErrMsg="";
												if(hostedFieldsErr){
													$("#hostedFieldsErrorMessage").css("display", "block"); 
													switch (hostedFieldsErr.code) {
														case 'HOSTED_FIELDS_TIMEOUT':
															hostedFieldsErrMsg= "Please try placing order after sometime"; //unknown error .
															//Occurs when Hosted Fields does not finish setting up within 60 seconds.
															 break;
														case 'HOSTED_FIELDS_INVALID_FIELD_KEY':
															 hostedFieldsErrMsg= "Please try placing order after sometime"; //merchant error
															 break;
														case 'HOSTED_FIELDS_INVALID_FIELD_SELECTOR':
															hostedFieldsErrMsg= "Please try placing order after sometime"; //merchant error
															break;
														case 'HOSTED_FIELDS_FIELD_DUPLICATE_IFRAME':  
															hostedFieldsErrMsg= "Please try placing order after sometime"; //merchant error
															break;
														case 'HOSTED_FIELDS_FIELD_PROPERTY_INVALID':
															hostedFieldsErrMsg= "Please try placing order after sometime"; //merchant error
															break;  
														default:
															hostedFieldsErrMsg= "Please try placing order after sometime"; //merchant error
													}
												}
																				  
													hostedFieldsErrMsg=BrainTreeMobilePayments.errorMessages["BT_HOSTEDFIELDS_HOSTEDFIELDSERR_FOR_CVV"];							  
													document.getElementById("hostedFieldsErrorMessage").innerHTML=hostedFieldsErrMsg;
													
													return;
												
									});
																			
																	   
							}).catch( function(clientErr) {
																			
								 
								console.error("clientErr:",clientErr);
								var createErrMsg="";
								$("#hostedFieldsWrapper").css("display", "none"); //if error occurs don't displaywrapper
								MessageHelper.displayErrorMessage(BrainTreeMobilePayments.errorMessages["BT_GENERIC_CLIENT_TOKEN_ERROR"]);	
								cursor_clear();
									return;
							 });
	},

/**
 * to display apple pay button in mobile page
 */
applePayPayment:function(applePaybuttonId,clientToken){


var button = applePaybuttonId;
				
			// apple pay
					if (!window.ApplePaySession) {
					  MessageHelper.displayErrorMessage(BrainTreeMobilePayments.errorMessages["BT_APPLEPAY_DEVICE_NOT_SUPPORTED"]);	
					  return;
					}

					if (!ApplePaySession.canMakePayments()) {
					  console.error('This device is not capable of making Apple Pay payments');
					  MessageHelper.displayErrorMessage(BrainTreeMobilePayments.errorMessages["BT_APPLEPAY_DEVICE_NOT_CAPABLE"]);	
					  return;
					}
					else
				braintree.client.create({
				  authorization: clientToken
				}).then( function (clientInstance) {
				  
				
					//device data
				if(advancedFraudTools == "true"){
						braintree.dataCollector.create({
							client: clientInstance,
							kount: true
						  }).then(function( dataCollectorInstance) {
							// At this point, you should access the
							// dataCollectorInstance.deviceData value and
							// provide it
							// to your server, e.g. by injecting it into your
							// form as a hidden input.
							var deviceData = JSON.parse(dataCollectorInstance.deviceData);
							document.querySelector('#deviceSessionId').value = deviceData.device_session_id;
							document.querySelector('#fraudMerchantId').value = deviceData.fraud_merchant_id;

						  }).catch(function (err){
								
								console.error("device data error apple pay",err);
								MessageHelper.displayErrorMessage(BrainTreeMobilePayments.errorMessages["BT_GENERIC_DEVICE_DATA_ERROR"]);		
								 return;
								
							});
				}
							
				// apple pay
							braintree.applePay.create({
							client: clientInstance
						  }, function (applePayErr, applePayInstance) {
							if (applePayErr) {
							  console.error('Error creating applePayInstance:', applePayErr);
							 MessageHelper.displayErrorMessage(BrainTreeMobilePayments.errorMessages["BT_APPLEPAY_APPLEPAY_ERR"]);	
							  return;
							}

							var promise = ApplePaySession.canMakePaymentsWithActiveCard(applePayInstance.merchantIdentifier);
							promise.then(function (canMakePaymentsWithActiveCard) {
							  if (canMakePaymentsWithActiveCard) {
									// Set up Apple Pay buttons
									//displaying apple pay button only if the instance is created
									$("#applePay").css("display","block");
									$("#"+applePaybuttonId).css("display", "block");
									var keyForInst="applePay";
									instances_BT[keyForInst]=applePayInstance;
							  }
							});
						  });

				}).catch(function(clienterr){
					console.log("clienterr",clienterr);
					MessageHelper.displayErrorMessage(BrainTreeMobilePayments.errorMessages["BT_GENERIC_CLIENT_TOKEN_ERROR"]);	
				});
		},
		/**
		 * on click of apple pay button in mobile page
		 */
		applePayOnClick:function(amount){
					var applePayInstance=instances_BT["applePay"];
					var paymentRequest = applePayInstance.createPaymentRequest({
				  total: {
					label: 'My Store',
					amount: amount
				  },

				  // We recommend collecting billing address information, at
					// minimum
				  // billing postal code, and passing that billing postal code
					// with
				  // all Apple Pay transactions as a best practice.
				  requiredBillingContactFields: ["postalAddress"]
				});
				console.log(paymentRequest.countryCode);
				console.log(paymentRequest.currencyCode);
				console.log(paymentRequest.merchantCapabilities);
				console.log(paymentRequest.supportedNetworks);
				
				var session = new ApplePaySession(2, paymentRequest);
					session.onvalidatemerchant = function (event) {
				  applePayInstance.performValidation({
					validationURL: event.validationURL,
					displayName: 'My Store'
				  }, function (err, merchantSession) {
					if (err) {
						console.log("apple pay failed to load",err);
						MessageHelper.displayErrorMessage(BrainTreeMobilePayments.errorMessages["BT_APPLEPAY_PERFORM_VALIDATION_ERR"]);	
					  return;
					}
					session.completeMerchantValidation(merchantSession);
					
				  });
				};
						
						session.onpaymentauthorized = function (event) {
					  applePayInstance.tokenize({
						token: event.payment.token
					  }, function (tokenizeErr, payload) {
						if (tokenizeErr) {
						  console.error('Error tokenizing Apple Pay:', tokenizeErr);
						 MessageHelper.displayErrorMessage(BrainTreeMobilePayments.errorMessages["BT_APPLEPAY_TOKENIZEERR"]);	
						  session.completePayment(ApplePaySession.STATUS_FAILURE);
						  return;
						}
						
						session.completePayment(ApplePaySession.STATUS_SUCCESS);

						// Send payload.nonce to your server.
						console.log('nonce:', payload.nonce);
						alert("payload.type: "+payload.type);
						document.querySelector('#pay_nonce').value = payload.nonce;
						document.querySelector('#pay_type').value = payload.type;
							document.getElementById("payMethodId_BT").value =document.getElementById("payment_method").value; 
							document.getElementById("fromSavedPaymentFlag").value = "false";
							document.getElementById("save_card").value =  "false";
							document.getElementById("payment_method_form_BrainTree_NewPayments").submit(); 
						// If requested, address information is accessible in
						// event.payment
						// and may also be sent to your server.
						console.log('billingPostalCode:', event.payment.billingContact.postalCode);
					  });
					};
					session.begin();
					
	},
	/***
	 * 3D secure check in mobile page
	 */
	threeDSecureCheck : function(paynonce){
			
			var bankFrame = document.querySelector('.bt-modal-body');
			braintree.client.create({
			  // Use the generated client token to instantiate the Braintree client.
			  authorization: btClientToken
			}, function (clientErr, clientInstance) {
			  if (clientErr) {
				console.log("clientErr",clientErr);
				MessageHelper.displayErrorMessage(BrainTreeMobilePayments.errorMessages["BT_GENERIC_CLIENT_TOKEN_ERROR"]);	
				return;
			  }

			  braintree.threeDSecure.create({
				client: clientInstance
			  }, function (threeDSecureErr, threeDSecureInstance) {
				if (threeDSecureErr) {
				  // Handle error in 3D Secure component creation
				  console.error("threeDSecureErr:",threeDSecureErr);
				  MessageHelper.displayErrorMessage(BrainTreeMobilePayments.errorMessages["BT_THREE_D_SECURE_ERROR"]);	
				  return;
				}
				console.log("threeDSecureInstance",threeDSecureInstance);
				
				threeDSecureInstance.verifyCard({
				  amount: grandTotalAmount,
				  nonce:  paynonce ,// NONCE_FROM_INTEGRATION,
				  addFrame: function (err, iframe) {
					// Set up your UI and add the iframe.
					 bankFrame.appendChild(iframe);
					$(".threeDsecureWindow").css("display", "flex"); 
				  },
				  removeFrame: function () {
					// Remove UI that you added in addFrame.
					
					var iframe = bankFrame.querySelector('iframe');
					$(".threeDsecureWindow").css("display", "none");
					iframe.parentNode.removeChild(iframe);
				  }
				}, function (err, response) {
				  // Send response.nonce to use in your transaction
					if (err) {
						console.error("error when response failed to generate:",err);
						MessageHelper.displayErrorMessage(BrainTreeMobilePayments.errorMessages["BT_THREE_D_SECURE_RESPONSE_FAILED_ERROR"]);	
						return;
					  }
					var threeDNonce = response.nonce;
					document.getElementById('3Dsecure_nonce').value = threeDNonce;
					document.getElementById("payment_method_form_BrainTree_NewPayments").submit(); 
					
				});
					//when clicked on close button of frame
					 var closeFrame = document.getElementById('text-close');
					 closeFrame.addEventListener('click', function () {
						threeDSecureInstance.cancelVerifyCard(removeFrame());
						});
					 function removeFrame() {
					// Remove UI that you added in addFrame.
						var iframe = bankFrame.querySelector('iframe');
						$(".threeDsecureWindow").css("display", "none");
						iframe.parentNode.removeChild(iframe);
					 }
			  });
			});
		}
}
