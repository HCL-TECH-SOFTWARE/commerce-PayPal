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
package com.hcl.commerce.braintree.vault.commands;

import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

import javax.ws.rs.core.MediaType;

import org.apache.wink.client.ClientConfig;
import org.apache.wink.client.ClientResponse;
import org.apache.wink.client.Resource;
import org.apache.wink.client.RestClient;
import org.apache.wink.json4j.JSONObject;
import org.codehaus.jackson.JsonProcessingException;
import org.codehaus.jackson.map.ObjectMapper;
import org.codehaus.jackson.map.ObjectWriter; 

import com.braintreegateway.BraintreeGateway;
import com.braintreegateway.PaymentMethodNonce;
import com.braintreegateway.Result;
import com.hcl.commerce.braintree.objects.SavedPayments;
import com.hcl.commerce.braintree.persistence.SavedPaymentsDaoImpl;
import com.hcl.commerce.braintree.valueObjects.BraintreeCreditCardDetails;
import com.hcl.commerce.payments.braintree.builder.HCLBrainTreeRequestBuilder;
import com.hcl.commerce.payments.braintree.processor.HCLBrainTreeProcessor;
import com.hcl.commerce.payments.braintree.processor.helper.HCLBrainTreeProcessorHelper;
import com.hcl.commerce.payments.braintree.services.BrainTreeServiceErrorException;
import com.hcl.commerce.payments.braintree.services.BrainTreeServiceException;
import com.hcl.commerce.payments.braintree.util.HCLBrainTreeConstants;
import com.hcl.commerce.payments.braintree.util.HCLBrainTreeUtility;
import com.hcl.commerce.payments.braintree.valueobjects.HCLBrainTreeCreditCardRequestObject;
import com.ibm.commerce.command.ControllerCommandImpl;
import com.ibm.commerce.datatype.TypedProperty;
import com.ibm.commerce.exception.ECApplicationException;
import com.ibm.commerce.foundation.logging.LoggingHelper;
import com.ibm.commerce.foundation.persistence.EntityDao;
import com.ibm.commerce.ras.ECMessage;
import com.ibm.commerce.ras.ECMessageSeverity;
import com.ibm.commerce.ras.ECMessageType;
import com.ibm.commerce.server.ECConstants;


public class HCLFetchInfoFromBTCmdImpl extends ControllerCommandImpl implements HCLFetchInfoFromBTCmd {

	private TypedProperty requestProperties = new TypedProperty();
	public String store_Id;
	public String methodFlagVal;
	private static final String CLASS_NAME = "HCLFetchInfoFromBTCmdImpl";
	private static final Logger LOGGER = Logger.getLogger(CLASS_NAME);
	public static final String CARD_DETAILS = "CD";
	public static final String CLIENT_TOKEN = "CT";
	public static final String DELETE_CARD = "DC";
	public static final String PAYMENT_OPTIONS = "PO";
	public static final String CARD_VERIFICATION = "CV";
	public static final String PAYPAL_CREDIT_FINANCING_OPTIONS = "PCF";
	public static final String VALUE = "value";
	public static final String CURRENCY_CODE = "currency_code";
	public static final String FINANCING_COUNTRY_CODE = "financing_country_code";
	public static final String TRANSACTION_AMOUNT = "transaction_amount";
	public static final String AUTHORIZATION = "Authorization";
	public static final String URL = "PAYPAL_CREDIT_FINANCING_OPTIONS_URL";
	public static final String AUTHORIZATION_TOKEN = "PAYPAL_AUTHORIZATION_TOKEN";

	public void performExecute() throws ECApplicationException {
		String METHOD_NAME = "performExecute";
		LOGGER.entering(CLASS_NAME, METHOD_NAME);
		JSONObject jsonResult = new JSONObject();
		if (LOGGER.isLoggable(Level.FINEST)) {
			LOGGER.logp(Level.FINEST, CLASS_NAME, METHOD_NAME,
					" requestProperties:: " + requestProperties + " methodFlagVal:: " + methodFlagVal);
		}
		
		if (CLIENT_TOKEN.equals(methodFlagVal)) {
			jsonResult = getClientToken();
		} else if (PAYMENT_OPTIONS.equals(methodFlagVal)) {
			jsonResult = getBrainTreeInfo();
		} else if (CARD_DETAILS.equals(methodFlagVal)) {
			jsonResult = getDisplayCardDetails();
		} else if (DELETE_CARD.equals(methodFlagVal)) {
			jsonResult = deleteCardFromVault();
		} else if (CARD_VERIFICATION.equals(methodFlagVal)) {
			jsonResult = vaultedCrediCardVerification();
		} else if (PAYPAL_CREDIT_FINANCING_OPTIONS.equals(methodFlagVal)) {
			jsonResult = getPaypalCreditFinancingOption();
		}

		TypedProperty response = new TypedProperty();
		response.put("result", jsonResult);

		setResponseProperties(response);
		if (LoggingHelper.isEntryExitTraceEnabled(LOGGER))
			LOGGER.exiting(CLASS_NAME, METHOD_NAME);
	}

	// getting Global variables from properties file like multiplecapture flag,
	// paypalCreditEnable flag
	public JSONObject getBrainTreeInfo() {
		final String METHOD_NAME = "getBrainTreeInfo";

		if (LoggingHelper.isEntryExitTraceEnabled(LOGGER))
			LOGGER.entering(CLASS_NAME, METHOD_NAME);

		JSONObject jsonResult = new JSONObject();

		try {
			Integer storeId = new Integer(store_Id);
			HCLBrainTreeUtility util = HCLBrainTreeUtility.getInstance(storeId);
			String enableVaultToCustomer = util.getConfProperty(HCLBrainTreeConstants.VAULT_ENABLE_FLAG, storeId);
			String useVaultForAuth = util.getConfProperty(HCLBrainTreeConstants.MULTIPLE_DEPOSIT_ENABLE_FLAG, storeId);
			String isPaypalCreditEnable = util.getConfProperty(HCLBrainTreeConstants.PAYPAL_CREDIT_ENABLE, storeId);
			String advancedFraudTools = util.getConfProperty(HCLBrainTreeConstants.ADVANCED_FRAUD_TOOLS_ENABLE, storeId);
			String paypalEnableInCart = util.getConfProperty(HCLBrainTreeConstants.PAYPAL_ENABLE_IN_CART, storeId);
			String paypalMerchantName = util.getConfProperty(HCLBrainTreeConstants.PAYPAL_MERCHANT_NAME, storeId);
			String locale = getCommandContext().getLocale().toString();
			String paypalFlow = util.getConfProperty(HCLBrainTreeConstants.PAYPAL_FLOW, storeId);
			String paypalIntent = util.getConfProperty(HCLBrainTreeConstants.PAYPAL_CHECKOUT_INTENT, storeId);
			String threeDSecureEnable = util.getConfProperty(HCLBrainTreeConstants.THREED_SECURE_ENABLE_FLAG, storeId);
			String billingAgreementDescription = util.getConfProperty(HCLBrainTreeConstants.PAYPAL_BILLING_AGREEMENT_DESCRIPTION, storeId);
			String paypalBillingAddressEnable = util.getConfProperty(HCLBrainTreeConstants.PAYPAL_BILLING_ADDRESS_ENABLE, storeId);
			String paymentEnvironment = util.getConfProperty(HCLBrainTreeConstants.PAYMENT_ENVIRONMENT, storeId);
			String googlepayPaymentEnvironment = util.getConfProperty(HCLBrainTreeConstants.GOOGLEPAY_PAYMENT_ENVIRONMENT, storeId);
			String googlePayPaymentMerchantId = util.getConfProperty(HCLBrainTreeConstants.GOOGLEPAY_PAYMENT_MERCHANTID,storeId);

			jsonResult.put("enableVaultToCustomer", enableVaultToCustomer);
			jsonResult.put("useVaultForAuth", useVaultForAuth);
			jsonResult.put("isPaypalCreditEnable", isPaypalCreditEnable);
			jsonResult.put("advancedFraudTools", advancedFraudTools);
			jsonResult.put("paypalEnableInCart", paypalEnableInCart);
			jsonResult.put("paypalMerchantName", paypalMerchantName);
			jsonResult.put("locale", locale);
			jsonResult.put("paypalFlow", paypalFlow);
			jsonResult.put("paypalIntent", paypalIntent);
			jsonResult.put("threeDSecureEnable", threeDSecureEnable);
			jsonResult.put("billingAgreementDescription", billingAgreementDescription);
			jsonResult.put("paypalBillingAddressEnable", paypalBillingAddressEnable);
			jsonResult.put("paymentEnvironment", paymentEnvironment);
			jsonResult.put("googlepayPaymentEnvironment", googlepayPaymentEnvironment);
			jsonResult.put("googlePayPaymentMerchantId", googlePayPaymentMerchantId);

		} catch (Exception e) {

		}
		if (LoggingHelper.isEntryExitTraceEnabled(LOGGER))
			LOGGER.exiting(CLASS_NAME, METHOD_NAME);
		return jsonResult;
	}

	// getting BrainTree Client token for enable payments
	public JSONObject getClientToken() {
		final String METHOD_NAME = "getClientToken";

		if (LoggingHelper.isEntryExitTraceEnabled(LOGGER))
			LOGGER.entering(CLASS_NAME, METHOD_NAME);
		JSONObject jsonResult = new JSONObject();
		try {
			String currency = getCommandContext().getCurrency().toString();

			HCLBrainTreeProcessorHelper helper = HCLBrainTreeProcessorHelper.getInstance(Integer.parseInt(store_Id));
			HCLBrainTreeProcessor service = helper.getBrainTreeProcessor(Integer.parseInt(store_Id));
			String clientToken = service.generateClientToken(currency);

			if (LOGGER.isLoggable(Level.FINEST)) {
				LOGGER.logp(Level.FINEST, CLASS_NAME, METHOD_NAME, "clientToken is " + clientToken);
			}
			jsonResult.put("clientToken", clientToken);
		} catch (Exception e) {
			e.printStackTrace();
		}
		if (LoggingHelper.isEntryExitTraceEnabled(LOGGER))
			LOGGER.exiting(CLASS_NAME, METHOD_NAME);

		return jsonResult;
	}

	// Setting markforDetele flag is 1 when user delete payment in
	// savedPaymentLsit
	public JSONObject deleteCardFromVault() {
		final String METHOD_NAME = "deleteCardFromVault";

		if (LoggingHelper.isEntryExitTraceEnabled(LOGGER))
			LOGGER.entering(CLASS_NAME, METHOD_NAME);
		JSONObject jsonResult = new JSONObject();
		try {

			String payToken = requestProperties.getString("x_payToken", null);
			Long userId = getCommandContext().getUserId();
			Timestamp currTimestamp = new Timestamp(System.currentTimeMillis());

			EntityDao savedPaymentDao = new SavedPaymentsDaoImpl();
			List savedPaymentsList = savedPaymentDao.query("SavedPayments.getSavedPaymentsByMemberIdAndPaymentToken",
					new Long(getCommandContext().getUserId()), payToken);

			SavedPayments savedPayments = (SavedPayments) savedPaymentsList.get(0);
			savedPayments.setMarkForDelete(1);
			savedPayments.setMarkForDeleteDate(currTimestamp);

			if (savedPayments.getMarkForDelete() == 1) {
				jsonResult.put("deleteResult", "deletedCardSuccessfully");
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		if (LoggingHelper.isEntryExitTraceEnabled(LOGGER))
			LOGGER.exiting(CLASS_NAME, METHOD_NAME);
		return jsonResult;
	}

	public JSONObject getDisplayCardDetails() {
		final String METHOD_NAME = "getDisplayCardDetails";

		if (LoggingHelper.isEntryExitTraceEnabled(LOGGER))
			LOGGER.entering(CLASS_NAME, METHOD_NAME);
		JSONObject jsonResult = new JSONObject();

		// get the credit cards list
		List<BraintreeCreditCardDetails> btCardDetailsList = new ArrayList<BraintreeCreditCardDetails>();

		try {

			EntityDao savedPaymentsDao = new SavedPaymentsDaoImpl();
			List savedPaymentsList = savedPaymentsDao.query(
					"SavedPayments.getSavedPaymentsByMemberIdAndMarkForDeleteAndAddedInPIAuth",
					new Long(getCommandContext().getUserId()), 0, 1);
			for (int i = 0; i < savedPaymentsList.size(); i++) {

				SavedPayments savedPayment = (SavedPayments) savedPaymentsList.get(i);
				// VO object created in commerce
				BraintreeCreditCardDetails btCardDetails = new BraintreeCreditCardDetails();

				btCardDetails.setCardType(savedPayment.getPaymentType());
				btCardDetails.setMaskedCreditCardNumber(savedPayment.getPaymentAccount());
				btCardDetails.setExpirationDate(savedPayment.getExpiryDate());
				btCardDetails.setPayTokenId(savedPayment.getPaymentToken());
				btCardDetails.setPaymentMethodId(savedPayment.getPaymentMethodId());
				btCardDetailsList.add(btCardDetails);
			}

			jsonResult.put("btCardDetailsList", btCardDetailsList);

		} catch (Exception e1) {
			e1.printStackTrace();
		}
		if (LoggingHelper.isEntryExitTraceEnabled(LOGGER))
			LOGGER.exiting(CLASS_NAME, METHOD_NAME);

		return jsonResult;
	}

	public void validateParameters() {
		String METHOD_NAME = "validateParameters";
		if (LoggingHelper.isEntryExitTraceEnabled(LOGGER))
			LOGGER.entering(CLASS_NAME, METHOD_NAME);
		try {
			if (LOGGER.isLoggable(Level.FINEST)) {
				LOGGER.logp(Level.FINEST, CLASS_NAME, METHOD_NAME,
						"request Properties are: " + getCommandContext().getRequestProperties());
			}
			requestProperties = getCommandContext().getRequestProperties();

			store_Id = getCommandContext().getStoreId().toString();
			methodFlagVal = requestProperties.getString("methodFlag", null);
			if (LOGGER.isLoggable(Level.FINEST)) {
				LOGGER.logp(Level.FINEST, CLASS_NAME, METHOD_NAME,
						"StoreId is " + store_Id + " methodFlagVal" + methodFlagVal);
			}
		} catch (Exception e) {
			LOGGER.info(e.getMessage());
		}
		if (LoggingHelper.isEntryExitTraceEnabled(LOGGER))
			LOGGER.exiting(CLASS_NAME, METHOD_NAME);

	}

	public JSONObject vaultedCrediCardVerification() throws ECApplicationException {
		final String METHOD_NAME = "vaultedCrediCardVerification";

		if (LoggingHelper.isEntryExitTraceEnabled(LOGGER))
			LOGGER.entering(CLASS_NAME, METHOD_NAME);
		JSONObject jsonResult = new JSONObject();

		if (LOGGER.isLoggable(Level.FINEST)) {
			LOGGER.logp(Level.FINEST, CLASS_NAME, METHOD_NAME, "requestProperties is " + requestProperties);
		}
		String payToken = requestProperties.getString("payToken", null);
		String cvvNonce = requestProperties.getString("cvvNonce", null);
		String storeId = requestProperties.getString("storeId", null);
		String catalogId = requestProperties.getString("catalogId", null);
		String billingAddressId = requestProperties.getString("billingAddressId", null);
		String payType = requestProperties.getString("payType", null);
		String deviceSessionId = requestProperties.getString("deviceSessionId", null);
		String fraudMerchantId = requestProperties.getString("fraudMerchantId", null);
		String paymentMethodId = requestProperties.getString("paymentMethodId", null);
		String userId = getCommandContext().getUserId().toString();

		HashMap<String, String> creditCardDetailsMap = new HashMap<String, String>();
		creditCardDetailsMap.put("storeId", storeId);
		creditCardDetailsMap.put("userId", userId);
		creditCardDetailsMap.put("billingAddressId", billingAddressId);
		creditCardDetailsMap.put("fromSavedPaymentFlag", "true"); // this method
																	// gets
																	// called
																	// for saved
																	// payments
																	// only
		creditCardDetailsMap.put("payType", payType);
		creditCardDetailsMap.put("deviceSessionId", deviceSessionId);
		creditCardDetailsMap.put("fraudMerchantId", fraudMerchantId);
		creditCardDetailsMap.put("paymentMethodId", paymentMethodId);

		HCLBrainTreeProcessorHelper helper = null;
		try {
			helper = HCLBrainTreeProcessorHelper.getInstance(Integer.parseInt(storeId));
			HCLBrainTreeRequestBuilder builder = helper.getBraintreeRequestBuilder(Integer.parseInt(storeId));
			HCLBrainTreeProcessor service = helper.getBrainTreeProcessor(Integer.parseInt(storeId));
			HCLBrainTreeCreditCardRequestObject ccreqObj = builder.getCreditCardDetailsObject(creditCardDetailsMap);
			service.cardVerificationByCVVAndAVS(cvvNonce, payToken, ccreqObj);

			String is3DSecureEnabled = HCLBrainTreeUtility.getInstance(new Integer(store_Id))
					.getConfProperty(HCLBrainTreeConstants.THREED_SECURE_ENABLE_FLAG, new Integer(store_Id));
			if (LOGGER.isLoggable(Level.FINEST)) {
				LOGGER.logp(Level.FINEST, CLASS_NAME, METHOD_NAME, "is3DSecureEnabled" + is3DSecureEnabled);
			}
			if (is3DSecureEnabled.equalsIgnoreCase("true")) {
				// if 3dsecure is enabled,convert paytoken to nonce
				BraintreeGateway gateway = HCLBrainTreeUtility.getInstance(new Integer(store_Id))
						.getGatewayObject(new Integer(store_Id));
				Result<PaymentMethodNonce> result = gateway.paymentMethodNonce().create(payToken);
				String nonce = result.getTarget().getNonce();
				jsonResult.put("nonce", nonce);
			}
			jsonResult.put("is3DSecureEnabled", is3DSecureEnabled);

		} catch (BrainTreeServiceException btse) {
			LOGGER.logp(Level.SEVERE, CLASS_NAME, METHOD_NAME, "Encountered exception [" + btse.toString() + "]", btse);
			throw new ECApplicationException(ECMessage._ERR_CMD_BAD_EXEC_CMD, CLASS_NAME, METHOD_NAME);
		} catch (BrainTreeServiceErrorException btsee) {
			LOGGER.logp(Level.SEVERE, CLASS_NAME, METHOD_NAME, "Encountered exception [" + btsee.toString() + "]",
					btsee);
			throw new ECApplicationException(new ECMessage(ECMessageSeverity.ERROR, ECMessageType.USER,
					"BRAINTREE_ERROR_" + btsee.getError(0).getErrorCode(),
					helper.getErrorResourceBundleName(getStoreId())), CLASS_NAME, "methodName");
		} catch (Exception e1) {
			e1.printStackTrace();
		}

		if (LoggingHelper.isEntryExitTraceEnabled(LOGGER))
			LOGGER.exiting(CLASS_NAME, METHOD_NAME);

		return jsonResult;
	}

	public void setRequestProperties(TypedProperty requestProperties) {
		this.requestProperties = requestProperties;
	}

	// getting BrainTree Client token for enable payments
	public JSONObject getPaypalCreditFinancingOption() {
		final String METHOD_NAME = "getPaypalCreditFinancingOption";

		if (LoggingHelper.isEntryExitTraceEnabled(LOGGER))
			LOGGER.entering(CLASS_NAME, METHOD_NAME);
		JSONObject jsonResult = new JSONObject();
		try {
			String country = getCommandContext().getCountry().toString();
			String currency = getCommandContext().getCurrency().toString();
			String amount = requestProperties.getString("priceValue", null);
			
			Integer storeId = new Integer(store_Id);
			HCLBrainTreeUtility util = HCLBrainTreeUtility.getInstance(storeId);
			String url = util.getConfProperty(URL,storeId);
			String AuthToken = util.getConfProperty(AUTHORIZATION_TOKEN,storeId);
			
			if (LOGGER.isLoggable(Level.FINEST)) {
				LOGGER.logp(Level.FINEST, CLASS_NAME, METHOD_NAME, "currency : "+ currency+" amount:: "+amount+" country:: "+country);
			}
			ClientConfig clientConfig = new ClientConfig();
			clientConfig.readTimeout(30000);
			clientConfig.connectTimeout(30000);
			RestClient restClient = new RestClient(clientConfig);
			
			Resource restResource = restClient.resource(url);
			//.resource("https://api.sandbox.paypal.com/v1/credit/calculated-financing-options");
			restResource.accept(MediaType.APPLICATION_JSON);
			restResource.header(ECConstants.EC_CONTENT_TYPE, MediaType.APPLICATION_JSON);
			restResource.header(AUTHORIZATION,AuthToken);
			//"Basic QVNyTlNYYU1vTHpFVXlNZjQ5VmdnTHdBSTZxaTRicmFJRHJQWGtEVlVIcWF6Z1lMcVRpekFYQ0dYb3lWZ09qNWhVSWdYUkdoclMtV2R3YXQ6RUdGakQ0S1U5SkVGMEs5S21ub0lMaFFGR1JFUXVFb0FuRmdxandRY0NCRnZiN2lwOFVmZnNrb2owSGVQX0t5dFFZQXlMX0pwVElDZWxxcm4=");

			String json = "";
			Map amounts = new LinkedHashMap<String, String>();
			Map detailsMap = new LinkedHashMap<String, String>();
			detailsMap.put(FINANCING_COUNTRY_CODE, country);
			amounts.put(VALUE, amount);
			amounts.put(CURRENCY_CODE, currency);
			detailsMap.put(TRANSACTION_AMOUNT, amounts);
			ObjectWriter ow = new ObjectMapper().writer().withDefaultPrettyPrinter();
			
			try {
				json = ow.writeValueAsString(detailsMap);
				if (LOGGER.isLoggable(Level.FINEST)) {
					LOGGER.logp(Level.FINEST, CLASS_NAME, METHOD_NAME, "json : " + json);
				}
			} catch (JsonProcessingException e) {
				e.printStackTrace();
			}

			ClientResponse clientResponse = restResource.contentType(MediaType.APPLICATION_JSON).post(json.toString());

			int statusCode = clientResponse.getStatusCode();
			String responseEntity = clientResponse.getEntity(String.class);
			if (LOGGER.isLoggable(Level.FINEST)) {
				LOGGER.logp(Level.FINEST, CLASS_NAME, METHOD_NAME, "responseEntity : " + responseEntity);
			}
			jsonResult = new JSONObject(responseEntity);

			if (LOGGER.isLoggable(Level.FINEST)) {
				LOGGER.logp(Level.FINEST, CLASS_NAME, METHOD_NAME, "response is " + jsonResult);
			}

		} catch (Exception e) {
			e.printStackTrace();
		}
		if (LoggingHelper.isEntryExitTraceEnabled(LOGGER))
			LOGGER.exiting(CLASS_NAME, METHOD_NAME);

		return jsonResult;
	}
}
