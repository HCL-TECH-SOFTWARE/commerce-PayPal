/**
*==================================================
Copyright [2022] [HCL Technologies]

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
package com.hcl.commerce.braintree.vault.commands;

import java.util.logging.Level;
import java.util.logging.Logger;
import java.util.HashMap;

import com.hcl.commerce.payments.braintree.builder.HCLBrainTreeRequestBuilder;
import com.hcl.commerce.payments.braintree.processor.HCLBrainTreeProcessor;
import com.hcl.commerce.payments.braintree.processor.helper.HCLBrainTreeProcessorHelper;
import com.hcl.commerce.payments.braintree.services.BrainTreeServiceErrorException;
import com.hcl.commerce.payments.braintree.services.BrainTreeServiceException;
import com.hcl.commerce.payments.braintree.valueobjects.HCLBrainTreeCreditCardRequestObject;
import com.hcl.commerce.payments.braintree.valueobjects.HCLBrainTreeCreditCardResponseObject;
import com.ibm.commerce.command.TaskCommandImpl;
import com.ibm.commerce.datatype.TypedProperty;
import com.ibm.commerce.exception.ECApplicationException;
import com.ibm.commerce.exception.ECException;
import com.ibm.commerce.foundation.logging.LoggingHelper;
import com.ibm.commerce.ras.ECMessage;
import com.ibm.commerce.ras.ECMessageSeverity;
import com.ibm.commerce.ras.ECMessageType;

public class HCLVaultTaskCmdImpl extends TaskCommandImpl implements HCLVaultTaskCmd {

	private static final String CLASS_NAME = "HCLVaultTaskCmdImpl";
	private static final Logger LOGGER = Logger.getLogger(CLASS_NAME);
	TypedProperty reqProperties = new TypedProperty();
	public Integer storeId;
	public String user_Id;
	public String orderId;
	public String fromSavedPaymentFlag;
	public String payType;
	public String deviceSessionId;
	public String fraudMerchantId;
	public String billingAddressId;
	public String payToken;
	public String payMethodId;

	public void setRequestProperties(TypedProperty requestProperties) {
		reqProperties = requestProperties;
		
		 storeId = getCommandContext().getStoreId();
		 user_Id = getCommandContext().getUserId().toString();
		 orderId = reqProperties.getString("orderId",null);
		 fromSavedPaymentFlag = "false";//reqProperties.getString("fromSavedPaymentFlag",null);
		 payType = reqProperties.getString("pay_type",null);
		 deviceSessionId=reqProperties.getString("deviceSessionId",null);
		 fraudMerchantId=reqProperties.getString("fraudMerchantId",null);
		 billingAddressId=reqProperties.getString("billing_address_id",null);
		 payMethodId=reqProperties.getString("payMethodId",null);
	}

	public void performExecute() throws ECException {

		final String METHOD_NAME = "performExecute";
		if (LoggingHelper.isEntryExitTraceEnabled(LOGGER))
			LOGGER.entering(CLASS_NAME, METHOD_NAME);
		HCLBrainTreeProcessorHelper helper = null;
		try {

			// getting StoreId form transaction object.
			
			HashMap<String,String> creditCardDetailsMap=new HashMap<String,String>();
			creditCardDetailsMap.put("storeId",getStoreId().toString());
			creditCardDetailsMap.put("userId",getUser_Id());
			creditCardDetailsMap.put("billingAddressId",getBillingAddressId());
			creditCardDetailsMap.put("orderId",getOrderId());
			creditCardDetailsMap.put("fromSavedPaymentFlag",getFromSavedPaymentFlag());
			creditCardDetailsMap.put("payType",getPayType());
			creditCardDetailsMap.put("paymentMethodId", getPayMethodId());
			
			helper = HCLBrainTreeProcessorHelper.getInstance(storeId);
			HCLBrainTreeRequestBuilder builder = helper.getBraintreeRequestBuilder(storeId);
			HCLBrainTreeProcessor service = helper.getBrainTreeProcessor(storeId);
				/* saving card details in BT vault & commerce DB*/
				// getting HCLBrainTreeCreditCardRequestObject by calling getCreditCardDetailsObject method in builder class
				String payNonce = reqProperties.getString("pay_nonce");
				creditCardDetailsMap.put("pay_nonce",payNonce);
				HCLBrainTreeCreditCardRequestObject ccreqObj = builder.getCreditCardDetailsObject( creditCardDetailsMap );
				HCLBrainTreeCreditCardResponseObject resObj = service.generatePayToken(ccreqObj);
				
				if (LOGGER.isLoggable(Level.FINEST)) {
					LOGGER.logp(Level.FINEST, CLASS_NAME, METHOD_NAME,
							"paymethod Token : " + resObj.getPayToken());
				}
				setPayToken(resObj.getPayToken());
			
		} catch (BrainTreeServiceException btse) {
			LOGGER.logp(Level.SEVERE, CLASS_NAME, METHOD_NAME, "Encountered exception ["+btse.toString()+"]", btse);
			throw new ECApplicationException(ECMessage._ERR_CMD_BAD_EXEC_CMD, CLASS_NAME, METHOD_NAME);
		} catch (BrainTreeServiceErrorException btsee) {
			LOGGER.logp(Level.SEVERE, CLASS_NAME, METHOD_NAME, "Encountered exception ["+btsee.toString()+"]", btsee);
			 String eroorjhf = btsee.getError(0).getErrorCode().toString();
			throw new ECApplicationException(new ECMessage
					 (ECMessageSeverity.ERROR,ECMessageType.USER, 
							 "BRAINTREE_ERROR_" + btsee.getError(0).getErrorCode(),helper.getErrorResourceBundleName(getStoreId())),
							 CLASS_NAME, "methodName");	
		} catch (Exception e1) {
			LOGGER.logp(Level.SEVERE, CLASS_NAME, METHOD_NAME, "Encountered exception ["+e1.toString()+"]", e1);
			throw new ECApplicationException(ECMessage._ERR_CMD_BAD_EXEC_CMD,
					CLASS_NAME, METHOD_NAME);
		}
		
		if (LoggingHelper.isEntryExitTraceEnabled(LOGGER))
			LOGGER.exiting(CLASS_NAME, METHOD_NAME);
	}

	
	
	
	public Integer getStoreId() {
		return storeId;
	}


	public String getUser_Id() {
		return user_Id;
	}

	public String getOrderId() {
		return orderId;
	}

	public String getFromSavedPaymentFlag() {
		return fromSavedPaymentFlag;
	}

	public String getPayType() {
		return payType;
	}

	public String getDeviceSessionId() {
		return deviceSessionId;
	}

	public String getFraudMerchantId() {
		return fraudMerchantId;
	}

	public String getBillingAddressId() {
		return billingAddressId;
	}
	

	public String getPayMethodId() {
		return payMethodId;
	}

	public void setPayToken(String payToken) {
		this.payToken = payToken;
	}
	
	public String getPayToken() {
		return payToken;
	}
}
