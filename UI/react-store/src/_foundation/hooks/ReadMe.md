## Add the following code to the above hooks file.
 ```ruby

/**PAYPAL POC **/
 const [showPaypal, setShowPaypal] = useState<boolean>(false);
 const [paypalTransactionFlag, setPaypalTransactionFlag] = useState<boolean>(false);
  const [paypalAddressdetails, setPaypalAddressDetails] = useState<any>({});
  const [paypalPayload, setPaypalPayload] = useState<any>({});
  useEffect(()=>{
   if(addressDetails && cart){
   setPaypalAddressDetails({
     grandTotal: cart.grandTotal,
     grandTotalCurrency:  cart?.grandTotalCurrency,
     shipping:  addressDetails?.contactList[0],

   })
 }
 },[addressDetails,cart])
  /**PAYPAL POC **/
  function updateBillingAddress(payload) {
    console.log("updated..");
    let { city, countryCode, line1, line2, postalCode, state, recipientName } = payload.details['billingAddress'];
    let body = {
      addressTypeFromPayPal: 'PayPalBillingAddress',
      addressType: 'B',
      recipientName: recipientName,
      address1: line1 || "",
      address2: line2 || "",
      city: city,
      state: state,
      countryCode: countryCode,
      postalCode: postalCode
    };
    paypalService.updateBillingAddress(body).then((data) => {
      // let finaldata = JSON.parse(data);
      console.log("Updated Billing Address --", data);
      var addressId = data['result']['updatedAddressId'];
     // setselectedBillAddressId(addressId);
      setPaypalPayloadData(payload);
    });
  }
  function setPaypalPayloadData(payload) {
    let deviceData = paypalService.getDeviceSessionData();
    setPaypalPayload({
      PayPalEmailId: payload.details.email,
      fraudMerchantId: deviceData['fraud_merchant_id'] || "",
      deviceSessionId: deviceData['device_session_id'] || "",
      fromSavedPaymentFlag: 'false',
      cvv_nonce: '',
      pay_token: '',
      pay_nonce: payload.nonce,
      pay_type: payload.type
    })
  }
  function onSucessTransactionOfPaypal(payload) {
    console.log("paypal success --", payload);
    if (payload.details['billingAddress']) {
      updateBillingAddress(payload);
    } else {
      setPaypalPayloadData(payload);
    }
    //paypalTransactionFlag=true;
    setPaypalTransactionFlag(true);
    //submit();
  }
 /**PAYPAL POC **/
  
