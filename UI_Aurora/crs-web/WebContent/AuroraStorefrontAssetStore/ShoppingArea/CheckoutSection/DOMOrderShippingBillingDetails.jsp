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

<!-- BEGIN DOMOrderShippingBillingDetails.jsp -->
<%-- 
  *****
  * This JSP file displays the shipping and billing page of the "Pick up in store" shopping flow.
  * Currently the "Pick up in store" checkout flow only allows for a single shipment. The entire
  * shipping information section of this page is read only.
  * The billing section allows shoppers to choose their payment options for the order. If the 
  * shopper had selected "Pay in store" option on the previous page then the billing section
  *	is in read only form.
  *****
--%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://commerce.ibm.com/foundation" prefix="wcf" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib uri="http://commerce.ibm.com/coremetrics"  prefix="cm" %>
<%@ taglib uri="http://commerce.ibm.com/base" prefix="wcbase" %>
<%@ taglib uri="flow.tld" prefix="flow" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ include file="../../Common/EnvironmentSetup.jspf"%>
<%@ include file="../../Common/nocache.jspf"%>
<!-- BRAINTREE START -->
<script>
	var isPickUpInStore = true;
	var isMultipleShipping = false;
</script>
<!-- BRAINTREE END -->
<c:set var="pageCategory" value="Checkout" scope="request"/>

<html xmlns="http://www.w3.org/1999/xhtml" lang="${shortLocale}" xml:lang="${shortLocale}"
	xmlns:wairole="http://www.w3.org/2005/01/wai-rdf/GUIRoleTaxonomy#"
	xmlns:waistate="http://www.w3.org/2005/07/aaa">
<head>
	<%@ include file="../../Common/CommonCSSToInclude.jspf"%>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	
	<%-- Tealeaf should be set up before coremetrics inside CommonJSToInclude.jspf --%>
	<script type="text/javascript" src="${jsAssetsDir}javascript/Tealeaf/tealeafWC.js"></script>
	<c:if test="${env_Tealeaf eq 'true' && env_inPreview != 'true'}">
		<script type="text/javascript" src="${jsAssetsDir}javascript/Tealeaf/tealeaf.js"></script>
	</c:if>
	
	<%@ include file="../../Common/CommonJSToInclude.jspf"%>
    
	<title><c:out value="${storeName}"/> - <fmt:message bundle="${storeText}" key="TITLE_SINGLE_SHIPMENT_DISPLAY" /></title>

	<c:set var="pageSize" value="${WCParam.pageSize}" />
	<c:if test="${empty pageSize}">
		<c:set var="pageSize" value="${maxOrderItemsPerPage}"/>
	</c:if>

	<c:set var="beginIndex" value="${WCParam.beginIndex}" />
	<c:if test="${empty beginIndex}">
		<c:set var="beginIndex" value="0" />
	</c:if>

	<fmt:formatNumber var="currentPage" value="${(beginIndex/pageSize)+1}"/>
	<fmt:parseNumber var="currentPage" value="${currentPage}" integerOnly="true"/>

	<wcf:rest var="order" url="store/{storeId}/cart/@self" scope="request">
		<wcf:var name="storeId" value="${WCParam.storeId}" encode="true"/>
		<wcf:param name="pageSize" value="${pageSize}"/>
		<wcf:param name="pageNumber" value="${currentPage}"/>
		<wcf:param name="sortOrderItemBy" value="orderItemID"/>
	</wcf:rest>
	
	<c:set var="shippingInfo" value="${order}"/>

	<c:if test="${beginIndex == 0}">
		<fmt:parseNumber var="numEntries" value="${order.recordSetTotal}" integerOnly="true" />
		<c:if test="${numEntries > order.recordSetCount}">		
			<c:set var="pageSize" value="${order.recordSetCount}" />
		</c:if>
	</c:if>	
	<c:set var="usablePaymentInfo" value="${requestScope.usablePaymentInfo}"/>
	<c:if test="${empty usablePaymentInfo || usablePaymentInfo == null}">
		<wcf:rest var="usablePaymentInfo" url="store/{storeId}/cart/@self/usable_payment_info" scope="request">
			<wcf:var name="storeId" value="${WCParam.storeId}" encode="true"/>
			<wcf:param name="orderId" value="${order.orderId}"/>
		</wcf:rest>
	</c:if>
	<c:set var="paymentInstruction" value="${order}" scope="request"/>
	
	<c:set var="totalExistingPaymentMethods" value="1"/>
	<c:forEach var="paymentInstance" items="${paymentInstruction.paymentInstruction}" varStatus="paymentCount">
		<c:set var="totalExistingPaymentMethods" value="${paymentCount.count}"/>
	</c:forEach>

	<c:set var="quickCheckoutProfileForPayment" value="${param.quickCheckoutProfileForPayment}"/>
	<c:if test="${empty quickCheckoutProfileForPayment}">
		<c:set var="quickCheckoutProfileForPayment" value="${WCParam.quickCheckoutProfileForPayment}"/>
	</c:if>
	
	<c:if test="${quickCheckoutProfileForPayment}">
		<%-- we should use quick checkout profile for payment options..with quick checkout there will be only one payment method --%>
		<c:set var="totalExistingPaymentMethods" value="1"/>
	</c:if>
	
	<c:set var="showPayInStoreOnly" value="${WCParam.payInStore}"/>
	<c:if test="${empty showPayInStoreOnly}">
		<c:forEach var="paymentInstance" items="${paymentInstruction.paymentInstruction}">
			<c:if test="${paymentInstance.payMethodId == 'PayInStore'}">
				<c:set var="showPayInStoreOnly" value="true"/>
			</c:if>
		</c:forEach>
	</c:if>
	<c:if test="${empty showPayInStoreOnly}">
		<c:set var="showPayInStoreOnly" value="false"/>
	</c:if>
	
	<wcf:url var="ShoppingCartURL" value="RESTOrderCalculate" type="Ajax">
		<wcf:param name="langId" value="${langId}" />
		<wcf:param name="storeId" value="${WCParam.storeId}" />
		<wcf:param name="catalogId" value="${WCParam.catalogId}" />
		<wcf:param name="URL" value="AjaxOrderItemDisplayView" />
		<wcf:param name="errorViewName" value="AjaxOrderItemDisplayView" />
		<wcf:param name="updatePrices" value="1" />
		<wcf:param name="calculationUsageId" value="-1" />
		<wcf:param name="orderId" value="." />
	</wcf:url>

	<wcf:url var="StoreSelectionURL" value="CheckoutStoreSelectionView">
		<wcf:param name="langId" value="${langId}" />
		<wcf:param name="storeId" value="${WCParam.storeId}" />
		<wcf:param name="catalogId" value="${WCParam.catalogId}" />
		<wcf:param name="fromPage" value="ShoppingCart" />
	</wcf:url>
	
	<wcf:url var="CheckoutAddressURL" value="CheckoutPayInStoreView">
		<wcf:param name="langId" value="${langId}" />
		<wcf:param name="storeId" value="${WCParam.storeId}" />
		<wcf:param name="catalogId" value="${WCParam.catalogId}" />
		<wcf:param name="payInStore" value="${showPayInStoreOnly}" />
	</wcf:url>

	<wcf:url var="ShippingAddressDisplayURL" value="ShippingAddressDisplayView" type="Ajax">
		<wcf:param name="langId" value="${langId}" />						
		<wcf:param name="storeId" value="${WCParam.storeId}" />
		<wcf:param name="catalogId" value="${WCParam.catalogId}" />
	</wcf:url>

	<c:set var="currentOrderId" value="${order.orderId}" />

	<%-- This declares the common error messages and <c:url tags --%>
	<%@ include file="CommonUtilities.jspf"%>

<%-- Include controllers declarations after common contexts declarations.. controllers will make a local copy of the render contexts.. so render contexts should be declared before controllers. Never declare two contexts with same id.. Even if two contexts with same id is defined, they should be defined before defining controller..Because if you declare context and controller in this order..
{context - controller - context} the controller will make a local copy of the first context declared and always refers to it.. But updateContext and other functions will refer to second context declared and so there wont be any sync between context used in code and context referred by controller..Controllers use context by value and not by reference.. --%>

	<script type="text/javascript">
		$(document).ready(function() { 
			ServicesDeclarationJS.setCommonParameters('<c:out value="${WCParam.langId}"/>','<c:out value="${WCParam.storeId}"/>','<c:out value="${WCParam.catalogId}"/>');
			SBServicesDeclarationJS.setCommonParameters('<c:out value="${WCParam.langId}"/>','<c:out value="${WCParam.storeId}"/>','<c:out value="${WCParam.catalogId}"/>');
			CommonContextsJS.setCommonParameters('<c:out value="${WCParam.langId}"/>','<c:out value="${WCParam.storeId}"/>','<c:out value="${WCParam.catalogId}"/>');
			SBControllersDeclarationJS.setRefreshURL('shippingAddressSelectBoxArea','<c:out value="${ShippingAddressDisplayURL}"/>');
			CommonContextsJS.setContextProperty('billingAddressDropDownBoxContext','billingURL1','${billingAddressDisplayURL_1}');
			CommonContextsJS.setContextProperty('billingAddressDropDownBoxContext','billingURL2','${billingAddressDisplayURL_2}');
			CommonContextsJS.setContextProperty('billingAddressDropDownBoxContext','billingURL3','${billingAddressDisplayURL_3}');
			<fmt:message bundle="${storeText}" key="ERROR_UPDATE_FIRST" var="ERROR_UPDATE_FIRST"/>
			<fmt:message bundle="${storeText}" key="SHOPCART_ADDED" var="SHOPCART_ADDED"/>
			<fmt:message bundle="${storeText}" key="SHOPCART_REMOVEITEM" var="SHOPCART_REMOVEITEM"/>
			<fmt:message bundle="${storeText}" key="SHIPPING_INVALID_ADDRESS" var="SHIPPING_INVALID_ADDRESS"/>
			<fmt:message bundle="${storeText}" key="EDPPaymentMethods_CANNOT_RECONCILE_PAYMENT_AMT" var="EDPPaymentMethods_CANNOT_RECONCILE_PAYMENT_AMT"/>
			<fmt:message bundle="${storeText}" key="EDPPaymentMethods_PAYMENT_AMOUNT_LARGER_THAN_ORDER_AMOUNT" var="EDPPaymentMethods_PAYMENT_AMOUNT_LARGER_THAN_ORDER_AMOUNT"/>
			<fmt:message bundle="${storeText}" key="EDPPaymentMethods_NO_ACCOUNT_NUMBER" var="EDPPaymentMethods_NO_ACCOUNT_NUMBER"/>
			<fmt:message bundle="${storeText}" key="EDPPaymentMethods_INVALID_EXPIRY_DATE" var="EDPPaymentMethods_INVALID_EXPIRY_DATE"/>
			<fmt:message bundle="${storeText}" key="EDPPaymentMethods_NO_AMOUNT" var="EDPPaymentMethods_NO_AMOUNT"/>
			<fmt:message bundle="${storeText}" key="EDPPaymentMethods_AMOUNT_NAN" var="EDPPaymentMethods_AMOUNT_NAN"/>
			<fmt:message bundle="${storeText}" key="EDPPaymentMethods_AMOUNT_LT_ZERO" var="EDPPaymentMethods_AMOUNT_LT_ZERO"/>
			<fmt:message bundle="${storeText}" key="EDPPaymentMethods_NO_BILLING_ADDRESS" var="EDPPaymentMethods_NO_BILLING_ADDRESS"/>
			<fmt:message bundle="${storeText}" key="EDPPaymentMethods_BILLING_ADDRESS_INVALID" var="EDPPaymentMethods_BILLING_ADDRESS_INVALID"/>
			<fmt:message bundle="${storeText}" key="EDPPaymentMethods_CVV_NOT_NUMERIC" var="EDPPaymentMethods_CVV_NOT_NUMERIC"/>
			<fmt:message bundle="${storeText}" key="EDPPaymentMethods_PAYMENT_AMOUNT_PROBLEM" var="EDPPaymentMethods_PAYMENT_AMOUNT_PROBLEM"/>
			<fmt:message bundle="${storeText}" key="EDPPaymentMethods_NO_PAYMENT_SELECTED" var="EDPPaymentMethods_NO_PAYMENT_SELECTED"/>
			<fmt:message bundle="${storeText}" key="EDPPaymentMethods_NO_ROUTING_NUMBER" var="EDPPaymentMethods_NO_ROUTING_NUMBER"/>
			<fmt:message bundle="${storeText}" key="EDPPaymentMethods_NO_BANK_ACCOUNT_NO" var="EDPPaymentMethods_NO_BANK_ACCOUNT_NO"/>
			<fmt:message bundle="${storeText}" key="PROMOTION_CODE_EMPTY" var="PROMOTION_CODE_EMPTY"/>
					
			MessageHelper.setMessage("ERROR_UPDATE_FIRST", <wcf:json object="${ERROR_UPDATE_FIRST}"/>);
			MessageHelper.setMessage("SHOPCART_REMOVEITEM", <wcf:json object="${SHOPCART_REMOVEITEM}"/>);
			MessageHelper.setMessage("SHIPPING_INVALID_ADDRESS", <wcf:json object="${SHIPPING_INVALID_ADDRESS}"/>);
			MessageHelper.setMessage("SHOPCART_ADDED", <wcf:json object="${SHOPCART_ADDED}"/>);
			CheckoutPayments.setErrorMessage("EDPPaymentMethods_CANNOT_RECONCILE_PAYMENT_AMT", <wcf:json object="${EDPPaymentMethods_CANNOT_RECONCILE_PAYMENT_AMT}"/>);
			CheckoutPayments.setErrorMessage("EDPPaymentMethods_PAYMENT_AMOUNT_LARGER_THAN_ORDER_AMOUNT", <wcf:json object="${EDPPaymentMethods_PAYMENT_AMOUNT_LARGER_THAN_ORDER_AMOUNT}"/>);
			CheckoutPayments.setErrorMessage("EDPPaymentMethods_NO_ACCOUNT_NUMBER", <wcf:json object="${EDPPaymentMethods_NO_ACCOUNT_NUMBER}"/>);
			CheckoutPayments.setErrorMessage("EDPPaymentMethods_INVALID_EXPIRY_DATE", <wcf:json object="${EDPPaymentMethods_INVALID_EXPIRY_DATE}"/>);
			CheckoutPayments.setErrorMessage("EDPPaymentMethods_NO_AMOUNT", <wcf:json object="${EDPPaymentMethods_NO_AMOUNT}"/>);
			CheckoutPayments.setErrorMessage("EDPPaymentMethods_AMOUNT_NAN", <wcf:json object="${EDPPaymentMethods_AMOUNT_NAN}"/>);
			CheckoutPayments.setErrorMessage("EDPPaymentMethods_AMOUNT_LT_ZERO", <wcf:json object="${EDPPaymentMethods_AMOUNT_LT_ZERO}"/>);
			CheckoutPayments.setErrorMessage("EDPPaymentMethods_NO_BILLING_ADDRESS", <wcf:json object="${EDPPaymentMethods_NO_BILLING_ADDRESS}"/>);
			CheckoutPayments.setErrorMessage("EDPPaymentMethods_BILLING_ADDRESS_INVALID", <wcf:json object="${EDPPaymentMethods_BILLING_ADDRESS_INVALID}"/>);
			CheckoutPayments.setErrorMessage("EDPPaymentMethods_CVV_NOT_NUMERIC", <wcf:json object="${EDPPaymentMethods_CVV_NOT_NUMERIC}"/>);
			CheckoutPayments.setErrorMessage("EDPPaymentMethods_PAYMENT_AMOUNT_PROBLEM", <wcf:json object="${EDPPaymentMethods_PAYMENT_AMOUNT_PROBLEM}"/>);
			CheckoutPayments.setErrorMessage("EDPPaymentMethods_NO_PAYMENT_SELECTED", <wcf:json object="${EDPPaymentMethods_NO_PAYMENT_SELECTED}"/>);
			CheckoutPayments.setErrorMessage("EDPPaymentMethods_NO_ROUTING_NUMBER", <wcf:json object="${EDPPaymentMethods_NO_ROUTING_NUMBER}"/>);
			CheckoutPayments.setErrorMessage("EDPPaymentMethods_NO_BANK_ACCOUNT_NO", <wcf:json object="${EDPPaymentMethods_NO_BANK_ACCOUNT_NO}"/>);
			CheckoutPayments.setErrorMessage("PROMOTION_CODE_EMPTY", <wcf:json object="${PROMOTION_CODE_EMPTY}"/>);
		});
	</script>

	<script type="text/javascript">
		$(document).ready(shipmentPageLoaded);
	
		function shipmentPageLoaded(){
			CheckoutHelperJS.initializeShipmentPage("1");
			CheckoutHelperJS.setCommonParameters('<c:out value="${langId}"/>','<c:out value="${storeId}"/>','<c:out value="${catalogId}"/>');
		}
	</script>
</head>
<body>

<wcpgl:widgetImport useIBMContextInSeparatedEnv="${isStoreServer}" url="${env_siteWidgetsDir}Common/QuickInfo/QuickInfoPopup.jsp"/>

	<!-- Page Start -->
	<div id="page" class="nonRWDPage">
		<div id="grayOut"></div>
		<%-- This file includes the progressBar mark-up and success/error message display markup --%>
		<%@ include file="../../Common/CommonJSPFToInclude.jspf"%>

		<!-- Header Nav Start -->
		<div class="header_wrapper_position" id="headerWidget">
			<%out.flush();%>
			<c:import url = "${env_jspStoreDir}/Widgets/Header/Header.jsp" />
			<%out.flush();%>
		</div>
		<!-- Header Nav End -->
			
		<c:choose>
			<c:when test="${empty order.orderItem || order.orderItem == null}">
				<div class="content_wrapper_position" role="main">
					<div class="content_wrapper">
						<div class="content_left_shadow">
							<div class="content_right_shadow">
								<div class="main_content">
									<div class="container_full_width">

									<%-- Display Empty Shopping Cart --%>
										<div id="box">
											<div class="contentgrad_header" id="WC_UnregisteredCheckout_div_5">
												<div class="left_corner" id="WC_UnregisteredCheckout_div_6"></div>
												<div class="left" id="WC_UnregisteredCheckout_div_7"></div>
												<div class="right_corner" id="WC_UnregisteredCheckout_div_8"></div>
											</div>
						                                   
											<div class="body" id="WC_UnregisteredCheckout_div_9">
												<%@ include file="../../Snippets/ReusableObjects/EmptyShopCartDisplay.jspf"%>
											</div>
											<div class="footer" id="WC_EmptyShopCartDisplay_div_10">
												<div class="left_corner" id="WC_EmptyShopCartDisplay_div_11"></div>
												<div class="left" id="WC_EmptyShopCartDisplay_div_12"></div>
												<div class="right_corner" id="WC_EmptyShopCartDisplay_div_13"></div>
											</div>
										</div>
									</div>
								</div>
							</div>
						</div>
					</div>
				</div>
			</c:when>
			<c:otherwise>
				<!-- Main Content Start -->
				<div class="content_wrapper_position" role="main">
					<div class="content_wrapper" wcType="RefreshArea" id="content_wrapper" widgetId="content_wrapper" declareFunction="declareControllerForMainAndAddressDiv()" role="main">
						<div class="content_left_shadow">
							<div class="content_right_shadow">
								<div class="main_content">
									<div class="container_full_width">
									     <!-- Breadcrumb Start -->
										<div id="checkout_crumb">
											<div class="crumb" id="WC_SingleShipmentDisplay_div_4">
												<c:if test="${!empty order.orderItem}">
													<a href="<c:out value="${ShoppingCartURL}"/>" id="WC_SingleShipmentDisplay_links_1">
														<span class="step_off"><fmt:message bundle="${storeText}" key="BCT_SHOPPING_CART"/></span>
													</a>
													<span class="step_arrow"></span>
													<a href="<c:out value="${StoreSelectionURL}"/>" id="WC_SingleShipmentDisplay_links_2">
														<span class="step_off"><fmt:message bundle="${storeText}" key="BCT_STORE_SELECTION"/></span>
													</a>
													<span class="step_arrow"></span>
													<a href="<c:out value="${CheckoutAddressURL}"/>" id="WC_SingleShipmentDisplay_links_3">
														<span class="step_off"><fmt:message bundle="${storeText}" key="BCT_ADDRESS"/></span>
													</a>
													<span class="step_arrow"></span>
													<span class="step_on"><fmt:message bundle="${storeText}" key="BCT_SHIPPING_AND_BILLING"/></span>
													<span class="step_arrow"></span>
													<span class="step_off"><fmt:message bundle="${storeText}" key="BCT_ORDER_SUMMARY"/></span>
												</c:if>
											</div>
										</div>
     									<!-- Breadcrumb End -->
<%-- TODO  This .jsp does not include what PromotionChoiceOfFreeGiftsPopup.jspf needs, other pages do, so commenting this out to do later so existing
pages will still work.
										<%@ include file="../../Snippets/Marketing/Promotions/PromotionChoiceOfFreeGiftsPopup.jspf" %> --%>

										<!-- Content Start -->
										<!-- There are two parts in the content (editAddressContents and mainContents Div)..One Div contains the entire checkoutContents (shopping cart, shipping address, billing info and other things.. The second DIV contains only edit Address page .. On click of Edit Address button, the first div will be hidden and edit address page div will be displayed...
										Instead of having both the div's in same page, we can make a call to server on click of edit button and get the edit Address page..But the problem in that case is, if user clicks on Cancel/Submit button after changing the address details, we update the server with the changes and again redirect the user to Shipping and Billing address page which results in resetting any changes made in shipping / billing details. User will loose all the changes made in shipping/billing page before clicking on edit address button..To avoid this situation we have both the DIV's defined in this page and use hide/show logic here..-->
										<div id="mainContents" style="display:block">			
											<div id="box">
												<div class="main_header" id="WC_SingleShipmentDisplay_div_5">
													<div class="left_corner" id="WC_SingleShipmentDisplay_div_6"></div>
													<div class="headingtext" id="WC_SingleShipmentDisplay_div_7"><span aria-level="1" class="main_header_text" role="heading"><fmt:message bundle="${storeText}" key="BCT_SHIPPING_INFO"/></span></div>
													<div class="right_corner" id="WC_SingleShipmentDisplay_div_8"></div>
													<%@ include file="../../Snippets/ReusableObjects/CheckoutTopESpotDisplay.jspf"%>		
												</div>
												<flow:ifEnabled  feature="MultipleShipments">	
													<div class="checkout_subheader" id="WC_SingleShipmentDisplay_div_9">
														<div class="checkout_subheader_content" id="WC_SingleShipmentDisplay_div_11"><span class="content_text"><fmt:message bundle="${storeText}" key="SINGLE_SHIPMENT_DESCRIPTION"/></span></div>
													</div>
												</flow:ifEnabled>
												<div class="body left" id="WC_SingleShipmentDisplay_div_16">
													<div id="shipping">
														<div class="shipping_address" id="WC_SingleShipmentDisplay_div_12">
															<c:set var="selectedPhysicalStoreId" value="${shippingInfo.orderItem[0].physicalStoreId}"/>
															<c:catch var="physicalStoreException">
																<wcf:rest var="physicalStore" url="store/{storeId}/storelocator/byStoreId/{uniqueId}">
																	<wcf:var name="storeId" value="${WCParam.storeId}" encode="true"/>
																	<wcf:var name="uniqueId" value="${selectedPhysicalStoreId}" encode="true"/>
																</wcf:rest>
															</c:catch>

															<c:out value="${physicalStore.PhysicalStore[0].Description[0].displayStoreName}"/><br />
															<c:import url="/${sdb.jspStoreDir}/Snippets/Member/StoreAddress/DOMAddressDisplay.jsp">
																<c:param name="physicalStoreId" value="${selectedPhysicalStoreId}"/>
															</c:import>
															<input type="hidden" value="${selectedPhysicalStoreId}" id="physicalStoreId" name="physicalStoreId" />

															<p>&nbsp;</p>
															<a role="button" class="button_secondary tlignore" id="WC_SingleShipmentDisplay_links_4" href="javascript:setPageLocation('<c:out value="${StoreSelectionURL}"/>')">
																<div class="left_border"></div>
																<div class="button_text"><fmt:message bundle="${storeText}" key="SINGLE_SHIPMENT_CHANGE_STORE"/></div>
																<div class="right_border"></div>
															</a>
														</div>
														
														<flow:ifEnabled feature="ShowHideOrderItems">
															<div class="clear_float"></div>
															<div class="orderExpandArea">  
																<span id="OrderItemsExpandArea">
																	<a id="OrderItemDetails_plusImage_link" class="tlignore" href="javaScript:CheckoutHelperJS.toggleOrderItemDetailsShipping('WC_ShipmentDisplay_div_17', 'traditionalShipmentDetailsContext', 'true');" onclick="javaScript:TealeafWCJS.processDOMEvent(event);">
																		<img id="OrderItemDetailsPlus" style="display:inline" src="<c:out value='${jspStoreImgDir}images/'/>icon_plus.png">
																		<p id="OrderItemDetailsShowPrompt" style="display:inline"> <fmt:message bundle="${storeText}" key="SHOW_ORDER_ITEMS"/> </p>
																	</a>
																	<a id="OrderItemDetails_minusImage_link" style="display:none" class="tlignore" href="javaScript:CheckoutHelperJS.toggleOrderItemDetailsShipping('WC_ShipmentDisplay_div_17', 'traditionalShipmentDetailsContext', 'true');" onclick="javaScript:TealeafWCJS.processDOMEvent(event);">
																		<img id="OrderItemDetailsMinus" style="display:none" src="<c:out value='${jspStoreImgDir}images/'/>icon_minus.png">
																		<p id="OrderItemDetailsHidePrompt" style="display:none"><fmt:message bundle="${storeText}" key="HIDE_ORDER_ITEMS"/></p>
																	</a>
																</span>
														</flow:ifEnabled>
														
																<span id="singleShipmentOrderDetails_ACCE_Label" class="spanacce"><fmt:message bundle="${storeText}" key="ACCE_Region_Order_Item_List"/></span>
																<div wcType="RefreshArea" widgetId="singleShipmentOrderDetails" declareFunction="declareTraditionalShipmentDetailsController()" ariaMessage="<fmt:message bundle="${storeText}" key="ACCE_Status_Order_Item_List_Updated"/>" ariaLiveId="${ariaMessageNode}" role="region"
																id="WC_ShipmentDisplay_div_17" refreshurl="${TraditionalAjaxShippingDetailsViewURL}" aria-labelledby="singleShipmentOrderDetails_ACCE_Label" style="display:none;">
																	<flow:ifEnabled feature="ShowHideOrderItems">
																		<%-- Retrieve the current page of order & order item information from this request --%>
																		<c:set var="pgorder" value="${requestScope.order}" />
																		<c:if test="${empty pgorder || pgorder==null}">
																			<wcf:rest var="pgorder" url="store/{{storeId}/cart/@self">
																				<wcf:var name="storeId" value="${WCParam.storeId}" encode="true"/>
																				<wcf:param name="pageSize" value="1"/>
																				<wcf:param name="pageNumber" value="1"/>
																				<wcf:param name="sortOrderItemBy" value="orderItemID"/>
																			</wcf:rest>
																		</c:if>
																		<input type="hidden" name="OrderTotalAmount" value="<c:out value='${pgorder.grandTotal}'/>" id="OrderTotalAmount" />
																	</flow:ifEnabled>
																	<flow:ifDisabled feature="ShowHideOrderItems">
																		<%out.flush();%>
																		<c:import url="/${sdb.jspStoreDir}/ShoppingArea/CheckoutSection/SingleShipment/OrderItemDetails.jsp"> 
																			<%-- OrderShippingBillingView is used both in AJAX and non-AJAX checkout flow --%>
																			<c:param name="returnView" value="DOMOrderShippingBillingView?payInStore=${showPayInStoreOnly}"/>
																		</c:import>
																		<%out.flush();%>
																	</flow:ifDisabled>
																</div>
															<flow:ifEnabled feature="ShowHideOrderItems">
																<div id="orderExpandAreaBottom"></div>
															</div>
															</flow:ifEnabled>
														<flow:ifDisabled feature="ShowHideOrderItems">
															<script>
																$(document).ready(function() { 
																	$("#WC_ShipmentDisplay_div_17").css("display", "");
																});
															</script>
														</flow:ifDisabled>
														
														<span id="singleShipmentOrderTotalsDetail_ACCE_Label" class="spanacce"><fmt:message bundle="${storeText}" key="ACCE_Region_Order_Total"/></span>
														<div wcType="RefreshArea" widgetId="singleShipmentOrderTotalsDetail" declareFunction="declareCurrentOrderTotalsAreaController()" id="WC_ShipmentDisplay_div_18" refreshurl="${AjaxCurrentOrderInformationViewURL}"
															ariaMessage="<fmt:message bundle="${storeText}" key="ACCE_Status_Order_Total_Updated"/>" ariaLiveId="${ariaMessageNode}" role="region" aria-labelledby="singleShipmentOrderTotalsDetail_ACCE_Label">
															<%out.flush();%>
																<c:import url="/${sdb.jspStoreDir}/ShoppingArea/CheckoutSection/SingleShipment/SingleShipmentOrderTotalsSummary.jsp">
																	<%-- OrderShippingBillingView is used both in AJAX and non-AJAX checkout flow --%>
																	<c:param name="returnView" value="DOMOrderShippingBillingView"/>
																</c:import>
															<%out.flush();%>
														</div>

													</div>
													<br clear="all" />
												</div>
												<br/>&nbsp;		

												<div class="main_header" id="WC_SingleShipmentDisplay_div_22">
													<div class="left_corner_straight" id="WC_SingleShipmentDisplay_div_23"></div>
													<div class="headingtext" id="WC_SingleShipmentDisplay_div_24"><span aria-level="1" class="main_header_text" role="heading"><fmt:message bundle="${storeText}" key="BILL_BILLING_INFO" /></span></div>
													<div class="right_corner_straight" id="WC_SingleShipmentDisplay_div_25"></div>
												</div>

												<c:choose>
													<c:when test="${showPayInStoreOnly}">

														<wcf:url var="orderTotalAsJSONURL" value="orderTotalAsJSON" type="Ajax">
															<wcf:param name="langId" value="${langId}" />						
															<wcf:param name="storeId" value="${WCParam.storeId}" />
															<wcf:param name="catalogId" value="${WCParam.catalogId}" />
														</wcf:url>

														<!-- BillingAddressDropDownDisplay.jspf uses this URL and rendercontext and refreshController -->
														<wcf:url var="AddressDisplayURL" value="AjaxAddressDisplayView" type="Ajax">
															<wcf:param name="langId" value="${langId}" />						
															<wcf:param name="storeId" value="${WCParam.storeId}" />
															<wcf:param name="catalogId" value="${WCParam.catalogId}" />
														</wcf:url>

														<!-- Display information message for pay in store -->
														<form name="PaymentForm1" id="PaymentForm1" method="post" action="">
															<div class="checkout_subheader" id="WC_SingleShipmentDisplay_div_26">
																<div class="checkout_subheader_content" id="WC_SingleShipmentDisplay_div_28">
																	<span class="content_text"><fmt:message bundle="${storeText}" key="SINGLE_SHIPMENT_PAY_DESCRIPTION" /></span>
																</div>
															</div>
															<div class="body shipping_billing_height" id="WC_SingleShipmentDisplay_div_29a">
																<div id="billing">
																	<div id="billingAddress1" class="billing_address_container">
																		<div wcType="RefreshArea" id="billingAddressSelectBoxArea_1" widgetId="billingAddressSelectBoxArea_1" objectId="1" declareFunction="declareBillingAddressSelectBoxAreaController('billingAddressSelectBoxArea_1')" 
																			refreshurl="${billingAddressDisplayURL}">	
																			<%out.flush();%>
																				<c:import url="/${sdb.jspStoreDir}/ShoppingArea/CheckoutSection/SingleShipment/BillingAddressDropDownDisplay.jsp">
																					<c:param name="selectedAddressId" value=""/>
																					<c:param name="paymentAreaNumber" value="1"/>
																					<c:param name="paymentMethodSelected" value="PayInStore"/>
																				</c:import>
																			<%out.flush();%>
																		</div>
																	</div>
																	<div class="bold" id="billing_method"><fmt:message bundle="${storeText}" key="SINGLE_SHIPMENT_PAY_IN_STORE" /></div>
																	<br/>
																	<div id="WC_SingleShipmentDisplay_div_29c">
																		<a role="button" class="button_secondary tlignore" id="WC_SingleShipmentDisplay_links_6" href="javascript:setPageLocation('<c:out value="${CheckoutAddressURL}"/>')">
																			<div class="left_border"></div>
																			<div class="button_text"><fmt:message bundle="${storeText}" key="SINGLE_SHIPMENT_PAY_CHANGE"/></div>
																			<div class="right_border"></div>
																		</a>									
																	</div>
																	<br clear="all"/>
																</div>
															</div>
	
															<div wcType="RefreshArea" id="orderTotalAmountArea" widgetId="orderTotalAmountArea" declareFunction="declareOrderTotalController()" refreshurl="${orderTotalAsJSONURL}"></div>
							   
															<c:forEach var="paymentInstance" items="${paymentInstruction.paymentInstruction}">
																<c:if test="${!empty existingPI}">
																	<c:set var="existingPI" value="${existingPI},"/>
																</c:if>
																<c:set var="existingPI" value="${existingPI}${paymentInstance.piId}"/>
															</c:forEach>
															<fmt:parseNumber var="piAmount" value="${order.grandTotal}"/>
															<c:set var="piAmount" value="${piAmount}"/>
															<input type="hidden" name="storeId" value="<c:out value="${storeId}"/>" id="WC_SingleShipmentDisplayf_inputs_1a"/>
															<input type="hidden" name="catalogId" value="<c:out value="${catalogId}"/>" id="WC_SingleShipmentDisplayf_inputs_2a"/>
															<input type="hidden" name="langId" value="<c:out value="${langId}"/>" id="WC_SingleShipmentDisplayf_inputs_3a"/>
															<input type="hidden" name="existingPiId" value="<c:out value="${existingPI}"/>" id="WC_SingleShipmentDisplayf_inputs_4a"/>
															<input type="hidden" name="payMethodId" id="payMethodId" value="PayInStore"/>
															<input type="hidden" name="mandatoryFields" id="mandatoryFields_1" value=""/>
															<input type="hidden" name="numberOfPaymentMethods" id="numberOfPaymentMethods" value="1"/>
															<input type="hidden" name="piAmount_display" id="piAmount_1_display" value="<fmt:formatNumber value="${piAmount}" />"/>
															<input type="hidden" name="piAmount" id="piAmount_1" value="<c:out value="${piAmount}" />" onchange="CheckoutPayments.formatAmountDisplayForLocale('1')"/>
															<input type="hidden" name="selectedAddressId_1" id="selectedAddressId_1" value="" />
															<input type="hidden" name="authToken" value="${authToken}" id="authToken_1"/>
															<input type="hidden" name="piId" value="" id="WC_SingleShipmentDisplayf_inputs_5a"/>
															<input type="hidden" name="paymentDataEditable" value="" id="WC_SingleShipmentDisplayf_inputs_6a"/>
															<input type="hidden" name="orderId" value="${order.orderId}" id="WC_SingleShipmentDisplayf_inputs_7a"/>
														</form>
														<script type="text/javascript">
															$(document).ready(function(){
																CheckoutPayments.initializeOverallPaymentObjects();
																CheckoutPayments.initializePaymentAreaDataDirtyFlags();
															});
														</script>
													</c:when>
													<c:otherwise>
														<!-- Display drop down box to select number of payment options.. -->
														<div class="checkout_subheader" id="WC_SingleShipmentDisplay_div_notInStore_26">
															<div class="checkout_subheader_content" id="WC_SingleShipmentDisplay_div_notInStore_28">
																<span class="content_text"><label for="numberOfPaymentMethods"><fmt:message bundle="${storeText}" key="BILL_MULTIPLE_BILLING_MESSAGE" /></label>
																	<select class="drop_down_billing" name="numberOfPaymentMethods" id="numberOfPaymentMethods" onchange="JavaScript:CheckoutPayments.setNumberOfPaymentMethods(<c:out value="${numberOfPaymentMethods}"/>,this,'paymentSection');CheckoutPayments.reinitializePaymentObjects(this);">
																		<c:set var="selectStr" value="" />
																		<c:forEach var="i" begin="1" end="${numberOfPaymentMethods}">
																			<c:if test="${i == totalExistingPaymentMethods}">
																				<c:set var="selectStr" value="selected=selected" />
																			</c:if>
																			<option value="<c:out value="${i}"/>" <c:out value="${selectStr}"/>>
																			<fmt:message bundle="${storeText}" key="BILL_PAYMENT_OPTIONS">
																				<fmt:param value="${i}"/>
																			</fmt:message>
																			</option>
																			<c:set var="selectStr" value="" />
																		</c:forEach>
																	</select>
																</span>
															</div>
														</div>
														<div class="body shipping_billing_height" id="WC_SingleShipmentDisplay_div_notInStore_30">
															<%@ include file="CheckoutPaymentsAndBillingAddress.jspf"%>
														</div>
													</c:otherwise>
												</c:choose>
												<%@ include file="OrderAdditionalDetailExt.jspf"%>

												<div class="button_footer_line" id="WC_SingleShipmentDisplay_div_32_1">
													<a role="button" class="button_secondary tlignore" id="WC_SingleShipmentDisplay_links_7" href="javascript:setPageLocation('<c:out value="${CheckoutAddressURL}"/>')">
														<div class="left_border"></div>
														<div class="button_text"><fmt:message bundle="${storeText}" key="SINGLE_SHIPMENT_BACK" /><span class="spanacce"><fmt:message bundle="${storeText}" key="SINGLE_SHIPMENT_BACKSTEP" /></span></div>
														<div class="right_border"></div>
													</a>
													<!-- BRAINTREE START -->
													<a role="button" class="button_primary button_left_padding tlignore" id="shippingBillingPageNext" href="JavaScript:setCurrentId('shippingBillingPageNext');BrainTreePayments.brainTreeCheckOut('PaymentForm');">
														<div class="left_border"></div>
														<div class="button_text"><fmt:message bundle="${storeText}" key="NEXT" /><span class="spanacce"><fmt:message bundle="${storeText}" key="Checkout_ACCE_next_summary" /></span></div>
														<div class="right_border"></div>
													</a>
													<!-- BRAINTREE END -->
													<span class="button_right_side_message" id="WC_SingleShipmentDisplay_div_32_3">
														<fmt:message bundle="${storeText}" key="ORD_MESSAGE"/>
													</span>
												</div>

												<div class="right_corner" id="WC_SingleShipmentDisplay_div_37"></div>
												<div class="espot_checkout_bottom" id="WC_CheckoutStoreSelection_div_13">
													<%@ include file="../../Snippets/ReusableObjects/CheckoutBottomESpotDisplay.jspf"%>
												</div>													
											</div>
										</div>
										<!-- Create an area for editing an existing address -->
										<div id="editAddressContents" style="display:none">
											<div wcType="RefreshArea" id="editShippingAddressArea1" widgetId="editShippingAddressArea1" declareFunction="declareDOMEditShippingAdddressAreaController()"
												refreshurl="${editAddressDisplayURL}">
											</div>
										
										<!-- Content End -->
									</div>
								</div>
							</div>
						</div>			
					</div>
					<input type="hidden" name="shipmentTypeId" id="shipmentTypeId" value="1"/>
					<!-- Main Content End -->     
				</div><!-- End of mainContents Div-->
			</c:otherwise>
		</c:choose>

		<!-- Footer Start -->
		<div class="footer_wrapper_position">
			<%out.flush();%>
				<c:import url = "${env_jspStoreDir}/Widgets/Footer/Footer.jsp" />
			<%out.flush();%>
		</div>						  
		<!-- Footer End -->  
 
	</div>

	<flow:ifEnabled feature="Analytics">
		<cm:pageview/>
	</flow:ifEnabled>
<%@ include file="../../Common/JSPFExtToInclude.jspf"%> </body>
</html>
<!-- END DOMOrderShippingBillingDetails.jsp -->
