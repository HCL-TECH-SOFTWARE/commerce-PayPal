<%--
 =================================================================
  Licensed Materials - Property of HCL Technologies

  HCL Commerce

  (C) Copyright HCL Technologies Limited 1996, 2020

 =================================================================
--%>
<%-- 
  ***
  * This jsp displays the address details given an addressId.
  ***
--%>
<!-- BEGIN AddressDisplay.jsp -->
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://commerce.ibm.com/base" prefix="wcbase" %>
<%@ taglib uri="http://commerce.ibm.com/foundation" prefix="wcf" %>
<%@ taglib uri="flow.tld" prefix="flow" %>
<%@ include file="../../../Common/EnvironmentSetup.jspf" %>

<c:set var="addressId" value="${WCParam.addressId}"/>
<c:if test="${empty WCParam.addressId}" >
	<c:set var="addressId" value="${param.addressId}"/>
</c:if>
<!--  BRAINTREE START -->
<c:set var="populateAddressFlag" value="${param.populateSelectedShippingAddressFlag}"/>
<c:if test="${empty param.populateSelectedShippingAddressFlag}" >
	<c:set var="populateAddressFlag" value="false"/>
</c:if>
<!-- BRAINTREE END -->
<c:if test='${param.email != "true"}'>
	<script type="text/javascript">
		$(document).ready(function() {
			console.debug("addressId= " + "<c:out value="${addressId}"/>");
			console.debug("mode= " + "<c:out value="${mode}"/>");
		});
	</script>
</c:if>

<c:if test="${!empty addressId && addressId != -1}" >
	
	<c:set var="person" value="${requestScope.person}"/>
	<c:if test="${empty person || person==null}">
		<wcf:rest var="person" url="store/{storeId}/person/@self" scope="request">
			<wcf:var name="storeId" value="${WCParam.storeId}" encode="true"/>
		</wcf:rest>
	</c:if>

	<c:set var="personAddresses" value="${person}"/>
	<c:set var="addressFieldsValid" value="true"/>
	<c:set var="shownAddress" value="false"/>
	<c:set var="contact" value="${person}"/>
	<c:if test="${contact.addressId eq addressId}" >
		<!--  BRAINTREE START -->	
		<c:if test="${populateAddressFlag eq 'true'}" >
			<script>selectedShippingContact = ${contact};</script>
		</c:if>
		<!--  BRAINTREE END -->
		<%@ include file="../../../Snippets/ReusableObjects/AddressDisplay.jspf"%>
		<c:set var="shownAddress" value="true"/>
		<c:choose>
			<c:when test="${!empty contact.addressLine[0] && contact.addressLine[0] != '-' && !empty contact.country && contact.country != '-'}" >
				<c:set var="addressFieldsValid" value="true"/>
			</c:when>
			<c:otherwise>
				<c:set var="addressFieldsValid" value="false"/>
			</c:otherwise>
		</c:choose>
	</c:if>
	<c:if test="${!shownAddress}" >
		<c:forEach items="${personAddresses.contact}" var="contact">
			<c:if test="${contact.addressId eq addressId}" >
				<!--  BRAINTREE START -->
				<c:if test="${populateAddressFlag eq 'true'}" >
					<script>selectedShippingContact = ${contact};</script>
				</c:if>
				<!--  BRAINTREE END -->
				<%@ include file="../../../Snippets/ReusableObjects/AddressDisplay.jspf"%>
				<c:set var="shownAddress" value="true"/>
				<c:choose>
					<c:when test="${!empty contact.addressLine[0] && contact.addressLine[0] != '-' && !empty contact.country && contact.country != '-'}" >
						<c:set var="addressFieldsValid" value="true"/>
					</c:when>
					<c:otherwise>
						<c:set var="addressFieldsValid" value="false"/>
					</c:otherwise>
				</c:choose>
			</c:if>
		</c:forEach>
	</c:if>
	
	<c:catch>
		<%-- Display the Organization Address from the contract --%>
		<c:set var="activeOrgId" value="${CommandContext.activeOrganizationId}"/>
		<c:if test="${!shownAddress}">
			<c:set var="organization" value="${requestScope.organization}"/>
			<c:if test="${empty organization || organization==null}">
				<wcf:rest var="organization" url="store/{storeId}/organization/{organizationId}">
					<wcf:var name="storeId" value="${WCParam.storeId}" encode="true"/>
					<wcf:var name="organizationId" value="${activeOrgId}" encode="true"/>
				</wcf:rest>
			</c:if>
			<c:set var="organizationAddresses" value="${organization.addressBook}"/>
			<c:set var ="contact" value="${organization.contactInfo}"/>
			<c:if test="${contact.addressId eq addressId}">
				<c:set var="setIsOrg" value="true"/>
				<%@ include file="../../../Snippets/ReusableObjects/AddressDisplay.jspf"%>	
				<c:set var ="shownAddress" value="true"/>
				<c:remove var="setIsOrg"/>
				<c:choose>
					<c:when test="${!empty contact.address1 && contact.address1 != '-' && !empty contact.country && contact.country != '-'}" >
						<c:set var="addressFieldsValid" value="true"/>
					</c:when>
					<c:otherwise>
						<c:set var="addressFieldsValid" value="false"/>
					</c:otherwise>
				</c:choose>
			</c:if>
			<c:if test="${!shownAddress}" >
				<c:forEach items="${organizationAddresses}" var="contact">
					<c:if test="${contact.addressId eq addressId}" >
						<c:set var="setIsOrg" value="true"/>
						<%@ include file="../../../Snippets/ReusableObjects/AddressDisplay.jspf"%>
						<c:set var="shownAddress" value="true"/>
						<c:remove var="setIsOrg"/>
						<c:choose>
							<c:when test="${!empty contact.address1 && contact.address1 != '-' && !empty contact.country && contact.country != '-'}" >
								<c:set var="addressFieldsValid" value="true"/>
							</c:when>
							<c:otherwise>
								<c:set var="addressFieldsValid" value="false"/>
							</c:otherwise>
						</c:choose>
					</c:if>
				</c:forEach>
			</c:if>
		</c:if>
	</c:catch>
	<c:if test="${param.fromPage == 'BillingInfo'}">
		<input type="hidden" name="billing_address_isValid" id="billing_address_isValid_<c:out value="${param.count}"/>" value="${addressFieldsValid}"/>
	</c:if>
</c:if>
<!-- END AddressDisplay.jsp -->
