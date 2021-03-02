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
import Axios, { AxiosPromise, AxiosRequestConfig } from "axios";
import { getSite } from "../../hooks/useSite";
import { storageSessionHandler } from "../../utils/storageUtil";

let DEVICE_SESSION_OBJ = {};
const paypalService = {
    getClientToken(): AxiosPromise<any> {
        let storeID = getSite()?.storeID;
        const currentUser = storageSessionHandler.getCurrentUser();
        let requestOptions: AxiosRequestConfig = Object.assign({
            url: "/wcs/resources/braintree/" + storeID + "/clienttoken",
            method: "GET",
            headers: {
                "WCToken": currentUser.WCToken,
                "WCTrustedToken": currentUser.WCTrustedToken
            }

        });
        return Axios(requestOptions);
    },
    updateBillingAddress(body): AxiosPromise<any> {
        let storeID = getSite()?.storeID;
        const currentUser = storageSessionHandler.getCurrentUser();
        let requestOptions: AxiosRequestConfig = Object.assign({
            url: "/wcs/resources/braintree/" + storeID + "/updateShippingAddress",
            method: "POST",
            data: body,
            headers: {
                "WCToken": currentUser.WCToken,
                "WCTrustedToken": currentUser.WCTrustedToken
            }

        });
        return Axios(requestOptions);
    },
    setDeviceSessionData(obj) {
        DEVICE_SESSION_OBJ = obj;
        console.log("DEVICE DATA ---", DEVICE_SESSION_OBJ);
    },
    getDeviceSessionData() {
        console.log("GET DEVICE OBJECT--", DEVICE_SESSION_OBJ);
        return DEVICE_SESSION_OBJ;
    }
};

export default paypalService;
