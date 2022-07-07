<%--
 =================================================================
  Licensed Materials - Property of HCL Technologies

  HCL Commerce

  (C) Copyright HCL Technologies Limited 1996, 2020

 =================================================================
--%>
<%-- 
  *****
  * This JSP displays the selected physical stores.
  *****
--%>

<!-- BEGIN SelectedStoreList.jsp -->
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://commerce.ibm.com/base" prefix="wcbase" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="flow.tld" prefix="flow" %>
<%@ taglib uri="http://commerce.ibm.com/foundation" prefix="wcf" %>
<%@ include file="../../Common/EnvironmentSetup.jspf" %>

<c:set var="fromPage" value="StoreLocator" />
<c:if test="${!empty WCParam.fromPage}">
  <c:set var="fromPage" value="${WCParam.fromPage}" />
</c:if>
<c:if test="${!empty param.fromPage}">
  <c:set var="fromPage" value="${param.fromPage}" />
</c:if>

<c:set var="pickUpStoreId" value="${cookie.WC_pickUpStore.value}" />

<c:set var="cookieVal" value="${cookie.WC_physicalStores.value}" />
<c:if test="${!empty cookieVal}">	
  <c:set var="cookieVal" value="${fn:replace(cookieVal, '%2C', ',')}" scope="page" />
	
  <c:catch var="physicalStoreException">
    <wcf:rest var="physicalStores" url="store/{storeId}/storelocator/byStoreIds">
      <wcf:var name="storeId" value="${WCParam.storeId}" encode="true"/>
      <c:forTokens items="${cookieVal}" delims="," var="phyStoreId">
        <wcf:param name="physicalStoreId" value="${phyStoreId}" />	
      </c:forTokens>
    </wcf:rest>
  </c:catch>
</c:if>

<c:if test="${fromPage == 'ShoppingCart'}">
  <c:set var="storeId" value="" scope="page" />
  <c:if test="${!empty WCParam.storeId}">
    <c:set var="storeId" value="${WCParam.storeId}" scope="page" />
  </c:if>
  <c:if test="${!empty param.storeId}">
    <c:set var="storeId" value="${param.storeId}" scope="page" />
  </c:if>

  <c:set var="orderId" value="" scope="page" />
  <c:if test="${!empty WCParam.orderId}">
    <c:set var="orderId" value="${WCParam.orderId}" scope="page" />
  </c:if>
  <c:if test="${!empty param.orderId}">
    <c:set var="orderId" value="${param.orderId}" scope="page" />
  </c:if>
  
  <c:if test="${!empty orderId}">
	<wcf:rest var="productListOnCart" url="/store/{storeId}/order/{orderId}">
		<wcf:var name="storeId" value="${storeId}" />
		<wcf:var name="orderId" value="${orderId}" />
		<wcf:param name="sortOrderItemBy" value="orderItemID"/>
	</wcf:rest>
	<c:set var="physicalStoresHasInventory" value=""/>
	<c:set var="physicalStoresNum" value="${fn:length(physicalStores.PhysicalStore)}" />
	<c:set var="productsNum" value="${fn:length(productListOnCart.orderItem)}" />

	<c:forEach var="physicalStoresList" items="${physicalStores.PhysicalStore}">
		<c:set var="physicalStoresIDs" value="${physicalStoresIDs}${physicalStoresList.uniqueID},"/>
	</c:forEach>
	<c:if test="${!empty physicalStoresIDs}">
		<c:set var="strLength" value="${fn:length(physicalStoresIDs)-1}" />
		<c:set var="physicalStoresIDs" value="${fn:substring(physicalStoresIDs, 0, strLength)}"/>
	</c:if>

	<c:forEach var="productsList" items="${productListOnCart.orderItem}">
		<c:set var="productIDs" value="${productIDs}${productsList.productId},"/>
	</c:forEach>

	<c:if test="${!empty productIDs}">
		<c:set var="strLength" value="${fn:length(productIDs)-1}" />
		<c:set var="productIDs" value="${fn:substring(productIDs, 0, strLength)}"/>
	</c:if>
	
	<c:catch var="inventoryException">
		<wcf:rest var="overallInventoryAvailablityList" url="store/{storeId}/inventoryavailability/byOrderId/{orderId}">
			<wcf:var name="storeId" value="${WCParam.storeId}" encode="true"/>
			<wcf:var name="orderId" value="${orderId}" encode="true"/>
			<wcf:param name="physicalStoreId" value="${physicalStoresIDs}"/>
		</wcf:rest>
	</c:catch>
	<c:forEach var="physicalStoreIds" items="${overallInventoryAvailablityList.overallInventoryAvailability}">
		<c:set var="resultPhysicalStoreIds" value="${resultPhysicalStoreIds}${physicalStoreIds.physicalStoreId},"/>
	</c:forEach>
	<c:forEach var="physicalStoreInvStatus" items="${overallInventoryAvailablityList.overallInventoryAvailability}">
		<c:set var="resultPhysicalStoreInvStatus" value="${resultPhysicalStoreInvStatus}${physicalStoreInvStatus.overallInventoryStatus},"/>
	</c:forEach>

  </c:if>
</c:if>

<div id="your_store_list" class="gift_content margin_below">

  <c:if test="${!empty physicalStoreException}">
    <br /><span class="instruction"><fmt:message bundle="${storeText}" key="STORE_LIST_EMPTY"/></span><br /><br />
  </c:if>
  <c:if test="${empty physicalStoreException}">
    <c:set var="resultNum" value="${fn:length(physicalStores.PhysicalStore)}" />
    <c:if test="${resultNum <= 0}">
      <br /><fmt:message bundle="${storeText}" key="STORE_LIST_EMPTY" /><br /><br />
    </c:if>
    <c:if test="${resultNum > 0}">
    
      <c:if test="${fromPage == 'ShoppingCart'}">
<p class="text_padding"><fmt:message bundle="${storeText}" key="PICK_UP_ST_STORE_MESSAGE" /></p>
      </c:if>
<fieldset><legend><span class="spanacce"><fmt:message bundle="${storeText}" key='SELECTED_STORES_SUMMARY'/></span></legend>
<table id="bopis_table1" tabindex="-1" summary="<fmt:message bundle="${storeText}" key='SELECTED_STORES_SUMMARY'/>" cellpadding="0" cellspacing="0" border="0" width="100%">
  <tr class="nested">
      <c:if test="${fromPage == 'ShoppingCart'}">
    <th class="align_left" id="PhysicalStores_tableCell_0">&nbsp;</th>
      </c:if>
    <th class="align_left" id="PhysicalStores_tableCell_1"><fmt:message bundle="${storeText}" key="SELECTED_STORES_COLUMN1" /></th>
    <th class="align_left" id="PhysicalStores_tableCell_2"><fmt:message bundle="${storeText}" key="SELECTED_STORES_COLUMN2" /></th>
      <c:if test="${fromPage == 'ShoppingCart'}">
    <th class="align_left" id="PhysicalStores_tableCell_3"><fmt:message bundle="${storeText}" key="SELECTED_STORES_COLUMN3" /></th>
      </c:if>
    <th class="align_left" id="PhysicalStores_tableCell_4">&nbsp;</th>
  </tr>
            
      <c:forEach var="i" begin="0" end="${resultNum-1}" varStatus="status">
        <c:set var="storeHourIndex" value=-1 />
        <c:set var="attributeNum" value="${fn:length(physicalStores.PhysicalStore[i].Attribute)}" />
        <c:if test="${attributeNum > 0}">
          <c:forEach var="j" begin="0" end="${attributeNum - 1}">
            <c:if test="${physicalStores.PhysicalStore[i].Attribute[j].name == 'StoreHours'}">
              <c:set var="storeHoursIndex" value="${j}" />
              <c:set var="j" value="${attributeNum}" />
            </c:if>
          </c:forEach>
        </c:if>
					
  <tr id="${physicalStores.PhysicalStore[i].uniqueID}">
      <c:if test="${fromPage == 'ShoppingCart'}">
        <c:set var="invStatus" value="" />
        <c:if test="${!empty cookieVal}">
          <c:set var="storeUniqueId" value="${physicalStores.PhysicalStore[i].uniqueID}" />	
          <c:set var="resultPhyStoreInvStatusArray" value="${fn:split(resultPhysicalStoreInvStatus, ',')}" />
          <c:set var="k" value="0" />
          <c:forTokens items="${resultPhysicalStoreIds}" delims="," var="resultPhyStoreId">
            <c:if test"${resultPhyStoreId == storeUniqueId}">
              <c:set var="invStatus" value="${resultPhyStoreInvStatusArray[k]}" />
            </c:if>
            <c:set var="k" value="${k+1}" />
          </c:forTokens>
        </c:if>

    <td id="WC_SelectedStoreList_td_1_<c:out value='${status.count}'/>" width="23" headers="PhysicalStores_tableCell_0" <c:choose><c:when test="${i == resultNum - 1}"><c:out value="class=no_bottom_border"/></c:when><c:otherwise><c:out value="class=dotted_bottom_border"/></c:otherwise></c:choose>>
        <c:choose>
          <c:when test="${invStatus=='Available' || invStatus=='Backorderable'}">
            <c:choose>
              <c:when test="${!empty pickUpStoreId && pickUpStoreId==physicalStores.PhysicalStore[i].uniqueID}">
              <!-- BRAINTREE START -->
      <input name="pickUpStore" id="pickUpStore_${i}" type="radio" onclick="Javascript:PhysicalStoreCookieJSStore.setPickUpStoreIdToCookie(${physicalStores.PhysicalStore[i].uniqueID}); pickUpStoreId=${physicalStores.PhysicalStore[i].uniqueID};BrainTreePayments.checkPaypalStoreSelectionForm();" checked="checked" />
              </c:when>
              <c:otherwise>
      <input name="pickUpStore" id="pickUpStore_${i}" type="radio" onclick="Javascript:PhysicalStoreCookieJSStore.setPickUpStoreIdToCookie(${physicalStores.PhysicalStore[i].uniqueID}); pickUpStoreId=${physicalStores.PhysicalStore[i].uniqueID};BrainTreePayments.checkPaypalStoreSelectionForm();" />
              <!-- BRAINTREE END -->
              </c:otherwise>
            </c:choose>
          </c:when>
          <c:otherwise>
      <input name="pickUpStore" id="pickUpStore_${i}" type="radio" disabled="true" />
          </c:otherwise>
        </c:choose>
    </td>
      </c:if>

    <td id="WC_SelectedStoreList_td_2_<c:out value='${status.count}'/>" width="250" headers="PhysicalStores_tableCell_1" <c:choose><c:when test="${i == resultNum - 1}"><c:out value="class=no_bottom_border"/></c:when><c:otherwise><c:out value="class=dotted_bottom_border"/></c:otherwise></c:choose>>
    <p class="my_account_content_bold"><label for="pickUpStore_${i}"><c:out value="${physicalStores.PhysicalStore[i].Description[0].displayStoreName}" /></label></p>
    <p><c:out value="${physicalStores.PhysicalStore[i].addressLine[0]}" /></p>
    <p><c:out value="${physicalStores.PhysicalStore[i].city}" />, <c:out value="${physicalStores.PhysicalStore[i].stateOrProvinceName}" />  <c:out value="${physicalStores.PhysicalStore[i].postalCode}" /></p>
    <p><c:out value="${physicalStores.PhysicalStore[i].telephone1}" /></p></td>

    <c:choose>
      <c:when test="${storeHoursIndex > -1}">
        <td id="WC_SelectedStoreList_td_3_<c:out value='${status.count}'/>" width="160" headers="PhysicalStores_tableCell_2" <c:choose><c:when test="${i == resultNum - 1}"><c:out value="class=no_bottom_border"/></c:when><c:otherwise><c:out value="class=dotted_bottom_border"/></c:otherwise></c:choose>><c:out value="${physicalStores.PhysicalStore[i].Attribute[storeHoursIndex].displayValue}" escapeXml="false" /></td>
      </c:when>
      <c:otherwise>
        <td id="WC_SelectedStoreList_td_4_<c:out value='${status.count}'/>" width="160" headers="PhysicalStores_tableCell_2" <c:choose><c:when test="${i == resultNum - 1}"><c:out value="class=no_bottom_border"/></c:when><c:otherwise><c:out value="class=dotted_bottom_border"/></c:otherwise></c:choose>></td>
      </c:otherwise>
    </c:choose>                 

      <c:if test="${fromPage == 'ShoppingCart'}">
    <td id="WC_SelectedStoreList_td_5_<c:out value='${status.count}'/>" class="avail <c:choose><c:when test="${i == resultNum - 1}"><c:out value="no_bottom_border"/></c:when><c:otherwise><c:out value="dotted_bottom_border"/></c:otherwise></c:choose>" width="168" headers="PhysicalStores_tableCell_3">
      <c:choose>
        <c:when test="${!empty orderId}">
          <c:choose>
            <c:when test="${invStatus != ''}">
              <img src="<c:out value='${jspStoreImgDir}images/' />${invStatus}.gif" alt="<fmt:message bundle="${storeText}" key='AVAILABILITY_${invStatus}_IMAGE'/>" />
              <fmt:message bundle="${storeText}" key="INV_STATUS_${invStatus}"/> 
            </c:when>
            
            <c:otherwise>
              <fmt:message bundle="${storeText}" key="INV_INV_NA"/> 
            </c:otherwise>
          </c:choose>

        </c:when>
        
        <c:otherwise>
          <fmt:message bundle="${storeText}" key="INV_STATUS_NO_SHOP_CART_ITEM"/> 
        </c:otherwise>
      </c:choose>
    
    </td>
      </c:if>

    <td id="WC_SelectedStoreList_td_6_<c:out value='${status.count}'/>" headers="PhysicalStores_tableCell_4" <c:choose><c:when test="${i == resultNum - 1}"><c:out value="class=no_bottom_border"/></c:when><c:otherwise><c:out value="class=dotted_bottom_border"/></c:otherwise></c:choose>>
      <a class="remove_store_link hover_underline tlignore" id="removePhysicalStoreAction<c:out value='${i}' />" href="Javascript:setCurrentId('removePhysicalStoreAction${i}'); storeLocatorJSStore.removePhysicalStore(<c:out value="${physicalStores.PhysicalStore[i].uniqueID}" />); storeLocatorJSStore.removeFromStoreList('<c:out value="${fromPage}" />','<c:out value="${physicalStores.PhysicalStore[i].uniqueID}" />');"><img src="<c:out value='${jspStoreImgDir}${env_vfileColor}' />table_x_delete.png" alt="<fmt:message bundle="${storeText}" key='TABLE_X_DELETE_IMAGE'/>" /><fmt:message bundle="${storeText}" key="REMOVE_PHYSICAL_STORE" /></a>
    </td>
  </tr>
  
      </c:forEach>
</table></fieldset>
    
    </c:if>
  </c:if>

</div>
<!-- END SelectedStoreList.jsp -->
