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

<!--Apple Pay-->
<script type="text/javascript">
	$(document).ready(function() 
		{ 
			BrainTreePayments.applePayPayment('apple-pay-button_<c:out value='${param.paymentMethodCount}'/>','<c:out value='${param.clientToken}'/>','<c:out value='${param.paymentMethodCount}'/>'); 
		});
	</script>
		
			<div id="applePay_<c:out value='${param.paymentMethodCount}'/>" style=" margin-left:25px;  display:none;" >
				
				<button type="button"  style="background-color:white; border:none; width:100; height:48; " id="apple-pay-button_<c:out value='${param.paymentMethodCount}'/>" onclick="JavaScript: BrainTreePayments.applePayOnClick('PaymentForm','1','${order.grandTotal}')" >
											<svg xmlns="http://www.w3.org/2000/svg" width="120" height="48" viewBox="0 0 130.981 48.002"><path fill="#FFF" d="M68.267 1l.762.001c.209.001.418.004.628.009.381.01.829.031 1.26.109.399.072.737.183 1.064.349a3.485 3.485 0 0 1 1.533 1.534c.166.326.276.664.348 1.064.077.427.099.876.108 1.259.006.208.009.417.01.628.002.253.002.508.002.762v34.572c0 .254 0 .508-.002.765a25.97 25.97 0 0 1-.01.625c-.01.383-.031.832-.108 1.262A3.748 3.748 0 0 1 73.514 45a3.516 3.516 0 0 1-1.535 1.535 3.745 3.745 0 0 1-1.062.349 8.618 8.618 0 0 1-1.257.108c-.21.005-.42.008-.633.008-.253.002-.508.002-.761.002H6.706c-.251 0-.502 0-.756-.002-.21 0-.42-.003-.625-.008a8.728 8.728 0 0 1-1.26-.108A3.704 3.704 0 0 1 3 46.534a3.45 3.45 0 0 1-.888-.646A3.468 3.468 0 0 1 1.468 45a3.737 3.737 0 0 1-.349-1.064 8.372 8.372 0 0 1-.109-1.259 32.785 32.785 0 0 1-.009-.626L1 41.441V6.562l.001-.609c.001-.209.004-.418.009-.628.01-.381.031-.829.109-1.261a3.7 3.7 0 0 1 .349-1.063 3.494 3.494 0 0 1 1.533-1.533 3.72 3.72 0 0 1 1.063-.348 8.409 8.409 0 0 1 1.261-.109c.209-.005.418-.008.626-.009L6.715 1h61.552"/><path d="M68.267 1l.762.001c.209.001.418.004.628.009.381.01.829.031 1.26.109.399.072.737.183 1.064.349a3.485 3.485 0 0 1 1.533 1.534c.166.326.276.664.348 1.064.077.427.099.876.108 1.259.006.208.009.417.01.628.002.253.002.508.002.762v34.572c0 .254 0 .508-.002.765a25.97 25.97 0 0 1-.01.625c-.01.383-.031.832-.108 1.262A3.748 3.748 0 0 1 73.514 45a3.516 3.516 0 0 1-1.535 1.535 3.745 3.745 0 0 1-1.062.349 8.618 8.618 0 0 1-1.257.108c-.21.005-.42.008-.633.008-.253.002-.508.002-.761.002H6.706c-.251 0-.502 0-.756-.002-.21 0-.42-.003-.625-.008a8.728 8.728 0 0 1-1.26-.108A3.704 3.704 0 0 1 3 46.534a3.45 3.45 0 0 1-.888-.646A3.468 3.468 0 0 1 1.468 45a3.737 3.737 0 0 1-.349-1.064 8.372 8.372 0 0 1-.109-1.259 32.785 32.785 0 0 1-.009-.626L1 41.441V6.562l.001-.609c.001-.209.004-.418.009-.628.01-.381.031-.829.109-1.261a3.7 3.7 0 0 1 .349-1.063 3.494 3.494 0 0 1 1.533-1.533 3.72 3.72 0 0 1 1.063-.348 8.409 8.409 0 0 1 1.261-.109c.209-.005.418-.008.626-.009L6.715 1h61.552m0-1H6.715l-.769.001c-.216.001-.432.004-.648.01a9.519 9.519 0 0 0-1.41.124 4.78 4.78 0 0 0-1.341.442 4.526 4.526 0 0 0-1.97 1.971 4.738 4.738 0 0 0-.442 1.341 9.387 9.387 0 0 0-.125 1.41c-.005.215-.008.431-.009.647L0 6.715v34.572l.001.77c.001.216.004.432.01.647.013.47.041.944.125 1.409.084.473.223.912.441 1.341a4.489 4.489 0 0 0 1.971 1.971c.429.219.868.357 1.34.442.465.083.939.111 1.41.124.216.006.431.009.648.009.256.002.513.002.769.002h61.552c.256 0 .513 0 .769-.002.216-.001.432-.004.648-.009.47-.013.944-.041 1.41-.124a4.774 4.774 0 0 0 1.34-.442 4.482 4.482 0 0 0 1.971-1.971c.219-.429.357-.868.441-1.341.084-.465.111-.939.124-1.409.006-.216.009-.432.01-.647.002-.257.002-.513.002-.77V6.715c0-.257 0-.513-.002-.77a27.832 27.832 0 0 0-.01-.647 9.398 9.398 0 0 0-.124-1.41 4.736 4.736 0 0 0-.441-1.341A4.506 4.506 0 0 0 72.434.576a4.774 4.774 0 0 0-1.34-.442 9.542 9.542 0 0 0-1.41-.124c-.217-.006-.433-.008-.648-.01h-.769z"/><path d="M22.356 14.402c.692-.839 1.159-2.005 1.032-3.167-1 .041-2.209.668-2.921 1.504-.645.742-1.203 1.93-1.049 3.069 1.112.086 2.246-.567 2.938-1.406zm2.873 7.374c-.022-2.513 2.05-3.722 2.146-3.782-1.169-1.7-2.982-1.936-3.628-1.962-1.545-.153-3.018.91-3.799.91-.784 0-1.99-.886-3.274-.859-1.684.024-3.237.979-4.104 2.486-1.745 3.043-.443 7.537 1.261 9.998.834 1.205 1.826 2.559 3.133 2.51 1.258-.049 1.73-.814 3.25-.814 1.517-.002 1.946.812 3.271.789 1.352-.029 2.21-1.23 3.039-2.441.953-1.395 1.348-2.75 1.368-2.818-.027-.018-2.633-1.012-2.663-4.017zm16.096-7.375c-.504-.486-1.154-.864-1.932-1.124-.771-.257-1.697-.387-2.752-.387a18 18 0 0 0-2.023.105 29.84 29.84 0 0 0-1.674.235l-.163.028v17.667h1.613v-7.443c.543.093 1.165.142 1.851.142.913 0 1.768-.117 2.542-.346a5.681 5.681 0 0 0 2.038-1.063 5.142 5.142 0 0 0 1.361-1.769c.33-.7.498-1.523.498-2.449 0-.766-.121-1.455-.357-2.048a4.685 4.685 0 0 0-1.002-1.548zm-1.482 6.748c-.828.694-2 1.046-3.487 1.046-.409 0-.796-.018-1.151-.051a5.4 5.4 0 0 1-.81-.136v-7.513c.213-.039.477-.076.787-.109.393-.042.866-.063 1.408-.063a6.71 6.71 0 0 1 1.843.239 4.243 4.243 0 0 1 1.417.694c.387.3.691.69.902 1.16.213.476.32 1.044.32 1.687-.001 1.335-.415 2.36-1.229 3.046zm12.482 8.122c-.018-.5-.025-1.002-.025-1.502v-4.911c0-.582-.059-1.176-.174-1.766a4.481 4.481 0 0 0-.668-1.644c-.328-.492-.787-.898-1.361-1.208-.574-.309-1.32-.465-2.219-.465-.656 0-1.297.085-1.902.254a6.04 6.04 0 0 0-1.779.846l-.131.091.545 1.275.197-.133a5.272 5.272 0 0 1 1.396-.664 5.218 5.218 0 0 1 1.547-.238c.672 0 1.209.122 1.592.362.389.243.682.544.871.896.197.363.326.749.383 1.15.061.417.09.79.09 1.11v.142c-2.391-.011-4.258.387-5.498 1.186-1.301.838-1.961 2.031-1.961 3.545 0 .436.078.875.232 1.309.156.439.393.832.703 1.168.312.34.715.617 1.197.824.48.209 1.045.314 1.676.314a4.693 4.693 0 0 0 2.534-.693c.332-.205.627-.438.879-.689a4.99 4.99 0 0 0 .307-.338h.062l.148 1.434h1.555l-.043-.23a9.898 9.898 0 0 1-.153-1.425zm-1.638-2.516c0 .172-.041.408-.119.691a3.53 3.53 0 0 1-.434.863 3.314 3.314 0 0 1-1.689 1.275 3.946 3.946 0 0 1-1.293.197 2.56 2.56 0 0 1-.85-.145 2.051 2.051 0 0 1-.715-.428 2.13 2.13 0 0 1-.502-.727c-.127-.293-.191-.656-.191-1.078 0-.691.186-1.252.551-1.662a3.62 3.62 0 0 1 1.438-.975 7.377 7.377 0 0 1 1.943-.443 17.699 17.699 0 0 1 1.861-.081v2.513zm12.585-8.693l-3.01 8.183c-.188.494-.363.992-.523 1.477-.078.242-.152.471-.225.689h-.057a60.845 60.845 0 0 0-.23-.715c-.156-.48-.324-.951-.496-1.4l-3.219-8.234h-1.721L58.396 29.9c.121.285.139.416.139.469 0 .016-.006.113-.141.473a8.585 8.585 0 0 1-.977 1.816c-.369.502-.707.91-1.008 1.211-.35.35-.711.637-1.078.854-.375.221-.717.4-1.02.535l-.174.078.561 1.363.178-.066c.146-.055.42-.18.836-.383.42-.207.885-.535 1.381-.979a7.143 7.143 0 0 0 1.162-1.309c.34-.488.68-1.061 1.014-1.697.33-.635.66-1.357.982-2.148.322-.795.668-1.684 1.025-2.639l3.719-9.416h-1.723z"/></svg>
				</button>	
			</div>
			
								