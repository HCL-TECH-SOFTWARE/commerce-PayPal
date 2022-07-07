<%--
 =================================================================
  Licensed Materials - Property of HCL Technologies

  HCL Commerce

  (C) Copyright HCL Technologies Limited 1996, 2020

 =================================================================
--%>
<!-- BEGIN CheckoutLogon.jsp -->
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://commerce.ibm.com/base" prefix="wcbase" %>
<%@ taglib uri="http://commerce.ibm.com/foundation" prefix="wcf" %>
<%@ taglib uri="flow.tld" prefix="flow" %>
<%@ include file="../../../Common/EnvironmentSetup.jspf"%>
 
<!-- Start - JSP File Name:  CheckoutLogon.jsp -->
<wcf:url var="OrderCalculateURL" value="OrderShippingBillingView" type="Ajax">
	<wcf:param name="langId" value="${langId}" />						
	<wcf:param name="storeId" value="${WCParam.storeId}" />
	<wcf:param name="catalogId" value="${WCParam.catalogId}" />
	<wcf:param name="shipmentType" value="single" />
</wcf:url>
<!-- BRAINTREE START -->
<wcf:rest var="getToken" url="braintree/{storeId}/clienttoken" scope="request">
	<wcf:var name="storeId" value="${WCParam.storeId}" encode="true"/>
</wcf:rest>
<c:set var="getTokenResult" value="${getToken.result}"/>
<wcf:rest var="getPaymentOptions" url="braintree/{storeId}/paymentOptions" scope="request">
	<wcf:var name="storeId" value="${WCParam.storeId}" encode="true"/>
</wcf:rest>
<c:set var="getPaymentOptionsResult" value="${getPaymentOptions.result}"/>
<c:set var="isPayPalCreditEnable" value="${getPaymentOptionsResult.isPaypalCreditEnable}"/>
<c:set var="useVaultForAuth" value="${getPaymentOptionsResult.useVaultForAuth}"/>
<c:set var="advancedFraudTools" value="${getPaymentOptionsResult.advancedFraudTools}"/>
<c:set var="paypalEnableInCart" value="${getPaymentOptionsResult.paypalEnableInCart}"/>

<c:set var="paypalMerchantName" value="${getPaymentOptionsResult.paypalMerchantName}"/>
<c:set var="paypalFlow" value="${getPaymentOptionsResult.paypalFlow}"/>
<c:set var="paypalIntent" value="${getPaymentOptionsResult.paypalIntent}"/>
<c:set var="locale" value="${getPaymentOptionsResult.locale}"/>
<c:set var="billingAgreementDescription" value="${getPaymentOptionsResult.billingAgreementDescription}"/>
<c:set var="paypalBillingAddressEnable" value="${getPaymentOptionsResult.paypalBillingAddressEnable}"/>
<c:set var="paymentEnvironment" value="${getPaymentOptionsResult.paymentEnvironment}"/>
<fmt:formatNumber var="orderTotalAmount" value="${order.grandTotal}" type="number" maxFractionDigits="2" />							 
<!-- BRAINTREE END -->
<c:set var="guestUserURL" value="${OrderCalculateURL}"/>
<c:if test="${userType eq 'G'}">
	<c:set var="validAddressId" value=""/>
	<%-- The below getdata statment for UsableShippingInfo can be removed if the order services can return order details and shipping details in same service call --%>
	<wcf:rest var="orderUsableShipping" url="store/{storeId}/cart/@self/usable_shipping_info" scope="request">
		<wcf:var name="storeId" value="${WCParam.storeId}" encode="true"/>
		<wcf:param name="pageSize" value="1"/>
		<wcf:param name="pageNumber" value="1"/>
	</wcf:rest>
	<c:forEach var="usableAddress" items="${orderUsableShipping.usableShippingAddress}">
		<c:if test="${!empty usableAddress.nickName && usableAddress.nickName != profileBillingNickname}" >
			<c:set var="validAddressId" value="true"/>
		</c:if>
	</c:forEach>
	<c:if test="${empty validAddressId && order.x_isPersonalAddressesAllowedForShipping && (!env_contractSelection || (env_contractSelection && WCParam.guestChkout == '1'))}" >
		<wcf:url var="guestUserURL" value="UnregisteredCheckoutView" type="Ajax">
			<wcf:param name="langId" value="${langId}" />						
			<wcf:param name="storeId" value="${WCParam.storeId}" />
			<wcf:param name="catalogId" value="${WCParam.catalogId}" />
		</wcf:url>
	</c:if>
</c:if>

<wcf:url var="PhysicalStoreSelectionURL" value="CheckoutStoreSelectionView">
	<wcf:param name="langId" value="${langId}" />
	<wcf:param name="storeId" value="${WCParam.storeId}" />
	<wcf:param name="catalogId" value="${WCParam.catalogId}" />
	<wcf:param name="fromPage" value="ShoppingCart" />
</wcf:url>

<c:if test="${userType != 'G'}">
	<%-- See if this user has quick checkout profile created or not, if quick checkout enabled --%>
	<flow:ifEnabled feature="quickCheckout">
		<wcf:rest var="quickOrder" url="store/{storeId}/order/byStatus/{status}">
			<wcf:var name="storeId" value="${WCParam.storeId}" encode="true"/>
			<wcf:var name="status" value="Q"/>
		</wcf:rest>
		<c:if test="${!empty quickOrder.Order}">
			<c:set var="quickCheckoutProfile" value="true"/>
		</c:if>
	</flow:ifEnabled>
</c:if>

<c:if test="${userType == 'G'}">	
	<wcf:url var="ForgetPasswordURL" value="ResetPasswordGuestErrorView">
		<wcf:param name="langId" value="${langId}" />
		<wcf:param name="storeId" value="${WCParam.storeId}" />
		<wcf:param name="catalogId" value="${WCParam.catalogId}" />
		<wcf:param name="state" value="forgetpassword" />
	</wcf:url>	

	<form method="post" name="AjaxLogon" id="AjaxLogon" action="Logon">

		<%-- Start setting parameters required for merging the cart and doing orderCalculate immediately after Logon --%>
		<input type="hidden" name="mergeCart" value="true" id="WC_RememberMeLogonForm_FormInput_mergeCart_In_AjaxLogon_1"/>
		<input type="hidden" name="toOrderId" value="." id="WC_RememberMeLogonForm_FormInput_toOrderId_In_AjaxLogon_1"/>
		<flow:ifEnabled feature="MultipleActiveOrders">
			<input type="hidden" name="deleteIfEmpty" value="." id="WC_RememberMeLogonForm_FormInput_deleteIfEmpty_In_AjaxLogon_1"/>
			<input type="hidden" name="fromOrderId" value="." id="WC_RememberMeLogonForm_FormInput_fromOrderId_AjaxLogon_1"/>
		</flow:ifEnabled>
		<flow:ifDisabled feature="MultipleActiveOrders">
			<input type="hidden" name="deleteIfEmpty" value="*" id="WC_RememberMeLogonForm_FormInput_deleteIfEmpty_AjaxLogon_1_1"/>
			<%-- MultipleActiveOrders is disabled. Order merging behavior should be the same as B2C --%>
			<input type="hidden" name="fromOrderId" value="*" id="WC_RememberMeLogonForm_FormInput_fromOrderId_In_AjaxLogon_1_1"/>
		</flow:ifDisabled>	
		<input type="hidden" name="continue" value="1" id="WC_RememberMeLogonForm_FormInput_continue_In_AjaxLogon_1"/>
		<input type="hidden" name="createIfEmpty" value="1" id="WC_RememberMeLogonForm_FormInput_createIfEmpty_In_AjaxLogon_1"/>
		<input type="hidden" name="calculationUsageId" value="-1" id="WC_RememberMeLogonForm_FormInput_calculationUsageId_-1_In_AjaxLogon_1"/>
		<input type="hidden" name="calculationUsageId" value="-2" id="WC_RememberMeLogonForm_FormInput_calculationUsageId_-2_In_AjaxLogon_1"/>
		<input type="hidden" name="calculationUsageId" value="-7" id="WC_RememberMeLogonForm_FormInput_calculationUsageId_-7_In_AjaxLogon_1"/>
		<input type="hidden" name="updatePrices" value="0" id="WC_RememberMeLogonForm_FormInput_updatePrices_In_AjaxLogon_1"/>
		<%-- 
			When mergeCart is set to true, Logon command will use MigrateUserEntriesCmdImpl to merge guest user cart with logged on user cart.
			If following request parameters are missing, then orderItemMove and OrderCalculate commands will use below values by default:
			fromOrderId = *, toOrderId = ., createIfEmpty = 1, deleteIfEmpty = *, updatePrices = 0, calculationUsageId = -1,-2,-7, continue = 1
		--%>
		<%-- End setting parameters required for merging the cart and doing orderCalculate --%>


		<input type="hidden" name="storeId" value="<c:out value="${WCParam.storeId}"/>" id="WC_RememberMeLogonForm_FormInput_storeId_In_AjaxLogon_1"/>
		<input type="hidden" name="catalogId" value="<c:out value="${WCParam.catalogId}"/>" id="WC_RememberMeLogonForm_FormInput_catalogId_In_AjaxLogon_1"/>
		<input type="hidden" name="URL" value="" id="WC_AccountDisplay_FormInput_URL_In_Logon_1" />
		<c:choose>
			<c:when test="${!empty WCParam.ErrorCode && WCParam.ErrorCode == '2430'}">						
				<script type="text/javascript">
				document.location.href = "ResetPasswordForm?storeId="
						+ <c:out value="${WCParam.storeId}"/> + "&catalogId=" + <c:out value="${WCParam.catalogId}"/>
						+ "&langId=" + <c:out value="${langId}"/> + "&errorCode=" + <c:out value="${WCParam.ErrorCode}"/>;
				</script>
			</c:when>
			<c:otherwise>
				<input type="hidden" name="reLogonURL" value="AjaxOrderItemDisplayView" id="WC_RememberMeLogonForm_FormInput_reLogonURL_In_AjaxLogon_1"/>
			</c:otherwise>
		</c:choose>
		<input type="hidden" name="errorViewName" value="AjaxOrderItemDisplayView" id="WC_RememberMeLogonForm_FormInput_errorViewName_In_AjaxLogon_1"/>	

		<div class="top_border" id="WC_CheckoutLogonf_div_0">
			<div id="customers_new_or_returning">
				<div class="new" id="WC_CheckoutLogonf_div_1">
					<h2><fmt:message bundle="${storeText}" key="SHOPCART_NEW_CUSTOMER"/></h2>
					<p><fmt:message bundle="${storeText}" key="SHOPCART_CHECKOUT_WITHOUT_SIGNING"/></p>
					<br />
					<p><fmt:message bundle="${storeText}" key="SHOPCART_TEXT1"/></p>
					<br />
					<p><fmt:message bundle="${storeText}" key="SHOPCART_TEXT2"/></p>
					<div class="new_returning_button" id="WC_CheckoutLogonf_div_2">
						<div class="button_align" id="WC_CheckoutLogonf_div_3">
							<a href="#" role="button" class="button_primary" id="guestShopperContinue" onclick="javascript:if(CheckoutHelperJS.canCheckoutContinue('<c:out value="${userType}"/>') && CheckoutHelperJS.updateShoppingCart(document.ShopCartForm)){TealeafWCJS.processDOMEvent(event);ShipmodeSelectionExtJS.guestShopperContinue('<c:out value='${guestUserURL}'/>', '<c:out value='${PhysicalStoreSelectionURL}'/>');}return false;">
								<div class="left_border"></div>
								<div class="button_text"><fmt:message bundle="${storeText}" key="SHOPCART_CONTINUE" /></div>
								<div class="right_border"></div>
							</a>
						</div>
					</div>
				</div>
				
				<c:if test="${env_shopOnBehalfSessionEstablished eq 'false'}">
					<%-- If onBehalf session is established, then it is CSR shopping as guest. So cannot log-in as user. --%>
					<div class="returning" id="WC_CheckoutLogonf_div_4">
						<h2><fmt:message bundle="${storeText}" key="SHOPCART_TEXT3"/></h2>
						<p><fmt:message bundle="${storeText}" key="SHOPCART_TEXT4"/></p>
						<br />
						<p><label for="WC_CheckoutLogon_FormInput_logonId"><fmt:message bundle="${storeText}" key="SHOPCART_USERNAME"/></label></p>
						<p>
							<input id="WC_CheckoutLogon_FormInput_logonId" name="logonId" type="text" size="25" onchange="javaScript:TealeafWCJS.processDOMEvent(event);" onkeypress="if(event.keyCode==13){javascript:if(CheckoutHelperJS.canCheckoutContinue() && CheckoutHelperJS.updateShoppingCart(document.ShopCartForm)){ShipmodeSelectionExtJS.guestShopperLogon('javascript:LogonForm.SubmitAjaxLogin(document.AjaxLogon)', '<c:out value='${OrderCalculateURL}'/>', '<c:out value='${PhysicalStoreSelectionURL}'/>');}}" />
						</p>
						<br />
						<p><label for="WC_CheckoutLogon_FormInput_logonPassword"><fmt:message bundle="${storeText}" key="SHOPCART_PASSWORD"/></label></p>
						<p>
							<input id="WC_CheckoutLogon_FormInput_logonPassword" name="logonPassword" type="password" autocomplete="off" size="25" onchange="javaScript:TealeafWCJS.processDOMEvent(event);" onkeypress="if(event.keyCode==13){javascript:if(CheckoutHelperJS.canCheckoutContinue() && CheckoutHelperJS.updateShoppingCart(document.ShopCartForm)){ShipmodeSelectionExtJS.guestShopperLogon('javascript:LogonForm.SubmitAjaxLogin(document.AjaxLogon)', '<c:out value='${OrderCalculateURL}'/>', '<c:out value='${PhysicalStoreSelectionURL}'/>');}}" />
						</p>
						<p><a href="<c:out value="${ForgetPasswordURL}"/>" class="myaccount_link hover_underline" id="WC_CheckoutLogonf_links_1"><fmt:message bundle="${storeText}" key="SHOPCART_FORGOT"/></a></p>
						<div class="new_returning_button" id="WC_CheckoutLogonf_div_5">
							<div class="button_align" id="WC_CheckoutLogonf_div_6">
								<a href="#" role="button" class="button_primary" id="guestShopperLogon" onclick="javascript:TealeafWCJS.processDOMEvent(event);if(CheckoutHelperJS.canCheckoutContinue() && CheckoutHelperJS.updateShoppingCart(document.ShopCartForm)){ShipmodeSelectionExtJS.guestShopperLogon('javascript:LogonForm.SubmitAjaxLogin(document.AjaxLogon)','<c:out value='${OrderCalculateURL}'/>', '<c:out value='${PhysicalStoreSelectionURL}'/>');}return false;">
									<div class="left_border"></div>
									<div class="button_text"><fmt:message bundle="${storeText}" key="SHOPCART_SIGNIN" /></div>
									<div class="right_border"></div>
								</a>
							</div>
						</div>
					</div>
				</c:if>
			</div>
		</div>
	 	<br clear="all" />
	 	<br />
	</form>
</c:if>

<div id="WC_CheckoutLogonf_div_9">
	<%-- User is not a guest user AND (order is NOT locked OR CSR is accessing the shopCart page), then display Checkout Button --%>
	<c:if test="${userType != 'G' && (currentOrderLocked != 'true' || env_shopOnBehalfSessionEstablished eq 'true')}">
		<div class="left" id="shopcartCheckoutButton">
			<c:choose>
				<c:when test="${requestScope.allContractsValid}">
					<div class="button_align left" id="WC_CheckoutLogonf_div_10">
					<a href="#" role="button" class="button_primary" id="shopcartCheckout" tabindex="0" onclick="javascript:TealeafWCJS.processDOMEvent(event);if(CheckoutHelperJS.canCheckoutContinue('<c:out value="${userType}"/>') && CheckoutHelperJS.updateShoppingCart(document.ShopCartForm)){ShipmodeSelectionExtJS.registeredUserContinue('<c:out value='${OrderCalculateURL}'/>', '<c:out value='${PhysicalStoreSelectionURL}'/>');}return false;">
				</c:when>
				<c:otherwise>
					<div class="disabled left" id="WC_CheckoutLogonf_div_10">
					<a role="button" class="button_primary" id="shopcartCheckout" tabindex="0" onclick="javascript:TealeafWCJS.processDOMEvent(event);setPageLocation('#')">
				</c:otherwise>
			</c:choose>
			<div class="left_border"></div>
			<div class="button_text"><fmt:message bundle="${storeText}" key="SHOPCART_CHECKOUT" /></div>
			<div class="right_border"></div>				
			</a>
			</div>	
			<!-- BRAINTREE START -->
			<!--  Hide quick checkout option -->
			<!--<c:if test="${quickCheckoutProfile}">
				<c:set var="quickOrderId" value="${quickOrder.Order[0].orderId}"/>
				<div class="left" id="quickCheckoutButton">
					<div class="button_align" id="WC_CheckoutLogonf_div_13">
						<a href="#" role="button" class="button_primary button_left_padding" id="WC_CheckoutLogonf_links_2" tabindex="0" onclick="javascript:if(CheckoutHelperJS.canCheckoutContinue('<c:out value="${userType}"/>') && CheckoutHelperJS.updateShoppingCart(document.ShopCartForm)){setCurrentId('WC_CheckoutLogonf_links_2'); ShipmodeSelectionExtJS.updateCartWithQuickCheckoutProfile('<c:out value='${quickOrderId}'/>');}">
							<div class="left_border"></div>
							<div class="button_text"><fmt:message bundle="${storeText}" key="QUICKCHECKOUT" /></div>
							<div class="right_border"></div>
						</a>
					</div>
				</div>
			</c:if>-->
			<!-- BRAINTREE END -->
		</div>
	</c:if>
</div>

<!-- BRAINTREE START -->
<c:if test="${paypalEnableInCart eq 'true'}" >
		<div id="paypalCheckoutInCart" class="paypalCheckoutInCart" style="<c:if test="${userType eq 'G'}">padding-left: 220px;</c:if> display: grid; margin-left: 10px; float: left; position: initial; margin-bottom: 10px; <c:if test="${userType ne 'G'}">border-left: 1px solid rgb(229, 229, 229);</c:if> ">
			<div id="paypal-button" style="float: left; padding-left:5px;"></div>
			<c:if test="${isPayPalCreditEnable eq 'true'}">
				<span style="position:absolute;padding-top:40px;padding-bottom:20px; padding-left: 70px;<c:if test="${userType eq 'G'}">padding-left:290px;</c:if>"><fmt:message bundle="${storeText}" key="OR" /></span>
				<div id="paypal-credit-button" style="float: left; padding-left:5px; padding-top: 20px;"></div>
			</c:if>
		<script type="text/javascript">
			var advancedFraudTools= '${advancedFraudTools}';
			var paypalMerchantName='${paypalMerchantName}';
			var paypalFlow='${paypalFlow}';
			var paypalIntent='${paypalIntent}';
			var localeVal = '${locale}';
			var billingAgreementDescription ='${billingAgreementDescription}';
			var paypalBillingAddressEnable ='${paypalBillingAddressEnable}';
			var paymentEnvironment ='${paymentEnvironment}';
			BrainTreePayments.payPalVaultPaymentFromExpressCheckout('paypal-button','paypal-credit-button','${getTokenResult.clientToken}','${order.orderItem[0].orderItemId}','${OrderCalculateURL}','${orderTotalAmount}', '${userType}' , false ,'${isPayPalCreditEnable}','${useVaultForAuth}');
		</script>
		</div>
</c:if>
<!-- BRAINTREE END -->
<%@ include file="CheckoutLogonEIExt.jspf"%>
<!-- END CheckoutLogon.jsp -->
