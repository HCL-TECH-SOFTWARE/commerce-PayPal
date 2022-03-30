<!DOCTYPE html PUBLIC "-//WAPFORUM//DTD XHTML Mobile 1.2//EN" "http://www.openmobilealliance.org/tech/DTD/xhtml-mobile12.dtd">

<%--
=================================================================
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
=================================================================
--%>

<%--
  *****
  * This JSP displays allows the user to select the payment type, and provide
  * payment details for order checkout.
  *****
--%>

<!-- BEGIN OrderPaymentDetails.jsp -->

<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://commerce.ibm.com/base" prefix="wcbase" %>
<%@ taglib uri="http://commerce.ibm.com/foundation" prefix="wcf" %>

<%@ include file="../../../include/parameters.jspf" %>
<%@ include file="../../../Common/EnvironmentSetup.jspf" %>
<%@ include file="../../include/nocache.jspf" %>
<%@ include file="../../include/ErrorMessageSetup.jspf" %>



<!-- BRAINTREE START -->

<!-- venmo -->
<script src="https://js.braintreegateway.com/web/3.38.0/js/venmo.min.js"></script>
<!-- devicedata -->
<script src="https://js.braintreegateway.com/web/3.38.0/js/data-collector.min.js"></script>
<!-- hosted fields -->
<script src="https://js.braintreegateway.com/web/3.38.0/js/hosted-fields.min.js"></script>
<!-- google pay -->
<script src="https://pay.google.com/gp/p/js/pay.js"></script>
<script src="https://js.braintreegateway.com/web/3.38.0/js/google-payment.min.js"></script>
<!--apple pay-->
<script src="https://js.braintreegateway.com/web/3.38.0/js/apple-pay.min.js"></script>
<!--3Dsecure -->
<script src="https://js.braintreegateway.com/web/3.38.0/js/three-d-secure.min.js"></script>


<!-- Rest calls for getting client token, paymentOptions, saved payments list details  -->
<wcf:rest var="getToken" url="braintree/{storeId}/clienttoken" scope="request">
	<wcf:var name="storeId" value="${WCParam.storeId}" encode="true"/>
</wcf:rest>
<c:set var="getTokenResult" value="${getToken.result}"/>


<wcf:rest var="getPaymentOptions" url="braintree/{storeId}/paymentOptions" scope="request">
	<wcf:var name="storeId" value="${WCParam.storeId}" encode="true"/>
</wcf:rest>
<c:set var="getPaymentOptionsResult" value="${getPaymentOptions.result}"/>						
<c:set var="showSavedPaymentsFlag" value="${getPaymentOptionsResult.enableVaultToCustomer}"/>
<c:set var="useVaultForAuth" value="${getPaymentOptionsResult.useVaultForAuth}"/>
<c:set var="isPayPalCreditEnable" value="${getPaymentOptionsResult.isPaypalCreditEnable}"/>
<c:set var="threeDSecureEnable" value="${getPaymentOptionsResult.threeDSecureEnable}"/>
<c:set var="advancedFraudTools" value="${getPaymentOptionsResult.advancedFraudTools}"/>
<c:set var="paypalFlow" value="${getPaymentOptionsResult.paypalFlow}"/>
<c:set var="paypalIntent" value="${getPaymentOptionsResult.paypalIntent}"/>
<c:set var="locale" value="${getPaymentOptionsResult.locale}"/>
<c:set var="billingAgreementDescription" value="${getPaymentOptionsResult.billingAgreementDescription}"/>
<c:set var="paymentEnvironment" value="${getPaymentOptionsResult.paymentEnvironment}"/>
<c:set var="googlepayPaymentEnvironment" value="${getPaymentOptionsResult.googlepayPaymentEnvironment}"/>
<c:set var="googlePayPaymentMerchantId" value="${getPaymentOptionsResult.googlePayPaymentMerchantId}"/>
							


<wcf:rest var="displayCardDetails" url="braintree/{storeId}/displayCardDetails" scope="request">
		<wcf:var name="storeId" value="${WCParam.storeId}" encode="true"/>
</wcf:rest>
<c:set var="creditCardDetailsList" value="${displayCardDetails.result}"/><br>
<c:set var="creditCardDetailsListInfo" value="${creditCardDetailsList.btCardDetailsList}" />
<script src="https://code.jquery.com/jquery-1.9.1.min.js"></script>
<script>
$(document).ready(function(){
		<fmt:message bundle="${storeText}" key="BT_GENERIC_CLIENT_TOKEN_ERROR" var="BT_GENERIC_CLIENT_TOKEN_ERROR"/>
		<fmt:message bundle="${storeText}" key="BT_GENERIC_DEVICE_DATA_ERROR" var="BT_GENERIC_DEVICE_DATA_ERROR"/>
		<fmt:message bundle="${storeText}" key="BT_PAYPAL_ONCANCEL" var="BT_PAYPAL_ONCANCEL"/>
		<fmt:message bundle="${storeText}" key="BT_PAYPAL_ONERROR" var="BT_PAYPAL_ONERROR"/>
		<fmt:message bundle="${storeText}" key="BT_PAYPAL_CHECKOUTERROR" var="BT_PAYPAL_CHECKOUTERROR"/>
		<fmt:message bundle="${storeText}" key="BT_VENMO_ERROR_VENMO_CANCELLED" var="BT_VENMO_ERROR_VENMO_CANCELLED"/>
		<fmt:message bundle="${storeText}" key="BT_VENMO_ERROR_VENMO_APP_CANCELLED" var="BT_VENMO_ERROR_VENMO_APP_CANCELLED"/>
		<fmt:message bundle="${storeText}" key="BT_VENMO_ERROR_GENERIC" var="BT_VENMO_ERROR_GENERIC"/>
		<fmt:message bundle="${storeText}" key="BT_VENMO_BROWSER_NOT_SUPPORTED" var="BT_VENMO_BROWSER_NOT_SUPPORTED"/>
		<fmt:message bundle="${storeText}" key="BT_GOOGLEPAY_PARSING_ERROR" var="BT_GOOGLEPAY_PARSING_ERROR"/>
		<fmt:message bundle="${storeText}" key="BT_GOOGLEPAY_ERROR_AT_LOADPAYMENTDATA" var="BT_GOOGLEPAY_ERROR_AT_LOADPAYMENTDATA"/>
		<fmt:message bundle="${storeText}" key="BT_GOOGLEPAY_RESPONSE_FAILED_ERROR" var="BT_GOOGLEPAY_RESPONSE_FAILED_ERROR"/>
		<fmt:message bundle="${storeText}" key="BT_GOOGLEPAY_PAYMENT_ERROR" var="BT_GOOGLEPAY_PAYMENT_ERROR"/>
		<fmt:message bundle="${storeText}" key="BT_APPLEPAY_DEVICE_NOT_SUPPORTED" var="BT_APPLEPAY_DEVICE_NOT_SUPPORTED"/>
		<fmt:message bundle="${storeText}" key="BT_APPLEPAY_DEVICE_NOT_CAPABLE" var="BT_APPLEPAY_DEVICE_NOT_CAPABLE"/>
		<fmt:message bundle="${storeText}" key="BT_APPLEPAY_APPLEPAY_ERR" var="BT_APPLEPAY_APPLEPAY_ERR"/>
		<fmt:message bundle="${storeText}" key="BT_APPLEPAY_PERFORM_VALIDATION_ERR" var="BT_APPLEPAY_PERFORM_VALIDATION_ERR"/>
		<fmt:message bundle="${storeText}" key="BT_APPLEPAY_TOKENIZEERR" var="BT_APPLEPAY_TOKENIZEERR"/>
		<fmt:message bundle="${storeText}" key="BT_THREE_D_SECURE_ERROR" var="BT_THREE_D_SECURE_ERROR"/>
		<fmt:message bundle="${storeText}" key="BT_THREE_D_SECURE_RESPONSE_FAILED_ERROR" var="BT_THREE_D_SECURE_RESPONSE_FAILED_ERROR"/>
		<fmt:message bundle="${storeText}" key="BT_EMPTY_PAYMENT_ERROR" var="BT_EMPTY_PAYMENT_ERROR"/>
		<fmt:message bundle="${storeText}" key="BT_HOSTEDFIELDS_ERROR" var="BT_HOSTEDFIELDS_ERROR"/>
		<fmt:message bundle="${storeText}" key="BT_CVV_FIELD_EMPTY" var="BT_CVV_FIELD_EMPTY"/>
		<fmt:message bundle="${storeText}" key="BT_CVV_FIELD_INVALID" var="BT_CVV_FIELD_INVALID"/>
		<fmt:message bundle="${storeText}" key="BT_HOSTEDFIELDS_EMPTY" var="BT_HOSTEDFIELDS_EMPTY"/>
		<fmt:message bundle="${storeText}" key="BT_HOSTEDFIELDS_INVALID" var="BT_HOSTEDFIELDS_INVALID"/>
		<fmt:message bundle="${storeText}" key="BT_HOSTEDFIELDS_NETWORK_ERROR" var="BT_HOSTEDFIELDS_NETWORK_ERROR"/>
		<fmt:message bundle="${storeText}" key="BT_HOSTEDFIELDS_TOKENIZATION_FAIL_ON_DUPLICATE" var="BT_HOSTEDFIELDS_TOKENIZATION_FAIL_ON_DUPLICATE"/>
		<fmt:message bundle="${storeText}" key="BT_HOSTEDFIELDS_TOKENIZATION_CVV_VERIFICATION_FAILED" var="BT_HOSTEDFIELDS_TOKENIZATION_CVV_VERIFICATION_FAILED"/>
		<fmt:message bundle="${storeText}" key="BT_HOSTEDFIELDS_FAILED_TOKENIZATION" var="BT_HOSTEDFIELDS_FAILED_TOKENIZATION"/>
		<fmt:message bundle="${storeText}" key="BT_HOSTEDFIELDS_DEFAULT_ERROR" var="BT_HOSTEDFIELDS_DEFAULT_ERROR"/>
		<fmt:message bundle="${storeText}" key="BT_HOSTEDFIELDS_HOSTEDFIELDSERR_FOR_CVV" var="BT_HOSTEDFIELDS_HOSTEDFIELDSERR_FOR_CVV"/>
		
		
		
		
		BrainTreeMobilePayments.setErrorMessage("BT_GENERIC_CLIENT_TOKEN_ERROR", <wcf:json object="${BT_GENERIC_CLIENT_TOKEN_ERROR}"/>);
		BrainTreeMobilePayments.setErrorMessage("BT_GENERIC_DEVICE_DATA_ERROR", <wcf:json object="${BT_GENERIC_DEVICE_DATA_ERROR}"/>);
		BrainTreeMobilePayments.setErrorMessage("BT_PAYPAL_ONCANCEL", <wcf:json object="${BT_PAYPAL_ONCANCEL}"/>);
		BrainTreeMobilePayments.setErrorMessage("BT_PAYPAL_ONERROR", <wcf:json object="${BT_PAYPAL_ONERROR}"/>);
		BrainTreeMobilePayments.setErrorMessage("BT_PAYPAL_CHECKOUTERROR", <wcf:json object="${BT_PAYPAL_CHECKOUTERROR}"/>);
		BrainTreeMobilePayments.setErrorMessage("BT_VENMO_ERROR_VENMO_CANCELLED", <wcf:json object="${BT_VENMO_ERROR_VENMO_CANCELLED}"/>);
		BrainTreeMobilePayments.setErrorMessage("BT_VENMO_ERROR_VENMO_APP_CANCELLED", <wcf:json object="${BT_VENMO_ERROR_VENMO_APP_CANCELLED}"/>);
		BrainTreeMobilePayments.setErrorMessage("BT_VENMO_ERROR_GENERIC", <wcf:json object="${BT_VENMO_ERROR_GENERIC}"/>);
		BrainTreeMobilePayments.setErrorMessage("BT_VENMO_BROWSER_NOT_SUPPORTED", <wcf:json object="${BT_VENMO_BROWSER_NOT_SUPPORTED}"/>);
		BrainTreeMobilePayments.setErrorMessage("BT_GOOGLEPAY_PARSING_ERROR", <wcf:json object="${BT_GOOGLEPAY_PARSING_ERROR}"/>);
		BrainTreeMobilePayments.setErrorMessage("BT_GOOGLEPAY_ERROR_AT_LOADPAYMENTDATA", <wcf:json object="${BT_GOOGLEPAY_ERROR_AT_LOADPAYMENTDATA}"/>);
		BrainTreeMobilePayments.setErrorMessage("BT_GOOGLEPAY_RESPONSE_FAILED_ERROR", <wcf:json object="${BT_GOOGLEPAY_RESPONSE_FAILED_ERROR}"/>);
		BrainTreeMobilePayments.setErrorMessage("BT_GOOGLEPAY_PAYMENT_ERROR", <wcf:json object="${BT_GOOGLEPAY_PAYMENT_ERROR}"/>);
		BrainTreeMobilePayments.setErrorMessage("BT_APPLEPAY_DEVICE_NOT_SUPPORTED", <wcf:json object="${BT_APPLEPAY_DEVICE_NOT_SUPPORTED}"/>);
		BrainTreeMobilePayments.setErrorMessage("BT_APPLEPAY_DEVICE_NOT_CAPABLE", <wcf:json object="${BT_APPLEPAY_DEVICE_NOT_CAPABLE}"/>);
		BrainTreeMobilePayments.setErrorMessage("BT_APPLEPAY_APPLEPAY_ERR", <wcf:json object="${BT_APPLEPAY_APPLEPAY_ERR}"/>);
		BrainTreeMobilePayments.setErrorMessage("BT_APPLEPAY_PERFORM_VALIDATION_ERR", <wcf:json object="${BT_APPLEPAY_PERFORM_VALIDATION_ERR}"/>);
		BrainTreeMobilePayments.setErrorMessage("BT_APPLEPAY_TOKENIZEERR", <wcf:json object="${BT_APPLEPAY_TOKENIZEERR}"/>);
		BrainTreeMobilePayments.setErrorMessage("BT_THREE_D_SECURE_ERROR", <wcf:json object="${BT_THREE_D_SECURE_ERROR}"/>);
		BrainTreeMobilePayments.setErrorMessage("BT_THREE_D_SECURE_RESPONSE_FAILED_ERROR", <wcf:json object="${BT_THREE_D_SECURE_RESPONSE_FAILED_ERROR}"/>);
		BrainTreeMobilePayments.setErrorMessage("BT_EMPTY_PAYMENT_ERROR", <wcf:json object="${BT_EMPTY_PAYMENT_ERROR}"/>);
		BrainTreeMobilePayments.setErrorMessage("BT_HOSTEDFIELDS_ERROR", <wcf:json object="${BT_HOSTEDFIELDS_ERROR}"/>);
		BrainTreeMobilePayments.setErrorMessage("BT_CVV_FIELD_EMPTY", <wcf:json object="${BT_CVV_FIELD_EMPTY}"/>);
		BrainTreeMobilePayments.setErrorMessage("BT_CVV_FIELD_INVALID", <wcf:json object="${BT_CVV_FIELD_INVALID}"/>);
		BrainTreeMobilePayments.setErrorMessage("BT_HOSTEDFIELDS_EMPTY", <wcf:json object="${BT_HOSTEDFIELDS_EMPTY}"/>);
		BrainTreeMobilePayments.setErrorMessage("BT_HOSTEDFIELDS_INVALID", <wcf:json object="${BT_HOSTEDFIELDS_INVALID}"/>);
		BrainTreeMobilePayments.setErrorMessage("BT_HOSTEDFIELDS_NETWORK_ERROR", <wcf:json object="${BT_HOSTEDFIELDS_NETWORK_ERROR}"/>);
		BrainTreeMobilePayments.setErrorMessage("BT_HOSTEDFIELDS_TOKENIZATION_FAIL_ON_DUPLICATE", <wcf:json object="${BT_HOSTEDFIELDS_TOKENIZATION_FAIL_ON_DUPLICATE}"/>);
		BrainTreeMobilePayments.setErrorMessage("BT_HOSTEDFIELDS_TOKENIZATION_CVV_VERIFICATION_FAILED", <wcf:json object="${BT_HOSTEDFIELDS_TOKENIZATION_CVV_VERIFICATION_FAILED}"/>);
		BrainTreeMobilePayments.setErrorMessage("BT_HOSTEDFIELDS_FAILED_TOKENIZATION", <wcf:json object="${BT_HOSTEDFIELDS_FAILED_TOKENIZATION}"/>);
		BrainTreeMobilePayments.setErrorMessage("BT_HOSTEDFIELDS_DEFAULT_ERROR", <wcf:json object="${BT_HOSTEDFIELDS_DEFAULT_ERROR}"/>);
		BrainTreeMobilePayments.setErrorMessage("BT_HOSTEDFIELDS_HOSTEDFIELDSERR_FOR_CVV", <wcf:json object="${BT_HOSTEDFIELDS_HOSTEDFIELDSERR_FOR_CVV}"/>);
		
});
</script>	
<!-- BRAINTREE END -->

<%-- Required variables for breadcrumb support --%>
<c:set var="shoppingcartPageGroup" value="true" scope="request"/>
<c:set var="paymentSelectionPage" value="true" scope="request"/>

<c:set var="storeId" value="${WCParam.storeId}" />
<c:set var="catalogId" value="${WCParam.catalogId}" />

<wcf:rest var="usablePayments" url="store/{storeId}/cart/@self/usable_payment_info">
	<wcf:var name="storeId" value="${WCParam.storeId}" encode="true"/>
	<wcf:param name="accessProfile" value="IBM_UsablePaymentInfo" />
</wcf:rest>

<wcf:rest var="person" url="store/{storeId}/person/@self">
	<wcf:var name="storeId" value="${WCParam.storeId}" encode="true"/>
</wcf:rest>

<c:set var="pickUpAt" value="" />
<wcf:rest var="order" url="store/{storeId}/cart/@self" scope="request">
	<wcf:var name="storeId" value="${WCParam.storeId}" encode="true"/>
	<wcf:param name="sortOrderItemBy" value="orderItemID"/>
	<wcf:param name="pageSize" value="${pageSize}"/>
	<wcf:param name="pageNumber" value="1"/>
</wcf:rest>
<!-- BRAINTREE START-->
<fmt:formatNumber var="totalAmount" value="${order.grandTotal}" type="number" maxFractionDigits="2" />
<!-- BRAINTREE END-->
<wcf:rest var="shippingInfo" url="store/{storeId}/cart/@self/shipping_info">
	<wcf:var name="storeId" value="${WCParam.storeId}" encode="true"/>
	<wcf:param name="pageSize" value="${pageSize}"/>
	<wcf:param name="pageNumber" value="1"/>
</wcf:rest>
<c:set var="pickUpAt" value="${shippingInfo.orderItem[0].physicalStoreId}" />

<wcf:rest var="paymentInstruction" url="store/{storeId}/cart/@self/payment_instruction" scope="request">
	<wcf:var name="storeId" value="${WCParam.storeId}" encode="true"/>
	<wcf:param name="pageSize" value="${pageSize}"/>
	<wcf:param name="pageNumber" value="1"/>
</wcf:rest>

<html xmlns="http://www.w3.org/1999/xhtml" lang="${shortLocale}" xml:lang="${shortLocale}">

	<head>
		<title><fmt:message bundle="${storeText}" key="PAYMENT_TITLE"/></title>
		<meta http-equiv="content-type" content="application/xhtml+xml" />
		<meta http-equiv="cache-control" content="max-age=300" />
		<meta name="viewport" content="${viewport}" />
		<link rel="stylesheet" type="text/css" href="${env_vfileStylesheet_m30}" />

		<%@ include file="../../include/CommonAssetsForHeader.jspf" %>
	</head>

	<body>
		<div id="wrapper" class="ucp_active"> <!-- User Control Panel is ON-->
			<%@ include file="../../include/HeaderDisplay.jspf" %>

			<!-- Start Breadcrumb Bar -->
			<div id="breadcrumb" class="item_wrapper_gradient">
				<a id="back_link" href="javascript:if (history.length>0) {history.go(-1);}"><div class="back_arrow left">
					<div class="arrow_icon"></div>
				</div></a>
				<div class="page_title left"><fmt:message bundle="${storeText}" key="PAYMENT_TITLE"/></div>
				<div class="clear_float"></div>
			</div>
			<!-- End Breadcrumb Bar -->

			<!-- Start Step Container -->
			<div id="step_container" class="item_wrapper" style="display:block">
				<div class="small_text left">
					<fmt:message bundle="${storeText}" key="CHECKOUT_STEP">
						<fmt:param value="4"/>
						<fmt:param value="${totalCheckoutSteps}"/>
					</fmt:message>
				</div>
				<div class="clear_float"></div>
			</div>
			<!--End Step Container -->

			<!-- Start Notification Container -->
			<c:if test="${!empty errorMessage}">
				<div id="notification_container" class="item_wrapper notification" style="display:block">
					<p class="error"><c:out value="${errorMessage}"/></p>
				</div>
			</c:if>
			<!--End Notification Container -->

			<div id="order_payment_method">
				<form name="PromotionCodeForm" method="post" action="RESTPromotionCodeApply" id="PromotionCodeForm" >
					<input type="hidden" name="authToken" value="${authToken}" />
					<div id="promotion_code_container" class="item_wrapper">
						<div id="promotion_codes">
							<wcf:url var="mOrderPaymentDetailsUpdate" value="m30OrderPaymentDetails">
								<wcf:param name="langId" value="${langId}" />
								<wcf:param name="storeId" value="${WCParam.storeId}" />
								<wcf:param name="catalogId" value="${WCParam.catalogId}" />
							</wcf:url>

							<p><fmt:message bundle="${storeText}" key="ENTER_PROMOTION"/></p>
							<div class="item_spacer_5px"></div>
							<div class="left input_align"><label for="promoCode"><fmt:message bundle="${storeText}" key="MOSC_PROMOTION_CODE"/>&nbsp;</label></div>
							<input type="text" name="promoCode" id="promoCode" size="8" class="inputfield input_width_promo left" onfocus='javascript:document.getElementById("shop_cart_update_button").setAttribute("class", "secondary_button button_full");'/>
							<div class="clear_float"></div>
							<div class="item_spacer_5px"></div>

							<input type="hidden" name="langId" value="${langId}" />
							<input type="hidden" name="storeId" value="${fn:escapeXml(WCParam.storeId)}" />
							<input type="hidden" name="catalogId" value="${fn:escapeXml(WCParam.catalogId)}" />

							<input type="hidden" name="orderId" value="${order.orderId}" />
							<input type="hidden" name="taskType" value="A" />
							<input type="hidden" name="URL" value="RESTOrderCalculate?calculationUsageId=-1&URL=${mOrderPaymentDetailsUpdate}" />
							<input type="hidden" name="errorViewName" value="m30OrderPaymentDetails" />
							<input type="hidden" name="addressId" value="${fn:escapeXml(WCParam.addressId)}" />

							<wcf:rest var="promoCodeListBean" url="store/{storeId}/cart/@self/assigned_promotion_code">
								<wcf:var name="storeId" value="${WCParam.storeId}" encode="true"/>
							</wcf:rest>


							<c:forEach var="promotionCode" items="${promoCodeListBean.promotionCode}" varStatus="status">
								<wcf:url var="RemovePromotionCode" value="RESTPromotionCodeRemove">
									<wcf:param name="authToken" value="${authToken}"/>
									<wcf:param name="orderId" value="${order.orderId}" />
									<wcf:param name="taskType" value="R" />
									<wcf:param name="URL" value="OrderCalculate?calculationUsageId=-1&URL=${mOrderPaymentDetailsUpdate}" />
									<wcf:param name="promoCode" value="${promotionCode.code}" />
									<wcf:param name="errorViewName" value="m30OrderPaymentDetails" />
									<wcf:param name="addressId" value="${WCParam.addressId}" />
								</wcf:url>
								<div class="multi_button_container">
									<a id="<c:out value='promo_code_${status.count}_remove'/>" href="${fn:escapeXml(RemovePromotionCode)}" title="<fmt:message bundle="${storeText}" key="WISHLIST_REMOVE"/>">
										<div class="secondary_button button_third_slim vertical_fix_slim"><fmt:message bundle="${storeText}" key="WISHLIST_REMOVE"/>&nbsp;<c:out value="${promotionCode.code}" /></div>
									</a>
									<div class="item_spacer_5px"></div>
								</div>
							</c:forEach>
							<div class="clear_float"></div>
						</div>
					</div>

					<c:set var="returnView" value="m30OrderPaymentDetails"/>
					<%@ include file="../../Snippets/Order/CouponWallet.jspf" %>

					<div id="shopping_cart_costs" class="item_wrapper">
						<%@ include file="../../Snippets/ReusableObjects/OrderItemOrderTotalDisplay.jspf"%>

						<div class="single_button_container">
							<a id="promo_code_submit" href="#" onclick="javascript:document.PromotionCodeForm.submit(); return false;"><div id='shop_cart_update_button' class="secondary_button button_full"><fmt:message bundle="${storeText}" key="UPDATE_ORDER_TOTAL"/></div></a>
						</div>
						<div class="clear_float"></div>
					</div>
				</form>

				<div id="payment_method_selection_div">
					<wcf:url var="orderSummary" value="m30OrderShippingBillingSummaryView">
						<wcf:param name="langId" value="${langId}" />
						<wcf:param name="storeId" value="${WCParam.storeId}" />
						<wcf:param name="catalogId" value="${WCParam.catalogId}" />
					</wcf:url>

					<c:set var="nextURL" value="${orderSummary}" />
					<c:set var="paymentFormAction" value="RESTOrderPIAdd"/>
					<wcf:url var="addNewPayment" value="${paymentFormAction}">
						<wcf:param name="URL" value="${orderSummary}" />
						<wcf:param name="authToken" value="${authToken}" />
					</wcf:url>

					<%-- Remove existing payment methods, since we will only support 1 payment method. --%>
					<c:if test="${!empty paymentInstruction.paymentInstruction}">
						<c:set var="paymentFormAction" value="RESTOrderPIDelete"/>
						<c:set var="removeExistingPI" value="true"/>
						<c:set var="nextURL" value="${addNewPayment}" />
					</c:if>
					
					<!-- BRAINTREE START -->
				<c:if test="${userType ne 'G'}"	>
					<div class="item_wrapper">
						<form id="saved_payment_method_selection" method="post">
							<div><label for="savedPayments"><fmt:message bundle="${storeText}" key="SAVED_PAYMENTS_MOBILE"/></label><br></div>
							<div class="dropdown_container">
								<select class="drop_down_savedPayments inputfield input_width_full"  name="savedCardsList" id="savedCardsList" onchange="JavaScript:BrainTreeMobilePayments.displaySelectedPayment('<c:out value='${getTokenResult.clientToken}'/>', '<c:out value='${creditCardDetailsListInfo}'/>');" >
									<option value="" selected="selected">Select Payment</option> 
										<c:forEach var="creditCardDetails" items="${creditCardDetailsListInfo}">
		               							<option value="${creditCardDetails.payTokenId}" >${creditCardDetails.cardType}: ${creditCardDetails.maskedCreditCardNumber}</option>
		           						</c:forEach>
								</select>
							</div>
						</form>
					</div>	
				</c:if>
					<!-- Saved Payments -->
					<div id="brainTree_SavedPayments" class="item_wrapper">
									<!-- <label for="savedPayments"><fmt:message bundle="${storeText}" key="SAVED_PAYMENTS_MOBILE"/></label><br>
										<select class="drop_down_savedPayments inputfield input_width_full"  name="savedCardsList" id="savedCardsList" onchange="JavaScript:BrainTreeMobilePayments.displaySelectedPayment('<c:out value='${getTokenResult.clientToken}'/>', '<c:out value='${creditCardDetailsListInfo}'/>');" >
											<option value="" selected="selected">Select Payment</option> 
											  <c:forEach var="creditCardDetails" items="${creditCardDetailsListInfo}">
		               								 <option value="${creditCardDetails.payTokenId}" >${creditCardDetails.cardType}: ${creditCardDetails.maskedCreditCardNumber}</option>
		           							 </c:forEach>
										</select> -->
	  									<div id ="showSavedCard" name="showSavedCard" style="display:none; margin-top: 10px;">	
					  				    	
					  				    	<div id="savedCreditCardInfo" style="display:none; margin-top: 10px;">
						  				    	<label for="card-number" style="font-weight:bold; "><fmt:message bundle="${storeText}" key="CARD_NUMBER"/></label><div id="maskedcardNumber"></div><br>
							  					<label for="expiration-date" style="margin-top:10px; font-weight:bold; "><fmt:message bundle="${storeText}" key="EXPIRATION_DATE"/></label><div id="expiryDate"></div><br>
							  					<div id="CVVhostedFieldsErrorMessage" style="display:none; color:red;  font-size: 15px;">
							  					</div>
							  					<label for="cvv" style="margin-top:10px; font-weight:bold; "><fmt:message bundle="${storeText}" key="CVV"/></label><div id="onlyCvv" style="height: 20px; width:50px;"></div>
							  					<br>
						  					</div>
						  					<div id="savedPaymentInfo" style="display:none; margin-top: 10px;">
						  						<label for="paymentAccount" style="font-weight:bold; "><fmt:message bundle="${storeText}" key="PAYPAL_EMAIL"/></label><div id="paymentAccountMail"></div><br>
						  					</div>
						  					
						  					<!-- <div id="deleteCard" ><input type="button" class="button_secondary tlignore" id="btnDelete" value="Delete Card" onclick="JavaScript:CheckoutPayments.deleteSelectedCardFromVault('dummy');"></div>-->
						  					<a role="button" class="button_secondary tlignore" style="width: 105px;" id="deleteCard" tabindex="0" href="JavaScript:CheckoutPayments.deleteSelectedCardFromVault(null);">
													<div class="left_border"></div>
													<div class="button_text"><fmt:message bundle="${storeText}" key="DELETE_PAYMENT"/></div>
													<div class="right_border"></div>
												</a>
										</div> 
						</div>
					<!-- BRAINTREE END -->
					
					<div class="item_wrapper">
						<form id="payment_method_selection" method="post">
							<c:catch var="error">
								<wcf:rest var="paymentPolicyListDataBean" url="store/{storeId}/cart/@self/payment_policy_list" scope="page">
									<wcf:var name="storeId" value="${WCParam.storeId}" encode="true"/>
								</wcf:rest>
							</c:catch>

							<!-- BRAINTREE START -->
							<!-- <div><label for="payment_method"><fmt:message bundle="${storeText}" key="PAYMENT_METHOD"/></label></div>
							<div class="dropdown_container">
								<select id="payment_method" name="payment_method" class="inputfield input_width_full" onchange="checkPaymentMethod(this);">
									<option disabled selected><fmt:message bundle="${storeText}" key="BILL_BILLING_SELECT_BILLING_METHOD"/></option>
									<c:if test="${!empty(pickUpAt)}">
										<%-- Enable Pay in store payment type --%>
										<c:forEach items="${paymentPolicyListDataBean.resultList[0].paymentPolicyInfoUsableWithoutTA}" var="paymentPolicyInfo" varStatus="status">
											<c:if test="${ !empty paymentPolicyInfo.attrPageName }" >
												<c:if test="${paymentPolicyInfo.policyName == 'PayInStore'}">
													<option value="${paymentPolicyInfo.policyName}"><fmt:message bundle="${storeText}" key="PAY_IN_STORE"/></option>
												</c:if>
											</c:if>
										</c:forEach>
									</c:if>
									
									

									<%-- Enable credit card payment types --%>
									<option value="credit_card"><fmt:message bundle="${storeText}" key="CREDIT_CARD"/></option>
								</select>
							</div>-->
							
							<div><label for="payment_method"><fmt:message bundle="${storeText}" key="PAYMENT_METHOD"/></label></div>
							<div class="dropdown_container">
								<select id="payment_method" name="payment_method" class="inputfield input_width_full" onchange="checkPaymentMethod(this);">
									<option disabled selected value="" ><fmt:message bundle="${storeText}" key="BILL_BILLING_SELECT_BILLING_METHOD"/></option>
											<%-- Enable Pay in store payment type --%>
											<c:forEach items="${paymentPolicyListDataBean.resultList[0].paymentPolicyInfoUsableWithoutTA}" var="paymentPolicyInfo" varStatus="status">
												<c:if test="${ !empty paymentPolicyInfo.attrPageName }" >
													<c:if test="${(paymentPolicyInfo.policyName == 'PayInStore' &&  !empty(pickUpAt)) || paymentPolicyInfo.policyName == 'ZVenmo' || paymentPolicyInfo.policyName == 'ZGooglePay' || paymentPolicyInfo.policyName == 'ZCreditCard' ||paymentPolicyInfo.policyName == 'ZPayPal' }">
														<option value="${paymentPolicyInfo.policyName}"
														<c:if test="${! empty WCParam.PayPalEmailId && paymentPolicyInfo.policyName == 'ZPayPal'}"  >
															selected="selected"
														</c:if>>${paymentPolicyInfo.shortDescription}</option>
													</c:if>
													<c:if test="${paymentPolicyInfo.policyName == 'ZApplePay' }" >
														<script>
															if (window.ApplePaySession) {
																var paymentMethodListToDisplay = document.getElementById("payment_method");
															    var option = document.createElement("option");
															    option.text ='${paymentPolicyInfo.shortDescription}';
															    option.value= '${paymentPolicyInfo.policyName}';
															    paymentMethodListToDisplay.add(option);
														    }
														   
														  
													    </script>	
													</c:if>
												</c:if>
											</c:forEach>
											
								</select>
							</div>
							
							<!-- BRAINTREE END -->
						</form>
					</div>

					<%-- Pay in store form.  Must seperate into different forms because empty credit card inputs will treated as errors --%>

					<form id="payment_method_form_payinstore" method="post" action="${paymentFormAction}">
						<fieldset>
							<wcf:url var="orderSummary" value="m30OrderShippingBillingSummaryView">
								<wcf:param name="langId" value="${langId}" />
								<wcf:param name="storeId" value="${WCParam.storeId}" />
								<wcf:param name="catalogId" value="${WCParam.catalogId}" />
							</wcf:url>

							<input type="hidden" name="langId" value="${langId}" />
							<input type="hidden" name="storeId" value="${fn:escapeXml(WCParam.storeId)}" />
							<input type="hidden" name="catalogId" value="${fn:escapeXml(WCParam.catalogId)}" />
							<c:if test="${removeExistingPI}"><input type="hidden" name="piId" value=""/></c:if>
							<input type="hidden" name="payMethodId" value="" id="payMethodId_payinstore" />
							<input type="hidden" name="URL" value="${nextURL}"/>
							<input type="hidden" name="piAmount" value="${order.grandTotal}"/>
							<input type="hidden" name="billing_address_id" value="${fn:escapeXml(WCParam.addressId)}"/>
							<input type="hidden" name="addressId" value="${fn:escapeXml(WCParam.addressId)}"/>
							<input type="hidden" name="errorViewName" value="m30OrderPaymentDetails"/>
							<input type="hidden" name="authToken" value="${authToken}"/>
							
							<!-- BRAINTREE START -->
							<input type="hidden" name="fromSavedPaymentFlag" id="fromSavedPaymentFlag_PayInStore" value="false" />
							<input type="hidden" name="save_card"  id="save_card_PayInStore" value="false" />
							<!-- BRAINTREE END -->
						</fieldset>
					</form>

					<!-- BRAINTREE START -->
					
					<form id="payment_method_form_BrainTree_NewPayments" method="post" action="${paymentFormAction}">	
						<fieldset></fieldset>
						
						
								<input type="hidden" name="pay_nonce" id="pay_nonce" value="${WCParam.pay_nonce}"/>
								<input type="hidden" name="pay_type" id="pay_type" value="${WCParam.pay_type}"/>
								<input type="hidden" name="fromSavedPaymentFlag" id="fromSavedPaymentFlag" value="false" />
								<input type="hidden" name="save_card"  id="save_card" value="false" />
								<input type="hidden" name="payMethodId" value="" id="payMethodId_BT" />
								<input type="hidden" name="PayPalEmailId" value="" id="PayPalEmailId" value="${WCParam.PayPalEmailId}"/>
								<input type="hidden" id="pay_token" name="pay_token" value="${WCParam.pay_token}"/>
								<input type="hidden" id="cvv_nonce" name="cvv_nonce" />
								<input type="hidden" id="3Dsecure_nonce" name="3Dsecure_nonce" />
								
								<input type="hidden" id="account" name="account"  />
								<input type="hidden" id="deviceSessionId" name="deviceSessionId" />
								<input type="hidden" id="fraudMerchantId" name="fraudMerchantId" />
								
								
								
								<input type="hidden" name="langId" value="${langId}" />
								<input type="hidden" name="storeId" value="${fn:escapeXml(WCParam.storeId)}" />
								<input type="hidden" name="catalogId" value="${fn:escapeXml(WCParam.catalogId)}" />
								<c:if test="${removeExistingPI}"><input type="hidden" name="piId" value=""/></c:if>
								<input type="hidden" name="URL" value="${nextURL}"/>
								<input type="hidden" name="piAmount" value="${order.grandTotal}"/>
								<input type="hidden" name="billing_address_id" value="${fn:escapeXml(WCParam.addressId)}"/>
								<input type="hidden" name="addressId" value="${fn:escapeXml(WCParam.addressId)}"/>
								<input type="hidden" name="errorViewName" value="m30OrderPaymentDetails"/>
								<input type="hidden" name="authToken" value="${authToken}"/>
								
								<!-- CreditCard -->
								<div id="payment_method_BrainTree_CreditCard" class="item_wrapper" style="display:none">
									<div id="hostedFieldsErrorMessage" style="display:none; color:red;  font-size: 15px;">
							  		</div>
									<div class="hostedFieldsWrapper" id="hostedFieldsWrapper">
										<label for="card-number"><fmt:message bundle="${storeText}" key="CARD_NUMBER"/></label><div id="card-number" style="height: 25px;"></div>
										<label for="cvv" style="margin-top:10px; word-wrap:normal;" ><fmt:message bundle="${storeText}" key="CVV"/></label><div id="cvv" style="height: 25px; width: 50px;"></div>
										<label for="expiration-date" style="margin-top:10px;"><fmt:message bundle="${storeText}" key="EXPIRATION_DATE"/></label><div id="expiration-date" style="height: 25px; width: 100px;"></div>
										
										<input type="hidden" id="account" name="account"  /><br>
										<c:if test="${showSavedPaymentsFlag eq 'true' && userType ne 'G'}">
											<input type="checkbox" id="saveCardCheckBox" name="saveCard" value="saveCard" /><fmt:message bundle="${storeText}" key="SAVE_CARD"/><br>
										</c:if>	
									</div>
								</div>
									
						
								<!-- Venmo -->
								<div id="payment_method_BrainTree_Venmo" class="item_wrapper" style="display:none">
								
									<button type="button" id="venmo-button" onclick="javascript: return false;" style=" display:none; width:180px; height:48px; border: none;
										background: none;"> 
										<svg width="180px" height="48px" viewBox="0 0 280 48" version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
										    <!-- Generator: Sketch 46.1 (44463) - http://www.bohemiancoding.com/sketch -->
										    <title>svg/blue_venmo_button_280x48</title>
										    <desc>Created with Sketch.</desc>
										    <defs></defs>
										    <g id="Page-1" stroke="none" stroke-width="1" fill="none" fill-rule="evenodd">
										        <g id="blue_venmo_button_280x48">
										            <rect id="Rectangle" fill="#3D95CE" x="0" y="0" width="280" height="48" rx="4"></rect>
										            <g id="Group" transform="translate(98.000000, 16.000000)" fill="#FFFFFF">
										                <path d="M14.1355722,0.0643062201 C14.6997229,0.996022242 14.9540614,1.95569119 14.9540614,3.16795034 C14.9540614,7.03443424 11.6533091,12.0572714 8.97435371,15.5842648 L2.85545503,15.5842648 L0.401435711,0.910859951 L5.75920168,0.402203543 L7.05667586,10.8432743 C8.26898429,8.86832019 9.76503373,5.76467606 9.76503373,3.64865382 C9.76503373,2.49041769 9.56660332,1.70150782 9.25650148,1.0519281 L14.1355722,0.0643062201 L14.1355722,0.0643062201 Z" id="Shape"></path>
										                <path d="M21.0794779,6.525633 C22.0654018,6.525633 24.5475201,6.07462046 24.5475201,4.66393896 C24.5475201,3.98655114 24.0685351,3.64865382 23.5040948,3.64865382 C22.5165776,3.64865382 21.2206966,4.83281521 21.0794779,6.525633 L21.0794779,6.525633 Z M20.9665029,9.31947756 C20.9665029,11.0419863 21.924328,11.7177809 23.1941378,11.7177809 C24.5769225,11.7177809 25.9009024,11.3798836 27.6217431,10.505377 L26.9735853,14.9065874 C25.7611321,15.4989577 23.8715531,15.8942092 22.0374478,15.8942092 C17.3850512,15.8942092 15.7199738,13.0728462 15.7199738,9.545708 C15.7199738,4.97417302 18.4284766,0.120067244 24.0124822,0.120067244 C27.08685,0.120067244 28.8059526,1.84243114 28.8059526,4.24073451 C28.8062423,8.10707358 23.8437439,9.29152463 20.9665029,9.31947756 L20.9665029,9.31947756 Z" id="Shape"></path>
										                <path d="M44.2677372,3.50758567 C44.2677372,4.07185827 44.1821369,4.89031424 44.0969712,5.42518557 L42.4892503,15.58412 L37.2722686,15.58412 L38.7387707,6.27159447 C38.7665799,6.01900427 38.8520354,5.51049269 38.8520354,5.22835639 C38.8520354,4.55096858 38.4288137,4.3819475 37.9199918,4.3819475 C37.2441697,4.3819475 36.5667543,4.69203673 36.1155786,4.918412 L34.4522393,15.5842648 L29.2058551,15.5842648 L31.6026627,0.374540282 L36.1433878,0.374540282 L36.2008892,1.58853744 C37.2721237,0.88319669 38.6827177,0.120356912 40.6841129,0.120356912 C43.3356936,0.120067244 44.2677372,1.47498771 44.2677372,3.50758567 L44.2677372,3.50758567 Z" id="Shape"></path>
										                <path d="M59.7554481,1.78507694 C61.2496147,0.713885943 62.6604983,0.120067244 64.6058406,0.120067244 C67.2846511,0.120067244 68.216405,1.47498771 68.216405,3.50758567 C68.216405,4.07185827 68.1310944,4.89031424 68.0459287,5.42518557 L66.4400908,15.58412 L61.2216606,15.58412 L62.7161168,6.07476529 C62.7436363,5.82058192 62.8014274,5.51049269 62.8014274,5.31380835 C62.8014274,4.55111341 62.3780609,4.3819475 61.8693838,4.3819475 C61.2213709,4.3819475 60.5736477,4.6640838 60.0927798,4.918412 L58.4297302,15.5842648 L53.2126036,15.5842648 L54.7070598,6.07491013 C54.7345794,5.82072676 54.7906323,5.51063753 54.7906323,5.31395319 C54.7906323,4.55125824 54.367121,4.38209233 53.860182,4.38209233 C53.1829115,4.38209233 52.5069445,4.69218156 52.0557688,4.91855683 L50.3911259,15.5844097 L45.1464798,15.5844097 L47.5429977,0.374685116 L52.0282492,0.374685116 L52.1691783,1.64444329 C53.2126036,0.883486357 54.6220389,0.12064658 56.511473,0.12064658 C58.1474376,0.120067244 59.2185273,0.825552826 59.7554481,1.78507694 L59.7554481,1.78507694 Z" id="Shape"></path>
										                <path d="M78.5990953,6.21583344 C78.5990953,4.97417302 78.288559,4.12761929 77.358688,4.12761929 C75.2997914,4.12761929 74.8770043,7.76743825 74.8770043,9.62942196 C74.8770043,11.0419863 75.2722719,11.9162033 76.2018532,11.9162033 C78.1479196,11.9162033 78.5990953,8.07767231 78.5990953,6.21583344 L78.5990953,6.21583344 Z M69.5751464,9.40463986 C69.5751464,4.60817794 72.1127383,0.120067244 77.9512273,0.120067244 C82.3505888,0.120067244 83.9587442,2.71679297 83.9587442,6.30099573 C83.9587442,11.0418415 81.4485271,15.9514186 75.4692539,15.9514186 C71.0415037,15.9514186 69.5751464,13.0446036 69.5751464,9.40463986 L69.5751464,9.40463986 Z" id="Shape"></path>
										            </g>
										        </g>
										    </g>
										</svg>
								</button> 
								</div>
								
								
								
								
								<!--PayPal  -->
								
								<div id="payment_method_BrainTree_PayPal" class="item_wrapper"  style="display:none;">
										<c:if test="${empty WCParam.paypalCredit || ! WCParam.paypalCredit}" >
												<img src="https://www.paypalobjects.com/webstatic/en_US/i/buttons/pp-acceptance-medium.png" alt="PayPal" style="display: inline-block;vertical-align: middle;">
												&nbsp;&nbsp;
												<c:if test="${empty WCParam.paypalCredit}" >
													<a href="https://www.paypal.com/en/webapps/mpp/paypal-popup" target="_blank" style="color: #589bc6;">What's PayPal?</a><br><br>
												</c:if>
											</c:if>
											<c:if test="${WCParam.paypalCredit}" >
												<img alt="" src="https://www.paypalobjects.com/webstatic/en_US/i/buttons/ppc-acceptance-medium.png" style="display: inline-block;vertical-align: middle;">
												&nbsp;&nbsp;
											</c:if>
											<c:if test="${! empty WCParam.PayPalEmailId}" >
										 		${WCParam.PayPalEmailId}
										 	</c:if>
											<div class="paypalCheckoutdiv" style="display:none;">
												<div id="paypal-button" style=" padding-left:25px;"></div>
												<c:if test="${isPayPalCreditEnable eq 'true'}">
													<div id="paypal-credit-button" style=" padding-left:25px;"></div>
												</c:if>
												<c:if test="${showSavedPaymentsFlag eq 'true' && userType ne 'G' && useVaultForAuth eq 'true' && paypalFlow eq 'vault' }">
														<input type="checkbox"  style="padding-left:25px;" id="savePaymentCheckBox" name="savePayment" value="savePayment" /><fmt:message bundle="${storeText}" key="SAVE_PAYMENT"/><br>
												</c:if>	
											</div>	
								
								</div>
								
								<!--Apple Pay-->
								<div  id="payment_method_BrainTree_ApplePay" class="item_wrapper"  style="display:none; margin-top:15px;">
									<div id="applePay"  style="display: none;" >
									 	<button type="button"  style="background-color:white; border:none; width:100; height:48;" id="apple-pay-button" onclick="JavaScript: BrainTreeMobilePayments.applePayOnClick('${totalAmount}')" >
											<svg xmlns="http://www.w3.org/2000/svg" width="120" height="48" viewBox="0 0 130.981 48.002"><path fill="#FFF" d="M68.267 1l.762.001c.209.001.418.004.628.009.381.01.829.031 1.26.109.399.072.737.183 1.064.349a3.485 3.485 0 0 1 1.533 1.534c.166.326.276.664.348 1.064.077.427.099.876.108 1.259.006.208.009.417.01.628.002.253.002.508.002.762v34.572c0 .254 0 .508-.002.765a25.97 25.97 0 0 1-.01.625c-.01.383-.031.832-.108 1.262A3.748 3.748 0 0 1 73.514 45a3.516 3.516 0 0 1-1.535 1.535 3.745 3.745 0 0 1-1.062.349 8.618 8.618 0 0 1-1.257.108c-.21.005-.42.008-.633.008-.253.002-.508.002-.761.002H6.706c-.251 0-.502 0-.756-.002-.21 0-.42-.003-.625-.008a8.728 8.728 0 0 1-1.26-.108A3.704 3.704 0 0 1 3 46.534a3.45 3.45 0 0 1-.888-.646A3.468 3.468 0 0 1 1.468 45a3.737 3.737 0 0 1-.349-1.064 8.372 8.372 0 0 1-.109-1.259 32.785 32.785 0 0 1-.009-.626L1 41.441V6.562l.001-.609c.001-.209.004-.418.009-.628.01-.381.031-.829.109-1.261a3.7 3.7 0 0 1 .349-1.063 3.494 3.494 0 0 1 1.533-1.533 3.72 3.72 0 0 1 1.063-.348 8.409 8.409 0 0 1 1.261-.109c.209-.005.418-.008.626-.009L6.715 1h61.552"/><path d="M68.267 1l.762.001c.209.001.418.004.628.009.381.01.829.031 1.26.109.399.072.737.183 1.064.349a3.485 3.485 0 0 1 1.533 1.534c.166.326.276.664.348 1.064.077.427.099.876.108 1.259.006.208.009.417.01.628.002.253.002.508.002.762v34.572c0 .254 0 .508-.002.765a25.97 25.97 0 0 1-.01.625c-.01.383-.031.832-.108 1.262A3.748 3.748 0 0 1 73.514 45a3.516 3.516 0 0 1-1.535 1.535 3.745 3.745 0 0 1-1.062.349 8.618 8.618 0 0 1-1.257.108c-.21.005-.42.008-.633.008-.253.002-.508.002-.761.002H6.706c-.251 0-.502 0-.756-.002-.21 0-.42-.003-.625-.008a8.728 8.728 0 0 1-1.26-.108A3.704 3.704 0 0 1 3 46.534a3.45 3.45 0 0 1-.888-.646A3.468 3.468 0 0 1 1.468 45a3.737 3.737 0 0 1-.349-1.064 8.372 8.372 0 0 1-.109-1.259 32.785 32.785 0 0 1-.009-.626L1 41.441V6.562l.001-.609c.001-.209.004-.418.009-.628.01-.381.031-.829.109-1.261a3.7 3.7 0 0 1 .349-1.063 3.494 3.494 0 0 1 1.533-1.533 3.72 3.72 0 0 1 1.063-.348 8.409 8.409 0 0 1 1.261-.109c.209-.005.418-.008.626-.009L6.715 1h61.552m0-1H6.715l-.769.001c-.216.001-.432.004-.648.01a9.519 9.519 0 0 0-1.41.124 4.78 4.78 0 0 0-1.341.442 4.526 4.526 0 0 0-1.97 1.971 4.738 4.738 0 0 0-.442 1.341 9.387 9.387 0 0 0-.125 1.41c-.005.215-.008.431-.009.647L0 6.715v34.572l.001.77c.001.216.004.432.01.647.013.47.041.944.125 1.409.084.473.223.912.441 1.341a4.489 4.489 0 0 0 1.971 1.971c.429.219.868.357 1.34.442.465.083.939.111 1.41.124.216.006.431.009.648.009.256.002.513.002.769.002h61.552c.256 0 .513 0 .769-.002.216-.001.432-.004.648-.009.47-.013.944-.041 1.41-.124a4.774 4.774 0 0 0 1.34-.442 4.482 4.482 0 0 0 1.971-1.971c.219-.429.357-.868.441-1.341.084-.465.111-.939.124-1.409.006-.216.009-.432.01-.647.002-.257.002-.513.002-.77V6.715c0-.257 0-.513-.002-.77a27.832 27.832 0 0 0-.01-.647 9.398 9.398 0 0 0-.124-1.41 4.736 4.736 0 0 0-.441-1.341A4.506 4.506 0 0 0 72.434.576a4.774 4.774 0 0 0-1.34-.442 9.542 9.542 0 0 0-1.41-.124c-.217-.006-.433-.008-.648-.01h-.769z"/><path d="M22.356 14.402c.692-.839 1.159-2.005 1.032-3.167-1 .041-2.209.668-2.921 1.504-.645.742-1.203 1.93-1.049 3.069 1.112.086 2.246-.567 2.938-1.406zm2.873 7.374c-.022-2.513 2.05-3.722 2.146-3.782-1.169-1.7-2.982-1.936-3.628-1.962-1.545-.153-3.018.91-3.799.91-.784 0-1.99-.886-3.274-.859-1.684.024-3.237.979-4.104 2.486-1.745 3.043-.443 7.537 1.261 9.998.834 1.205 1.826 2.559 3.133 2.51 1.258-.049 1.73-.814 3.25-.814 1.517-.002 1.946.812 3.271.789 1.352-.029 2.21-1.23 3.039-2.441.953-1.395 1.348-2.75 1.368-2.818-.027-.018-2.633-1.012-2.663-4.017zm16.096-7.375c-.504-.486-1.154-.864-1.932-1.124-.771-.257-1.697-.387-2.752-.387a18 18 0 0 0-2.023.105 29.84 29.84 0 0 0-1.674.235l-.163.028v17.667h1.613v-7.443c.543.093 1.165.142 1.851.142.913 0 1.768-.117 2.542-.346a5.681 5.681 0 0 0 2.038-1.063 5.142 5.142 0 0 0 1.361-1.769c.33-.7.498-1.523.498-2.449 0-.766-.121-1.455-.357-2.048a4.685 4.685 0 0 0-1.002-1.548zm-1.482 6.748c-.828.694-2 1.046-3.487 1.046-.409 0-.796-.018-1.151-.051a5.4 5.4 0 0 1-.81-.136v-7.513c.213-.039.477-.076.787-.109.393-.042.866-.063 1.408-.063a6.71 6.71 0 0 1 1.843.239 4.243 4.243 0 0 1 1.417.694c.387.3.691.69.902 1.16.213.476.32 1.044.32 1.687-.001 1.335-.415 2.36-1.229 3.046zm12.482 8.122c-.018-.5-.025-1.002-.025-1.502v-4.911c0-.582-.059-1.176-.174-1.766a4.481 4.481 0 0 0-.668-1.644c-.328-.492-.787-.898-1.361-1.208-.574-.309-1.32-.465-2.219-.465-.656 0-1.297.085-1.902.254a6.04 6.04 0 0 0-1.779.846l-.131.091.545 1.275.197-.133a5.272 5.272 0 0 1 1.396-.664 5.218 5.218 0 0 1 1.547-.238c.672 0 1.209.122 1.592.362.389.243.682.544.871.896.197.363.326.749.383 1.15.061.417.09.79.09 1.11v.142c-2.391-.011-4.258.387-5.498 1.186-1.301.838-1.961 2.031-1.961 3.545 0 .436.078.875.232 1.309.156.439.393.832.703 1.168.312.34.715.617 1.197.824.48.209 1.045.314 1.676.314a4.693 4.693 0 0 0 2.534-.693c.332-.205.627-.438.879-.689a4.99 4.99 0 0 0 .307-.338h.062l.148 1.434h1.555l-.043-.23a9.898 9.898 0 0 1-.153-1.425zm-1.638-2.516c0 .172-.041.408-.119.691a3.53 3.53 0 0 1-.434.863 3.314 3.314 0 0 1-1.689 1.275 3.946 3.946 0 0 1-1.293.197 2.56 2.56 0 0 1-.85-.145 2.051 2.051 0 0 1-.715-.428 2.13 2.13 0 0 1-.502-.727c-.127-.293-.191-.656-.191-1.078 0-.691.186-1.252.551-1.662a3.62 3.62 0 0 1 1.438-.975 7.377 7.377 0 0 1 1.943-.443 17.699 17.699 0 0 1 1.861-.081v2.513zm12.585-8.693l-3.01 8.183c-.188.494-.363.992-.523 1.477-.078.242-.152.471-.225.689h-.057a60.845 60.845 0 0 0-.23-.715c-.156-.48-.324-.951-.496-1.4l-3.219-8.234h-1.721L58.396 29.9c.121.285.139.416.139.469 0 .016-.006.113-.141.473a8.585 8.585 0 0 1-.977 1.816c-.369.502-.707.91-1.008 1.211-.35.35-.711.637-1.078.854-.375.221-.717.4-1.02.535l-.174.078.561 1.363.178-.066c.146-.055.42-.18.836-.383.42-.207.885-.535 1.381-.979a7.143 7.143 0 0 0 1.162-1.309c.34-.488.68-1.061 1.014-1.697.33-.635.66-1.357.982-2.148.322-.795.668-1.684 1.025-2.639l3.719-9.416h-1.723z"/></svg>
										</button>	
									</div>
								</div>
								
								<!--3Dsecure-->
								<div id="modal" class="hidden threeDsecureWindow">
								  <div class="bt-mask"></div>
								  <div class="bt-modal-frame">
									<div class="bt-modal-header">
									  <div class="header-text">Authentication</div>
									</div>
									<div class="bt-modal-body"></div>
									<div class="bt-modal-footer"><a id="text-close" href="#">Cancel</a></div>
								  </div>
								</div>
								
					</form>
					
					<!-- Google pay -->
								<div id="payment_method_BrainTree_GooglePay" class="item_wrapper" style="display:none">
								
									<button  id="google-pay-button" onclick=" submitPaymentInfo();"  style="width: 90px;
													border-radius: 8px;
													height: 45px;  background-color: white;">
													<svg xmlns="http://www.w3.org/2000/svg" 
													width="45" height="45"
													viewBox="0 -60 435.97 380.13">
													<path d="M206.2 84.58v50.75h-16.1V10h42.7a38.61 38.61 0 0 1 27.65 10.85A34.88 34.88 0 0 1 272 47.3a34.72 34.72 0 0 1-11.55 26.6q-11.2 10.68-27.65 10.67h-26.6zm0-59.15v43.75h27a21.28 21.28 0 0 0 15.93-6.48 21.36 21.36 0 0 0 0-30.63 21 21 0 0 0-15.93-6.65h-27zm102.9 21.35q17.85 0 28.18 9.54t10.32 26.16v52.85h-15.4v-11.9h-.7q-10 14.7-26.6 14.7-14.17 0-23.71-8.4a26.82 26.82 0 0 1-9.54-21q0-13.31 10.06-21.17t26.86-7.88q14.34 0 23.62 5.25v-3.68A18.33 18.33 0 0 0 325.54 67 22.8 22.8 0 0 0 310 61.13q-13.49 0-21.35 11.38l-14.18-8.93q11.7-16.8 34.63-16.8zm-20.83 62.3a12.86 12.86 0 0 0 5.34 10.5 19.64 19.64 0 0 0 12.51 4.2 25.67 25.67 0 0 0 18.11-7.52q8-7.53 8-17.67-7.53-6-21-6-9.81 0-16.36 4.73c-4.41 3.2-6.6 7.09-6.6 11.76zM436 49.58l-53.76 123.55h-16.62l19.95-43.23-35.35-80.32h17.5l25.55 61.6h.35l24.85-61.6z" fill="#5f6368"/><path d="M141.14 73.64A85.79 85.79 0 0 0 139.9 59H72v27.73h38.89a33.33 33.33 0 0 1-14.38 21.88v18h23.21c13.59-12.53 21.42-31.06 21.42-52.97z" fill="#4285f4"/><path d="M72 144c19.43 0 35.79-6.38 47.72-17.38l-23.21-18C90.05 113 81.73 115.5 72 115.5c-18.78 0-34.72-12.66-40.42-29.72H7.67v18.55A72 72 0 0 0 72 144z" fill="#34a853"/><path d="M31.58 85.78a43.14 43.14 0 0 1 0-27.56V39.67H7.67a72 72 0 0 0 0 64.66z" fill="#fbbc04"/><path d="M72 28.5a39.09 39.09 0 0 1 27.62 10.8l20.55-20.55A69.18 69.18 0 0 0 72 0 72 72 0 0 0 7.67 39.67l23.91 18.55C37.28 41.16 53.22 28.5 72 28.5z" fill="#ea4335"/>
													</svg>
									</button>
								</div>
					
					
					<%-- Credit card form.  Must seperate into multiple forms because empty credit card inputs will be treated as errors --%>
					 
				<!-- 	<c:choose>
						<c:when test="${!empty(pickUpAt)}">
							<div id="payment_method_creditcard" class="item_wrapper" style="display:none">
						</c:when>
						<c:otherwise>
							<div id="payment_method_creditcard" class="item_wrapper" style="display:block">
						</c:otherwise>
					</c:choose>
						<form id="payment_method_form_creditcard" method="post" action="${paymentFormAction}">
							<fieldset>
								<div><label for="card_type"><fmt:message bundle="${storeText}" key="CARD_TYPE"/></label></div>
								
								<div class="dropdown_container">
									<select id="card_type" class="inputfield input_width_full" name="cc_brand">
										<c:forEach items="${paymentPolicyListDataBean.resultList[0].paymentPolicyInfoUsableWithoutTA}" var="paymentPolicyInfo" varStatus="status">
											<c:if test="${ !empty paymentPolicyInfo.attrPageName }" >
												<c:if test="${paymentPolicyInfo.attrPageName == 'StandardVisa' || paymentPolicyInfo.attrPageName == 'StandardMasterCard' || paymentPolicyInfo.attrPageName == 'StandardAmex'}">
													<option value="${paymentPolicyInfo.policyName}"><c:out value="${paymentPolicyInfo.shortDescription}" /></option>
												</c:if>
											</c:if>
										</c:forEach>
									</select>
								</div>
								<div class="item_spacer_10px"></div>

								<div class="input_container">
									<div><label for="card_number"><fmt:message bundle="${storeText}" key="MOPD_CARD_NUMBER"/></label></div>
									<input type="text" pattern="[0-9]*" id="card_number" name="account" class="inputfield input_width_standard" />
								</div>
								<div class="item_spacer_5px"></div>

								<jsp:useBean id="now1" class="java.util.Date"/>
								<c:set var="expire_month" value="${now1.month + 1}"/>
								<div>
									<div class="credit_card_date">
										<div><label for="card_month"><fmt:message bundle="${storeText}" key="MONTH"/></label></div>
										<select id="card_month" class="inputfield input_width_90" name="expire_month">
											<option <c:if test="${expire_month == 1 || expire_month == '01'}" > selected="selected" </c:if> value="01">01</option>
											<option <c:if test="${expire_month == 2 || expire_month == '02'}" > selected="selected" </c:if> value="02">02</option>
											<option <c:if test="${expire_month == 3 || expire_month == '03'}" > selected="selected" </c:if> value="03">03</option>
											<option <c:if test="${expire_month == 4 || expire_month == '04'}" > selected="selected" </c:if> value="04">04</option>
											<option <c:if test="${expire_month == 5 || expire_month == '05'}" > selected="selected" </c:if> value="05">05</option>
											<option <c:if test="${expire_month == 6 || expire_month == '06'}" > selected="selected" </c:if> value="06">06</option>
											<option <c:if test="${expire_month == 7 || expire_month == '07'}" > selected="selected" </c:if> value="07">07</option>
											<option <c:if test="${expire_month == 8 || expire_month == '08'}" > selected="selected" </c:if> value="08">08</option>
											<option <c:if test="${expire_month == 9 || expire_month == '09'}" > selected="selected" </c:if> value="09">09</option>
											<option <c:if test="${expire_month == 10 }" > selected="selected" </c:if> value="10">10</option>
											<option <c:if test="${expire_month == 11 }" > selected="selected" </c:if> value="11">11</option>
											<option <c:if test="${expire_month == 12 }" > selected="selected" </c:if> value="12">12</option>
										</select>
									</div>

									<div class="credit_card_date">
										<div><label for="card_year"><fmt:message bundle="${storeText}" key="YEAR"/></label></div>
										<select id="card_year" class="inputfield input_width_90" name="expire_year">
											<c:forEach begin="0" end="10" varStatus="counter">
												<option value="${now1.year + 1900 + counter.index}">${now1.year + 1900 + counter.index}</option>
											</c:forEach>
										</select>
									</div>
									<div class="clear_float"></div>
								</div>
								<div class="item_spacer_5px"></div>

								<div class="input_container">
									<div><label for="cvc_number"><fmt:message bundle="${storeText}" key="CCV2_NUMBER"/></label></div>
									<input type="text" pattern="[0-9]*" id="cvc_number" name="cc_cvc" class="inputfield input_width_standard" />
								</div>

								<input type="hidden" name="langId" value="${langId}" />
								<input type="hidden" name="storeId" value="${fn:escapeXml(WCParam.storeId)}" />
								<input type="hidden" name="catalogId" value="${fn:escapeXml(WCParam.catalogId)}" />
								<c:if test="${removeExistingPI}"><input type="hidden" name="piId" value=""/></c:if>
								<input type="hidden" name="payMethodId" value="" id="payMethodId_creditcard" /> 
								<input type="hidden" name="URL" value="${nextURL}"/>
								<input type="hidden" name="piAmount" value="${order.grandTotal}"/>
								<input type="hidden" name="billing_address_id" value="${fn:escapeXml(WCParam.addressId)}"/>
								<input type="hidden" name="addressId" value="${fn:escapeXml(WCParam.addressId)}"/>
								<input type="hidden" name="errorViewName" value="m30OrderPaymentDetails"/>
								<input type="hidden" name="authToken" value="${authToken}"/>
							</fieldset>
							<div class="item_spacer"></div>
							
							
							
							
						</form>
					</div> -->
				

					<div id = "continueCheckoutBtn" class="single_button_container item_wrapper">
						<a id="continue_shopping_link" onclick="submitPaymentInfo();" title="<fmt:message bundle="${storeText}" key="CONTINUE_CHECKOUT"/>" href="#">
							<div class="primary_button button_full"><fmt:message bundle="${storeText}" key="CONTINUE_CHECKOUT"/></div>
						</a>
						<div class="clear_float"></div>
					</div>
					<!-- BRAINTREE END -->
				</div>

			</div>

			<%@ include file="../../include/FooterDisplay.jspf" %>
		</div>

	<script type="text/javascript">
	//<![CDATA[
	<!-- BRAINTREE START--> <!--override the below OOTB code with the below code for both checkPaymentMethod() & submitpaymentInfo() functions -->
		var instances_BT=[];
		var gPayPaymentsClient_BT=[];
		var isMultipleShipping = false;
		var shippingAddressSelected=${shippingInfo.orderItem};
		var userType='${userType}';
		var threeDSecureEnable='${threeDSecureEnable}';
		var advancedFraudTools='${advancedFraudTools}';
		var btClientToken = '${getTokenResult.clientToken}';
		var grandTotalAmount = '${totalAmount}'; 
		var googlePayPaymentMerchantId = '${googlePayPaymentMerchantId}';
		function checkPaymentMethod(methodSelect) {
			var selectedMethod = methodSelect.options[methodSelect.selectedIndex].value;
			var continueCheckoutBtnId = document.getElementById("continueCheckoutBtn");
			 if(selectedMethod == "ZCreditCard") {
				
					  $("#payment_method_BrainTree_Venmo").css("display", "none");
					  $("#payment_method_BrainTree_GooglePay").css("display", "none");
					  $("#payment_method_BrainTree_PayPal").css("display", "none");
					  $("#payment_method_BrainTree_ApplePay").css("display", "none");
					  
				BrainTreeMobilePayments.creditCardPayment('<c:out value='${getTokenResult.clientToken}'/>');
				
				continueCheckoutBtnId.classList.remove("btn-disabled-BT");
			}
			else if (selectedMethod == "ZVenmo") {
					
					 
					  $("#payment_method_BrainTree_CreditCard").css("display", "none");
					  $("#payment_method_BrainTree_GooglePay").css("display", "none");
					  $("#payment_method_BrainTree_PayPal").css("display", "none");
					  $("#payment_method_BrainTree_ApplePay").css("display", "none"); 
					
					var venmoButton = document.getElementById('venmo-button');
					BrainTreeMobilePayments.venmoPayment('<c:out value='${getTokenResult.clientToken}'/>',venmoButton);	
					
					//continue checkout button accessible for this payment
					continueCheckoutBtnId.classList.remove("btn-disabled-BT");

					//removing error mesaage if any have occured when credit card selected.
					// So that after selecting this payment, again if user selects creditcard previously occured error message is cleared for this instance 
					document.getElementById("hostedFieldsErrorMessage").innerHTML="";
									
			}
			else if(selectedMethod=="ZGooglePay"){
					
					  $("#payment_method_BrainTree_Venmo").css("display", "none");
					  $("#payment_method_BrainTree_CreditCard").css("display", "none");
					  $("#payment_method_BrainTree_PayPal").css("display", "none");
					  $("#payment_method_BrainTree_ApplePay").css("display", "none"); 
					BrainTreeMobilePayments.googlePayPayment('<c:out value='${getTokenResult.clientToken}'/>' , '<c:out value='${googlepayPaymentEnvironment}'/>');
					
					//continue checkout button accessible for this payment
					continueCheckoutBtnId.classList.remove("btn-disabled-BT");

					//removing error mesaage if any have occured when credit card selected.
					// So that after selecting this payment, again if user selects creditcard previously occured error message is cleared for this instance 
					document.getElementById("hostedFieldsErrorMessage").innerHTML="";
					
			}
			else if (selectedMethod=="ZPayPal"){
					
					$("#payment_method_BrainTree_Venmo").css("display", "none");
					  $("#payment_method_BrainTree_CreditCard").css("display", "none");
					  $("#payment_method_BrainTree_GooglePay").css("display", "none");
					  $("#payment_method_BrainTree_ApplePay").css("display", "none"); 
					  
					if('${WCParam.PayPalEmailId}' == ''){
						BrainTreeMobilePayments.payPalPayment('paypal-button','paypal-credit-button','<c:out value='${getTokenResult.clientToken}'/>', '<c:out value='${pickUpAt}'/>' ,'<c:out value='${totalAmount}'/>', '<c:out value='${userType}'/>','<c:out value='${isPayPalCreditEnable}'/>','<c:out value='${useVaultForAuth}'/>' ,shippingAddressSelected,'<c:out value='${paypalFlow}'/>','<c:out value='${paypalIntent}'/>', '<c:out value='${paymentEnvironment}'/>');
															
					}
					
					//if selected method is PayPal ,disable the Continue checkout button
				continueCheckoutBtnId.classList.add("btn-disabled-BT");
						
					//removing error mesaage if any have occured when credit card selected.
					// So that after selecting this payment, again if user selects creditcard previously occured error message is cleared for this instance 
					document.getElementById("hostedFieldsErrorMessage").innerHTML="";
					
			}
			else if (selectedMethod=="ZApplePay"){
					  
					  $("#payment_method_BrainTree_Venmo").css("display", "none");
					  $("#payment_method_BrainTree_CreditCard").css("display", "none");
					  $("#payment_method_BrainTree_GooglePay").css("display", "none");
					  $("#payment_method_BrainTree_PayPal").css("display", "none");
					  $("#payment_method_BrainTree_ApplePay").css("display", "block");
						BrainTreeMobilePayments.applePayPayment('apple-pay-button','<c:out value='${getTokenResult.clientToken}'/>');
						
						//continue checkout button accessible for this payment
						continueCheckoutBtnId.classList.remove("btn-disabled-BT");

						//removing error mesaage if any have occured when credit card selected.
						// So that after selecting this payment, again if user selects creditcard previously occured error message is cleared for this instance 
					document.getElementById("hostedFieldsErrorMessage").innerHTML="";
			}
			else if(selectedMethod=="PayInStore"){ 
				      
				      $("#payment_method_BrainTree_Venmo").css("display", "none");
					  $("#payment_method_BrainTree_CreditCard").css("display", "none");
					  $("#payment_method_BrainTree_GooglePay").css("display", "none");
					  $("#payment_method_BrainTree_PayPal").css("display", "none");
					  $("#payment_method_BrainTree_ApplePay").css("display", "none");
					  
					  //continue checkout button accessible for this payment
						continueCheckoutBtnId.classList.remove("btn-disabled-BT");

						//removing error mesaage if any have occured when credit card selected.
						// So that after selecting this payment, again if user selects creditcard previously occured error message is cleared for this instance 
					document.getElementById("hostedFieldsErrorMessage").innerHTML="";
			}
			
			
			
			if(userType!="G"){
				//close saved payments when new payments are opened and set the dropdown to default option
					document.getElementById("savedCardsList").value= "";
					$("#showSavedCard").css("display", "none");
			}
		}

		function submitPaymentInfo() {
			var paymentMethod = document.getElementById("payment_method");
			var selectedMethod = paymentMethod.options[paymentMethod.selectedIndex].value;
			//for saved payments
			var savedpaymentMethod = document.getElementById("savedCardsList");
			var selectedsavedpaymentMethod = "";
			if(savedpaymentMethod!=null )
			{
				selectedsavedpaymentMethod=savedpaymentMethod.options[savedpaymentMethod.selectedIndex].value;
			}
			
			if(selectedMethod=="ZCreditCard"){
				var key="inst_creditCard";
				var inst = instances_BT[key];
				BrainTreeMobilePayments.creditCardOnSubmit(inst);
				document.getElementById("fromSavedPaymentFlag").value ="false";
			}
			else if(selectedMethod=="ZGooglePay")
			{
				 BrainTreeMobilePayments.googlePayOnClick('${totalAmount}');
				
			}
			else if(selectedMethod=="ZVenmo")
			{
				
				document.getElementById("venmo-button").click();
			}
			else if(selectedMethod=="ZApplePay")
			{
			BrainTreeMobilePayments.applePayOnClick('${totalAmount}');
			}
			else if(selectedsavedpaymentMethod!=""){
				
				document.getElementById("fromSavedPaymentFlag").value ="true";
				if( document.getElementById("pay_type").value=="PayPalAccount" ||  document.getElementById("pay_type").value=="PayPalCredit" ){
					document.getElementById("payment_method_form_BrainTree_NewPayments").submit();
				}
				else
				{
					var keyforInst="cvvInst";
					var inst = instances_BT[keyforInst];
					BrainTreeMobilePayments.creditCardOnSubmit(inst);
				}
				
				
			}
			else if(selectedMethod=="PayInStore"){
			    document.getElementById("payMethodId_payinstore").value = selectedMethod;
				document.getElementById("payment_method_form_payinstore").submit();
			}
			else
			{
				MessageHelper.displayErrorMessage(BrainTreeMobilePayments.errorMessages["BT_EMPTY_PAYMENT_ERROR"]);
			}

		  <!--BRAINTREE END -->
		}

	//]]>
	</script>


	<%@ include file="../../../Common/JSPFExtToInclude.jspf"%> </body>
</html>

<!-- END OrderPaymentDetails.jsp -->
