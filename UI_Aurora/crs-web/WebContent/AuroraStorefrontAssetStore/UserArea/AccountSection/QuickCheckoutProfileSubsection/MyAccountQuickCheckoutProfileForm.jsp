<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://commerce.ibm.com/base" prefix="wcbase" %>
<%@ taglib uri="flow.tld" prefix="flow" %>
<%@ include file="../../../Common/EnvironmentSetup.jspf" %>
<%@ include file="../../../Common/nocache.jspf" %>
<%@ taglib uri="http://commerce.ibm.com/foundation" prefix="wcf" %>
<%@ taglib uri="http://commerce.ibm.com/coremetrics"  prefix="cm" %>
<%@ include file="../../../include/ErrorMessageSetup.jspf" %>
<c:set var="myAccountPage" value="true" scope="request"/>
<c:set var="hasBreadCrumbTrail" value="false" scope="request"/>
<c:set var="pageCategory" value="MyAccount" scope="request"/>

<c:set var="usablePaymentInfo" value="${requestScope.usablePaymentInfo}"/>
<c:if test="${empty usablePaymentInfo || usablePaymentInfo == null}">
	<wcf:rest var="usablePaymentInfo" url="store/{storeId}/cart/@self/usable_payment_info">
		<wcf:var name="storeId" value="${WCParam.storeId}" encode="true"/>
		<wcf:param name="orderId" value="${WCParam.orderId}"/>
	</wcf:rest>
</c:if>	
<wcf:rest var="order" url="store/{storeId}/cart/@self">
	<wcf:var name="storeId" value="${WCParam.storeId}" encode="true"/>
	<wcf:param name="langId" value="${langId}" />
</wcf:rest>

<c:catch var="error">
	<wcf:rest var="paymentPolicyListDataBean" url="store/{storeId}/cart/@self/payment_policy_list" scope="page">
		<wcf:var name="storeId" value="${WCParam.storeId}" encode="true"/>
	</wcf:rest>
</c:catch>

<c:set var="paymentSectionStyle" value="style='visibility:hidden' class='my_account_payment_hidden'"/>
<c:forEach items="${paymentPolicyListDataBean.resultList[0].paymentPolicyInfoUsableWithoutTA}" var="paymentPolicyInfo" varStatus="status">
	<c:if test="${ !empty paymentPolicyInfo.attrPageName }" >
		<c:if test="${paymentPolicyInfo.attrPageName == 'StandardVisa' || paymentPolicyInfo.attrPageName == 'StandardMasterCard' || paymentPolicyInfo.attrPageName == 'StandardAmex'}">
			<c:set var="paymentSectionStyle" value="style='visibility:visible' class='my_account_payment_visible'" />
		</c:if>
	</c:if>
</c:forEach>

<wcf:rest var="orderListBean" url="store/{storeId}/order" scope="request">
	<wcf:var name="storeId" value="${WCParam.storeId}" encode="true"/>
	<wcf:param name="q" value="orderProfile"/>
	<wcf:param name="userId" value="${CommandContext.userId}"/>
	<wcf:param name="retrievalOrderStatus" value="Q"/>
</wcf:rest>

<c:choose>
<c:when test="${empty errorMessage}">
	<c:forEach items="${orderListBean.resultList}" var="orderBean" varStatus="status">
		<c:if test="${!empty orderBean.paymentInfo}">
			<c:set var="payment_method" value="${orderBean.paymentInfo.payment_method}"/>
			<c:set var="account" value="${orderBean.paymentInfo.account}"/>
			<c:set var="cc_brand" value="${orderBean.paymentInfo.cc_brand}"/>
			<c:set var="card_brand" value="${orderBean.paymentInfo.card_brand}"/>
			<c:set var="expire_year" value="${orderBean.paymentInfo.expire_year}"/>
			<c:set var="expire_month" value="${orderBean.paymentInfo.expire_month}"/>
			<c:set var="cc_cvc" value="${orderBean.paymentInfo.cc_cvc}"/>
			<c:set var="payment_token" value="${orderBean.paymentInfo.payment_token}"/>
			<c:set var="display_value" value="${orderBean.paymentInfo.display_value}"/>
			<c:if test="${empty account && !empty display_value}">
				<c:set var="account" value="${display_value}"/>
			</c:if>
		</c:if>

		<c:if test="${!empty orderBean.currentAddressDataBean}">
			<c:set var="billingTemp_addressId" value="${orderBean.currentAddressDataBean.addressId}"/>
			<c:set var="billingTemp_nickName" value="${orderBean.currentAddressDataBean.nickName}"/>
			<c:set var="billingTemp_addressType" value="${orderBean.currentAddressDataBean.addressType}"/>
			<c:set var="billingTemp_primary" value="${orderBean.currentAddressDataBean.primary}"/>
			<c:set var="billingTemp_lastName" value="${orderBean.currentAddressDataBean.lastName}"/>
			<c:set var="billingTemp_middleName" value="${orderBean.currentAddressDataBean.middleName}"/>
			<c:set var="billingTemp_firstName" value="${orderBean.currentAddressDataBean.firstName}"/>
			<c:set var="billingTemp_address1" value="${orderBean.currentAddressDataBean.address1}"/>
			<c:set var="billingTemp_address2" value="${orderBean.currentAddressDataBean.address2}"/>
			<c:set var="billingTemp_city" value="${orderBean.currentAddressDataBean.city}"/>
			<c:set var="billingTemp_state" value="${orderBean.currentAddressDataBean.state}"/>
			<c:set var="billingTemp_zipCode" value="${orderBean.currentAddressDataBean.zipCode}"/>
			<c:set var="billingTemp_country" value="${orderBean.currentAddressDataBean.country}"/>
			<c:set var="billingTemp_phone1" value="${orderBean.currentAddressDataBean.phone1}"/>
			<c:set var="billingTemp_email1" value="${orderBean.currentAddressDataBean.email1}"/>
		</c:if>

		<c:forEach items="${orderBean.uniqueShippingAddresses}" var="orderItemBean" varStatus="status">
			<c:set var="profileOrderItemBean" value="${orderItemBean}"  scope="request"/>
			<c:set var="shippingAddressBean" value="${orderItemBean}"  scope="request"/>
			<c:if test="${!empty orderItemBean}">
				<c:set var="shippingTemp_addressId" value="${orderItemBean.addressId}"/>
				<c:set var="shippingTemp_nickName" value="${orderItemBean.nickName}"/>
				<c:set var="shippingTemp_addressType" value="${orderItemBean.addressType}"/>
				<c:set var="shippingTemp_primary" value="${orderItemBean.primary}"/>
				<c:set var="shippingTemp_lastName" value="${orderItemBean.lastName}"/>
				<c:set var="shippingTemp_middleName" value="${orderItemBean.middleName}"/>
				<c:set var="shippingTemp_firstName" value="${orderItemBean.firstName}"/>
				<c:set var="shippingTemp_address1" value="${orderItemBean.address1}"/>
				<c:set var="shippingTemp_address2" value="${orderItemBean.address2}"/>
				<c:set var="shippingTemp_city" value="${orderItemBean.city}"/>
				<c:set var="shippingTemp_state" value="${orderItemBean.state}"/>
				<c:set var="shippingTemp_zipCode" value="${orderItemBean.zipCode}"/>
				<c:set var="shippingTemp_country" value="${orderItemBean.country}"/>
				<c:set var="shippingTemp_phone1" value="${orderItemBean.phone1}"/>
				<c:set var="shippingTemp_email1" value="${orderItemBean.email1}"/>
			</c:if>
		</c:forEach>
		<c:set var="shippingModeInfo" value="${orderBean.orderItemDataBeans[0]}"/>
	</c:forEach>
	<c:if test="${empty account && !empty payment_token && !empty payment_method}">
	    <wcf:rest var="tokenData" url="store/{storeId}/cart/@self/payment_instruction/payment_token">
			<wcf:var name="storeId" value="${WCParam.storeId}" encode="true" />
			<wcf:param name="payment_token" value="${payment_token}" />
			<wcf:param name="payment_method" value="${payment_method}" />								
		</wcf:rest>						
		<wcf:rest var="edpMaskBean" url="store/{storeId}/cart/@self/payment_instruction/sensitive_data_mask_by_plain_string">
			<wcf:var name="storeId" value="${WCParam.storeId}" encode="true"/>
			<wcf:param name="plainString" value="${tokenData.payment_token_data.display_value}"/>
		</wcf:rest>
		<c:set var="account" value="${edpMaskBean.resultList[0].maskedString}" />
	</c:if>
</c:when>

<c:otherwise>
	<c:set var="payment_method" value="${WCParam.pay_payment_method}"/>
	<c:set var="account" value="${WCParam.pay_temp_account}"/>
	<c:set var="cc_brand" value="${WCParam.pay_cc_brand}"/>
	<c:set var="card_brand" value="${WCParam.pay_card_brand}"/>
	<c:set var="expire_year" value="${WCParam.pay_expire_year}"/>
	<c:set var="expire_month" value="${WCParam.pay_expire_month}"/>
	<c:set var="cc_cvc" value="${WCParam.pay_cc_cvc}"/>
	<c:set var="billingTemp_addressId" value="${WCParam.billing_addressId1}"/>
	<c:set var="billingTemp_lastName" value="${WCParam.billing_lastName}"/>
	<c:set var="billingTemp_middleName" value="${WCParam.billing_middleName}"/>
	<c:set var="billingTemp_firstName" value="${WCParam.billing_firstName}"/>
	<c:set var="billingTemp_address1" value="${WCParam.billing_address1}"/>
	<c:set var="billingTemp_address2" value="${WCParam.billing_address2}"/>
	<c:set var="billingTemp_city" value="${WCParam.billing_city}"/>
	<c:set var="billingTemp_state" value="${WCParam.billing_state}"/>
	<c:set var="billingTemp_zipCode" value="${WCParam.billing_zipCode}"/>
	<c:set var="billingTemp_country" value="${WCParam.billing_country}"/>
	<c:set var="billingTemp_phone1" value="${WCParam.billing_phone1}"/>
	<c:set var="billingTemp_email1" value="${WCParam.billing_email1}"/>

	<c:set var="shippingTemp_addressId" value="${WCParam.shipping_addressId}"/>
	<c:set var="shippingTemp_lastName" value="${WCParam.shipping_lastName}"/>
	<c:set var="shippingTemp_middleName" value="${WCParam.shipping_middleName}"/>
	<c:set var="shippingTemp_firstName" value="${WCParam.shipping_firstName}"/>
	<c:set var="shippingTemp_address1" value="${WCParam.shipping_address1}"/>
	<c:set var="shippingTemp_address2" value="${WCParam.shipping_address2}"/>
	<c:set var="shippingTemp_city" value="${WCParam.shipping_city}"/>
	<c:set var="shippingTemp_state" value="${WCParam.shipping_state}"/>
	<c:set var="shippingTemp_zipCode" value="${WCParam.shipping_zipCode}"/>
	<c:set var="shippingTemp_country" value="${WCParam.shipping_country}"/>
	<c:set var="shippingTemp_phone1" value="${WCParam.shipping_phone1}"/>
	<c:set var="shippingTemp_email1" value="${WCParam.shipping_email1}"/>
</c:otherwise>
</c:choose>
<wcf:url var="quickCheckOutActionUrl" value="RESTPersonChangeServiceCheckoutProfileUpdate" />
<fmt:message bundle="${storeText}" key="MA_QUICK_CHECKOUT" var="contentPageName" scope="request"/>

<!DOCTYPE HTML>

<%--
 =================================================================
  Licensed Materials - Property of HCL Technologies

  HCL Commerce

  (C) Copyright HCL Technologies Limited 1996, 2020

 =================================================================
--%>
<!-- BEGIN MyAccountQuickCheckoutProfileForm.jsp -->
<html xmlns="http://www.w3.org/1999/xhtml" lang="${shortLocale}" xml:lang="${shortLocale}">
<head>
	<%@ include file="../../../Common/CommonCSSToInclude.jspf"%>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<title><fmt:message bundle="${storeText}" key="MA_QUICK_CHECKOUT"/></title>
	<%@ include file="../../../Common/CommonJSToInclude.jspf"%>
	<%@ include file="../../../Common/CommonJSPFToInclude.jspf"%>

	<script type="text/javascript">
		$(document).ready(function() { 
			<fmt:message bundle="${storeText}" key="ERROR_RecipientTooLong" var="ERROR_RecipientTooLong"/>
			<fmt:message bundle="${storeText}" key="ERROR_FirstNameTooLong" var="ERROR_FirstNameTooLong"/>
			<fmt:message bundle="${storeText}" key="ERROR_LastNameTooLong" var="ERROR_LastNameTooLong"/>
			<fmt:message bundle="${storeText}" key="ERROR_MiddleNameTooLong" var="ERROR_MiddleNameTooLong"/>
			<fmt:message bundle="${storeText}" key="ERROR_AddressTooLong" var="ERROR_AddressTooLong"/>
			<fmt:message bundle="${storeText}" key="ERROR_CityTooLong" var="ERROR_CityTooLong"/>
			<fmt:message bundle="${storeText}" key="ERROR_StateTooLong" var="ERROR_StateTooLong"/>
			<fmt:message bundle="${storeText}" key="ERROR_CountryTooLong" var="ERROR_CountryTooLong"/>
			<fmt:message bundle="${storeText}" key="ERROR_ZipCodeTooLong" var="ERROR_ZipCodeTooLong"/>
			<fmt:message bundle="${storeText}" key="ERROR_PhoneTooLong" var="ERROR_PhoneTooLong"/>
			<fmt:message bundle="${storeText}" key="ERROR_RecipientEmpty" var="ERROR_RecipientEmpty"/>
			<fmt:message bundle="${storeText}" key="ERROR_FirstNameEmpty" var="ERROR_FirstNameEmpty"/>
			<fmt:message bundle="${storeText}" key="ERROR_LastNameEmpty" var="ERROR_LastNameEmpty"/>
			<fmt:message bundle="${storeText}" key="ERROR_MiddleNameEmpty" var="ERROR_MiddleNameEmpty"/>
			<fmt:message bundle="${storeText}" key="ERROR_AddressEmpty" var="ERROR_AddressEmpty"/>
			<fmt:message bundle="${storeText}" key="ERROR_CityEmpty" var="ERROR_CityEmpty"/>
			<fmt:message bundle="${storeText}" key="ERROR_StateEmpty" var="ERROR_StateEmpty"/>
			<fmt:message bundle="${storeText}" key="ERROR_CountryEmpty" var="ERROR_CountryEmpty"/>
			<fmt:message bundle="${storeText}" key="ERROR_ZipCodeEmpty" var="ERROR_ZipCodeEmpty"/>
			<fmt:message bundle="${storeText}" key="ERROR_PhonenumberEmpty" var="ERROR_PhonenumberEmpty"/>
			<fmt:message bundle="${storeText}" key="ERROR_EmailEmpty" var="ERROR_EmailEmpty"/>
			<fmt:message bundle="${storeText}" key="PWDREENTER_DO_NOT_MATCH" var="PWDREENTER_DO_NOT_MATCH"/>
			<fmt:message bundle="${storeText}" key="REQUIRED_FIELD_ENTER" var="REQUIRED_FIELD_ENTER"/>
			<fmt:message bundle="${storeText}" key="ERROR_INVALIDPHONE" var="ERROR_INVALIDPHONE"/>
			<fmt:message bundle="${storeText}" key="INVALID_EXPIRY_DATE" var="INVALID_EXPIRY_DATE"/>
			<fmt:message bundle="${storeText}" key="AB_SELECT_ADDRTYPE" var="AB_SELECT_ADDRTYPE"/>
			<fmt:message bundle="${storeText}" key="ERROR_DEFAULTADDRESS" var="ERROR_DEFAULTADDRESS"/>
			<fmt:message bundle="${storeText}" key="ERROR_INVALIDEMAILFORMAT" var="ERROR_INVALIDEMAILFORMAT"/>
			<fmt:message bundle="${storeText}" key="ERROR_MESSAGE_TYPE" var="ERROR_MESSAGE_TYPE"/>


			MessageHelper.setMessage("REQUIRED_FIELD_ENTER", <wcf:json object="${REQUIRED_FIELD_ENTER}"/>);
			MessageHelper.setMessage("INVALID_EXPIRY_DATE", <wcf:json object="${INVALID_EXPIRY_DATE}"/>);
			MessageHelper.setMessage("ERROR_RecipientTooLong", <wcf:json object="${ERROR_RecipientTooLong}"/>);
			MessageHelper.setMessage("ERROR_FirstNameTooLong", <wcf:json object="${ERROR_FirstNameTooLong}"/>);
			MessageHelper.setMessage("ERROR_LastNameTooLong", <wcf:json object="${ERROR_LastNameTooLong}"/>);
			MessageHelper.setMessage("ERROR_MiddleNameTooLong", <wcf:json object="${ERROR_MiddleNameTooLong}"/>);
			MessageHelper.setMessage("ERROR_AddressTooLong", <wcf:json object="${ERROR_AddressTooLong}"/>);
			MessageHelper.setMessage("ERROR_CityTooLong", <wcf:json object="${ERROR_CityTooLong}"/>);
			MessageHelper.setMessage("ERROR_StateTooLong", <wcf:json object="${ERROR_StateTooLong}"/>);
			MessageHelper.setMessage("ERROR_CountryTooLong", <wcf:json object="${ERROR_CountryTooLong}"/>);
			MessageHelper.setMessage("ERROR_ZipCodeTooLong", <wcf:json object="${ERROR_ZipCodeTooLong}"/>);
			MessageHelper.setMessage("ERROR_PhoneTooLong", <wcf:json object="${ERROR_PhoneTooLong}"/>);
			MessageHelper.setMessage("ERROR_RecipientEmpty", <wcf:json object="${ERROR_RecipientEmpty}"/>);
			/*Although for English, firstname is not mandatory. But it is mandatory for other languages.*/
			MessageHelper.setMessage("ERROR_FirstNameEmpty", <wcf:json object="${ERROR_FirstNameEmpty}"/>);
			MessageHelper.setMessage("ERROR_LastNameEmpty", <wcf:json object="${ERROR_LastNameEmpty}"/>);
			MessageHelper.setMessage("ERROR_MiddleNameEmpty", <wcf:json object="${ERROR_MiddleNameEmpty}"/>);
			MessageHelper.setMessage("ERROR_AddressEmpty", <wcf:json object="${ERROR_AddressEmpty}"/>);
			MessageHelper.setMessage("ERROR_CityEmpty", <wcf:json object="${ERROR_CityEmpty}"/>);
			MessageHelper.setMessage("ERROR_StateEmpty", <wcf:json object="${ERROR_StateEmpty}"/>);
			MessageHelper.setMessage("ERROR_CountryEmpty", <wcf:json object="${ERROR_CountryEmpty}"/>);
			MessageHelper.setMessage("ERROR_ZipCodeEmpty", <wcf:json object="${ERROR_ZipCodeEmpty}"/>);
			MessageHelper.setMessage("ERROR_PhonenumberEmpty", <wcf:json object="${ERROR_PhonenumberEmpty}"/>);
			MessageHelper.setMessage("ERROR_EmailEmpty", <wcf:json object="${ERROR_EmailEmpty}"/>);
			MessageHelper.setMessage("ERROR_INVALIDPHONE", <wcf:json object="${ERROR_INVALIDPHONE}"/>);
			MessageHelper.setMessage("ERROR_DEFAULTADDRESS", <wcf:json object="${ERROR_DEFAULTADDRESS}"/>);
			MessageHelper.setMessage("ERROR_SELECTADDRESS", <wcf:json object="${ERROR_SELECTADDRESS}"/>);
			MessageHelper.setMessage("ERROR_INVALIDEMAILFORMAT", <wcf:json object="${ERROR_INVALIDEMAILFORMAT}"/>);
			MessageHelper.setMessage("ERROR_MESSAGE_TYPE", <wcf:json object="${ERROR_MESSAGE_TYPE}"/>);
		});
	</script>
</head>
<body>

<%@ include file="../../../Snippets/Member/Address/AddressHelperCountrySelection.jspf" %>
<!-- Page Start -->
<div id="page">
	<!-- Import Header Widget -->
	<div class="header_wrapper_position" id="headerWidget">
		<%out.flush();%>
		<c:import url = "${env_jspStoreDir}/Widgets/Header/Header.jsp" />
		<%out.flush();%>
	</div>
	<!-- Header Nav End -->
	
	<!-- Main Content Start -->
	<div id="contentWrapper">
		<div id="content" role="main">		
			<div class="row margin-true">
				<div class="col12">				
					<%out.flush();%>
						<wcpgl:widgetImport useIBMContextInSeparatedEnv="${isStoreServer}" url="${env_siteWidgetsDir}com.ibm.commerce.store.widgets.BreadcrumbTrail/BreadcrumbTrail.jsp">  														
							<wcpgl:param name="pageGroup" value="Content"/>
						</wcpgl:widgetImport>
					<%out.flush();%>					
				</div>
			</div>
			<div class="rowContainer" id="container_MyAccountDisplayB2B">
				<div class="row margin-true">					
					<div class="col4 acol12 ccol3">
						<%out.flush();%>
							<wcpgl:widgetImport useIBMContextInSeparatedEnv="${isStoreServer}" url="${env_siteWidgetsDir}com.ibm.commerce.store.widgets.MyAccountNavigation/MyAccountNavigation.jsp"/>
						<%out.flush();%>		
					</div>
					<div class="col8 acol12 ccol9 right">							
						<!-- Content Start -->
						<div id="box" class="myAccountMarginRight">
							<div class="my_account" id="WC_MyAccountQuickCheckoutProfileForm_div_2">
								<h2 class="myaccount_header bottom_line"><fmt:message bundle="${storeText}" key="MA_QUICK_CHECKOUT"/></h2>
								<div class="contentline" id="WC_MyAccountQuickCheckoutProfileForm_div_7"></div>
								<div class="body" id="WC_MyAccountQuickCheckoutProfileForm_div_11">

									<form name="QuickCheckout" method="post" action="${quickCheckOutActionUrl}" id="QuickCheckout">
										<input type="hidden" name="storeId" value="<c:out value="${WCParam.storeId}"/>" id="WC_QuickCheckoutProfileForm_FormInput_storeId_In_QuickCheckout_1"/>
										<input type="hidden" name="langId" value="<c:out value="${WCParam.langId}"/>" id="WC_QuickCheckoutProfileForm_FormInput_langId_In_QuickCheckout_1"/>
										<input type="hidden" name="catalogId" value="<c:out value="${WCParam.catalogId}"/>" id="WC_QuickCheckoutProfileForm_FormInput_catalogId_In_QuickCheckout_1"/>
										<input type="hidden" name="page" value="quickcheckout" id="WC_QuickCheckoutProfileForm_FormInput_page_In_QuickCheckout_1"/>
										<input type="hidden" name="returnPage" value="<c:out value="${returnPage}"/>" id="WC_QuickCheckoutProfileForm_FormInput_returnPage_In_QuickCheckout_1"/>
										<input type="hidden" name="orderId" value="<c:out value="${WCParam.orderId}"/>" id="WC_QuickCheckoutProfileForm_FormInput_orderId_In_QuickCheckout_1"/>
										<input type="hidden" name="valueFromProfileOrder" value="Y" id="WC_MyAccountQuickCheckoutProfileForm_inputs_1"/>
										<input type="hidden" name="URL" value="AjaxLogonForm" id="WC_MyAccountQuickCheckoutProfileForm_inputs_2"/>
										<input type="hidden" name="errorViewName" value="ProfileFormView" id="WC_MyAccountQuickCheckoutProfileForm_inputs_8"/>
										<input type="hidden" name="myAcctMain" value="1" id="WC_MyAccountQuickCheckoutProfileForm_inputs_9"/>
										<input type="hidden" name="shipping_addressType" value="Shipping" id="WC_MyAccountQuickCheckoutProfileForm_inputs_3"/>
										<input type="hidden" name="billing_addressType" value="Billing" id="WC_MyAccountQuickCheckoutProfileForm_inputs_4"/>
										<input type="hidden" name="shipping_nickName" value="<c:out value="${'Default_Shipping_'}${WCParam.storeId}"/>" id="WC_QuickCheckoutProfileForm_FormInput_shipping_nickName_In_QuickCheckout_2"/>
										<input type="hidden" name="billing_nickName" value="<c:out value="${'Default_Billing_'}${WCParam.storeId}"/>" id="WC_QuickCheckoutProfileForm_FormInput_billing_nickName_In_QuickCheckout_2"/>
										<input type="hidden" name="pay_payment_method" value="" id="WC_MyAccountQuickCheckoutProfileForm_inputs_5"/>
										<input type="hidden" name="pay_payMethodId" value="" id="WC_MyAccountQuickCheckoutProfileForm_inputs_6"/>
										<input type="hidden" name="pay_cc_brand" value="" id="WC_MyAccountQuickCheckoutProfileForm_inputs_7"/>
										<input type="hidden" name="authToken" value="${authToken}" id="WC_MyAccountQuickCheckoutProfileForm_inputs_authToken_1"/>

										<div class="headingtext" id="WC_MyAccountQuickCheckoutProfileForm_div_12">
											<c:if test="${!empty errorMessage}">
												<script type="text/javascript">$(document).ready(function() { MessageHelper.displayErrorMessage("<c:out value='${errorMessage}'/>"); });</script>
											</c:if>
										</div>

										<div class="shipping_billing_content" id="normal">
											<div id="my_account_billing" role="region" aria-labelledby="my_account_billing_acce_label">
												<h1 id="my_account_billing_acce_label" class="my_account_content_bold"><fmt:message bundle="${storeText}" key="QC_BILLINGADDR"/></h1>
												<div id="WC_MyAccountQuickCheckoutProfileForm_div_13">
													<span class="required-field"  id="WC_MyAccountQuickCheckoutProfileForm_div_14"> *</span><fmt:message bundle="${storeText}" key="REQUIRED_FIELDS"/>
												</div>
												<br/>


												<div id="WC_MyAccountQuickCheckoutProfileForm_div_22">
													<script type="text/javascript">
														$(document).ready(function() { 
															billingProfile = new Object();
															billingProfile.firstName = "<c:out value="${billingTemp_firstName}"/>";
															billingProfile.lastName = "<c:out value="${billingTemp_lastName}"/>";
															billingProfile.middleName = "<c:out value="${billingTemp_middleName}"/>";
															billingProfile.address1 = "<c:out value="${billingTemp_address1}"/>";
															billingProfile.address2 = "<c:out value="${billingTemp_address2}"/>";
															billingProfile.city = "<c:out value="${billingTemp_city}"/>";
															billingProfile.state = "<c:out value="${billingTemp_state}"/>";
															billingProfile.country = "<c:out value="${billingTemp_country}"/>";
															billingProfile.zipCode = "<c:out value="${billingTemp_zipCode}"/>";
															billingProfile.email1 = "<c:out value="${billingTemp_email1}"/>";
															billingProfile.phone1 = "<c:out value="${billingTemp_phone1}"/>";
															
															shippingProfile = new Object();
															shippingProfile.firstName = "<c:out value="${shippingTemp_firstName}"/>";
															shippingProfile.lastName = "<c:out value="${shippingTemp_lastName}"/>";
															shippingProfile.middleName = "<c:out value="${shippingTemp_middleName}"/>";
															shippingProfile.address1 = "<c:out value="${shippingTemp_address1}"/>";
															shippingProfile.address2 = "<c:out value="${shippingTemp_address2}"/>";
															shippingProfile.city = "<c:out value="${shippingTemp_city}"/>";
															shippingProfile.state = "<c:out value="${shippingTemp_state}"/>";
															shippingProfile.country = "<c:out value="${shippingTemp_country}"/>";
															shippingProfile.zipCode = "<c:out value="${shippingTemp_zipCode}"/>";
															shippingProfile.email1 = "<c:out value="${shippingTemp_email1}"/>";
															shippingProfile.phone1 = "<c:out value="${shippingTemp_phone1}"/>";
															
															
														});
													</script>
												</div>

												<wcpgl:widgetImport useIBMContextInSeparatedEnv="${isStoreServer}" url="${env_siteWidgetsDir}com.ibm.commerce.store.widgets.AddressForm/AddressForm.jsp">
													<wcpgl:param name="addressId" value="${billingTemp_addressId}" />
													<wcpgl:param name="nickName" value="${billingTemp_nickName}" />
													<wcpgl:param name="addressType" value="${billingTemp_addressType}" />
													<wcpgl:param name="firstName" value="${billingTemp_firstName}"/>
													<wcpgl:param name="lastName" value="${billingTemp_lastName}"/>
													<wcpgl:param name="middleName" value="${billingTemp_middleName}"/>
													<wcpgl:param name="address1" value="${billingTemp_address1}"/>
													<wcpgl:param name="address2" value="${billingTemp_address2}"/>
													<wcpgl:param name="city" value="${billingTemp_city}"/>
													<wcpgl:param name="state" value="${billingTemp_state}"/>
													<wcpgl:param name="countryReg" value="${billingTemp_country}"/>
													<wcpgl:param name="zipCode" value="${billingTemp_zipCode}"/>
													<wcpgl:param name="phone" value="${billingTemp_phone1}"/>
													<wcpgl:param name="email1" value="${billingTemp_email1}"/>
													<wcpgl:param name="prefix" value="billing_" />
													<wcpgl:param name="pageName" value="QuickCheckoutAddressForm" />
													<wcpgl:param name="formName" value="document.QuickCheckout.name"/>
												</wcpgl:widgetImport>
												
												<script type="text/javascript">
													$(document).ready(function() {  											
														javascript:QuickCheckoutProfile.getCurrentProfile(billingProfile, 'billing');
													});
												</script>
												<br clear="all"/>
											<!-- BRAINTREE START -->
											<!-- hide payment Section  -->
											<!-- <div id="WC_MyAccountQuickCheckoutProfileForm_PI_div" ${paymentSectionStyle} >

													<h1 class="strong quick_checkout_profile_padding"><fmt:message bundle="${storeText}" key="PAYMENT_NUMBER_OF_METHODS"/></h1>
													<div class="label_spacer" id="WC_MyAccountQuickCheckoutProfileForm_div_23">
														<span class="required-field"  id="WC_MyAccountQuickCheckoutProfileForm_div_24"> *</span><label for="payMethodId">
															<fmt:message bundle="${storeText}" key="QC_TYPE"/>
														</label>
													</div>
													<c:set var="displayMethod" value="display:block" />

													<div id="paymentSection1" style="<c:out value="${displayMethod}"/>">
														<input type="hidden" name="langId" value="<c:out value="${WCParam.langId}"/>" id="WC_MyAccountQuickCheckoutProfileForm_inputs_8a"/>
														<jsp:useBean id="now1" class="java.util.Date"/>
														<input type="hidden" name="curr_year" value="<c:out value='${now1.year + 1900}'/>" id="WC_MyAccountQuickCheckoutProfileForm_inputs_9a"/>
														<input type="hidden" name="curr_month" value="<c:out value='${now1.month + 1}'/>" id="WC_MyAccountQuickCheckoutProfileForm_inputs_10"/>
														<input type="hidden" name="curr_date" value="<c:out value='${now1.date}'/>" id="WC_MyAccountQuickCheckoutProfileForm_inputs_11"/>
														<div id="WC_MyAccountQuickCheckoutProfileForm_div_25">
 															<select class="inputField" data-widget-type="wc.Select" aria-required="true" name="payMethodId" id="payMethodId" >
																<c:forEach items="${paymentPolicyListDataBean.resultList[0].paymentPolicyInfoUsableWithoutTA}" var="paymentPolicyInfo" varStatus="status">
															<c:set var="edp_SelectedValue" value="${payMethodId[0]}" scope="request" /> 
															<c:if test="${ !empty paymentPolicyInfo.attrPageName }" >
																<c:if test="${paymentPolicyInfo.attrPageName == 'StandardVisa' || paymentPolicyInfo.attrPageName == 'StandardMasterCard' || paymentPolicyInfo.attrPageName == 'StandardAmex'}">
																	<option <c:if test="${payment_method == paymentPolicyInfo.policyName}" > selected="selected" </c:if> value="<c:out value="${paymentPolicyInfo.policyName}" />"> <c:out value="${paymentPolicyInfo.shortDescription}" /></option>
																	
																	<c:if test="${paymentPolicyInfo.policyName == edp_SelectedValue }" >
																		<c:set var ="edp_AttrPageName" value="${paymentPolicyInfo.attrPageName}" />
																	</c:if>

																</c:if>
															</c:if>
														
																</c:forEach>
															</select>
														</div>
													</div>

													<c:if test="${empty expire_month}">
														<c:set var="expire_month" value="${now1.month + 1}"/>
													</c:if>
													<c:if test="${empty expire_year}">
														<c:set var="expire_year" value="${now1.year + 1900}"/>
													</c:if>

													<div class="label_spacer" id="WC_MyAccountQuickCheckoutProfileForm_div_26"><span class="required-field"  id="WC_MyAccountQuickCheckoutProfileForm_div_27"> *</span><label for="pay_temp_account"><fmt:message bundle="${storeText}" key="CARD_NUMBER"/></label></div>
													<div id="WC_MyAccountQuickCheckoutProfileForm_div_28">
							 						    <wcf:rest var="edpMaskBean" url="store/{storeId}/cart/@self/payment_instruction/sensitive_data_mask_by_plain_string">
															<wcf:var name="storeId" value="${WCParam.storeId}" encode="true"/>
															<wcf:param name="plainString" value="${account}"/>
														</wcf:rest>


														<c:choose>
															<c:when test="${!empty errorMessage}">
																<input class="inputField" aria-required="true" name="pay_temp_account" type="tel" class="form_input" size="35" value="" id="pay_temp_account" onChange="javascript:QuickCheckoutProfile.valueChanged('true');"/>
															</c:when>
															<c:otherwise>
																<input class="inputField" aria-required="true" name="pay_temp_account" type="tel" class="form_input" size="35" value="<c:out value='${edpMaskBean.resultList[0].maskedString}'/>" id="pay_temp_account" onChange="javascript:QuickCheckoutProfile.valueChanged('true');"/>
															</c:otherwise>
														</c:choose>
													</div>
													<div id="expiry_yearmonth">
														<div class="quick_drop" id="WC_MyAccountQuickCheckoutProfileForm_div_29">
															<div class="label_spacer" id="WC_MyAccountQuickCheckoutProfileForm_div_30">
																<span class="required-field"  id="WC_MyAccountQuickCheckoutProfileForm_div_31"> *</span><label for="pay_expire_month">
																<fmt:message bundle="${storeText}" key="expire_month"/></label>
															</div>
															<div id="WC_MyAccountQuickCheckoutProfileForm_div_32">
																<select  class="inputField" data-widget-type="wc.Select" aria-required="true" name="pay_expire_month" id="pay_expire_month" class="drop_down" size="1">
																	<option
																		<c:if test="${expire_month == 1 || expire_month == '01'}" > selected="selected" </c:if>
																		value="01">01</option>
																	<option
																		<c:if test="${expire_month == 2 || expire_month == '02'}" > selected="selected" </c:if>
																		value="02">02</option>
																	<option
																		<c:if test="${expire_month == 3 || expire_month == '03'}" > selected="selected" </c:if>
																		value="03">03</option>
																	<option
																		<c:if test="${expire_month == 4 || expire_month == '04'}" > selected="selected" </c:if>
																		value="04">04</option>
																	<option
																		<c:if test="${expire_month == 5 || expire_month == '05'}" > selected="selected" </c:if>
																		value="05">05</option>
																	<option
																		<c:if test="${expire_month == 6 || expire_month == '06'}" > selected="selected" </c:if>
																		value="06">06</option>
																	<option
																		<c:if test="${expire_month == 7 || expire_month == '07'}" > selected="selected" </c:if>
																		value="07">07</option>
																	<option
																		<c:if test="${expire_month == 8 || expire_month == '08'}" > selected="selected" </c:if>
																		value="08">08</option>
																	<option
																		<c:if test="${expire_month == 9 || expire_month == '09'}" > selected="selected" </c:if>
																		value="09">09</option>
																	<option
																		<c:if test="${expire_month == 10 }" > selected="selected" </c:if>
																		value="10">10</option>
																	<option
																		<c:if test="${expire_month == 11 }" > selected="selected" </c:if>
																		value="11">11</option>
																	<option
																		<c:if test="${expire_month == 12 }" > selected="selected" </c:if>
																		value="12">12</option>
																</select>
															</div>
														</div>
														<div class="quick_drop" id="WC_MyAccountQuickCheckoutProfileForm_div_34">
															<div class="label_spacer" id="WC_MyAccountQuickCheckoutProfileForm_div_35">
																<label for="pay_expire_year"><span class="required-field"  id="WC_MyAccountQuickCheckoutProfileForm_div_36"> *</span>
																<fmt:message bundle="${storeText}" key="expire_year"/></label>
															</div>
															<c:set var="current_year" value="${now1.year + 1900}"/>
															<div id="WC_MyAccountQuickCheckoutProfileForm_div_37">
																<select  class="inputField" data-widget-type="wc.Select" aria-required="true" name="pay_expire_year" id="pay_expire_year" class="drop_down" size="1">
																	<c:forEach begin="0" end="10" varStatus="counter">
																		<option
																			<c:if test="${expire_year == current_year+counter.index }" > selected="selected" </c:if>
																			value="${current_year+counter.index}">${current_year+counter.index}</option>
																	</c:forEach>
																</select>
															</div>
														</div>
														<br />
													</div>
												</div>-->
												<!-- BRAINTREE END -->
											</div>
											<div id="my_account_shipping" role="region" aria-labelledby="my_account_shipping_acce_label">
												<h1 id="my_account_shipping_acce_label" class="my_account_content_bold"><fmt:message bundle="${storeText}" key="QC_SHIPPINGADDR"/></h1>
												<div class="label_spacer" id="WC_MyAccountQuickCheckoutProfileForm_div_38">
													<label for="SameShippingAndBillingAddress"><img src="<c:out value='${jspStoreImgDir}'/>images/empty.gif" alt="<fmt:message bundle="${storeText}" key="UC_SAME"/>"/></label>
													<input class="checkbox" type="checkbox" name="SameShippingAndBillingAddress" onclick="JavaScript:QuickCheckoutProfile.showHide(document.QuickCheckout);" id="SameShippingAndBillingAddress"/>
													<span class="unregisteredCheckbox">
														<fmt:message bundle="${storeText}" key="UC_SAME"/>
													</span>
															
												</div>
												<br/>
												<div id="shipAddr">
													<wcpgl:widgetImport useIBMContextInSeparatedEnv="${isStoreServer}" url="${env_siteWidgetsDir}com.ibm.commerce.store.widgets.AddressForm/AddressForm.jsp">
														<wcpgl:param name="addressId" value="${shippingTemp_addressId}" />
														<wcpgl:param name="nickName" value="${shippingTemp_nickName}" />
														<wcpgl:param name="addressType" value="${shippingTemp_addressType}" />
														<wcpgl:param name="firstName" value="${shippingTemp_firstName}"/>
														<wcpgl:param name="lastName" value="${shippingTemp_lastName}"/>
														<wcpgl:param name="middleName" value="${shippingTemp_middleName}"/>
														<wcpgl:param name="address1" value="${shippingTemp_address1}"/>
														<wcpgl:param name="address2" value="${shippingTemp_address2}"/>
														<wcpgl:param name="city" value="${shippingTemp_city}"/>
														<wcpgl:param name="state" value="${shippingTemp_state}"/>
														<wcpgl:param name="countryReg" value="${shippingTemp_country}"/>
														<wcpgl:param name="zipCode" value="${shippingTemp_zipCode}"/>
														<wcpgl:param name="phone" value="${shippingTemp_phone1}"/>
														<wcpgl:param name="email1" value="${shippingTemp_email1}"/>
														<wcpgl:param name="prefix" value="shipping_" />
														<wcpgl:param name="pageName" value="QuickCheckoutAddressForm" />
														<wcpgl:param name="formName" value="document.QuickCheckout.name"/>
													</wcpgl:widgetImport>																													
												</div>
												<script type="text/javascript">
													$(document).ready(function() {  
														javascript:QuickCheckoutProfile.getCurrentProfile(shippingProfile, 'shipping');
													});
												</script>
						
												<br clear="all"/>

												<fieldset>
													<legend><span class="spanacce"><fmt:message bundle="${storeText}" key="WITHIN_US"/></span></legend>
													<h1 class="strong quick_checkout_profile_padding"><fmt:message bundle="${storeText}" key="WITHIN_US"/></h1>
													<c:if test="${!empty shippingModeInfo}">
														<c:set var="shippingModeId" value="${shippingModeInfo.shippingMode.shippingModeId}" />
													</c:if>
													<c:if test="${!empty errorMessage}">
														<c:set var="shippingModeId" value="${WCParam.shipModeId}" />
													</c:if>
													
													<wcf:rest var="shipModes" url="store/{storeId}/cart/shipping_modes">
														<wcf:var name="storeId" value="${storeId}" />
														<wcf:param name="langId" value="${langId}"/>
														<wcf:param name="responseFormat" value="json"/>
													</wcf:rest>
													
													<c:set var="shipModeApplied" value="" />
													<c:set var="firstValidState" value="1" />
													<c:forEach items="${shipModes.usableShippingMode}" var="shippingMode" varStatus="status">
														<c:if test="${status.count == 1 && shippingMode.shipModeCode == 'PickupInStore'}">
															<c:set var="firstValidState" value="2" />
														</c:if>
														<c:if test="${!empty shippingModeId && shippingMode.shipModeCode != 'PickupInStore'}">
															<c:choose>
																<c:when test="${shippingMode.shipModeId eq shippingModeId}">
																	<c:set var="selection" value="checked=true" />
																	<c:set var="shipModeApplied" value="true" />
																</c:when>
																<c:otherwise>
																	<c:set var="selection" value="" />
																</c:otherwise>
															</c:choose>
															
															<input type="radio" name="shipModeId" id="WC_QuickCheckoutProfileForm_FormInput_<c:out value='${shippingMode.shipModeId}'/>_In_QuickCheckout_1" value="<c:out value="${shippingMode.shipModeId}"/>" <c:out value="${selection}"/> class="radio"/>
															<label for="WC_QuickCheckoutProfileForm_FormInput_<c:out value='${shippingMode.shipModeId}'/>_In_QuickCheckout_1"><c:out value="${shippingMode.shipModeDescription}"/>
															<c:out value="${shippingMode.field1}"/>
															<c:out value="${shippingMode.field2}"/>
															</label>
															<br/>
														</c:if>
														<c:if test="${empty shippingModeId && shippingMode.shipModeCode != 'PickupInStore'}">
															<input type="radio" name="shipModeId" id="WC_QuickCheckoutProfileForm_FormInput_<c:out value='${shippingMode.shipModeId}'/>_In_QuickCheckout_1" value="<c:out value="${shippingMode.shipModeId}"/>" <c:if test="${status.count == firstValidState}">checked="true"</c:if> class="radio"/>
															<label for="WC_QuickCheckoutProfileForm_FormInput_<c:out value='${shippingMode.shipModeId}'/>_In_QuickCheckout_1"><c:out value="${shippingMode.shipModeDescription}"/>
															<c:out value="${shippingMode.field1}"/>
															<c:out value="${shippingMode.field2}"/></label>
															<br/>
														</c:if>
													</c:forEach>
												</fieldset>
											</div>
										</div>
									</form>
									<br clear="all" />
								</div>
							</div>
							<div class="button_footer_line" id="WC_MyAccountQuickCheckoutProfileForm_div_87">
								<a href="#" role="button" class="button_primary" id="WC_MyAccountQuickCheckoutProfileForm_links_7" onclick="javascript:QuickCheckoutProfile.UpdateProfile(document.QuickCheckout);return false;">
									<div class="left_border"></div>
									<div class="button_text"><fmt:message bundle="${storeText}" key="UPDATE"/></div>												
									<div class="right_border"></div>
								</a>
							</div>
						</div>
					</div>
				</div>
			</div>			
		</div>
	</div>	
	<!-- Content End -->
	<!-- Main Content End -->	

	<!-- Footer Start -->
	<div class="footer_wrapper_position">
		<%out.flush();%>
			<c:import url = "${env_jspStoreDir}/Widgets/Footer/Footer.jsp" />
		<%out.flush();%>
	</div>
	<!-- Footer End -->
</div>

<flow:ifEnabled feature="Analytics"><cm:pageview/></flow:ifEnabled>
<%@ include file="../../../Common/JSPFExtToInclude.jspf"%> </body>

</html>
<!-- END MyAccountQuickCheckoutProfileForm.jsp -->
