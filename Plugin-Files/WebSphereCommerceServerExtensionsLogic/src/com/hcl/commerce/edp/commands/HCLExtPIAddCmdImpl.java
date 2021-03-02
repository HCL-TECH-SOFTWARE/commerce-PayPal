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
package com.hcl.commerce.edp.commands;

import java.util.logging.Level;
import java.util.logging.Logger;

import com.hcl.commerce.payments.braintree.util.HCLBrainTreeConstants;
import com.hcl.commerce.payments.braintree.util.HCLBrainTreeUtility;
import com.hcl.commerce.braintree.vault.commands.HCLVaultTaskCmd;
import com.ibm.commerce.command.CommandFactory;
import com.ibm.commerce.datatype.TypedProperty;
import com.ibm.commerce.edp.commands.PIAddCmdImpl;
import com.ibm.commerce.exception.ECException;
import com.ibm.commerce.user.objects.AddressAccessBean;

public class HCLExtPIAddCmdImpl extends PIAddCmdImpl {

	public static final String CLASS_NAME = "HCLExtPIAddCmdImpl";
	public static final Logger LOGGER = Logger.getLogger(CLASS_NAME);
	public static final String PAYMNET_METHOD_ID = "payMethodId";
	public static final String BILLING_ADDRESS_ID = "billing_address_id";
	public static final String FROM_VAULT_PAYMENT = "fromSavedPaymentFlag";

	public void setRequestProperties(TypedProperty aReqParms) throws ECException {
		super.setRequestProperties(aReqParms);
	}

	public void performExecute() throws ECException {
		final String METHOD_NAME = "performExecute";
		LOGGER.entering(CLASS_NAME, METHOD_NAME);

		Integer store_Id = getStoreId();
		TypedProperty properties = getRequestProperties();

		String payMethodIdval  = properties.getString(PAYMNET_METHOD_ID, null);
		if(payMethodIdval != null && (payMethodIdval.equals("ZPayPal") || payMethodIdval.equals("ZPayPalCredit"))) {
			String fromSavedPaymentFlag = getRequestProperties().getString(HCLBrainTreeConstants.FROM_VAULT_PAYMENT, null);
		
			String savePaymentFlag = properties.getString(HCLBrainTreeConstants.SAVE_CARD_FLAG, null);
			String billingAddressId = properties.getString(BILLING_ADDRESS_ID, null);
			String paypalPaymentMethod = HCLBrainTreeUtility.getInstance(new Integer(store_Id)).getConfProperty(HCLBrainTreeConstants.PAYPAL_PAYMENT_METHOD, new Integer(store_Id));
			String paypalcreditPaymentMethod = HCLBrainTreeUtility.getInstance(new Integer(store_Id)).getConfProperty(HCLBrainTreeConstants.PAYPAL_CREDIT_PAYMENT_METHOD, new Integer(store_Id));	
			String paypalFlow = HCLBrainTreeUtility.getInstance(new Integer(store_Id)).getConfProperty(HCLBrainTreeConstants.PAYPAL_FLOW, new Integer(store_Id));
		
			//create token using paynonce when payment checkout with paypal floe:checkout , intent : order 
			if(! fromSavedPaymentFlag.equals("true") && (paypalPaymentMethod.equals(payMethodIdval) || paypalcreditPaymentMethod.equals(payMethodIdval)) ){
				if(paypalFlow.equals(HCLBrainTreeConstants.PAYPAL_FLOW_CHEKCOUT)){
					String paypalCheckoutIntent = HCLBrainTreeUtility.getInstance(new Integer(store_Id)).getConfProperty(HCLBrainTreeConstants.PAYPAL_CHECKOUT_INTENT, new Integer(store_Id));
					if(paypalCheckoutIntent.equals(HCLBrainTreeConstants.PAYPAL_INTNET_ORDER)){
						
						HCLVaultTaskCmd cmd = (HCLVaultTaskCmd) CommandFactory.createCommand("com.hcl.commerce.braintree.vault.commands.HCLVaultTaskCmd", getStoreId());
						cmd.setCommandContext(getCommandContext());
						cmd.setRequestProperties(getRequestProperties());
						cmd.execute();
						
						String payToken = cmd.getPayToken();
	
						if (LOGGER.isLoggable(Level.FINEST))
							LOGGER.logp(Level.FINEST, CLASS_NAME, METHOD_NAME, " HCLExtPIAddCmdImpl payToken:: " + payToken);
							
						properties.put(HCLBrainTreeConstants.PAY_TOKEN, payToken);
					}
				}
			}
			//Setting addressfiled2 from billing address if not empty address2
			if(billingAddressId != null){
				AddressAccessBean addressAB = new AddressAccessBean();
				addressAB.setInitKey_addressId(billingAddressId);
				String addresLineTwo = addressAB.getAddress2();
				if(addresLineTwo != null)
					properties.put(HCLBrainTreeConstants.BILLTO_ADDRESS_LINE_TWO, addresLineTwo);
			}
			
			super.setRequestProperties(properties);
		}
		else {
			if (LOGGER.isLoggable(Level.FINEST))
				LOGGER.logp(Level.FINEST, CLASS_NAME, METHOD_NAME, " HCLExtPIAddCmdImpl payMethodIdval:: " + payMethodIdval);
		}
		super.performExecute();
	}
	
}
