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
<!-- Set the taglib -->
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://commerce.ibm.com/base" prefix="wcbase" %>
<%@ taglib uri="http://commerce.ibm.com/foundation" prefix="wcf" %>
<%@ taglib uri="flow.tld" prefix="flow" %>
<%@ include file="../../../Common/EnvironmentSetup.jspf" %>
<c:set var="paymentAreaNumber" value="${WCParam.currentPaymentArea}"/>
<c:if test="${empty paymentAreaNumber}">
	<c:set var="paymentAreaNumber" value="${param.paymentAreaNumber}" />
</c:if>
<c:set var="paymentTCId" value="${param.paymentTCId}"/>

<script type="text/javascript">
	$(document).ready(function() { 
		if('${param.PayPalEmailId}' == '') 
			BrainTreePayments.payPalVaultPayment('paypal-button_<c:out value='${param.paymentMethodCount}'/>','paypal-credit-button_<c:out value='${param.paymentMethodCount}'/>','<c:out value='${param.clientToken}'/>','<c:out value='${param.paymentMethodCount}'/>', '${param.grandTotal}', '${param.userType}','${param.isPayPalCreditEnable}','${param.useVaultForAuth}');
			
	});
</script>

	<%-- The section to collect the protocol data for this payment method --%>
	<input type="hidden" name="paymentTCId" value="<c:out value="${paymentTCId}"/>" id="WC_StandardCOD_inputs_1_<c:out value='${paymentAreaNumber}'/>"/>
	<input type="hidden" id="mandatoryFields_<c:out value='${paymentAreaNumber}'/>" name="mandatoryFields"  value="billing_address_id"/>
	<span class="col1">
		<div class="paypalCheckoutdiv" style="display:block;">
			<div id="paypal-button_<c:out value='${param.paymentMethodCount}'/>" style=" padding-left:25px;"></div>
				<c:if test="${param.isPayPalCreditEnable eq 'true'}">
					<div id="paypal-credit-button_<c:out value='${param.paymentMethodCount}'/>" style=" padding-left:25px;"></div>
				</c:if>
				<br>
				<c:if test="${param.showSavedPaymentsFlag eq 'true' && param.userType ne 'G' && param.paypalFlow eq 'vault' && empty param.PayPalEmailId }">
					<input type="checkbox" id="saveCardCheckBox" name="saveCard" value="saveCard" /><fmt:message bundle="${storeText}" key="SAVE_CARD"/><br><br>
				</c:if>
		</div>
		<%--
		***************************
		* Start: Show the remaining amount -- the amount not yet allocated to a payment method
		***************************
		--%>
	
		<%@ include file="PaymentAmount.jspf"%>
	</span>
	