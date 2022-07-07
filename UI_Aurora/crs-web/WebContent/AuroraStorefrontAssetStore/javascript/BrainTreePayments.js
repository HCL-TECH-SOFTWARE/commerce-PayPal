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
 * @fileOverview This JavaScript file contains functions used by the payment
 *               section of the checkout pages.
 */

if (BrainTreePayments == null || typeof(BrainTreePayments) != "object") {
	var BrainTreePayments = new Object();
}

BrainTreePayments = {
	
	paypalBillingAddsId: {},
	
		/**
		 * Sets common parameters used by this JavaScript object
		 * 
		 * @param {String}
		 *            langId language ID to use
		 * @param {String}
		 *            storeId store ID to use
		 * @param {String}
		 *            catalog Catalog ID to use
		 */
		setCommonParameters:function(langId,storeId,catalogId){
			this.langId = langId;
			this.storeId = storeId;
			this.catalogId = catalogId;
		},

	checkPaypalStoreSelectionForm:function(){
		document.getElementById("paypalCheckoutButton").style.display="block";
	},

	
	
	/**
	 * to delete the saved payment from vault that is choosen to be deleted
	 */
		deleteSelectedCardFromVault:function(payToken){
			var savedCardsList = document.getElementById("savedCardsList");
			if(payToken != null){
				var selectedCardpayToken = payToken;
			}
			else{
				var selectedCardpayToken = savedCardsList.options[savedCardsList.selectedIndex].value;
			}
			var params = [];
			params["storeId"] = WCParamJS.storeId;
			params["catalogId"] = WCParamJS.catalogId;
			params["langId"] = this.langId;
			params["pay_token"]=selectedCardpayToken;
			wcService.invoke('AjaxRESTDeleteCardFromBraintreeVault', params); // AjaxDeleteCardFromBraintreeVault
		},

		/**
		 *  to display the selected payment from the saved payments section
		 */
		displaySelectedCard:function(clientToken,statusCount,listInfo)
		{

			var savedCardsList = document.getElementById("savedCardsList");
			var selectedCardpayToken = savedCardsList.options[savedCardsList.selectedIndex].value;

			// appending values in div and dispaying the div
			var parsedListInfo=JSON.parse(listInfo);
				
			if(selectedCardpayToken!=""){
				for(i=0;i<parsedListInfo.length;i++)
				{
					var cardToken=parsedListInfo[i].payTokenId;
					if(cardToken==selectedCardpayToken){
						var cardInfo=parsedListInfo[i];
						// if PayPal is the selected saved  payment
						if(cardInfo.cardType=="PayPalAccount" || cardInfo.cardType=="PayPalCredit"){
							document.getElementById("paymentAccountMail").innerHTML=cardInfo.maskedCreditCardNumber;
							document.querySelector('#pay_token').value = cardToken;
							document.querySelector('#pay_type').value = cardInfo.cardType;
							document.querySelector('#PaymentMethodId').value  = cardInfo.paymentMethodId;
							$("#savedPaymentInfo").css("display", "block"); // showing PayPal div
							$("#savedCreditCardInfo").css("display", "none"); 
							
						}else{ //if card is the selected saved  payment (because presently we are giving options to the user to save only  PayPal and cards)
								var cardNum=cardInfo.maskedCreditCardNumber;
								var expiryDate=cardInfo.expirationDate;
								// adding the data to the div
								document.getElementById("maskedcardNumber").innerHTML=cardNum;
								document.getElementById("expiryDate").innerHTML=expiryDate;
								document.getElementById("onlyCvv_"+statusCount).innerHTML = "";
								this.displayCVV(clientToken,statusCount);
								// assigning values to hidden params, which are passed to PIAdd execution
								document.querySelector('#pay_token').value = cardToken;
								document.querySelector('#account').value = cardInfo.maskedCreditCardNumber;
								document.querySelector('#pay_type').value = cardInfo.cardType;
								document.querySelector('#PaymentMethodId').value  = cardInfo.paymentMethodId;
								$("#savedPaymentInfo").css("display", "none");
								$("#savedCreditCardInfo").css("display", "block"); //showing creditcard div
							}
						// saved payment information div and delete payment option
						$("#showSavedCard").css("display", "block");
						$("#deleteCard").css("display", "block");
					}
				}
			}
			else
				{
					// if paytoken is empty, not showing the saved payment information div
					$("#showSavedCard").css("display", "none");	
				}
		},
			/**
			 *  to display CVV field,while displaying saved card information
			 */ 
			displayCVV:function(clientToken,statusCount) {
							braintree.client.create({
									 authorization: clientToken
									 }).then( function(clientInstance) {
												// hosted fields
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
														selector: '#onlyCvv_'+statusCount
													}
													
												}
																				  
											}).then(function (hostedFieldsInstance) {
												var keyforInst="cvvInst"+statusCount;
												var i=[];
												instances_BT[keyforInst]=hostedFieldsInstance;
												console.log("hostedFieldsInstance",hostedFieldsInstance);
												
											}).catch( function (hostedFieldsErr){
												if (hostedFieldsErr) {
													console.error("hostedFieldsError:",hostedFieldsErr);
													var paymentMethodNumberSelected=statusCount;
													var hostedFieldsErrMsg="";
													$("#hostedFieldsErrorMessage_"+statusCount).css("display", "block"); 
													switch (hostedFieldsErr.code) {
														case 'HOSTED_FIELDS_TIMEOUT':
															hostedFieldsErrMsg=  CheckoutPayments.errorMessages["BT_HOSTEDFIELDS_HOSTEDFIELDSERR_FOR_CVV"]; 
															 break;
														case 'HOSTED_FIELDS_INVALID_FIELD_KEY':
															 hostedFieldsErrMsg= CheckoutPayments.errorMessages["BT_HOSTEDFIELDS_HOSTEDFIELDSERR_FOR_CVV"]; // merchnat
																															// error
															 break;
														case 'HOSTED_FIELDS_INVALID_FIELD_SELECTOR':
															hostedFieldsErrMsg=  CheckoutPayments.errorMessages["BT_HOSTEDFIELDS_HOSTEDFIELDSERR_FOR_CVV"]; // merchnat
																															// error
															break;
														case 'HOSTED_FIELDS_FIELD_DUPLICATE_IFRAME':  
															hostedFieldsErrMsg=  CheckoutPayments.errorMessages["BT_HOSTEDFIELDS_HOSTEDFIELDSERR_FOR_CVV"]; // merchnat
																															// error
															break;
														case 'HOSTED_FIELDS_FIELD_PROPERTY_INVALID':
															hostedFieldsErrMsg=  CheckoutPayments.errorMessages["BT_HOSTEDFIELDS_HOSTEDFIELDSERR_FOR_CVV"]; // merchnat
																															// error
															break;  
														default:
															hostedFieldsErrMsg=  CheckoutPayments.errorMessages["BT_HOSTEDFIELDS_HOSTEDFIELDSERR_FOR_CVV"]; // merchnat
													} //TODO assign value to hostedFieldsErrMsg from property file
												document.getElementById("hostedFieldsErrorMessage_"+paymentMethodNumberSelected).innerHTML=hostedFieldsErrMsg;
												return;
												}	
											});
									 }).catch( function(clientErr) {
										 console.error("clientError:",clientErr);
										 var paymentMethodNumberSelected=statusCount;
										 var createErrMsg="";
										 if(clientErr){
											 $("#hostedFieldsWrapper_"+statusCount).css("display", "none"); 
											 MessageHelper.displayErrorMessage(CheckoutPayments.errorMessages["BT_GENERIC_CLIENT_TOKEN_ERROR"]);	
											 cursor_clear();
										 }									  
										return;
									 });
			},


		/**
		 * TO consume the braintree instances created after clicking on Next button of orderShippingBillingDetailsPage and  generate payload object from these instances.
		 */
		brainTreeInstances:function(inst,piFormName,paymentMethodNumberSelected,fromSavedPaymentFlag)
		{
			// instance of either saved creditcards or new credit cards	
			inst.tokenize(function (tokenizeErr, payload) {
				 				 if (tokenizeErr) { //error occured
				   					 console.error("tokenizeErr:",tokenizeErr);
									 var tokenizeErrMsg="";
									 switch (tokenizeErr.code) {
				      					case 'HOSTED_FIELDS_FIELDS_EMPTY':
											 tokenizeErrMsg=CheckoutPayments.errorMessages["BT_HOSTEDFIELDS_EMPTY"];
				        					 break;
				    				  	case 'HOSTED_FIELDS_FIELDS_INVALID':
				       						 console.error('Some fields are invalid:', tokenizeErr.details.invalidFieldKeys);
											 tokenizeErrMsg=CheckoutPayments.errorMessages["BT_HOSTEDFIELDS_INVALID"];// " Required  Fields are invalid. ";
				        					 break;
				      					case 'HOSTED_FIELDS_TOKENIZATION_FAIL_ON_DUPLICATE':
				        					 console.error('This payment method already exists in your vault.');
											 tokenizeErrMsg=CheckoutPayments.errorMessages["BT_HOSTEDFIELDS_TOKENIZATION_FAIL_ON_DUPLICATE"];
				        					break;
							      		case 'HOSTED_FIELDS_TOKENIZATION_CVV_VERIFICATION_FAILED':
							        		console.error('CVV did not pass verification');
											tokenizeErrMsg=CheckoutPayments.errorMessages["BT_HOSTEDFIELDS_TOKENIZATION_CVV_VERIFICATION_FAILED"];
											break;
									      case 'HOSTED_FIELDS_FAILED_TOKENIZATION':
									       console.error('Tokenization failed server side. Is the card valid?');
										   tokenizeErrMsg=CheckoutPayments.errorMessages["BT_HOSTEDFIELDS_FAILED_TOKENIZATION"];
									        break;
									      case 'HOSTED_FIELDS_TOKENIZATION_NETWORK_ERROR':
									        console.error('Network error occurred when tokenizing.');
											tokenizeErrMsg=CheckoutPayments.errorMessages["BT_HOSTEDFIELDS_NETWORK_ERROR"];
									        break;	
									      default:
									       // alert('Something bad happened!', tokenizeErr);
											tokenizeErrMsg= CheckoutPayments.errorMessages["BT_HOSTEDFIELDS_DEFAULT_ERROR"];
									 }
									 var errorMessageField = "hostedFieldsErrorMessage_"+paymentMethodNumberSelected;
									 if(fromSavedPaymentFlag == 'true'){
										 errorMessageField = "CVVhostedFieldsErrorMessage_"+paymentMethodNumberSelected;
										if(tokenizeErr.code == 'HOSTED_FIELDS_FIELDS_EMPTY'){
											tokenizeErrMsg = CheckoutPayments.errorMessages["BT_CVV_FIELD_EMPTY"];
										}
										else if(tokenizeErr.code == 'HOSTED_FIELDS_FIELDS_INVALID'){
											tokenizeErrMsg = CheckoutPayments.errorMessages["BT_CVV_FIELD_INVALID"];
										}
									 }
									$("#"+errorMessageField).css("display", "block");
									document.getElementById(errorMessageField).innerHTML=tokenizeErrMsg;
									
									return;
				 				 } 
				 				 else{ //payload object generated
										
				 					 // instance is of saved card,so payload object is of saved card
				 					 if(fromSavedPaymentFlag == 'true'){
				 						 document.querySelector('#cvv_nonce').value = payload.nonce;
										 var params = [];
										params["storeId"] = WCParamJS.storeId;
										params["catalogId"] = WCParamJS.catalogId;
										params["langId"] = WCParamJS.langId;
										params["pay_token"]=document.querySelector('#pay_token').value;
										params["cvv_nonce"]=document.querySelector('#cvv_nonce').value;
										params["billing_address_id"]=document.querySelector('#billing_address_id_1').value;
										params["payment_method_id"]=document.querySelector('#PaymentMethodId').value;
										params["device_session_id"]=document.querySelector('#deviceSessionId').value;
										params["fraud_merchant_id"]=document.querySelector('#fraudMerchantId').value;
										wcService.invoke('AjaxRESTVaultedCreditCardVerification', params);
				 					 }
									 else{ //instance is of new card,so payload object is of new card
										 var paynonce = payload.nonce;
										 document.querySelector('#pay_nonce').value = paynonce;
										 document.querySelector('#account').value = "**************"+payload.details.lastTwo;
										 document.querySelector('#pay_type').value = payload.details.cardType;

										 //3D secure check is to be done
										 if(threeDSecureEnable == 'true')
											BrainTreePayments.threeDSecureCheck(paynonce);
										 else
											CheckoutPayments.processCheckout(piFormName);
									}
				 				}
				});		
		},
		
		/**
		 * 3D secure check 
		 */
		threeDSecureCheck : function(paynonce){
			var bankFrame = document.querySelector('.bt-modal-body');
			var piAmountVal = document.getElementById('piAmount_1').value;
			braintree.client.create({
			  // Use the generated client token to instantiate the Braintree client.
			  authorization: btClientToken
			}, function (clientErr, clientInstance) {
			  if (clientErr) {
				console.log("clientError:",clientErr);
				MessageHelper.displayErrorMessage(CheckoutPayments.errorMessages["BT_GENERIC_CLIENT_TOKEN_ERROR"]);	
				return;
			  }

			  braintree.threeDSecure.create({
				client: clientInstance
			  }, function (threeDSecureErr, threeDSecureInstance) {
				if (threeDSecureErr) {
				  console.log("threeDSecureError:",threeDSecureErr);
				  MessageHelper.displayErrorMessage(CheckoutPayments.errorMessages["BT_THREE_D_SECURE_ERROR"]);	
				  return;
				}
				console.log("threeDSecureInstance:",threeDSecureInstance);
				
				threeDSecureInstance.verifyCard({
				  amount: piAmountVal,
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
				  
					if (err) {
						console.error("error when threeDsecure response failed:",err);
						MessageHelper.displayErrorMessage(CheckoutPayments.errorMessages["BT_THREE_D_SECURE_RESPONSE_FAILED_ERROR"]);	
						return;
					  }
					  
					//Send response.nonce to use in your transaction
					var threeDNonce = response.nonce;
					document.getElementById('3Dsecure_nonce').value = threeDNonce;
					CheckoutPayments.processCheckout('PaymentForm');
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
		},
		
		/**
		 * on click of Next button in orderShippingBillingDetails page this method is called to get the payNonce and the other required params of particular payment. Set these values to a map and then call processCheckout
		 */
		brainTreeCheckOut : function(piFormName,skipOrderPrepare){
			var numberOfPaymentMethods = document.getElementById("numberOfPaymentMethods");
			var numberOfPaymentMethodsSelected = numberOfPaymentMethods.options[numberOfPaymentMethods.selectedIndex].value;
			var fromSavedPaymentFlag =document.querySelector('#fromSavedPaymentFlag').value ;
			var payType = document.querySelector('#pay_type').value ;
			var paypalEmail= document.getElementById("PayPalEmailId").value;
			var paymentType = $("input[name='payMethodId']:checked").val();
			var payInStore = false;
			
			//below conditions help to perform certain steps  for each payment
			if(isPickUpInStore){
				if ($("#payInStorePaymentOption").is(':checked'))
					payInStore = true;
			}
			if((paymentType == 'ZPayPal' && paypalEmail!="") || payInStore || ( (payType == 'PayPalAccount' || payType == 'PayPalCredit') && fromSavedPaymentFlag == 'true' )){
				CheckoutPayments.processCheckout(piFormName);
			}
			else if (paymentType == 'ZGooglePay'){
				document.getElementById("google-pay-button_"+numberOfPaymentMethodsSelected).click();
				
			}
			else if (paymentType == 'ZApplePay'){
				document.getElementById("apple-pay-button_"+numberOfPaymentMethodsSelected).click();
				
			}
			else if (fromSavedPaymentFlag=='true' || paymentType == 'ZCreditCard'){
				if($('#showSavedCard').css('display') == 'none' && fromSavedPaymentFlag=='true')
					{
						MessageHelper.displayErrorMessage(CheckoutPayments.errorMessages["BT_EMPTY_PAYMENT_ERROR"]);	
						
					}
				else{
					var keyforInst="inst";
					if(fromSavedPaymentFlag == 'true' ){
						var keyforInst="cvvInst";
					}
						for(i=1;i<=numberOfPaymentMethodsSelected;i++)
						{
							// from all the created instances,getting only the
							// required instances
							var key=keyforInst+i;
							var testInstance = instances_BT[key];
							BrainTreePayments.brainTreeInstances(testInstance,piFormName,i,fromSavedPaymentFlag);
						}
				}	
			}
			else{ //when none of the payment is selected and clicked on Next button,showing an error
				MessageHelper.displayErrorMessage(CheckoutPayments.errorMessages["BT_EMPTY_PAYMENT_ERROR"]);	
			}
		},
		
	/**
	 * populate brain tree hosted fields when new card is selected.
	 */

		displayBraintreeFieldsForPayment:function(clientToken,statusCount){
			
			// displaying Next button
				var nextButtonId = document.getElementById("shippingBillingPageNext");
				nextButtonId.classList.remove("btn-disabled-BT");
				
				$(".billing_address_container").css("display", "block"); 
				
				
				// if already iframe exists,we are clearing it
				document.getElementById("card-number_"+statusCount).innerHTML = "";
				document.getElementById("cvv_"+statusCount).innerHTML = "";
				document.getElementById("expiration-date_"+statusCount).innerHTML = "";
				
				var client_token=clientToken;
				
				braintree.client.create({
					 authorization: client_token
					 }).then( function(clientInstance) {
								
								if(advancedFraudTools == "true"){
								// device data
								braintree.dataCollector.create({
										client: clientInstance,
										kount: true
									  }).then(function(dataCollectorInstance) {
										
										var deviceData = JSON.parse(dataCollectorInstance.deviceData);
										document.querySelector('#deviceSessionId').value = deviceData.device_session_id;
										document.querySelector('#fraudMerchantId').value = deviceData.fraud_merchant_id;

									  }).catch(function (err){
											console.error("device data error for credit card is:",err);
											MessageHelper.displayErrorMessage(CheckoutPayments.errorMessages["BT_GENERIC_DEVICE_DATA_ERROR"]);
											  return;
										});
								}
								// hosted fields
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
										selector: '#card-number_'+statusCount,
										border: '1px solid #333'
									},
									cvv: {
										selector: '#cvv_'+statusCount
									},
									expirationDate: {
										selector: '#expiration-date_'+statusCount
									}
								}
														          
							}).then(function (hostedFieldsInstance) {
										
										
									
									var keyforInst="inst"+statusCount;
									var i=[];
									instances_BT[keyforInst]=hostedFieldsInstance;
									console.log("hostedFieldsInstance:",hostedFieldsInstance);
									
									//START Advanced Hosted Field events
									 var cvvLabel = document.querySelector('label[for="bt_cvv"]');
									hostedFieldsInstance.on('cardTypeChange', function (event) {
										// This event is fired whenever a change in card type is detected.
										// It will only ever be fired from the number field.
										var cvvText;

										if (event.cards.length === 1) {
										 cvvText = event.cards[0].code.name;
										} else {
										 cvvText = 'CVV';
										}
										cvvLabel.innerHTML = cvvText;
									 });
									//END
								}).catch( function (hostedFieldsErr){
														            
								
									console.error("hostedFieldsErr:",hostedFieldsErr);
									var hostedFieldsErrMsg="";
								
									$("#hostedFieldsErrorMessage_"+statusCount).css("display", "block"); 
									switch (hostedFieldsErr.code) {
										case 'HOSTED_FIELDS_TIMEOUT':
											hostedFieldsErrMsg= CheckoutPayments.errorMessages["BT_HOSTEDFIELDS_ERROR"]; // unknown error 
											//Occurs when Hosted Fields does not finish setting up within 60seconds
											 break;
										case 'HOSTED_FIELDS_INVALID_FIELD_KEY':
											 hostedFieldsErrMsg= CheckoutPayments.errorMessages["BT_HOSTEDFIELDS_ERROR"]; // merchant error
											 break;
										case 'HOSTED_FIELDS_INVALID_FIELD_SELECTOR':
											hostedFieldsErrMsg= CheckoutPayments.errorMessages["BT_HOSTEDFIELDS_ERROR"]; // merchant error
											break;
										case 'HOSTED_FIELDS_FIELD_DUPLICATE_IFRAME':  
											hostedFieldsErrMsg=CheckoutPayments.errorMessages["BT_HOSTEDFIELDS_ERROR"]; //merchant error
											break;
										case 'HOSTED_FIELDS_FIELD_PROPERTY_INVALID':
											hostedFieldsErrMsg= CheckoutPayments.errorMessages["BT_HOSTEDFIELDS_ERROR"];//merchant error
											break;  
										default:
											hostedFieldsErrMsg= CheckoutPayments.errorMessages["BT_HOSTEDFIELDS_ERROR"];// merchant error
									}
								
								document.getElementById("hostedFieldsErrorMessage_"+statusCount).innerHTML=hostedFieldsErrMsg;
								return;
						});
				}).catch( function(clientErr) {
					console.error("clientErr:",clientErr);
					
						$("#hostedFieldsWrapper_"+statusCount).css("display", "none"); // if error occurs don't display wrapper
						MessageHelper.displayErrorMessage(CheckoutPayments.errorMessages["BT_GENERIC_CLIENT_TOKEN_ERROR"]);
						cursor_clear();
					return;
				 });
			},
		
		/**
		 * PayPal payment script
		 * 
		 */
		
		payPalVaultPayment:function(payPalDivId,paypalCreditbutton,clientToken,statusCount,amountval,userType,isPaypalCreditEnableFlag,isMultiCapEnable)
			{
				
				//disabling the Next button when paypal is selected
					var nextButtonId = document.getElementById("shippingBillingPageNext");
					nextButtonId.classList.add("btn-disabled-BT");
					
				// if already iframe exists,we are clearing it
				document.getElementById(payPalDivId).innerHTML = "";
				
				if(isPaypalCreditEnableFlag == 'true')
					document.getElementById(paypalCreditbutton).innerHTML = "";
				
				var client_token=clientToken;
				var enableShippingAddressFlag = true;
				var shippingAddressEditableFlag = true;
				var createPayPalPayment = {};
				var shippingAddressOverrideValues = {};
				
				if(isPickUpInStore)
					$(".billing_address_container").css("display", "none"); 
				
				if(isPickUpInStore || isMultipleShipping){
					enableShippingAddressFlag = false;
					shippingAddressEditableFlag = false;
				}else{
					var	recipientNameCmrce=selectedShippingContact.firstName+" "+selectedShippingContact.lastName;
					var	line1Cmrce= selectedShippingContact.addressLine[0];
					var line2Cmrce = selectedShippingContact.addressLine[1];
					var	cityCmrce= selectedShippingContact.city;
					var	stateCmrce= selectedShippingContact.state;  
					var	countryCodeCmrce= selectedShippingContact.country;                                                                                                
					var	postalCodeCmrce=selectedShippingContact.zipCode;
					var	phoneNumber = selectedShippingContact.phone1;
					
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
				
				if(paypalFlow == 'checkout'){
					createPayPalPayment["flow"]= paypalFlow;
					createPayPalPayment["intent"]= paypalIntent;
				}else{
					createPayPalPayment["flow"]= paypalFlow;
					createPayPalPayment["billingAgreementDescription"]=billingAgreementDescription;
				}
				
				createPayPalPayment["locale"] =localeVal;
				createPayPalPayment["currency"]= WCParamJS.commandContextCurrency ;
				createPayPalPayment["enableShippingAddress"]= enableShippingAddressFlag;
				createPayPalPayment["shippingAddressEditable"]= shippingAddressEditableFlag;
				createPayPalPayment["displayName"] = paypalMerchantName;
				
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
											MessageHelper.displayErrorMessage(CheckoutPayments.errorMessages["BT_GENERIC_DEVICE_DATA_ERROR"]);
											  return;
										});
						}
				// Create a PayPal Checkout component.
					  braintree.paypalCheckout.create({
						client: clientInstance
					  }).then(function ( paypalCheckoutInstance ) {
						
						// Set up PayPal with the checkout.js library
						paypal.Button.render({
							env: paymentEnvironment, // this value can be either 'production' or  'sandbox'
							commit: true, // This will add the transaction amount to the PayPal button
							style: {
									label: 'paypal',
									size:'small'
									
								  },
							  payment: function () {
								 var piAmountVal = document.getElementById('piAmount_'+statusCount).value;
								 createPayPalPayment["amount"]= piAmountVal;
								 return paypalCheckoutInstance.createPayment(createPayPalPayment);
							  },
							  onAuthorize: function (data, actions) {
								return paypalCheckoutInstance.tokenizePayment(data, function (err, payload) {
								  // Submit `payload.nonce` to your server
								  
								 BrainTreePayments.processPayPalResponseFromOrdBilling(isPickUpInStore , isMultipleShipping,payload,false );
								});
							  },
							  onCancel: function (data) {
								console.log('checkout.js payment cancelled', JSON.stringify(data, 0, 2)); 
								//MessageHelper.displayErrorMessage(CheckoutPayments.errorMessages["BT_PAYPAL_ONCANCEL"]); //no need to display to user
								return; 
							  },
							  onError: function (err) {
								console.error('checkout.js error', err); // TODO handle this when site is down give a msg to user
								MessageHelper.displayErrorMessage(CheckoutPayments.errorMessages["BT_PAYPAL_ONERROR"]);											
								return;										
							  }
								}, '#'+payPalDivId).then(function () {
								  // The PayPal button will be rendered in an
									// html element with the id
								  // `paypal-button`. This function will be
									// called when the PayPal button
								  // is set up and ready to be used.
								});

							// paypal credit
						if(isPaypalCreditEnableFlag == 'true'){
							paypal.Button.render({
							env: paymentEnvironment, // Or 'sandbox'
							commit: true, // This will add the transaction amount to the PayPal button
							style: {
									label: 'credit',
									size:'small'
								  },
        
							payment: function () {
								var piAmountVal = document.getElementById('piAmount_'+statusCount).value;
								createPayPalPayment["amount"]= piAmountVal;
								createPayPalPayment["offerCredit"] = true;
								return paypalCheckoutInstance.createPayment(createPayPalPayment);
							  },

							  onAuthorize: function (data, actions) {
								return paypalCheckoutInstance.tokenizePayment(data, function (err, payload) {
								  // Submit `payload.nonce` to your server
								 BrainTreePayments.processPayPalResponseFromOrdBilling(isPickUpInStore , isMultipleShipping,payload,true );
								});
							  },
							  onCancel: function (data) {
								console.log('checkout.js payment cancelled', JSON.stringify(data, 0, 2)); 
								return;		
							  },
							  onError: function (err) {
								//alert("PayPal payment options are invalid.");
								MessageHelper.displayErrorMessage(CheckoutPayments.errorMessages["BT_PAYPAL_ONERROR"]);
								console.error('checkout.js error:', err); 
								return;
																			
							  }
								}, '#'+paypalCreditbutton).then(function () {
								  // The PayPal button will be rendered in an
									// html element with the id
								  // `paypal-button`. This function will be
									// called when the PayPal button
								  // is set up and ready to be used.
								});
							}
					  }).catch(function(paypalCheckoutErr){
							console.error(" paypalCheckoutErr: ",paypalCheckoutErr);
							MessageHelper.displayErrorMessage(CheckoutPayments.errorMessages["BT_PAYPAL_CHECKOUTERROR"]);																				
							return;
					  });
					  
				}).catch(function(clientErr){
					console.error("clientErr:",clientErr); // TODO check if any  other errors exists
					MessageHelper.displayErrorMessage(CheckoutPayments.errorMessages["BT_GENERIC_CLIENT_TOKEN_ERROR"]);																				
					cursor_clear();
					return;
					
				});
		},
		
		/**
		 *  to process payload object of PayPal payment
		 */
	processPayPalResponseFromOrdBilling: function(isPickUpInStoreFlag , isMultipleShipping,payload,isPayplaCredit ){
		
		if(!isPickUpInStoreFlag && !isMultipleShipping ){
			BrainTreePayments.updateShippingAddressFromPaypal(payload ,"S" );
		  }
		document.querySelector('#pay_nonce').value = payload.nonce;
		document.querySelector('#pay_type').value = payload.type;
		document.querySelector('#PayPalEmailId').value = payload.details.email;
		if(isPayplaCredit)
			document.querySelector('#pay_type').value = "PayPalCredit";
		
		if(paypalBillingAddressEnable == 'true'){
			BrainTreePayments.updateBillingAddressFromPaypal(payload);
		  }
		  
		CheckoutPayments.processCheckout('PaymentForm');
	},
		
	/**
	 *  PayPal payment script for express checkout
	 */
		payPalVaultPaymentFromExpressCheckout:function(payPalDivId,paypalCreditButton,clientToken,orderItemId,redirectURL,grandTotal,userType,isPickUpStore,isPaypalCreditEnableFlag,isMultiCapEnable)
			{
				
				var client_token=clientToken;
				var addressType = "S";
				var deviceSessionId ;		
				var fraudMerchantId	;
				var enableShippingAddressFlag =  true ;
				var shippingAddressEditableFlag =  true;
				if(isPickUpStore){
					enableShippingAddressFlag = false ;
					shippingAddressEditableFlag = false ;
				}
				
				var createPayPalPayment={};
				
				if(paypalFlow == 'checkout'){
					createPayPalPayment["flow"]= paypalFlow;
					createPayPalPayment["intent"]= paypalIntent;
				}else{
					createPayPalPayment["flow"]= paypalFlow;
					createPayPalPayment["billingAgreementDescription"]=billingAgreementDescription;
				}
				
				createPayPalPayment["locale"] =localeVal;
				createPayPalPayment["amount"]= grandTotal;
				createPayPalPayment["currency"]= WCParamJS.commandContextCurrency ;
				createPayPalPayment["enableShippingAddress"]= enableShippingAddressFlag;
				createPayPalPayment["shippingAddressEditable"]= shippingAddressEditableFlag;
				createPayPalPayment["displayName"] = paypalMerchantName;
				
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
										deviceSessionId = deviceData.device_session_id;
										fraudMerchantId = deviceData.fraud_merchant_id;

									  }).catch(function (err){
											
											console.error("device data error for paypal express checkout is",err);
											MessageHelper.displayErrorMessage(CheckoutPayments.errorMessages["BT_GENERIC_DEVICE_DATA_ERROR"]);																				
											  return;
										});
						}
				// Create a PayPal Checkout component.
					  braintree.paypalCheckout.create({
						client: clientInstance
					  }).then(function ( paypalCheckoutInstance) {

						// Set up PayPal with the checkout.js library
						paypal.Button.render({
							env: paymentEnvironment, // Or 'sandbox'
							commit: true, // This will add the transaction amount to the PayPal button
							style: {
									label: 'paypal',
									size:'small'
								  },
							payment: function () {
										return paypalCheckoutInstance.createPayment(createPayPalPayment)
									},

							  onAuthorize: function (data, actions) {
								return paypalCheckoutInstance.tokenizePayment(data, function (err, payload) {
									// Submit `payload.nonce` to your server
									BrainTreePayments.processPayPalResponseFromShopcart(isPickUpStore , userType , payload , addressType , orderItemId, redirectURL, false , deviceSessionId , fraudMerchantId);
								  });
							  },

							  onCancel: function (data) {
								console.log('checkout.js payment cancelled', JSON.stringify(data, 0, 2)); 
								//MessageHelper.displayErrorMessage(CheckoutPayments.errorMessages["BT_PAYPAL_ONCANCEL"]);	//no need to display to user																			
								return; 
							  },

							  onError: function (err) {
								  	MessageHelper.displayErrorMessage(CheckoutPayments.errorMessages["BT_PAYPAL_ONERROR"]);																				
								console.error('checkout.js error', err); // TODO handle this. Whn site is down fgive a msg to user
								return;
							  }
								}, '#'+payPalDivId).then(function () {
								  // The PayPal button will be rendered in an
									// html element with the id
								  // `paypal-button`. This function will be
									// called when the PayPal button
								  // is set up and ready to be used.
								});

					if(isPaypalCreditEnableFlag == 'true'){
							// paypal credit
							createPayPalPayment["offerCredit"] = true;
						paypal.Button.render({
							env: paymentEnvironment, // Or 'sandbox'
							commit: true, // This will add the transaction amount to the PayPal button
							style: {
									label: 'credit',
									size:'small'
								  },
								  
							payment: function () {
									return paypalCheckoutInstance.createPayment(createPayPalPayment);
							  },

							  onAuthorize: function (data, actions) {
								return paypalCheckoutInstance.tokenizePayment(data, function (err, payload) {
									// Submit `payload.nonce` to your server
									BrainTreePayments.processPayPalResponseFromShopcart(isPickUpStore , userType , payload , addressType , orderItemId, redirectURL , true, deviceSessionId , fraudMerchantId);
									});
							  },

							  onCancel: function (data) {
								console.log('checkout.js payment cancelled', JSON.stringify(data, 0, 2));
								//MessageHelper.displayErrorMessage(CheckoutPayments.errorMessages["BT_PAYPAL_ONCANCEL"]); //no need to display to user
								return; 
							  },

							  onError: function (err) {
								console.error('checkout.js error', err); 
								MessageHelper.displayErrorMessage(CheckoutPayments.errorMessages["BT_PAYPAL_ONERROR"]);
								return; 
																			
							  }
								}, '#'+paypalCreditButton).then(function () {
								  // The PayPal button will be rendered in an
									// html element with the id
								  // `paypal-button`. This function will be
									// called when the PayPal button
								  // is set up and ready to be used.
								});
							}

					  }).catch(function(paypalCheckoutErr){
							console.log("paypalCheckoutErr:",paypalCheckoutErr);	
							MessageHelper.displayErrorMessage(CheckoutPayments.errorMessages["BT_PAYPAL_CHECKOUTERROR"]);					
							return;
					  });
					  

				}).catch(function(clientErr){
					console.error("clientErr",clientErr); // TODO check if any other errors exists
					MessageHelper.displayErrorMessage(CheckoutPayments.errorMessages["BT_GENERIC_CLIENT_TOKEN_ERROR"]);	
					cursor_clear();
					return;
					
				});
			},
		
			/**
			 * process Payload object of PayPal of shop cart page
			 */
		processPayPalResponseFromShopcart: function(isPickUpStore , userType , payload , addressType , orderItemId, redirectURL, 
									isPaypaCredit , deviceSessionId , fraudMerchantId)
		{
			var postRefreshHandlerParameters = [];
			var initialURL = "AjaxRESTOrderItemUpdate";
			var responseParams = {};
		
			if(isPickUpStore){
				if(userType == 'G' && paypalBillingAddressEnable == 'false')
					addressType ="B";
			ShipmodeSelectionExtJS.submitStoreSelectionForm(document.orderItemStoreSelectionForm);
			responseParams["payInStore"] = false;
			responseParams["isPickUpStore"] = true;
			}else{
				if(userType == 'G' && paypalBillingAddressEnable == 'false')
					addressType ="SB";
				responseParams["isPickUpStore"] = false;
			}
			
			if((isPickUpStore && userType == 'G' && paypalBillingAddressEnable == 'false' ) || !isPickUpStore){
				BrainTreePayments.updateShippingAddressFromPaypal(payload , addressType);
			}
			
			if(paypalBillingAddressEnable == 'true'){
				BrainTreePayments.updateBillingAddressFromPaypal(payload);
			}
			
			responseParams["pay_nonce"] = payload.nonce;
			responseParams["deviceSessionId"] = deviceSessionId;
			responseParams["fraudMerchantId"] = fraudMerchantId
			
			if(isPaypaCredit){
				responseParams["pay_type"] = "PayPalCredit";
				responseParams["paypalCredit"] = true;	
			}else{
				responseParams["pay_type"] = payload.type;
				responseParams["paypalCredit"] = false;	
			}
			responseParams["PayPalEmailId"] = payload.details.email;
			
			var urlRequestParams = [];
			urlRequestParams["remerge"] = "***";
			urlRequestParams["check"] = "*n";
			urlRequestParams["allocate"] = "***";
			urlRequestParams["backorder"] = "***";
			urlRequestParams["calculationUsage"] = "-1,-2,-3,-4,-5,-6,-7";
			urlRequestParams["calculateOrder"] = "1";
			urlRequestParams["orderItemId"] = orderItemId;
			urlRequestParams["orderId"] = ".";
					urlRequestParams["storeId"] = WCParamJS.storeId;
					postRefreshHandlerParameters.push({"URL":redirectURL,"requestType":"GET", "requestParams":responseParams}); 
					var service = getCustomServiceForURLChaining(initialURL,postRefreshHandlerParameters,null);
									service.invoke(urlRequestParams);
		},
		/**
		 * update shipping address with the shipping address obtained from paypal
		 */
		updateShippingAddressFromPaypal: function(payload , addressTypeVal){
			
			var postUdatingPaypalAddressData = {};
			if(addressTypeVal == "B"){
				postUdatingPaypalAddressData = { storeId: WCParamJS.storeId,
					catalogId: WCParamJS.catalogId , 
					lagId: WCParamJS.langId ,
					addressType:addressTypeVal,
					addressTypeFromPayPal:'StoreAddress',
					pickupStoreId: PhysicalStoreCookieJSStore.getPickUpStoreIdFromCookie()
				};
			}else{
				var ShippingAddressAddressLine2 ='' ;
				if(payload.details.shippingAddress.line2 != null)
					ShippingAddressAddressLine2 = payload.details.shippingAddress.line2;
					postUdatingPaypalAddressData = { storeId: WCParamJS.storeId,
					catalogId: WCParamJS.catalogId , 
					lagId: WCParamJS.langId ,
					addressTypeFromPayPal: 'PayPalShippingAddress' ,
					addressType:addressTypeVal,
					recipientName: payload.details.shippingAddress.recipientName,
					address1:payload.details.shippingAddress.line1,
					address2:ShippingAddressAddressLine2,
					city: payload.details.shippingAddress.city,
					state:payload.details.shippingAddress.state,
					countryCode:payload.details.shippingAddress.countryCode,
					postalCode:payload.details.shippingAddress.postalCode };
			}
					$.ajax({
						async: false,
						type: 'POST', 
						url: "AjaxRESTUpdateShippingAddressFromPaypalCheckout",
						data : postUdatingPaypalAddressData,
						success: function(responseData){
							var resultData = responseData;
							resultData = resultData.replace('/*','');
							resultData = resultData.replace('*/','');
							var finaldata = JSON.parse(resultData);
							var updatedAddressId = finaldata.result.updatedAddressId;
							
							if(updatedAddressId != ""){
							var paramsInfo=[];
							paramsInfo["addressId"]= updatedAddressId;
							paramsInfo["storeId"]= WCParamJS.storeId;
							paramsInfo["catalogId"] = WCParamJS.catalogId;
							paramsInfo["langId"] = WCParamJS.langId;;
							paramsInfo["orderId"] = ".";
							paramsInfo["calculationUsage"] = "-1,-2,-3,-4,-5,-6,-7";
							paramsInfo["allocate"] = "***";
							paramsInfo["backorder"] = "***";
							paramsInfo["remerge"] = "***";
							paramsInfo["check"] = "*n";
							paramsInfo["calculateOrder"] = "1";
							paramsInfo["requesttype"] ="ajax";
						   
							wcService.invoke("OrderItemAddressShipMethodUpdate", paramsInfo);
							}
						}
					});
		},
		
		/**
		 * to update billing address with the billing address obtained from paypal
		 */
		updateBillingAddressFromPaypal: function(payload){
			var BillingAddressRecipientName='';
			var BillingAddressAddressLine2 ='' ;
			
			if(payload.details.shippingAddress != null)
				BillingAddressRecipientName = payload.details.shippingAddress.recipientName;
			else
				BillingAddressRecipientName = "PayPalFirstName PayPalLastName";

			if(payload.details.billingAddress.line2 != null)
					BillingAddressAddressLine2 = payload.details.billingAddress.line2;

				var postData = { storeId: WCParamJS.storeId,
					catalogId: WCParamJS.catalogId , 
					lagId: WCParamJS.langId ,
					addressTypeFromPayPal: 'PayPalBillingAddress' ,
					addressType:'B',
					recipientName: BillingAddressRecipientName,
					address1:payload.details.billingAddress.line1,
					address2:BillingAddressAddressLine2,
					city: payload.details.billingAddress.city,
					state:payload.details.billingAddress.state,
					countryCode:payload.details.billingAddress.countryCode,
					postalCode:payload.details.billingAddress.postalCode };
					$.ajax({
						async: false,
						type: 'POST', 
						url: "AjaxRESTUpdateShippingAddressFromPaypalCheckout",
						data : postData,
						success: function(responseData){
							var resultData = responseData;
							resultData = resultData.replace('/*','');
							resultData = resultData.replace('*/','');
							var finaldata = JSON.parse(resultData);
							var addressId = finaldata.result.updatedAddressId;
							
							var billingAddressList = document.getElementById('billing_address_id_1');
							if(billingAddressList != null)
								billingAddressList.options[billingAddressList.selectedIndex].value = addressId;
						}
					});
		},
		/**
		 * To display google pay button
		 */
		googlePayPayment:function(googlePaybuttonId,clientToken,statusCount){

			//displaying the Next button if hidden
				
				var nextButtonId = document.getElementById("shippingBillingPageNext");
				nextButtonId.classList.remove("btn-disabled-BT");
				
				$(".billing_address_container").css("display", "block"); 
				var button = googlePaybuttonId
				var paymentsClient = new google.payments.api.PaymentsClient({
				  environment: googlepayPaymentEnvironment //'TEST'  Or 'PRODUCTION'
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
											console.error("device data error for google pay is:",err);
											MessageHelper.displayErrorMessage(CheckoutPayments.errorMessages["BT_GENERIC_DEVICE_DATA_ERROR"]);	
											  return;
										});
								}
					

				braintree.googlePayment.create({
					client: clientInstance
				  }).then(function (googlePaymentInstance) {
				   paymentsClient.isReadyToPay({
					  allowedPaymentMethods: ["CARD", "TOKENIZED_CARD"] // googlePaymentInstance.createPaymentDataRequest().allowedPaymentMethods
					}).then(function(response) {
					 if (response.result) {
						// assigning the googlePaymentInstance to a var.
						$("#googlePay_"+statusCount).css("display","block");
						
						var keyForInst="googlePay"+statusCount;
						gPayPaymentsClient_BT[keyForInst]=paymentsClient;
						instances_BT[keyForInst]=googlePaymentInstance;
					}
					}).catch(function (err) {
					  // Handle errors
					  console.error("error when response failed:",err);
					  MessageHelper.displayErrorMessage(CheckoutPayments.errorMessages["BT_GOOGLEPAY_RESPONSE_FAILED_ERROR"]);
					  return;
					});
				  }).catch(function(googlePaymentErr){
					console.error("googlePaymentError:",googlePaymentErr);
					MessageHelper.displayErrorMessage(CheckoutPayments.errorMessages["BT_GOOGLEPAY_PAYMENT_ERROR"]);
					return;
				  });

				  
				}).catch(function(clienterr){
					console.error("clienterr:",clienterr);
					MessageHelper.displayErrorMessage(CheckoutPayments.errorMessages["BT_GENERIC_CLIENT_TOKEN_ERROR"]);
					return;
				});
		},
		/**
		 * generating payload object ,on click of google pay payment
		 */
		googlePayOnClick : function(piFormName,statusCount){
			
			var googlePayInstance=instances_BT["googlePay"+statusCount];
			var paymentsClient=gPayPaymentsClient_BT["googlePay"+statusCount];
			var piAmountVal = document.getElementById('piAmount_'+statusCount).value;

			var paymentDataRequest = googlePayInstance.createPaymentDataRequest({
							// merchantId: googlePayPaymentMerchantId, //not needed for sandbox testing
							transactionInfo: {
							  currencyCode: WCParamJS.commandContextCurrency,
							  totalPriceStatus: 'FINAL',
							  totalPrice: piAmountVal // Your amount
							},
							cardRequirements: {
							  billingAddressRequired: true
							}
						  });

						  paymentsClient.loadPaymentData(paymentDataRequest).then(function(paymentData) {
							googlePayInstance.parseResponse(paymentData, function (err, result) {
							  if (err) {
								// Handle parsing error
								console.error(" parsing error ::"+err);
								MessageHelper.displayErrorMessage(CheckoutPayments.errorMessages["BT_GOOGLEPAY_PARSING_ERROR"]);
								return;
							  }
							  // Send result.nonce to your server
								document.querySelector('#pay_nonce').value = result.nonce;
								document.querySelector('#pay_type').value = result.type;
								setCurrentId('shippingBillingPageNext'); 
								CheckoutPayments.processCheckout(piFormName);	
							});
						  }).catch(function (err) {
							console.error("error when loadingPaymentData :",err);
							MessageHelper.displayErrorMessage(CheckoutPayments.errorMessages["BT_GOOGLEPAY_ERROR_AT_LOADPAYMENTDATA"]);
							return;
						  });
		},
		/**
		 * To display apple pay button
		 */
		applePayPayment:function(applePaybuttonId,clientToken,statusCount){
				
				// display in next button if hidden
				var nextButtonId = document.getElementById("shippingBillingPageNext");
				nextButtonId.classList.remove("btn-disabled-BT");
				
				var button = applePaybuttonId
				
			// apple pay
					if (!window.ApplePaySession) {
					  console.error('This device does not support Apple Pay');
					  MessageHelper.displayErrorMessage(CheckoutPayments.errorMessages["BT_APPLEPAY_DEVICE_NOT_SUPPORTED"]);
					  return; //TODO cross check this with the bT script
					}

					if (!ApplePaySession.canMakePayments()) {
					  console.error('This device is not capable of making Apple Pay payments');
					  MessageHelper.displayErrorMessage(CheckoutPayments.errorMessages["BT_APPLEPAY_DEVICE_NOT_CAPABLE"]);
					  return; //TODO ,see if it is correct to return
					}

				braintree.client.create({
				  authorization: clientToken
				}).then( function (clientInstance) {
					   
				// device data
						braintree.dataCollector.create({
							client: clientInstance,
							kount: true
						  }).then(function( dataCollectorInstance) {
							
							var deviceData = JSON.parse(dataCollectorInstance.deviceData);
							document.querySelector('#deviceSessionId').value = deviceData.device_session_id;
							document.querySelector('#fraudMerchantId').value = deviceData.fraud_merchant_id;

						  }).catch(function (err){
								
								console.error("device data error for apple pay is:"+err);
								MessageHelper.displayErrorMessage(CheckoutPayments.errorMessages["BT_GENERIC_DEVICE_DATA_ERROR"]);
								  return;
							});

							
				// apple pay
							braintree.applePay.create({
							client: clientInstance
						  }, function (applePayErr, applePayInstance) {
							if (applePayErr) {
							  console.error('Error creating applePayInstance:', applePayErr);
							  MessageHelper.displayErrorMessage(CheckoutPayments.errorMessages["BT_APPLEPAY_APPLEPAY_ERR"]);
							  
							  return;
							}
							
							var promise = ApplePaySession.canMakePaymentsWithActiveCard(applePayInstance.merchantIdentifier);
							promise.then(function (canMakePaymentsWithActiveCard) {
							 
							  if (canMakePaymentsWithActiveCard) {
									// Set up Apple Pay buttons
									var keyForInst="applePay"+statusCount;
									instances[keyForInst]=applePayInstance;
									$("#applePay_"+statusCount).css("display", "block");
									
							  }
							});
						  });

				}).catch(function(clienterr){
					console.error("clienterror:",clienterr);
					MessageHelper.displayErrorMessage(CheckoutPayments.errorMessages["BT_GENERIC_CLIENT_TOKEN_ERROR"]);
					return;
				});
		},
		/**
		 * to generate payload obejct of apple pay after the onclick of apple pay button
		 */
		applePayOnClick:function(piFormName,statusCount,amount){
					
					var applePayInstance=instances_BT["applePay"+statusCount];
					var paymentRequest = applePayInstance.createPaymentRequest({
				  total: {
					label: 'My Store',
					amount: amount
				  },
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
						console.error("apple pay failed to load");
						MessageHelper.displayErrorMessage(CheckoutPayments.errorMessages["BT_APPLEPAY_PERFORM_VALIDATION_ERR"]);
					  return;
					}
					session.completeMerchantValidation(merchantSession);
				  });
				};
						
						session.onpaymentauthorized = function (event) {
					  console.log('Your shipping address is:', event.payment.shippingContact);
						
					  applePayInstance.tokenize({
						token: event.payment.token
					  }, function (tokenizeErr, payload) {
						if (tokenizeErr) {
						  console.error('Error tokenizing Apple Pay:', tokenizeErr);
						  MessageHelper.displayErrorMessage(CheckoutPayments.errorMessages["BT_APPLEPAY_TOKENIZEERR"]);
						  session.completePayment(ApplePaySession.STATUS_FAILURE);
						  return;
						}
						session.completePayment(ApplePaySession.STATUS_SUCCESS);

						// Send payload.nonce to your server.
						console.log('nonce:', payload.nonce);
						
						document.querySelector('#pay_nonce').value = payload.nonce;
						document.querySelector('#pay_type').value = payload.type; //ApplePayCard
						setCurrentId('shippingBillingPageNext'); 
						CheckoutPayments.processCheckout(piFormName);
						// If requested, address information is accessible in
						// event.payment
						// and may also be sent to your server.
						console.log('billingPostalCode:', event.payment.billingContact.postalCode);
					  });
					};
					
					session.begin();
	},
		
		/**
		 * to deal with the Saved Payments and New Paymenst fieldsets
		 */
		toggleExpandNavBT:function(id,displayCardsFlag){
		
			var icon = byId("icon_" + id);
			var section_list = byId("section_list_" + id);
			if(icon.className == "arrow") {
				icon.className = "arrow arrow_collapsed";
				$(section_list).attr("aria-expanded", "false");
				$(section_list).css("display", "none");
			} else {
				icon.className = "arrow";
				$(section_list).attr("aria-expanded", "true");
				$(section_list).css("display", "block");
				
				if(displayCardsFlag=="true"){
					if(id=="newPayments"){
						
						$("#section_list_savedPayments").attr("aria-expanded", "false");
						$("#section_list_savedPayments").css("display", "none");
						
						// hide otherfield set
						//var iconOther = byId("icon_savedPayments");
						$("#icon_savedPayments").attr('class', 'arrow arrow_collapsed');
						//iconOther.className="arrow arrow_collapsed";
						document.querySelector('#fromSavedPaymentFlag').value = false;

						$(".paypalCheckoutdiv").css("display", "block"); 
						$("#newCardDetailsFillingDiv").css("display", "block"); // when
																				// saved
																				// card
																				// selected
																				// ,new
																				// card
																				// div
																				// should
																				// not
																				// be
																				// appeared
						$("#googlePay_1").css("display", "block");
						
						
					}
					else if(id=="savedPayments"){
						
						$(section_list_newPayments).attr("aria-expanded", "false");
						$(section_list_newPayments).css("display", "none");

						$(".paypalCheckoutdiv").css("display", "none"); 
						$("#newCardDetailsFillingDiv").css("display", "none"); // when
																				// saved
																				// card
																				// selected
																				// ,new
																				// card
																				// div
																				// should
																				// not
																				// be
																				// appeared
						$("#googlePay_1").css("display", "none");
						//hide other fieldset
						var iconOther = byId("icon_newPayments");
						iconOther.className="arrow arrow_collapsed";
						document.querySelector('#fromSavedPaymentFlag').value = true;
						
						//enabling Next Button
						var nextButtonId = document.getElementById("shippingBillingPageNext");
						nextButtonId.classList.remove("btn-disabled-BT");
						
					}
				}
				
				
			}
		},
		
		/**
		 * To display only one payment at a time. Hiding other payments if any are open
		 */
		displayCardDetailsDiv:function(paymentCard,statusCount){
			
			if(paymentCard=="newCard")
			{
				console.log("inside new card payment");
				$("#newCardDetailsFillingDiv").css("display", "block");
				$("#existingCardsList").css("display", "none"); 
				$(".paypalCheckoutdiv").css("display", "none"); 
				$("#googlePay_"+statusCount).css("display", "none"); 
				$(".billing_address_container").css("display", "block"); 
				
				// when new card selected ,savedcards div should not be appeared
			}
			else if (paymentCard=="existingCard")
			{
				$(".billing_address_container").css("display", "block"); 
				$("#existingCardsList").css({"width":"300px","margin-left":"210px","display": "block","word-wrap": "break-word"});
				$("#newCardDetailsFillingDiv").css("display", "none");
				// when saved card selected ,new card div should not be appeared
				$("#applePay_"+statusCount).css("display", "none");	 
			}
			else if (paymentCard=="payPal")
			{
				if(isPickUpInStore)
					$(".billing_address_container").css("display", "none"); 
				console.log("inside paypal  payment");
				$(".paypalCheckoutdiv").css("display", "block"); 
				$("#newCardDetailsFillingDiv").css("display", "none"); 
				$("#googlePay_"+statusCount).css("display", "none"); 
				$("#applePay_"+statusCount).css("display", "none");	
			}
			else if(paymentCard=="googlePay")
			{
				$(".billing_address_container").css("display", "block"); 
				$(".paypalCheckoutdiv").css("display", "none"); 
				$("#newCardDetailsFillingDiv").css("display", "none");
				$("#googlePay_"+statusCount).css("display", "block"); 
				$("#applePay_"+statusCount).css("display", "none");	
			}
			else if(paymentCard=="applePay")
					{
						$(".billing_address_container").css("display", "block"); 
						$(".paypalCheckoutdiv").css("display", "none"); 
						$("#newCardDetailsFillingDiv").css("display", "none");
						$("#googlePay_"+statusCount).css("display", "none"); 
						$("#applePay_"+statusCount).css("display", "block");
					}
			
		}
	}
