<!DOCTYPE HTML>

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
  * This JSP displays store locator content and allows shopper to select a store to add to the WC_physicalStores
  * cookie. This JSP will then update the shipping mode and address id associated with the order itmes of the
  * current order once the shopper clicks the next button in the shopping flow.
  *****
--%>

<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://commerce.ibm.com/base" prefix="wcbase" %>
<%@ taglib uri="http://commerce.ibm.com/foundation" prefix="wcf" %>
<%@ taglib uri="http://commerce.ibm.com/coremetrics"  prefix="cm" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="flow.tld" prefix="flow" %>
<%@ include file="../../Common/EnvironmentSetup.jspf" %>
<%@ include file="../../Common/nocache.jspf" %>
<%@ include file="../../include/ErrorMessageSetup.jspf" %>

<c:set var="pageCategory" value="Checkout" scope="request"/>

<!-- BEGIN CheckoutStoreSelection.jsp -->
<html xmlns="http://www.w3.org/1999/xhtml" lang="${shortLocale}" xml:lang="${shortLocale}">
<head>
	<%@ include file="../../Common/CommonCSSToInclude.jspf" %>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />

	<%-- Tealeaf should be set up before coremetrics inside CommonJSToInclude.jspf --%>
	<script type="text/javascript" src="${jsAssetsDir}javascript/Tealeaf/tealeafWC.js"></script>
	<c:if test="${env_Tealeaf eq 'true' && env_inPreview != 'true'}">
		<script type="text/javascript" src="${jsAssetsDir}javascript/Tealeaf/tealeaf.js"></script>
	</c:if>

	<%@ include file="../../Common/CommonJSToInclude.jspf" %>

	<title><fmt:message bundle="${storeText}" key="CO_STORE_SELECTION_TITLE" /></title>
</head>

<%-- constructs form used by ShipmodeSelectionExtJS --%>
<wcf:rest var="order" url="store/{storeId}/cart/@self" scope="request">
	<wcf:var name="storeId" value="${WCParam.storeId}" encode="true"/>
	<wcf:param name="sortOrderItemBy" value="orderItemID"/>
</wcf:rest>
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

<wcf:url var="shopViewURL" value="AjaxOrderItemDisplayView"></wcf:url>
<wcf:url var="ShoppingCartURL" value="RESTOrderCalculate" type="Ajax">
	<wcf:param name="langId" value="${langId}" />
	<wcf:param name="storeId" value="${WCParam.storeId}" />
	<wcf:param name="catalogId" value="${WCParam.catalogId}" />
	<wcf:param name="URL" value="${shopViewURL}" />
	<wcf:param name="updatePrices" value="1" />
	<wcf:param name="calculationUsageId" value="-1" />
	<wcf:param name="orderId" value="${order.orderId}" />
</wcf:url>
<script type="text/javascript">
	$(document).ready(function() {
		ShipmodeSelectionExtJS.setCommonParameters('<c:out value="${WCParam.langId}"/>','<c:out value="${WCParam.storeId}"/>','<c:out value="${WCParam.catalogId}"/>');
		ShipmodeSelectionExtJS.setOrderItemId('${order.orderItem[0].orderItemId}');
		<fmt:message bundle="${storeText}" key="ERR_NO_PHY_STORE" var="ERR_NO_PHY_STORE"/>
		MessageHelper.setMessage("message_NO_STORE", <wcf:json object="${ERR_NO_PHY_STORE}"/>);
	});
</script>

<flow:ifEnabled feature="Analytics">
	<c:if test="${userType == 'R' && WCParam.showRegTag == 'T'}">
		<script type="text/JavaScript">
			$(document).ready(function() { analyticsJS.publishShopCartLoginTags(); });
		</script>
	</c:if>
</flow:ifEnabled>

<body>

<!-- Page Start -->
<div id="page" class="nonRWDPage">
	<!-- Include top message display widget -->
	<%@ include file="../../Common/CommonJSPFToInclude.jspf"%>

	<!-- Header Nav Start -->
	<div class="header_wrapper_position" id="headerWidget">
		<%out.flush();%>
		<c:import url = "${env_jspStoreDir}/Widgets/Header/Header.jsp" />
		<%out.flush();%>
	</div>
	<!-- Header Nav End -->

	<!-- Main Content Start -->
	<div class="content_wrapper_position" role="main">
		<div class="content_wrapper">
			<div class="content_left_shadow">
				<div class="content_right_shadow">
					<div class="main_content">
						<div class="container_full_width">
							<!-- Breadcrumb Start -->
							<div id="checkout_crumb">
								<div class="crumb" id="WC_CheckoutStoreSelection_div_1">
									<a href="<c:out value="${ShoppingCartURL}"/>" id="WC_CheckoutStoreSelection_links_1">
										<span class="step_off"><fmt:message bundle="${storeText}" key="BCT_SHOPPING_CART"/></span>
									</a>
									<span class="step_arrow"></span>
									<span class="step_on"><fmt:message bundle="${storeText}" key="BCT_STORE_SELECTION"/></span>
									<span class="step_arrow"></span>
									<span class="step_off"><fmt:message bundle="${storeText}" key="BCT_ADDRESS"/></span>
									<span class="step_arrow"></span>
									<span class="step_off"><fmt:message bundle="${storeText}" key="BCT_SHIPPING_AND_BILLING"/></span>
									<span class="step_arrow"></span>
									<span class="step_off"><fmt:message bundle="${storeText}" key="BCT_ORDER_SUMMARY"/></span>
								</div>							</div>
							<!-- Breadcrumb End -->

							<div id="box">
								<wcf:rest var="usableShippingInfo" url="store/{storeId}/cart/@self/usable_shipping_info" scope="request">
									<wcf:var name="storeId" value="${WCParam.storeId}" encode="true"/>
									<wcf:param name="orderId" value="${order.orderId}" />
									<wcf:param name="pageSize" value="1"/>
									<wcf:param name="pageNumber" value="1"/>
								</wcf:rest>

								<%out.flush();%>
								<c:import url="/${sdb.jspStoreDir}/Snippets/StoreLocator/StoreLocator.jsp">
									<c:param name="fromPage" value="ShoppingCart" />
									<c:param name="orderId" value="${order.orderId}" />
								</c:import>
								<%out.flush();%>
							</div>
							<c:set var="orderItemArray" value="${order.orderItem}"/>
							<wcf:url var="OrderChangeServiceShipInfoUpdate" value="RESTOrderShipInfoUpdate">
								<wcf:param name="langId" value="${langId}" />
								<wcf:param name="storeId" value="${WCParam.storeId}" />
								<wcf:param name="catalogId" value="${WCParam.catalogId}" />
							</wcf:url>
							<wcf:url var="CheckoutPayInStoreView" value="CheckoutPayInStoreView">
								<wcf:param name="langId" value="${langId}" />
								<wcf:param name="storeId" value="${WCParam.storeId}" />
								<wcf:param name="catalogId" value="${WCParam.catalogId}" />
							</wcf:url>
							<form id="orderItemStoreSelectionForm" name="orderItemStoreSelectionForm" method="post" action="${OrderChangeServiceShipInfoUpdate}">
								<input type="hidden" id="storeId" name="storeId" value="${storeId}"/>
								<input type="hidden" id="catalogId" name="catalogId" value="${catalogId}"/>
								<input type="hidden" id="langId" name="langId" value="${langId}"/>
								<input type="hidden" id="fromPage" name="fromPage" value="ShoppingCart"/>
								<input type="hidden" id="orderId" name="orderId" value="${order.orderId}"/>
								<input type="hidden" id="errorViewName" name="errorViewName" value="CheckoutStoreSelectionView"/>
								<input type="hidden" id="URL" name="URL" value="${CheckoutPayInStoreView}&orderItemId*=&shipModeId*=&physicalStoreId*="/>
								<input type="hidden" name="calculationUsage" value="-1,-2,-3,-4,-5,-6,-7" id="calcUsage"/>

								<c:set var="doneLoop" value="false"/>
								<c:forEach items="${usableShippingInfo.orderItem}" var="curOrderItem">
									<c:if test="${not doneLoop}">
										<c:forEach items="${curOrderItem.usableShippingMode}" var="curShipmode">
											<c:if test="${not doneLoop}">
												<c:if test="${curShipmode.shipModeCode == 'PickupInStore'}">
													<c:set var="doneLoop" value="true"/>
													<c:set var="bopisShipmodeId" value="${curShipmode.shipModeId}"/>
												</c:if>
											</c:if>
										</c:forEach>
									</c:if>
								</c:forEach>
								<c:forEach items="${order.orderItem}" var="curOrderItem" varStatus="status">
								<input type="hidden" id="orderItemId_${status.count}" name="orderItemId_${status.count}" value="${curOrderItem.orderItemId}"/>
								<input type="hidden" id="shipModeId_${status.count}" name="shipModeId_${status.count}" value="${bopisShipmodeId}"/>
								</c:forEach>
								<input type="hidden" id="physicalStoreId" name="physicalStoreId" value=""/>
								<!-- Store selection footer -->
								<div class="button_footer_line" id="WC_CheckoutStoreSelection_div_4">
									<div class="left" id="WC_CheckoutStoreSelection_div_5">
										<a role="button" class="button_secondary" id="WC_CheckoutStoreSelection_links_2" href="javascript:setPageLocation('<c:out value="${ShoppingCartURL}"/>')">
											<div class="left_border"></div>
											<div class="button_text"><fmt:message bundle="${storeText}" key="CO_STORE_SELECTION_BACK"/><span class="spanacce"><fmt:message bundle="${storeText}" key="Checkout_ACCE_back_shopping_cart"/></span></div>
											<div class="right_border"></div>
										</a>
									</div>
									<div class="left" id="WC_CheckoutStoreSelection_div_8">
										<a href="#" role="button" class="button_primary button_left_padding" id="storeSelection_NextButton" onclick="javascript:TealeafWCJS.processDOMEvent(event);ShipmodeSelectionExtJS.submitStoreSelectionForm(document.orderItemStoreSelectionForm); return false;">
											<div class="left_border"></div>
											<div class="button_text"><fmt:message bundle="${storeText}" key="CO_STORE_SELECTION_NEXT"/><span class="spanacce"><fmt:message bundle="${storeText}" key="Checkout_ACCE_next_summary"/></span></div>
											<div class="right_border"></div>
										</a>
									</div>
									<div class="button_side_message" id="WC_CheckoutStoreSelection_div_11">
										<fmt:message bundle="${storeText}" key="CO_STORE_SELECTION_NEXTSTEP"/>
									</div>
									<!-- BRAINTREE START -->
									<c:set var="pickUpStoreId" value="${cookie.WC_pickUpStore.value}" />
									<c:if test="${paypalEnableInCart eq 'true'}" >
									<div id="paypalCheckoutButton" class="paypalCheckout" style=" padding-left: 75px; padding-top: 40px;<c:if test="${empty pickUpStoreId}">display:none;</c:if>">
										<div id="paypal-button" style="float: left; padding-bottom: 20px;"></div>
										<c:if test="${isPayPalCreditEnable eq 'true'}">
											<span style="position: absolute; padding-top: 35px; padding-left: 60px; display: -webkit-box;"><fmt:message bundle="${storeText}" key="OR" /></span>
											<div id="paypal-credit-button" style="float: left; display: contents;"></div>
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
											BrainTreePayments.payPalVaultPaymentFromExpressCheckout('paypal-button','paypal-credit-button','${getTokenResult.clientToken}','${order.orderItem[0].orderItemId}','DOMOrderShippingBillingView','${orderTotalAmount}', '${userType}' , true, '${isPayPalCreditEnable}','${useVaultForAuth}');
										</script>
									</div>
									</c:if>
									<!-- BRAINTREE END -->
								</div>
								<div class="espot_checkout_bottom" id="WC_CheckoutStoreSelection_div_13">
									<%@ include file="../../Snippets/ReusableObjects/CheckoutBottomESpotDisplay.jspf"%>
								</div>
							</form>
						</div>
						<!-- Main Content End -->
					</div>
				</div>
			</div>
		</div>
	</div>
</div>

<!-- Footer Start -->
<div class="footer_wrapper_position">
	<%out.flush();%>
		<c:import url = "${env_jspStoreDir}/Widgets/Footer/Footer.jsp" />
	<%out.flush();%>
</div>
<!-- Footer End -->

<flow:ifEnabled feature="Analytics">
	<cm:pageview/>
</flow:ifEnabled>

<%@ include file="../../Common/JSPFExtToInclude.jspf"%> </body>
</html>

<!-- END CheckoutStoreSelection.jsp -->
