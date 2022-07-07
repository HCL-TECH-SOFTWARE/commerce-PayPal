<%--
 =================================================================
  Licensed Materials - Property of HCL Technologies

  HCL Commerce

  (C) Copyright HCL Technologies Limited 1996, 2020

 =================================================================
--%>
<%--
  *****
  * This JSP file renders the shipping section of the shipping and billing page of the checkout flow.
  * It decides whether to display single shipment or multiple shipment details by inspecting the
  * current order items. A shipment is made up of the combination of shipping address and shipping method
  * selected for the order items.
  *****
--%>
<!-- BEGIN ShippingDetailsDisplay.jsp -->
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://commerce.ibm.com/foundation" prefix="wcf" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib uri="http://commerce.ibm.com/base" prefix="wcbase" %>
<%@ taglib uri="flow.tld" prefix="flow" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ include file="../../Common/EnvironmentSetup.jspf"%>
<%@ include file="../../Common/nocache.jspf"%>

<c:set var="shipmentTypeId" value="1"/>
<c:if test="${!empty param.shipmentTypeId}">
	<c:set var="shipmentTypeId" value="${param.shipmentTypeId}"/>
</c:if>

<c:set var="orderShipModeInfo" value="${requestScope.orderUsableShipping}"/>
 <c:if test="${empty orderShipModeInfo || orderShipModeInfo == null}">
	<wcf:rest var="orderShipModeInfo" url="store/{storeId}/cart/@self/usable_shipping_info" scope="request">
		<wcf:var name="storeId" value="${storeId}" encode="true"/>
		<wcf:param name="orderId" value="${WCParam.orderId}" />
		<wcf:param name="pageSize" value="${maxOrderItemsToInspect}"/>
		<wcf:param name="pageNumber" value="1"/>
	</wcf:rest>
</c:if>
<c:set var="hideSingleShipment" value="false"/>
<fmt:parseNumber var="maxOrderItemsToInspect" value="${maxOrderItemsToInspect}"/>
<fmt:parseNumber var="numEntries" value="${param.recordSetTotal}" integerOnly="true" />
<c:choose>
	<c:when test="${numEntries<=maxOrderItemsToInspect}">
		<c:set var="numberOfOrderItemsToInspect" value="${numEntries}"/>
	</c:when>
	<c:otherwise>
		<c:set var="numberOfOrderItemsToInspect" value="${maxOrderItemsToInspect}"/>
		<c:set var="hideSingleShipment" value="true"/>
	</c:otherwise>
</c:choose>

<c:if test="${empty orderShipModeInfo.usableShippingAddress}">
	<c:set var="hideSingleShipment" value="true"/>
</c:if>

<c:if test="${!hideSingleShipment}">
<c:choose>
<c:when test="${env_contractSelection || shipmentTypeId == 2}">
	<c:set var="endCount" value="${numberOfOrderItemsToInspect-1}"/>
</c:when>
<c:otherwise>
	<c:set var="endCount" value="${0}"/>
</c:otherwise>
</c:choose>


<jsp:useBean id="shipModeMap" class="java.util.HashMap" scope="request"/>
<c:forEach var="i" begin="0" end="${endCount}">
	<c:forEach var="shipMode" items="${orderShipModeInfo.orderItem[i].usableShippingMode}">
		<c:set var="shipModeId" value="${shipMode.shipModeId}"/>
		<c:set var="shipModeCnt" value="${shipModeMap[shipModeId]}"/>
		<c:choose>
		<c:when test="${empty shipModeCnt}">
			<c:set target="${shipModeMap}" property="${shipModeId}" value="1"/>
		</c:when>
		<c:otherwise>
			<c:set target="${shipModeMap}" property="${shipModeId}" value="${shipModeCnt+1}"/>
		</c:otherwise>
		</c:choose>
	</c:forEach>
</c:forEach>

<c:set var="orderItemCount" value="${fn:length(orderShipModeInfo.orderItem)}"/>
	<c:set var="hideSingleShipment" value="true"/>
	<c:forEach var="shipMode" items="${orderShipModeInfo.orderItem[0].usableShippingMode}">
		<c:set var="shipModeId" value="${shipMode.shipModeId}"/>
			<c:if test="${(!env_contractSelection && (shipModeMap[shipModeId] == orderItemCount)) || (shipModeMap[shipModeId] == numberOfOrderItemsToInspect)}">
				<c:set var="hideSingleShipment" value="false"/>
			</c:if>
	</c:forEach>
</c:if>

<script type="text/javascript">
	$(document).ready(function() {
		CheckoutHelperJS.initializeShipmentPage('<c:out value='${shipmentTypeId}'/>');
		CheckoutHelperJS.setCommonParameters('<c:out value="${langId}"/>','<c:out value="${storeId}"/>','<c:out value="${catalogId}"/>');
	});
</script>

<wcf:url var="MultipleShipmentPageURL" value="OrderShippingBillingView">
	<wcf:param name="langId" value="${langId}" />						
	<wcf:param name="storeId" value="${WCParam.storeId}" />
	<wcf:param name="catalogId" value="${WCParam.catalogId}" />
	<wcf:param name="orderId" value="${WCParam.orderId}" />
	<wcf:param name="quickCheckoutProfileForPayment" value="${WCParam.quickCheckoutProfileForPayment}" />
	<wcf:param name="forceShipmentType" value="2" />
</wcf:url>

<%@ include file="../../Snippets/Marketing/Promotions/PromotionChoiceOfFreeGiftsPopup.jspf" %>

<div class="main_header" id="WC_ShipmentDisplay_div_5">
	<div class="left_corner" id="WC_ShipmentDisplay_div_6"></div>
	<div class="headingtext" id="WC_ShipmentDisplay_div_7"><span aria-level="1" class="main_header_text" role="heading"><fmt:message bundle="${storeText}" key="BCT_SHIPPING_INFO"/></span></div>
	<div class="right_corner" id="WC_ShipmentDisplay_div_8"></div>
	<%@ include file="../../Snippets/ReusableObjects/CheckoutTopESpotDisplay.jspf"%>
</div>
<c:choose>
	<c:when test = "${shipmentTypeId == 1}">
		<flow:ifEnabled  feature="MultipleShipments">	
		   <div class="checkout_subheader" id="WC_ShipmentDisplay_div_9">		
				<div class="checkout_subheader_content" id="WC_ShipmentDisplay_div_11"><span class="content_text"><fmt:message bundle="${storeText}" key="SHIP_MULTIPLE_SHIPMENT_MESSAGE"/></span></div>
				<a role="button" class="button_primary header_element_align" id="WC_ShipmentDisplay_links_3" tabindex="0" href="javascript:setPageLocation('<c:out value="${MultipleShipmentPageURL}"/>')">
					<div class="left_border"></div>
					<div class="button_text"><fmt:message bundle="${storeText}" key="SHIP_MULTIPLE_SHIPMENTS" /><span class="spanacce"><fmt:message bundle="${storeText}" key="Checkout_ACCE_Multi_Shipping"/></span></div>
					<div class="right_border"></div>
				</a>				
				<div id="WC_ShipmentDisplay_div_14a" class="header_element_align">
					<%out.flush();%>
						<wcpgl:widgetImport useIBMContextInSeparatedEnv="${isStoreServer}" url= "${env_siteWidgetsDir}com.ibm.commerce.store.widgets.ContentRecommendation/ContentRecommendation.jsp">
							<wcpgl:param name="storeId" value="${storeId}" />
							<wcpgl:param name="catalogId" value="${catalogId}" />
							<wcpgl:param name="emsName" value="ShippingTop_Content" />
						</wcpgl:widgetImport>
					<%out.flush();%>				
				</div>
		   </div>
	   </flow:ifEnabled>
	</c:when>
	<c:otherwise>
		<c:if test="${!hideSingleShipment}">
		<!-- BRAINTREE START -->
			<script>
				isMultipleShipping = true;
			</script>
			<!-- BRAINTREE END -->
		 <div class="checkout_subheader" id="WC_MultipleShipmentDisplay_div_9">
			<div class="left_corner" id="WC_MultipleShipmentDisplay_div_10"></div>
			<c:forEach var="shipMode" items="${orderShipModeInfo.orderItem[0].usableShippingMode}">
				<c:set var="shipModeId" value="${shipMode.shipModeId}"/>
					<c:if test="${((!env_contractSelection && (shipModeMap[shipModeId] == orderItemCount)) || shipModeMap[shipModeId] == numberOfOrderItemsToInspect) && empty commonShipModeId && shipMode.shipModeCode != 'PickupInStore'}">
						<c:set var="commonShipModeId" value="${shipModeId}"/>
					</c:if>
			</c:forEach>
			<input type="hidden" id="commonShipModeId" name="commonShipModeId" value="${commonShipModeId}"/>
			<div class="checkout_subheader_content" id="WC_MultipleShipmentDisplay_div_11"><span class="content_text"><fmt:message bundle="${storeText}" key="SHIP_SINGLE_SHIPMENT_MESSAGE"/></span></div>
			<div class="header_element_align" id="WC_MultipleShipmentDisplay_div_12">
				<a role="button" class="button_primary" id="WC_MultipleShipmentDisplay_links_3" tabindex="0" href="JavaScript:setCurrentId('WC_MultipleShipmentDisplay_links_3'); CheckoutHelperJS.moveAllItemsToSingleShipment()">
					<div class="left_border"></div>
					<div class="button_text"><fmt:message bundle="${storeText}" key="SHIP_SINGLE_SHIPMENT"/><span class="spanacce"><fmt:message bundle="${storeText}" key="Checkout_ACCE_Single_Shipping" /></span></div>
					<div class="right_border"></div>
				</a>
			</div>
			<div id="WC_ShipmentDisplay_div_14a" class="header_element_align">
				<%out.flush();%>
					<wcpgl:widgetImport useIBMContextInSeparatedEnv="${isStoreServer}" url= "${env_siteWidgetsDir}com.ibm.commerce.store.widgets.ContentRecommendation/ContentRecommendation.jsp">
						<wcpgl:param name="storeId" value="${storeId}" />
						<wcpgl:param name="catalogId" value="${catalogId}" />
						<wcpgl:param name="emsName" value="ShippingTop_Content" />
					</wcpgl:widgetImport>
				<%out.flush();%>				
			</div>			
			<div class="right_corner" id="WC_MultipleShipmentDisplay_div_15"></div>
		 </div>
		</c:if>
	</c:otherwise>
</c:choose>


<div class="body left" id="WC_ShipmentDisplay_div_16">
	<div id="shipping">
		<c:choose>
			<c:when test = "${shipmentTypeId == 1}">
				<div wcType="RefreshArea" id="shippingAddressSelectBoxArea" widgetId="shippingAddressSelectBoxArea" declareFunction="declareShippingAddressSelectBoxAreaController()">
					 <%out.flush();%>
						<c:import url="/${sdb.jspStoreDir}/ShoppingArea/CheckoutSection/SingleShipment/ShippingAddressSelect.jsp">
							<c:param value="${param.addressId}" name="addressId"/>
							 <c:param value="${param.orderId}" name="orderId"/>
						</c:import>
					<%out.flush();%>
				</div>

				<%out.flush();%>
					<c:import url="/${sdb.jspStoreDir}/ShoppingArea/CheckoutSection/SingleShipment/SingleShipmentShippingMethodDetails.jsp">
						 <c:param value="${param.orderId}" name="orderId"/>
					</c:import>
				<%out.flush();%>
				<flow:ifEnabled feature="ShowHideOrderItems">
					<div class="clear_float"></div>
					<div class="orderExpandArea">
						<span id="OrderItemsExpandArea">
							<a id="OrderItemDetails_plusImage_link" href="javaScript:CheckoutHelperJS.toggleOrderItemDetailsShipping('WC_ShipmentDisplay_div_17', 'traditionalShipmentDetailsContext', 'true');" onclick="javaScript:TealeafWCJS.processDOMEvent(event);">
								<img id="OrderItemDetailsPlus" style="display:inline" src="<c:out value='${jspStoreImgDir}images/'/>icon_plus.png">
								<p id="OrderItemDetailsShowPrompt" style="display:inline"> <fmt:message bundle="${storeText}" key="SHOW_ORDER_ITEMS"/> </p>
							</a>
							<a id="OrderItemDetails_minusImage_link" style="display:none" href="javaScript:CheckoutHelperJS.toggleOrderItemDetailsShipping('WC_ShipmentDisplay_div_17', 'traditionalShipmentDetailsContext', 'true');" onclick="javaScript:TealeafWCJS.processDOMEvent(event);">
								<img id="OrderItemDetailsMinus" style="display:none" src="<c:out value='${jspStoreImgDir}images/'/>icon_minus.png">
								<p id="OrderItemDetailsHidePrompt" style="display:none;"><fmt:message bundle="${storeText}" key="HIDE_ORDER_ITEMS"/></p>
							</a>
						</span>
				</flow:ifEnabled>			
						<span id="singleShipmentOrderDetails_ACCE_Label" class="spanacce"><fmt:message bundle="${storeText}" key="ACCE_Region_Order_Item_List"/></span>
						<div wcType="RefreshArea" widgetId="singleShipmentOrderDetails" declareFunction="declareTraditionalShipmentDetailsController()" ariaMessage="<fmt:message bundle="${storeText}" key="ACCE_Status_Order_Item_List_Updated"/>" ariaLiveId="${ariaMessageNode}" role="region" aria-labelledby="singleShipmentOrderDetails_ACCE_Label" id="WC_ShipmentDisplay_div_17" style="display:none;">
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
								<%-- Required data needed on page load while order item details remain hidden --%>
								<input type="hidden" name="OrderTotalAmount" value="<c:out value='${pgorder.grandTotal}'/>" id="OrderTotalAmount" />
								<input type="hidden" id='orderItem_1' value='<c:out value="${pgorder.orderItem[0].orderItemId}"/>' name='orderItem_1' />
								<%-- dont change the name of this hidden input element. This variable is used in CheckoutHelper.js --%>
								<c:set var="totalNumberOfItems" value="${fn:length(pgorder.orderItem)}"/>
								<input type="hidden" id = "totalNumberOfItems" name="totalNumberOfItems" value='<c:out value="${totalNumberOfItems}"/>'/>								
							</flow:ifEnabled>
							<flow:ifDisabled feature="ShowHideOrderItems">
								<%out.flush();%>
									<c:import url="/${sdb.jspStoreDir}/ShoppingArea/CheckoutSection/SingleShipment/OrderItemDetails.jsp">
										<c:param name="returnView" value="OrderShippingBillingView"/>
									</c:import> 
								<%out.flush();%>
							</flow:ifDisabled>
						</div>
				<flow:ifEnabled feature="ShowHideOrderItems">
						<div id="orderExpandAreaBottom"></div>
					</div>
				</flow:ifEnabled>
				<flow:ifDisabled feature="ShowHideOrderItems">
					<script type="text/javascript">
						$(document).ready(function() {
							$("#WC_ShipmentDisplay_div_17").css("display", "");
						});
					</script>
				</flow:ifDisabled>
			</c:when>
			<c:otherwise>
				<c:set var="shipAsCompleteCheckBoxStatus" value="false"/>
				<c:if test="${order.shipAsComplete}">
					<c:set var="shipAsCompleteCheckBoxStatus" value="true"/>
				</c:if>
				<div id="WC_MultipleShipmentDisplay_div_17">
					<flow:ifEnabled feature="ShipAsComplete">
						<br/>
						<span class="checkbox">
								<input type="checkbox" title="<fmt:message bundle="${storeText}" key="SHIP_SHIP_AS_COMPLETE" />" class="checkbox" id="shipAsComplete" name = "shipAsComplete" onClick="setCurrentId('shipAsComplete'); CheckoutHelperJS.shipAsComplete(this)"
								<c:if test="${shipAsCompleteCheckBoxStatus}">
									checked="checked"
								</c:if> />
							<span class="text"><label for="shipAsComplete"><fmt:message bundle="${storeText}" key="SHIP_SHIP_AS_COMPLETE" /></label></span>
						</span>
					</flow:ifEnabled>
				</div>
				<%-- Show shipping charge refresh area --%>
				<flow:ifEnabled feature="ShippingChargeType">
					<div id="WC_MultipleShipmentDisplay_ShipCharge_Area" wcType="RefreshArea" widgetId="multipleShipmentShipCharge" declareFunction="declareMultipleShipmentShipChargeRefreshArea()" refreshurl='<c:out value="${AjaxMultipleShipmentShipChargeViewURL}"/>'>
						<%out.flush();%>
							<c:import url="/${sdb.jspStoreDir}/ShoppingArea/CheckoutSection/MultipleShipment/MultipleShipmentShipChargeExt.jsp">
								<c:param name="orderId" value="${param.orderId}"/>
							</c:import>
						<%out.flush();%>
					</div>
				</flow:ifEnabled>

				<flow:ifEnabled feature="ShowHideOrderItems">
					<div class="clear_float"></div>
					<div class="orderExpandArea">
						<span id="OrderItemsExpandArea">
							<a id="OrderItemDetails_plusImage_link" class="tlignore" href="javaScript:CheckoutHelperJS.toggleOrderItemDetailsShipping('WC_MultipleShipmentDisplay_div_18', 'multipleShipmentDetailsContext', 'true');" onclick="javaScript:TealeafWCJS.processDOMEvent(event);">
								<img id="OrderItemDetailsPlus" style="display:inline" src="<c:out value='${jspStoreImgDir}images/'/>icon_plus.png">
								<p id="OrderItemDetailsShowPrompt" style="display:inline"> <fmt:message bundle="${storeText}" key="SHOW_ORDER_ITEMS"/> </p>
							</a>
							<a id="OrderItemDetails_minusImage_link" style="display:none" class="tlignore" href="javaScript:CheckoutHelperJS.toggleOrderItemDetailsShipping('WC_MultipleShipmentDisplay_div_18', 'multipleShipmentDetailsContext', 'true');" onclick="javaScript:TealeafWCJS.processDOMEvent(event);">
								<img id="OrderItemDetailsMinus" style="display:none" src="<c:out value='${jspStoreImgDir}images/'/>icon_minus.png">
								<p id="OrderItemDetailsHidePrompt" style="display:none"><fmt:message bundle="${storeText}" key="HIDE_ORDER_ITEMS"/></p>
							</a>
						</span>						
				</flow:ifEnabled>
						<span id="multipleShipmentOrderDetails_ACCE_Label" class="spanacce"><fmt:message bundle="${storeText}" key="ACCE_Region_Order_Item_List"/></span>
						<div id="WC_MultipleShipmentDisplay_div_18" class="shipping_billing_img_padding" wcType ="RefreshArea" widgetId="multipleShipmentOrderDetails" declareFunction="declareMultipleShipmentOrderDetailsRefreshArea()" refreshurl='<c:out value="${AjaxMultipleShipmentOrderItemDetailsViewURL}"/>' ariaMessage="<fmt:message bundle="${storeText}" key="ACCE_Status_Order_Item_List_Updated"/>" ariaLiveId="${ariaMessageNode}" role="region" aria-labelledby="multipleShipmentOrderDetails_ACCE_Label" style="display:none;">
							<flow:ifEnabled feature="ShowHideOrderItems">
								<%-- Retrieve the current page of order & order item information from this request --%>
								<c:set var="pgorder" value="${requestScope.order}"/>
								<c:if test="${empty pgorder || pgorder==null}">
									<wcf:rest var="pgorder" url="store/{storeId}/cart/@self">
										<wcf:var name="storeId" value="${storeId}" encode="true"/>
										<wcf:param name="pageSize" value="1"/>
										<wcf:param name="pageNumber" value="1"/>
										<wcf:param name="sortOrderItemBy" value="orderItemID"/>
										<wcf:param name="langId" value="${langId}" />
									</wcf:rest>
									<c:set var="shippingInfo" value="${pgorder}"/>
								</c:if>

								<%-- Required data needed on page load while order item details remain hidden --%>
								<input type="hidden" name="OrderTotalAmount" value="<c:out value='${pgorder.grandTotal}'/>" id="OrderTotalAmount" />
								<input type="hidden" id='orderItem_1' value='<c:out value="${pgorder.orderItem[0].orderItemId}"/>' name='orderItem_1' />
								<c:set var="orderItemShippingInfo" value="${shippingInfo.orderItem[0]}"/>
								<input type="hidden" id="MS_ShipmentAddress_<c:out value="${pgorder.orderItem[0].orderItemId}"/>" value="<c:out value='${orderItemShippingInfo.addressId}'/>" name="MS_ShipmentAddress_<c:out value="${pgorder.orderItem[0].orderItemId}"/>"/>
								<input type="hidden" id="MS_requestedShippingDate_<c:out value="${pgorder.orderItem[0].orderItemId}"/>" value="<c:out value='${orderItemShippingInfo.requestedShipDate}'/>" name="MS_requestedShippingDate_<c:out value="${pgorder.orderItem[0].orderItemId}"/>"/>
								<c:set var="totalNumberOfItems" value="${fn:length(pgorder.orderItem)}"/>
								<input type="hidden" id = "totalNumberOfItems" name="totalNumberOfItems" value='<c:out value="${totalNumberOfItems}"/>'/>
							</flow:ifEnabled>
							<flow:ifDisabled feature="ShowHideOrderItems">
								<%out.flush();%>
									<c:import url="/${sdb.jspStoreDir}/ShoppingArea/CheckoutSection/MultipleShipment/MSOrderItemDetails.jsp">
										<c:param value="${param.orderId}" name="orderId"/>
									</c:import> 
								<%out.flush();%>
							</flow:ifDisabled>
						</div> 
				<flow:ifEnabled feature="ShowHideOrderItems">
						<div id="orderExpandAreaBottom"></div>
					</div>
				</flow:ifEnabled>
				<flow:ifDisabled feature="ShowHideOrderItems">
					<script type="text/javascript">
						$(document).ready(function() { 
							$("#WC_MultipleShipmentDisplay_div_18").css("display", "");
						});
					</script>
				</flow:ifDisabled>
			</c:otherwise>
		</c:choose>

		<flow:ifEnabled feature="SharedShippingBillingPage">
			<c:set var="fromPage" value="shippingBillingPage"/>
		</flow:ifEnabled>
		<flow:ifDisabled feature="SharedShippingBillingPage">
			<c:set var="fromPage" value="shippingPage"/>
		</flow:ifDisabled>
		
		<span id="singleShipmentOrderTotalsDetail_ACCE_Label" class="spanacce"><fmt:message bundle="${storeText}" key="ACCE_Region_Order_Total"/></span>
		<div wcType="RefreshArea" widgetId="singleShipmentOrderTotalsDetail"  declareFunction="declareCurrentOrderTotalsAreaController()" id="WC_ShipmentDisplay_div_18" ariaMessage="<fmt:message bundle="${storeText}" key="ACCE_Status_Order_Total_Updated"/>" ariaLiveId="${ariaMessageNode}" role="region" aria-labelledby="singleShipmentOrderTotalsDetail_ACCE_Label">
			<%out.flush();%>
				<c:import url="/${sdb.jspStoreDir}/ShoppingArea/CheckoutSection/SingleShipment/SingleShipmentOrderTotalsSummary.jsp">
					<%-- OrderShippingBillingView is used both in AJAX and non-AJAX checkout flow --%>
					<c:param name="returnView" value="OrderShippingBillingView"/>
					<c:param name="fromPage" value="${fromPage}"/>
				</c:import>
			<%out.flush();%>
		</div>
	</div>
	<br clear="all" />
</div>
<!-- END ShippingDetailsDisplay.jsp -->
