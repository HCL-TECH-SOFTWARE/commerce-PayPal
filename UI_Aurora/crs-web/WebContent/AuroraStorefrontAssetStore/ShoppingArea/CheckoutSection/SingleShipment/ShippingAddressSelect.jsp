<%--
 =================================================================
  Licensed Materials - Property of HCL Technologies

  HCL Commerce

  (C) Copyright HCL Technologies Limited 1996, 2020

 =================================================================
--%>
<%-- 
  ***
  * This jsp displays a select box with all applicable shipping addresses.
  ***
--%>
<!-- BEGIN ShippingAddressSelect.jsp -->
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://commerce.ibm.com/foundation" prefix="wcf" %>
<%@ taglib uri="http://commerce.ibm.com/base" prefix="wcbase" %>
<%@ taglib uri="flow.tld" prefix="flow" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ include file="../../../Common/EnvironmentSetup.jspf"%>
<%@ include file="../CommonUtilities.jspf"%>

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

<c:set var="orderShipInfo" value="${requestScope.orderUsableShipping}"/>
<c:if test="${empty orderShipInfo || orderShipInfo==null}">
	<c:choose>
		<c:when test="${empty param.orderId || param.orderId == null}">
			<wcf:rest var="orderShipInfo" url="store/{storeId}/cart/@self/usable_shipping_info">
				<wcf:var name="storeId" value="${WCParam.storeId}" encode="true"/>
			</wcf:rest>
		</c:when>
		<c:otherwise>
			<wcf:rest var="orderShipInfo" url="store/{storeId}/cart/@self/usable_shipping_info" scope="request">
				<wcf:var name="storeId" value="${WCParam.storeId}" encode="true"/>
				<wcf:param name="orderId" value="${param.orderId}"/>
				<wcf:param name="pageSize" value="${pageSize}"/>
				<wcf:param name="pageNumber" value="${currentPage}"/>
			</wcf:rest>
		</c:otherwise>
	</c:choose>
</c:if>

<c:set var="selectedAddressId" value="${param.addressId}"/>
<c:set var="hasValidAddresses" value="false"/>

<c:set var="order" value="${requestScope.order}" />
<c:if test="${empty order || order==null}">
	<wcf:rest var="order" url="store/{storeId}/cart/@self">
		<wcf:var name="storeId" value="${WCParam.storeId}"/>
		<wcf:param name="pageSize" value="${pageSize}"/>
		<wcf:param name="pageNumber" value="${currentPage}"/>
		<wcf:param name="sortOrderItemBy" value="orderItemID"/>
		<wcf:param name="langId" value="${langId}" />
	</wcf:rest>
</c:if>

<c:if test="${empty selectedAddressId}">
		<wcf:rest var="shippingInfo" url="store/{storeId}/cart/@self/shipping_info">
			<wcf:var name="storeId" value="${WCParam.storeId}"/>
			<wcf:param name="pageSize" value="${pageSize}"/>
			<wcf:param name="pageNumber" value="${currentPage}"/>
		</wcf:rest>
	<c:set var="selectedAddressId" value="${shippingInfo.orderItem[0].addressId}"/>
</c:if>

<c:set var="search01" value="'"/>
<c:set var="replaceStr01" value="\\'"/>

<fmt:message bundle="${storeText}" var="profileshipping" key="QC_DEFAULT_SHIPPING"/>
<fmt:message bundle="${storeText}" var="profilebilling"  key="QC_DEFAULT_BILLING"/>

<c:set var="person" value="${requestScope.person}"/>
<c:if test="${empty person || person==null}">
	<wcf:rest var="person" url="store/{storeId}/person/@self"  scope="request">
		<wcf:var name="storeId" value="${WCParam.storeId}" encode="true"/>
	</wcf:rest>
</c:if>
<c:catch>
	<c:set var="activeOrgId" value="${CommandContext.activeOrganizationId}"/>
	<c:set var="organization" value="${requestScope.organization}" />
	<c:if test="${empty organization || organization==null}">
		<wcf:rest var="organization" url="store/{storeId}/organization/{organizationId}">
			<wcf:var name="storeId" value="${WCParam.storeId}" encode="true"/>
			<wcf:var name="organizationId" value="${activeOrgId}" encode="true"/>
		</wcf:rest>
	</c:if>
	<c:set var="organizationAddresses" value="${organization.addressBook}"/>
	<c:set var ="contact" value="${organization.contactInfo}"/>
	<c:set var = "existingContactOrgAddress" value="${contactOrgAddress}"/>
	<c:set var ="contactOrgAddress" value="${contact.addressId}" scope="request"/>
	<c:forEach items="${organizationAddresses}" var="contact">
		<c:choose>
			<c:when test="${empty contactOrgAddress || contactOrgAddress eq null}">
				<c:set var="contactOrgAddress" value="${contact.addressId}" scope="request"/>
			</c:when>
			<c:otherwise>
				<c:set var="contactOrgAddress" value="${contactOrgAddress},${contact.addressId}" scope="request"/>
			</c:otherwise>
		</c:choose>
	</c:forEach>
	<c:if test="${empty existingContactOrgAddress}">
		<input type="hidden" id="shippingOrganizationAddressList" value="${contactOrgAddress}" name="shippingOrganizationAddressList"/>
	</c:if>
</c:catch>

<div class="shipping_address" id="WC_ShippingAddressSelectSingle_div_1">
	<p class="title"><label for="singleShipmentAddress"><fmt:message bundle="${storeText}" key="SHIP_SHIPPING_ADDRESS_COLON"/></label></p>
	<div class="shipping_address_content">
	<p>
	   <select class="drop_down_shipping" name="singleShipmentAddress" id="singleShipmentAddress" onChange="JavaScript:setCurrentId('singleShipmentAddress'); CheckoutHelperJS.displayAddressDetails(this.value,'Shipping');CheckoutHelperJS.updateAddressForAllItems(this);CheckoutHelperJS.showHideEditAddressLink(this,'<c:out value='${param.orderId}'/>')">
			<c:forEach var="contactInfoIdentifier" items="${orderShipInfo.usableShippingAddress}">
				<c:set var="hasValidAddresses" value="true"/>
				<option value="<c:out value='${contactInfoIdentifier.addressId}'/>"
					<c:if test="${selectedAddressId eq contactInfoIdentifier.addressId}" >
						selected="selected"
					</c:if>
				>
					<c:set var="contactInfoNickName" value="${contactInfoIdentifier.nickName}"/>
					<c:choose>
						<c:when test="${contactInfoNickName eq  profileShippingNickname}"><fmt:message bundle="${storeText}" key="QC_DEFAULT_SHIPPING"/></c:when>
						<c:when test="${contactInfoNickName eq  profileBillingNickname}"><fmt:message bundle="${storeText}" key="QC_DEFAULT_BILLING"/></c:when>
						<c:otherwise><c:out value="${contactInfoNickName}"/></c:otherwise>
					</c:choose>
				</option>
			</c:forEach>
			<%@ include file="SingleShippingAddressSelectExt.jspf" %>
			<%@ include file="GiftRegistrySingleShippingAddressSelectExt.jspf" %>
		</select>
	</p>

	<!-- Area where selected shipping Address details is showed in short.. -->
	<span id="shippingAddressDisplayArea_ACCE_Label" class="spanacce"><fmt:message bundle="${storeText}" key="ACCE_Region_Shipping"/></span>
	<!-- BRAINTREE START -->
	<!-- end populateSelectedShippingAddressFlag parameter -->
	<div wcType="RefreshArea" id="shippingAddressDisplayArea" widgetId="shippingAddressDisplayArea" declareFunction="declareShippingAddressDisplayAreaController()" refreshurl="${ShippingAddressDisplayURL}"
		ariaMessage="<fmt:message bundle="${storeText}" key="ACCE_Status_Shipping_Updated"/>" ariaLiveId="${ariaMessageNode}" role="region" aria-labelledby="shippingAddressDisplayArea_ACCE_Label">
		<c:import url="/${sdb.jspStoreDir}/Snippets/Member/Address/AddressDisplay.jsp">
			<c:param name="addressId" value= "${selectedAddressId}"/>
			<c:param name="populateSelectedShippingAddressFlag" value="true"/>
		</c:import>
	</div>
		<!-- BRAINTREE END -->
<%-- Use the value of personalAddressAllowed to hide/show the create/edit address link. --%>
<c:if test="${order.x_isPersonalAddressesAllowedForShipping}">
	<!-- Show Edit button only if there are any valid address.. -->
	<c:if test="${selectedAddressId != -1}" >
		<br/>
		<div class="editAddressLink hover_underline" id="editAddressLink_<c:out value='${param.orderId}'/>" style="display:block;">
			<a class="tlignore" href="JavaScript:CheckoutHelperJS.editAddress('singleShipmentAddress','-1','<c:out value='${fn:replace(profileshipping,search01,replaceStr01)}'/>','<c:out value='${fn:replace(profilebilling,search01,replaceStr01)}'/>');CheckoutHelperJS.setLastAddressLinkIdToFocus('WC_ShippingAddressSelectSingle_link_1');" id="WC_ShippingAddressSelectSingle_link_1">
				<img src="<c:out value='${jspStoreImgDir}'/>images/edit_icon.png" alt="" />
				<fmt:message bundle="${storeText}" key="ADDR_EDIT_ADDRESS"/>
			</a>
		</div>
		<wcf:url var="AddressEditView" value="AddressEditView" type="Ajax">
			<wcf:param name="langId" value="${WCParam.langId}" />
			<wcf:param name="storeId" value="${WCParam.storeId}" />
			<wcf:param name="catalogId" value="${WCParam.catalogId}" />
		</wcf:url>
	</c:if>
	
	<!-- new address link -->
	<div class="newShippingAddressButton hover_underline" id="newShippingAddressLink">
			<a class="tlignore" href="JavaScript:setCurrentId('singleShipmentAddress'); CheckoutHelperJS.addNewShippingAddress('Shipping');JavaScript:setCurrentId('singleShipmentAddress'); CheckoutHelperJS.updateAddressForAllItems('singleShipmentAddress');CheckoutHelperJS.setLastAddressLinkIdToFocus('WC_ShippingAddressSelectSingle_link_2');" id="WC_ShippingAddressSelectSingle_link_2">
				<img src="<c:out value='${jspStoreImgDir}${env_vfileColor}'/>table_plus_add.png" alt="" />
				<fmt:message bundle="${storeText}" key="ADDR_CREATE_ADDRESS"/>
			</a>
	</div>
</c:if>

<script type="text/javascript">
			$(document).ready(function() { 
				CheckoutHelperJS.showHideEditAddressLink(document.getElementById("singleShipmentAddress"),'<wcf:out value='${param.orderId}' escapeFormat='js'/>');
			});
</script>
	</div>
</div>
<!-- END ShippingAddressSelect.jsp -->
