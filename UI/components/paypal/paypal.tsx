/**
*==================================================
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
*==================================================
**/
import React from 'react';
import paypal from 'paypal-checkout';
import braintree from 'braintree-web';
import paypalService from '../../_foundation/apis/paypal/paypal.service';
import { getCode, getName } from 'country-list';

const PaypalComponent: React.FC<any> = (props: any) => {
    let advancedFraudTools = "true";
   
    let { grandTotal, grandTotalCurrency } = props.address;
    let { addressId, firstName, lastName, addressLine, city, state, country, zipCode, phone1 } = props.address.shipping;
    console.log("country code---",getCode(country));
    let countryCode=null;
    function getCountryCode(){
        if(getCode(country) === undefined){
            console.log(getName(country));
            if(getName(country)!== undefined){               
              countryCode=getCode(getName(country));
              console.log( countryCode);
            }else{
                alert("please add correct country name");
                return ;
            }
        }else{
            countryCode=getCode(country);
            console.log(countryCode);
        }
    }
    getCountryCode();
    let PaymentOption = {
        flow: 'vault',
        amount: grandTotal,
        locale: "en_US",
        currency: grandTotalCurrency,
        enableShippingAddress: true,
        shippingAddressEditable: true,
        displayName: "HCLCommerce",
        shippingAddressOverride: {
            recipientName: firstName + lastName,
            line1: addressLine[0] || "",
            line2: addressLine[1] || "",
            city,
            state,
            countryCode: countryCode,
            postalCode: zipCode,
            phone: phone1 || ""
        }
    }
    console.log("payment options--",PaymentOption);
    function startPayment() {
        getClientToken();
    }
    function getClientToken() {
        paypalService.getClientToken().then((responseData) => {
            console.log("CLIENT Token--", responseData);
            authorizeCheckout(responseData.data.result.clientToken);
        }).catch(function (clientErr) {
            console.error("Client Token Error---", clientErr);
            return;

        })
       
    }
    function authorizeCheckout(token) {
        let client_token = token;
        braintree.client.create({
            authorization: client_token
        }).then(function (clientInstance) {
            setDeviceSessionData(clientInstance);
            createPaypalCheckout(clientInstance);
        }).catch(function (clientErr) {
            console.error("Authorization Error---", clientErr);
            return;

        });
    }
    function setDeviceSessionData(clientInstance) {
        if (advancedFraudTools == "true") {
            braintree.dataCollector.create({
                client: clientInstance,
                kount: true
            }).then(function (dataCollectorInstance) {
                var deviceData = JSON.parse(dataCollectorInstance.deviceData);
                paypalService.setDeviceSessionData(deviceData);
            }).catch(function (err) {
                console.error("Device Data Error ---", err);
                return;
            });
        }
    }
    function createPaypalCheckout(clientInstance) {
        braintree.paypalCheckout.create({
            client: clientInstance
        }, function (createErr, paypalCheckoutInstance) {
            if (createErr) {
                console.error('Paypal Checkout Error--', createErr);
                return;
            }
            renderPayPalButton(paypalCheckoutInstance);
        });
    }
    function renderPayPalButton(paypalCheckoutInstance) {
        paypal.Button.render({
            env: 'sandbox',
            commit: true,
            locale: 'en_US',
            style: {
                label: 'paypal',
                size: 'small'
            },
            payment: function () {
                console.log("create payment");
                return paypalCheckoutInstance.createPayment(PaymentOption);
            },
            onAuthorize: function (data, actions) {
                console.log("authorise paypal");
                return paypalCheckoutInstance.tokenizePayment(data).then(function (payload) {
                    console.log("Payment Done ---", payload);
                    props.onSuccess(payload);
                });
            },
            onCancel: function (data) {
                console.log('Payment cCncelled ---', JSON.stringify(data));
                return;
            },
            onError: function (err) {
                console.error('Paylpal Button Error---', err);
                return;
            }
        }, '#paypal-button');
    }
    React.useEffect(() => {
        console.log("---Paypal Started---");
        startPayment();
    }, [])

    return (
        <div id="paypal-button"></div>
    );
}
export default PaypalComponent;