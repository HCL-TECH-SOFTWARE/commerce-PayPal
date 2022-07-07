<%--
 =================================================================
  Licensed Materials - Property of HCL Technologies

  HCL Commerce

  (C) Copyright HCL Technologies Limited 1996, 2020

 =================================================================
--%>
<%-- 
  *****
  * This JSP file displays a combo box with the applicable billing addresses for the current shopper.
  *****
--%>
<!-- BEGIN BillingAddressDropDownDisplay.jsp -->
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://commerce.ibm.com/base" prefix="wcbase" %>
<%@ taglib uri="http://commerce.ibm.com/foundation" prefix="wcf" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib uri="flow.tld" prefix="flow" %>
<%@ include file="../../../Common/EnvironmentSetup.jspf" %>
<%@ include file="../CommonUtilities.jspf"%>

<script type="text/javascript">
	$(document).ready(function() { 
		ServicesDeclarationJS.setCommonParameters('<c:out value='${WCParam.langId}'/>','<c:out value='${WCParam.storeId}'/>','<c:out value='${WCParam.catalogId}'/>');
		CheckoutPayments.setCommonParameters('<c:out value='${WCParam.langId}'/>','<c:out value='${WCParam.storeId}'/>','<c:out value='${WCParam.catalogId}'/>');
		CheckoutPayments.paymentSpecificAddress = <c:out value='${env_contractSelection}'/>;
	});
</script>

<c:set var="currentOrderId" value="${order.orderId}"/>
<c:if test="${empty currentOrderId || currentOrderId == null}">
	<c:set var="currentOrderId" value="${WCParam.orderId}"/>
</c:if>
<!-- BRAINTREE START -->
<c:set var="setPaypalBillingAddress" value="false" />
<c:if test="${! empty param.paypalBillingAddress || param.paypalBillingAddress != null}">
	<c:set var="setPaypalBillingAddress" value="${param.paypalBillingAddress}" />
</c:if>
<!-- BRAINTREE END -->
<c:set var="usablePaymentInfo" value="${requestScope.usablePaymentInfo}"/>
<c:if test="${empty usablePaymentInfo || usablePaymentInfo == null}">
	<wcf:rest var="usablePaymentInfo" url="store/{storeId}/cart/@self/usable_payment_info" scope="request">
		<wcf:var name="storeId" value="${WCParam.storeId}" encode="true"/>
		<wcf:param name="orderId" value="${currentOrderId}"/>
	</wcf:rest>
</c:if>

<c:set var="paymentMethodSelected" value="${WCParam.payMethodId}"/>
<c:if test="${empty paymentMethodSelected}">
	<c:set var="paymentMethodSelected" value="${param.paymentMethodSelected}" />
</c:if>

<c:if test="${empty paymentMethodSelected}">
	<c:forEach var="paymentInfo" items="${usablePaymentInfo.usablePaymentInformation}">
		<c:if test="${empty paymentMethodSelected}">
			<c:if test="${!empty paymentInfo.paymentMethodName}">
				<c:set var="paymentMethodSelected" value="${paymentInfo.paymentMethodName}" />
			</c:if>
		</c:if>
	</c:forEach>
</c:if>

<c:set var="selectedAddressId" value="${param.selectedAddressId}"/>
<c:set var="hasValidAddresses" value="false"/>

<c:forEach var="payment" items="${usablePaymentInfo.usablePaymentInformation}">
	<c:if test="${fn:length(payment.usableBillingAddress) > 0 && !hasValidAddresses}">
		<c:set var="hasValidAddresses" value="true"/>
	</c:if>
</c:forEach>

<c:set var="search01" value="'"/>
<c:set var="replaceStr01" value="\\'"/>

<fmt:message bundle="${storeText}" var="profileshipping" key="QC_DEFAULT_SHIPPING" />
<fmt:message bundle="${storeText}" var="profilebilling"  key="QC_DEFAULT_BILLING" />
<div class="billing_address" id="WC_BillingAddressDropDownDisplay_div_<c:out value='${param.paymentAreaNumber}'/>">
	<p class="title">
	<c:if test="${hasValidAddresses}"><label for="billing_address_id_<c:out value='${param.paymentAreaNumber}'/>"></c:if>
	<fmt:message bundle="${storeText}" key="BILL_BILLING_ADDRESS_COLON" />
	<c:if test="${hasValidAddresses}"></label></c:if>
	</p>
		<c:choose>
			<c:when test="${hasValidAddresses}">
				<select class="drop_down_billing" name="billing_address_id" id="billing_address_id_<c:out value='${param.paymentAreaNumber}'/>" onchange="JavaScript:MessageHelper.hideAndClearMessage();CheckoutPayments.displayBillingAddressDetails(this,<c:out value='${param.paymentAreaNumber}'/>,'Billing'); CheckoutPayments.removeCreditCardNumberAndCVV(<c:out value='${param.paymentAreaNumber}'/>, true, true);CheckoutPayments.updatePaymentObject(<c:out value='${param.paymentAreaNumber}'/>, 'billing_address_id');">
					<%-- Loop through all the payment options available and test if this option is the selected one or not..If this 
					option is the selected one, then get the valid billing address for this payment option.. Billing address varies based on the payment method selected..--%>
					
					<c:forEach var="payment" items="${usablePaymentInfo.usablePaymentInformation}">
						<c:choose>
							<c:when test="${payment.paymentMethodName eq paymentMethodSelected}">
								<c:forEach var="addressInPayment" items="${payment.usableBillingAddress}">
									<c:if test="${empty selectedAddressId}" >
										<c:set var="selectedAddressId" value="${addressInPayment.addressId}"/>
									</c:if>
									<c:set var="hasValidAddresses" value="true"/>
									<!-- BRAINTREE START -->
									<c:if test="${addressInPayment.addressId == selectedAddressId && setPaypalBillingAddress eq 'false'}">
										<c:set var="selectStr" value='selected="selected"' />
									</c:if>
									
									<c:if test="${addressInPayment.nickName == 'PayPalBillingAddress' && setPaypalBillingAddress eq 'true'}">
										<c:set var="selectedAddressId" value="${addressInPayment.addressId}"/>
										<c:set var="selectStr" value='selected="selected"' />
									</c:if>
									<!-- BRAINTREE END -->
									<option <c:out value="${selectStr}" escapeXml='false'/> value="${addressInPayment.addressId}"><c:choose><c:when test="${addressInPayment.nickName eq  profileShippingNickname}"><fmt:message bundle="${storeText}" key="QC_DEFAULT_SHIPPING" /></c:when>
									<c:when test="${addressInPayment.nickName eq  profileBillingNickname}"><fmt:message bundle="${storeText}" key="QC_DEFAULT_BILLING" /></c:when><c:otherwise><c:out value="${addressInPayment.nickName}"/></c:otherwise></c:choose></option>
									
									<c:set var="selectStr" value="" />
								</c:forEach>
						 	</c:when>
						</c:choose>
					</c:forEach>
				</select>

			</c:when>
			<c:otherwise>
				<div id="addBillingAddressButton<c:out value="${param.paymentAreaNumber}_${usablePaymentInfo.orderId}"/>">
					<a class="tlignore" href="JavaScript:MessageHelper.hideAndClearMessage();CheckoutPayments.createBillingAddress(<c:out value="${param.paymentAreaNumber}"/>,'Billing');">
						<img src="<c:out value='${jspStoreImgDir}${env_vfileColor}'/>table_plus_add.png" alt="" />
						<fmt:message bundle="${storeText}" key="ADDR_CREATE_ADDRESS" />
					</a>
				</div>
			</c:otherwise>
		</c:choose>

		<!-- Area where selected billing Address details is showed in short.. Needed only in case of web2.0 -->
		<span class="spanacce" id="billingAddressDisplayArea_<c:out value="${param.paymentAreaNumber}"/>_ACCE_Label">
			<fmt:message bundle="${storeText}" key="ACCE_Region_Billing">
				<fmt:param><c:out value="${param.paymentAreaNumber}"/></fmt:param>
			</fmt:message>
		</span>
		
		<div wcType="RefreshArea" role="region" objectId="billingAddressDisplayArea_<c:out value="${param.paymentAreaNumber}"/>" aria-labelledby="billingAddressDisplayArea_<c:out value="${param.paymentAreaNumber}"/>_ACCE_Label" id="billingAddressDisplayArea_<c:out value="${param.paymentAreaNumber}"/>" widgetId="billingAddressDisplayArea_<c:out value="${param.paymentAreaNumber}"/>"
			declareFunction="declareBillingAddressDisplayAreaController('billingAddressDisplayArea_<c:out value='${param.paymentAreaNumber}'/>')" refreshurl="${AddressDisplayURL}" ariaMessage="<fmt:message bundle="${storeText}" key="ACCE_Status_Billing_Updated"/>" ariaLiveId="${ariaMessageNode}">
			<c:import url="${env_jspStoreDir}Snippets/Member/Address/AddressDisplay.jsp">
				<c:param name="addressId" value= "${selectedAddressId}"/>
				<c:param name="count" value="${param.paymentAreaNumber}"/> 
				<c:param name="fromPage" value="BillingInfo"/>
			</c:import>
		</div>

		<c:if test="${selectedAddressId != -1 && hasValidAddresses}" >		
			<br/>
			<div id="editBillingAddressLink_<c:out value='${param.paymentAreaNumber}'/>" class="editAddressLink hover_underline">
					<a class="tlignore" href="JavaScript:CheckoutPayments.saveBillingAddressDropDownBoxContextProperties('edit','<c:out value="${param.paymentAreaNumber}"/>');JavaScript:CheckoutHelperJS.editBillingAddress('-1','<c:out value="${param.paymentAreaNumber}"/>','<c:out value='${fn:replace(profileshipping,search01,replaceStr01)}'/>','<c:out value='${fn:replace(profilebilling,search01,replaceStr01)}'/>');CheckoutHelperJS.setLastAddressLinkIdToFocus('editBillingAddressLink_a_edit_<c:out value='${param.paymentAreaNumber}'/>');" id="editBillingAddressLink_a_edit_<c:out value='${param.paymentAreaNumber}'/>">
					<img src="<c:out value='${jspStoreImgDir}'/>images/edit_icon.png" alt="" />
					<fmt:message bundle="${storeText}" key="ADDR_EDIT_ADDRESS" />
					</a>
			</div>
			
		</c:if>
		
		<!--  create a new address  -->
		<c:set var="allowCreateAddress" value="true" />
		<c:if test="${env_contractSelection}">
			<wcf:rest var="usableBillingAddressListBean" url="store/{storeId}/cart/@self/usable_billing_address/{orderId}" scope="request">
				<wcf:var name="storeId" value="${WCParam.storeId}" encode="true"/>
				<wcf:var name="orderId" value="${currentOrderId}" encode="true"/>
				<wcf:param name="profileName" value="IBM_UsableBillingAddressList_isPersonalAddressAllowForBilling" />
			</wcf:rest>
			<c:set var="allowCreateAddress" value="${usableBillingAddressListBean.resultList[0].isPersonalAddressAllowForBilling}" />
		</c:if>
		<c:if test="${allowCreateAddress}">
			<div id="createNewBillingAddress_<c:out value='${param.paymentAreaNumber}'/>" class="newShippingAddressButton hover_underline">
					<a class="tlignore" href="JavaScript:MessageHelper.hideAndClearMessage();CheckoutPayments.createBillingAddress(<c:out value="${param.paymentAreaNumber}"/>,'Billing');CheckoutHelperJS.setLastAddressLinkIdToFocus('editBillingAddressLink_a_create_<c:out value='${param.paymentAreaNumber}'/>');" id="editBillingAddressLink_a_create_<c:out value='${param.paymentAreaNumber}'/>">
						<img src="<c:out value='${jspStoreImgDir}${env_vfileColor}'/>table_plus_add.png" alt="" />
						<fmt:message bundle="${storeText}" key="ADDR_CREATE_ADDRESS" />
					</a>
			</div>
		</c:if>
 </div>
<!-- END BillingAddressDropDownDisplay.jsp -->
