
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

<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://commerce.ibm.com/base" prefix="wcbase"%>
<%@ taglib uri="http://commerce.ibm.com/foundation" prefix="wcf"%>
<%@ taglib uri="flow.tld" prefix="flow"%>
<%@ taglib uri="http://commerce.ibm.com/coremetrics" prefix="cm"%>
<%@ include file="../../../Common/EnvironmentSetup.jspf"%>
<%@ include file="../../../Common/nocache.jspf"%>

<c:set var="pageCategory" value="MyAccount" scope="request" />

<!DOCTYPE HTML>

<!-- BEGIN SavedCardsListDisplay.jsp -->
<html xmlns="http://www.w3.org/1999/xhtml"
	xmlns:wairole="http://www.w3.org/2005/01/wai-rdf/GUIRoleTaxonomy#"
	xmlns:waistate="http://www.w3.org/2005/07/aaa" lang="${shortLocale}"
	xml:lang="${shortLocale}">
<head>
<%@ include file="../../../Common/CommonCSSToInclude.jspf"%>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title><fmt:message bundle="${storeText}"
		key="SAVEDCARDSLIST_TITLE" /></title>
<%@ include file="../../../Common/CommonJSToInclude.jspf"%>
<fmt:message bundle="${storeText}" key="SAVEDCARDSLIST_TITLE"
	var="contentPageName" scope="request" />
</head>

<body>

	<%@ include file="../../../Common/MultipleWishListSetup.jspf"%>
	<%@ include file="../../../Common/CommonJSPFToInclude.jspf"%>

	<!-- Page Start -->
	<div id="page" class="nonRWDPage">

		<c:set var="myAccountPage" value="true" scope="request" />
		<c:set var="wishListPage" value="true" />
		<c:set var="hasBreadCrumbTrail" value="false" scope="request" />

		<!-- Import Header Widget -->
		<div class="header_wrapper_position" id="headerWidget">
			<%out.flush();%>
			<c:import url="${env_jspStoreDir}/Widgets/Header/Header.jsp" />
			<%out.flush();%>
		</div>
		<!-- Header Nav End -->

		<!-- Main Content Start -->

		<c:set var="myAccountPage" value="true" scope="request" />
	
		<!-- Main Content Start -->
		<div id="contentWrapper">
			<div id="content" role="main">
				<div class="row margin-true">
					<div class="col12">
						<%out.flush();%>
						<wcpgl:widgetImport useIBMContextInSeparatedEnv="${isStoreServer}"
							url="${env_siteWidgetsDir}com.ibm.commerce.store.widgets.BreadcrumbTrail/BreadcrumbTrail.jsp">
							<wcpgl:param name="pageGroup" value="Content" />
						</wcpgl:widgetImport>
						<%out.flush();%>
					</div>
				</div>
				<div class="rowContainer" id="container_MyAccountDisplayB2B">
					<div class="row margin-true">
						<div class="col4 acol12 ccol3">
							<%out.flush();%>
							<wcpgl:widgetImport
								useIBMContextInSeparatedEnv="${isStoreServer}"
								url="${env_siteWidgetsDir}com.ibm.commerce.store.widgets.MyAccountNavigation/MyAccountNavigation.jsp" />
							<%out.flush();%>
						</div>
						<div class="col8 acol12 ccol9 right">
						<h1 style="padding-left:15px";><fmt:message bundle="${storeText}" key="PAYMENTS_LIST" /></h1>
							<wcf:rest var="displayCardDetails"
								url="braintree/{storeId}/displayCardDetails" scope="request">
								<wcf:var name="storeId" value="${WCParam.storeId}" encode="true" />
							</wcf:rest>
							<c:set var="creditCardDetailsList" value="${displayCardDetails.result}" />
							
							<c:set var="creditCardDetailsListInfo" value="${creditCardDetailsList.btCardDetailsList}" />
							<div class="savedPaymentsDiv" style="border: 1px solid #e9e9e9; width: 950px; display: -webkit-inline-box;">
							
								<ul class="grid_mode_savepayments"  style=" padding-top: 50px;">
								<c:if test="${creditCardDetailsListInfo == ''}">
								<h1><fmt:message bundle="${storeText}" key="EMPTY_SAVED_PAYMENTS_LIST" /></h1>
								</c:if>
									<c:forEach var="creditCardDetails"
										items="${creditCardDetailsListInfo}">
										<li class=""
											style="float: left; width: 300px; display: grid; height: 200px; font-size: 15px; line-height: 16px;"><p>${creditCardDetails.cardType}</p>
											<!-- <p>${creditCardDetails.cardHolderName}</p> -->
											<p>${creditCardDetails.maskedCreditCardNumber}</p>
											<p>${creditCardDetails.expirationDate}</p> 
											<a
											class="button secondary" style="height: 13px; width: 100px;"
											wairole="button" role="button"
											href="JavaScript:BrainTreePayments.deleteSelectedCardFromVault('${creditCardDetails.payTokenId}');">
												<span class="remove">&nbsp;</span> Remove
										</a>
											<div class="test"
												style="height: 1px; width: 250px; border-bottom: 1px dotted #c9c9c9;"></div>
										</li>
									</c:forEach>
								</ul>
							</div>
						</div>
					</div>
				</div>
			</div>
			<!-- Main Content End -->

			<!-- Footer Start -->
			<div class="footer_wrapper_position">
				<%out.flush();%>
				<c:import url="${env_jspStoreDir}/Widgets/Footer/Footer.jsp" />
				<%out.flush();%>
			</div>
			<!-- Footer End -->
		</div>
	</div>
	<flow:ifEnabled feature="Analytics">
		<cm:pageview />
	</flow:ifEnabled>
	<%@ include file="../../../Common/JSPFExtToInclude.jspf"%>
</body>
</html>
<!-- END SavedCardsList.jsp -->
