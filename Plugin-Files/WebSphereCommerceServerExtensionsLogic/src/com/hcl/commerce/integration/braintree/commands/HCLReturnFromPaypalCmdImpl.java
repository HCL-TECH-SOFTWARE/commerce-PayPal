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
package com.hcl.commerce.integration.braintree.commands;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.logging.Level;
import java.util.logging.Logger;

import org.apache.wink.json4j.JSONException;
import org.apache.wink.json4j.JSONObject;

import com.ibm.commerce.base.helpers.BaseJDBCHelper;
import com.ibm.commerce.command.CommandFactory;
import com.ibm.commerce.command.ControllerCommandImpl;
import com.ibm.commerce.datatype.TypedProperty;
import com.ibm.commerce.exception.ECException;
import com.ibm.commerce.exception.ParameterNotFoundException;
import com.ibm.commerce.foundation.logging.LoggingHelper;
import com.ibm.commerce.user.objects.AddressAccessBean;
import com.ibm.commerce.usermanagement.commands.AddressAddCmd;
import com.ibm.commerce.usermanagement.commands.AddressUpdateCmd;

public class HCLReturnFromPaypalCmdImpl extends ControllerCommandImpl implements HCLReturnFromPaypalCmd {

	private static final String CLASS_NAME = "ProcessPayPalReturnCmdImpl";
	final Logger LOGGER = LoggingHelper.getLogger(HCLReturnFromPaypalCmdImpl.class);
	private static final String PAYPAL_BILLING_ADDRESS = "PayPalBillingAddress";
	private static final String PAYPAL_SHIPPING_ADDRESS = "PayPalShippingAddress";
	private static final String PICKUP_STORE_ADDRESS = "StoreAddress";
	
	TypedProperty addressProp = new TypedProperty();
	TypedProperty reqProp = new TypedProperty();
	boolean updateAddress = false;
	String reqAddressId = "";

	/**
	 * Default constructor. This constructor simply calls the constructor of its
	 * super class
	 */
	public HCLReturnFromPaypalCmdImpl() {
		super();
	}

	/**
	 * Execute this command's business logic. This method is called by its
	 * associated Action class.
	 */
	public void performExecute() throws ECException {
		final String METHOD_NAME = "performExecute";

		LOGGER.entering(CLASS_NAME, METHOD_NAME);

		try {
			reqProp = getRequestProperties();
			
			AddressAddCmd createAddressCmd = (AddressAddCmd) CommandFactory.createCommand(AddressAddCmd.NAME, getStoreId());
			createAddressCmd.setCommandContext(commandContext);
			AddressUpdateCmd createUpdateCmd = (AddressUpdateCmd) CommandFactory.createCommand(AddressUpdateCmd.NAME,getStoreId());
			createUpdateCmd.setCommandContext(commandContext);
			
			//getting type of address from paypal request like shipping or billing or storePickup address
			String addressTypeFromPayPal = reqProp.getString("addressTypeFromPayPal");
			
			if (LOGGER.isLoggable(Level.FINEST))
				LOGGER.logp(Level.FINEST, CLASS_NAME, METHOD_NAME, "  addressTypeFromPayPal  : " + addressTypeFromPayPal);

			if (PAYPAL_BILLING_ADDRESS.equals(addressTypeFromPayPal)) {
				addressProp = getPaypalBillingAddress();
				addressProp.put("nickName", PAYPAL_BILLING_ADDRESS);
				try{
					reqAddressId = new AddressAccessBean().findByNickname(PAYPAL_BILLING_ADDRESS, getCommandContext().getUserId()).getAddressId();
					updateAddress = true;
				} catch (Exception e) {}
				
				if (LOGGER.isLoggable(Level.FINEST))
					LOGGER.logp(Level.FINEST, CLASS_NAME, METHOD_NAME, " PayPal Billing Address ID : " + reqAddressId);
					
				

			} else if (PAYPAL_SHIPPING_ADDRESS.equals(addressTypeFromPayPal)) {

				addressProp = getshippingProp(addressProp);
				addressProp.put("nickName", PAYPAL_SHIPPING_ADDRESS);
				try {
					reqAddressId = new AddressAccessBean().findByNickname(PAYPAL_SHIPPING_ADDRESS, getCommandContext().getUserId()).getAddressId();
					updateAddress = true;
				} catch (Exception e) {
					// Do not break. create a new address
				}

				if (LOGGER.isLoggable(Level.FINEST))
					LOGGER.logp(Level.FINEST, CLASS_NAME, METHOD_NAME, " PayPal Shipping Address ID : " + reqAddressId);

				// already existing address only update with latest pickupStoreAddress
			} else if (PICKUP_STORE_ADDRESS.equals(addressTypeFromPayPal)) {

				String pickupStoreId = reqProp.getString("pickupStoreId");
				String addressId = getPhysicalStoreAddress(pickupStoreId);
				String addressType = reqProp.getString("addressType");
				addressProp.put("addressType", addressType);
				addressProp.put("nickName", PICKUP_STORE_ADDRESS);
				addressProp = getBillingAddressprop(addressProp, addressId);
				String existBillingAddId = null;
				try {
					existBillingAddId = new AddressAccessBean().findByNickname(PICKUP_STORE_ADDRESS, getCommandContext().getUserId()).getAddressId();
					updateAddress = true;
				} catch (Exception e) {// Do not break. create a new address
				}
			}
			
			if (updateAddress) {
				addressProp.put("addressId", reqAddressId);
				createUpdateCmd.setRequestProperties(addressProp);
				createUpdateCmd.execute();
				reqAddressId = createUpdateCmd.getAddressId();
			} else {
				createAddressCmd.setRequestProperties(addressProp);
				createAddressCmd.execute();
				reqAddressId = createAddressCmd.getAddressId();
			}
			
			if(PICKUP_STORE_ADDRESS.equals(addressTypeFromPayPal))
				reqAddressId = "";
			
			TypedProperty response = new TypedProperty();
			JSONObject jsonResult = new JSONObject();

			try {
				jsonResult.put("updatedAddressId", reqAddressId);
			} catch (JSONException e) {
				e.printStackTrace();
			}
			response.put("result", jsonResult);
			setResponseProperties(response);
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	// setting billing address param's by using selected pickupStoreaddress
	public TypedProperty getBillingAddressprop(TypedProperty req, String storeAddressId) {
		TypedProperty addressAddProp = req;
		AddressAccessBean addressAB = new AddressAccessBean();
		addressAB.setInitKey_addressId(storeAddressId);
		addressAddProp.put("lastName", addressAB.getLastName());
		addressAddProp.put("address1", addressAB.getAddress1());
		addressAddProp.put("city", addressAB.getCity());
		addressAddProp.put("isVerificationRequired", "false");
		addressAddProp.put("state", addressAB.getState());
		addressAddProp.put("country", addressAB.getCity());
		addressAddProp.put("zipCode", addressAB.getZipCode());
		addressAddProp.put("URL", "dummy");
		return addressAddProp;
	}

	// getting selected paypal Shipping address
	public TypedProperty getshippingProp(TypedProperty shipReq) throws ParameterNotFoundException {
		final String methodName = "getshippingProp";
		shipReq =	getAddressProp();
		return shipReq;
	}

	public TypedProperty getPaypalBillingAddress() throws ParameterNotFoundException {
		final String methodName = "getPaypalBillingAddress";
		TypedProperty billingadd = getAddressProp();
		return billingadd;
	}

	public TypedProperty getAddressProp() throws ParameterNotFoundException {

		TypedProperty addressProp = new TypedProperty();

		String recipientName = reqProp.getString("recipientName");
		String address1 = reqProp.getString("address1");
		String address2 = reqProp.getString("address2");
		String city = reqProp.getString("city");
		String state = reqProp.getString("state");
		String countryCode = reqProp.getString("countryCode");
		String postalCode = reqProp.getString("postalCode");
		String addressType = reqProp.getString("addressType");

		String shipToFirstName = "";
		String shipToLastName = "";
		if (recipientName != null) {
			if (recipientName.indexOf(" ") == -1) {
				shipToFirstName = recipientName;
				shipToLastName = recipientName;

			} else {
				String[] names = recipientName.split(" ");
				if (names.length == 1) {
					shipToFirstName = recipientName;
					shipToLastName = recipientName;
				} else {
					shipToFirstName = names[0];
					shipToLastName = "";
					for (int namesItr = 1; namesItr < names.length; namesItr++) {
						shipToLastName = shipToLastName + " " + names[namesItr];
					}
				}
			}
		}
		addressProp.put("URL", "dummy");
		addressProp.put("addressType", addressType);
		addressProp.put("lastName", shipToLastName);
		addressProp.put("firstName", shipToFirstName);
		addressProp.put("address1", address1);
		addressProp.put("address2", address2);
		addressProp.put("city", city);
		addressProp.put("isVerificationRequired", "false");
		addressProp.put("state", state);
		addressProp.put("country", countryCode);
		addressProp.put("zipCode", postalCode);

		return addressProp;
	}

	// getting StoreaddressId by using physicalStoreid
	public String getPhysicalStoreAddress(String physicalStoreId) throws Exception {
		final String methodName = "getPhysicalStoreAddress";

		Connection connection = null;
		PreparedStatement prpdStatement = null;
		ResultSet results = null;
		String addrId = null;
		try {
			String ffmCenterId = getCommandContext().getStore().getFulfillmentCenterId();

			if (ffmCenterId != null && !ffmCenterId.trim().equals("") && physicalStoreId != null
					&& !physicalStoreId.trim().equals(""))
				connection = BaseJDBCHelper.getDataSource().getConnection();
			String query = "SELECT ADDRESS_ID FROM STLFFMREL WHERE  STLOC_ID  = " + physicalStoreId;// +"
			// "+ffmCenterId;
			prpdStatement = connection.prepareStatement(query);
			results = prpdStatement.executeQuery();
			while (results.next()) {
				addrId = results.getString("ADDRESS_ID");
			}
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			if (results != null)
				results.close();
			if (prpdStatement != null)
				prpdStatement.close();
			if (connection != null)
				connection.close();

		}
		return addrId;

	}
}
