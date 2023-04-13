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
package com.hcl.commerce.integration.braintree.handler;

import javax.ws.rs.GET;
import javax.ws.rs.POST;
import javax.ws.rs.Path;
import javax.ws.rs.PathParam;
import javax.ws.rs.Produces;
import javax.ws.rs.QueryParam;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;

import com.ibm.commerce.datatype.TypedProperty;
import com.ibm.commerce.rest.classic.core.AbstractConfigBasedClassicHandler;
import com.ibm.commerce.rest.javadoc.ResponseSchema;

@Path("braintree/{storeId}")
public class HCLBrainTreeRestHandler extends AbstractConfigBasedClassicHandler { 
	private static final String RESOURCE_NAME = "braintree";
	private static final String GET_CLIENT_TOKEN_PATH = "clienttoken";
	private static final String GET_PAYMENT_OPTIONS = "paymentOptions";
	private static final String SAVE_CARD_DETAILS = "saveCardDetails";
	private static final String DISPLAY_CARD_DETAILS = "displayCardDetails";
	private static final String DELETE_CARD_FROM_BT_VAULT = "deleteCardFromBTVault";
	private static final String UPDATE_SHIPPING_ADDRESS = "updateShippingAddress";
	private static final String VAULTED_CREDIT_CARD_VERIFICATION = "vaultedCreditCardVerification";
	private static final String PAYPAL_CREDIT_FINACING_OPTION = "CalculatePayPalCreditfinancingOption/{priceValue}";
	
	public static final String CARD_DETAILS = "CD";
	public static final String CLIENT_TOKEN = "CT";
	public static final String DELETE_CARD = "DC";
	public static final String CARD_VERIFICATION="CV";
	public static final String PAYMENT_OPTIONS = "PO";
	public static final String PAYPAL_CREDIT_FINANCING_OPTIONS = "PCF";
	public String store_Id;
	private static final String CLASS_NAME_PARAMETER = "com.hcl.commerce.braintree.vault.commands.HCLFetchInfoFromBTCmd";
	private static final String CLASS_NAME_PARAMETER_UPDATE_SHIPPINGADDRESS = "com.hcl.commerce.integration.braintree.commands.HCLReturnFromPaypalCmd";

	@Override
	public String getResourceName() {
		return RESOURCE_NAME;
	}

	@Path(GET_CLIENT_TOKEN_PATH)
	@GET
	@Produces({ MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML, MediaType.APPLICATION_XHTML_XML, MediaType.APPLICATION_ATOM_XML })
	@ResponseSchema(parameterGroup = RESOURCE_NAME, responseCodes = {
			@com.ibm.commerce.rest.javadoc.ResponseCode(code = 200, reason = "The requested completed successfully."),
			@com.ibm.commerce.rest.javadoc.ResponseCode(code = 400, reason = "Bad request. Some of the inputs provided to the request aren't valid."),
			@com.ibm.commerce.rest.javadoc.ResponseCode(code = 401, reason = "Not authenticated. The user session isn't valid."),
			@com.ibm.commerce.rest.javadoc.ResponseCode(code = 403, reason = "The user isn't authorized to perform the specified request."),
			@com.ibm.commerce.rest.javadoc.ResponseCode(code = 404, reason = "The specified resource couldn't be found."),
			@com.ibm.commerce.rest.javadoc.ResponseCode(code = 500, reason = "Internal server error. Additional details will be contained on the server logs.") })
	public Response getClientToken(@PathParam("storeId") String storeId,
			@QueryParam(value = "responseFormat") String responseFormat) throws Exception {

		String METHODNAME = "getClientToken";
		Response response = null;
		try{
			TypedProperty requestProperties = initializeRequestPropertiesFromRequestMap(responseFormat);
			store_Id = storeId;
			if (responseFormat == null)
				responseFormat = "application/json";
			
			requestProperties.put("methodFlag", CLIENT_TOKEN);
			response = executeControllerCommandWithContext(storeId, CLASS_NAME_PARAMETER, requestProperties,responseFormat);
			
		}catch(Exception e){
			e.printStackTrace();
		}
		return response;
	}

	@Path(GET_PAYMENT_OPTIONS)
	@GET
	@Produces({ MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML, MediaType.APPLICATION_XHTML_XML,MediaType.APPLICATION_ATOM_XML })
	@ResponseSchema(parameterGroup = RESOURCE_NAME, responseCodes = {
			@com.ibm.commerce.rest.javadoc.ResponseCode(code = 200, reason = "The requested completed successfully."),
			@com.ibm.commerce.rest.javadoc.ResponseCode(code = 400, reason = "Bad request. Some of the inputs provided to the request aren't valid."),
			@com.ibm.commerce.rest.javadoc.ResponseCode(code = 401, reason = "Not authenticated. The user session isn't valid."),
			@com.ibm.commerce.rest.javadoc.ResponseCode(code = 403, reason = "The user isn't authorized to perform the specified request."),
			@com.ibm.commerce.rest.javadoc.ResponseCode(code = 404, reason = "The specified resource couldn't be found."),
			@com.ibm.commerce.rest.javadoc.ResponseCode(code = 500, reason = "Internal server error. Additional details will be contained on the server logs.") })
	public Response getPaymentOptions(@PathParam("storeId") String storeId, @QueryParam(value = "responseFormat") String responseFormat) throws Exception {

		String METHODNAME = "getPaymentOptions";
		Response response = null;
		try {
			TypedProperty requestProperties = initializeRequestPropertiesFromRequestMap(responseFormat);
			store_Id = storeId;
			if (responseFormat == null)
				responseFormat = "application/json";
			
			requestProperties.put("methodFlag", PAYMENT_OPTIONS);
		    response = executeControllerCommandWithContext(storeId, CLASS_NAME_PARAMETER, requestProperties,responseFormat);
			// Response.ok(jsonResult).type(MediaType.APPLICATION_JSON_TYPE).build();

		} catch (Exception e) {
			e.printStackTrace();
		}
		return response;
	}

	// to display card data
	@Path(DISPLAY_CARD_DETAILS)
	@GET
	@Produces({ MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML, MediaType.APPLICATION_XHTML_XML,MediaType.APPLICATION_ATOM_XML })
	@ResponseSchema(parameterGroup = RESOURCE_NAME, responseCodes = {
			@com.ibm.commerce.rest.javadoc.ResponseCode(code = 200, reason = "The requested completed successfully."),
			@com.ibm.commerce.rest.javadoc.ResponseCode(code = 400, reason = "Bad request. Some of the inputs provided to the request aren't valid."),
			@com.ibm.commerce.rest.javadoc.ResponseCode(code = 401, reason = "Not authenticated. The user session isn't valid."),
			@com.ibm.commerce.rest.javadoc.ResponseCode(code = 403, reason = "The user isn't authorized to perform the specified request."),
			@com.ibm.commerce.rest.javadoc.ResponseCode(code = 404, reason = "The specified resource couldn't be found."),
			@com.ibm.commerce.rest.javadoc.ResponseCode(code = 500, reason = "Internal server error. Additional details will be contained on the server logs.") })
	public Response displayCardDetails(@PathParam("storeId") String storeId,
			@QueryParam(value = "responseFormat") String responseFormat) throws Exception {

		String METHODNAME = "displayCardDetails";
		Response response = null;
	
		try{
			TypedProperty requestProperties = initializeRequestPropertiesFromRequestMap(responseFormat);
			requestProperties.put("methodFlag", CARD_DETAILS);
			response = executeControllerCommandWithContext(storeId, CLASS_NAME_PARAMETER, requestProperties,responseFormat);
		}catch(Exception e){
			e.printStackTrace();
		}
		
		return response;
	}

	@Path(DELETE_CARD_FROM_BT_VAULT)
	@POST
	@Produces({ MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML, MediaType.APPLICATION_XHTML_XML,MediaType.APPLICATION_ATOM_XML })
	@ResponseSchema(parameterGroup = RESOURCE_NAME, responseCodes = {
			@com.ibm.commerce.rest.javadoc.ResponseCode(code = 200, reason = "The requested completed successfully."),
			@com.ibm.commerce.rest.javadoc.ResponseCode(code = 400, reason = "Bad request. Some of the inputs provided to the request aren't valid."),
			@com.ibm.commerce.rest.javadoc.ResponseCode(code = 401, reason = "Not authenticated. The user session isn't valid."),
			@com.ibm.commerce.rest.javadoc.ResponseCode(code = 403, reason = "The user isn't authorized to perform the specified request."),
			@com.ibm.commerce.rest.javadoc.ResponseCode(code = 404, reason = "The specified resource couldn't be found."),
			@com.ibm.commerce.rest.javadoc.ResponseCode(code = 500, reason = "Internal server error. Additional details will be contained on the server logs.") })
	public Response deleteCardFromBTVault(@PathParam("storeId") String storeId,
			@QueryParam(value = "responseFormat") String responseFormat) throws Exception {

		String METHODNAME = "deleteCardFromBTVault";
		Response response = null;
		try{
		TypedProperty requestProperties = initializeRequestPropertiesFromRequestMap(responseFormat);
		store_Id = storeId;
		if (responseFormat == null)
			responseFormat = "application/json";
		
		requestProperties.put("methodFlag", DELETE_CARD);
		 response = executeControllerCommandWithContext(storeId, CLASS_NAME_PARAMETER, requestProperties,
				responseFormat);
		// Response.ok(jsonResult).type(MediaType.APPLICATION_JSON_TYPE).build();
		}catch (Exception e){
			e.printStackTrace();
		 }

		return response;
	}
	
	@Path(UPDATE_SHIPPING_ADDRESS)
	@POST
	@Produces({ MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML, MediaType.APPLICATION_XHTML_XML,
			MediaType.APPLICATION_ATOM_XML })
	@ResponseSchema(parameterGroup = RESOURCE_NAME, responseCodes = {
			@com.ibm.commerce.rest.javadoc.ResponseCode(code = 200, reason = "The requested completed successfully."),
			@com.ibm.commerce.rest.javadoc.ResponseCode(code = 400, reason = "Bad request. Some of the inputs provided to the request aren't valid."),
			@com.ibm.commerce.rest.javadoc.ResponseCode(code = 401, reason = "Not authenticated. The user session isn't valid."),
			@com.ibm.commerce.rest.javadoc.ResponseCode(code = 403, reason = "The user isn't authorized to perform the specified request."),
			@com.ibm.commerce.rest.javadoc.ResponseCode(code = 404, reason = "The specified resource couldn't be found."),
			@com.ibm.commerce.rest.javadoc.ResponseCode(code = 500, reason = "Internal server error. Additional details will be contained on the server logs.") })
	public Response updateShippingAddressFromPaypal(@PathParam("storeId") String storeId,
			@QueryParam(value = "responseFormat") String responseFormat) throws Exception {

		String METHODNAME = "updateShippingAddressFromPaypal";
		
		TypedProperty requestProperties = initializeRequestPropertiesFromRequestMap(responseFormat);
		store_Id = storeId;
		if (responseFormat == null)
			responseFormat = "application/json";
		
		Response response=null;
		response = executeControllerCommandWithContext(storeId, CLASS_NAME_PARAMETER_UPDATE_SHIPPINGADDRESS, requestProperties,
				responseFormat);
		

		return response;
	}

	

	@Path(VAULTED_CREDIT_CARD_VERIFICATION)
	@POST
	@Produces({ MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML, MediaType.APPLICATION_XHTML_XML,MediaType.APPLICATION_ATOM_XML })
	@ResponseSchema(parameterGroup = RESOURCE_NAME, responseCodes = {
			@com.ibm.commerce.rest.javadoc.ResponseCode(code = 200, reason = "The requested completed successfully."),
			@com.ibm.commerce.rest.javadoc.ResponseCode(code = 400, reason = "Bad request. Some of the inputs provided to the request aren't valid."),
			@com.ibm.commerce.rest.javadoc.ResponseCode(code = 401, reason = "Not authenticated. The user session isn't valid."),
			@com.ibm.commerce.rest.javadoc.ResponseCode(code = 403, reason = "The user isn't authorized to perform the specified request."),
			@com.ibm.commerce.rest.javadoc.ResponseCode(code = 404, reason = "The specified resource couldn't be found."),
			@com.ibm.commerce.rest.javadoc.ResponseCode(code = 500, reason = "Internal server error. Additional details will be contained on the server logs.") })
	public Response vaultedCreditCardVerification(@PathParam("storeId") String storeId, @QueryParam(value = "responseFormat") String responseFormat) throws Exception {

		String METHODNAME = "vaultedCreditCardVerification";
		Response response = null;
		try {
			TypedProperty requestProperties = initializeRequestPropertiesFromRequestMap(responseFormat);
			store_Id = storeId;
			if (responseFormat == null)
				responseFormat = "application/json";
			
			requestProperties.put("methodFlag", CARD_VERIFICATION);
		    response = executeControllerCommandWithContext(storeId, CLASS_NAME_PARAMETER, requestProperties,responseFormat);
		    

		} catch (Exception e) {
			e.printStackTrace();
		}
		return response;
	}
	
	@Path(PAYPAL_CREDIT_FINACING_OPTION)
	@GET
	@Produces({ MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML, MediaType.APPLICATION_XHTML_XML,MediaType.APPLICATION_ATOM_XML })
	@ResponseSchema(parameterGroup = RESOURCE_NAME, responseCodes = {
			@com.ibm.commerce.rest.javadoc.ResponseCode(code = 200, reason = "The requested completed successfully."),
			@com.ibm.commerce.rest.javadoc.ResponseCode(code = 400, reason = "Bad request. Some of the inputs provided to the request aren't valid."),
			@com.ibm.commerce.rest.javadoc.ResponseCode(code = 401, reason = "Not authenticated. The user session isn't valid."),
			@com.ibm.commerce.rest.javadoc.ResponseCode(code = 403, reason = "The user isn't authorized to perform the specified request."),
			@com.ibm.commerce.rest.javadoc.ResponseCode(code = 404, reason = "The specified resource couldn't be found."),
			@com.ibm.commerce.rest.javadoc.ResponseCode(code = 500, reason = "Internal server error. Additional details will be contained on the server logs.") })
	public Response getPaypalCreditFinacingOption(@PathParam("storeId") String storeId, @PathParam("priceValue") String priceValue , @QueryParam(value = "responseFormat") String responseFormat) throws Exception {

		String METHODNAME = "getPaypalCreditFinacingOption";
		Response response = null;
		try {
			TypedProperty requestProperties = initializeRequestPropertiesFromRequestMap(responseFormat);
			store_Id = storeId;
			if (responseFormat == null)
				responseFormat = "application/json";
			
			requestProperties.put("priceValue", priceValue);
			requestProperties.put("methodFlag", PAYPAL_CREDIT_FINANCING_OPTIONS);
		    response = executeControllerCommandWithContext(storeId, CLASS_NAME_PARAMETER, requestProperties,responseFormat);
		    

		} catch (Exception e) {
			e.printStackTrace();
		}
		return response;
	}
}
