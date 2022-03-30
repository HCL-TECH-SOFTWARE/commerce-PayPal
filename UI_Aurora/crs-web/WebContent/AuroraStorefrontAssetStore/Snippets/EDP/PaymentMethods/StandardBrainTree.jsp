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
		$(document).ready(function() 
			{ 
				BrainTreePayments.displayBraintreeFieldsForPayment('${param.clientToken}','${param.paymentMethodCount}');
			});
	</script>
	<%-- The section to collect the protocol data for this payment method --%>
	<input type="hidden" name="paymentTCId" value="<c:out value="${paymentTCId}"/>" id="WC_StandardCOD_inputs_1_<c:out value='${paymentAreaNumber}'/>"/>
	<input type="hidden" id="mandatoryFields_<c:out value='${paymentAreaNumber}'/>" name="mandatoryFields"  value="billing_address_id"/>
		<span class="col1">
		<div id="newCardDetailsFillingDiv" style=" margin-top: 10px; padding-left: 25px; ">
			<div id="hostedFieldsErrorMessage_<c:out value='1'/>" style="display:none; color:red;  font-size: 15px;"></div>
			<div class="hostedFieldsWrapper" id="hostedFieldsWrapper_<c:out value='1'/>" style="width: 300px; " >
				<label for="card-number"><fmt:message bundle="${storeText}" key="CARD_NUMBER"/></label><div id="card-number_<c:out value='1'/>" style="height: 25px;"></div>
				<label for="bt_cvv" style="margin-top:10px; word-wrap:normal;" ><fmt:message bundle="${storeText}" key="CVV"/></label><div id="cvv_<c:out value='1'/>" style="height: 25px; width: 50px;"></div>
				<label for="expiration-date" style="margin-top:10px;"><fmt:message bundle="${storeText}" key="EXPIRATION_DATE"/></label><div id="expiration-date_<c:out value='1'/>" style="height: 25px; width: 100px;"></div>
				<input type="hidden" id="saveCard" name="saveCard" value="true" />
				<br>
				<c:if test="${param.showSavedPaymentsFlag eq 'true' && param.userType ne 'G'}">
					<input type="checkbox" id="saveCardCheckBox" name="saveCard" value="saveCard" /><fmt:message bundle="${storeText}" key="SAVE_CARD"/><br><br>
				</c:if> 
			</div>
		</div>
		<%--
		***************************
		* Start: Show the remaining amount -- the amount not yet allocated to a payment method
		***************************
		--%>
	
		<%@ include file="PaymentAmount.jspf"%>
	</span>
	