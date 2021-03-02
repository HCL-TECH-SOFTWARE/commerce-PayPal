#readme
## Follow the below steps for the PayPal integration on the payment page

1. Add the State variables and create the below paypal object when component loads 

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
   ```
   
  2. Inside togglePayOption() method , add the below condition in the IF statement
  
       ```ruby
           if (
            paymentTCId &&
            paymentTCId !== "" &&
            payment.payMethodId !== PAYMENT.paymentMethodName.cod &&
           /**PAYPAL POC **/ payment.payMethodId !== PAYMENT.paymentMethodName.paypal/**PAYPAL POC **/
          ) 
       ```
   
  3. Inside isValidPaymentMethod() method, add the blow condition inside mainIF statement
       ```ruby
           if (
              selectedPaymentInfoList[paymentNumber].payMethodId !==
              PAYMENT.paymentMethodName.cod &&  /**PAYPAL POC **/selectedPaymentInfoList[paymentNumber].payMethodId !==
              PAYMENT.paymentMethodName.paypal /**PAYPAL POC **/
            )
       ```
       Add the else if condition at the end for the paypal validation
       ```ruby
            /**PAYPAL POC **/ else if (selectedPaymentInfoList[paymentNumber].payMethodId === PAYMENT.paymentMethodName.paypal) {
            return (paypalTransactionFlag) ? true : false;
          }
          /**PAYPAL POC **/
       ```
       
 4.  Inside Submit() method, add the condition in If statement for creditcard check
       ```ruby
          if (
          selectedPaymentInfoList[i].payMethodId !==
          PAYMENT.paymentMethodName.cod &&  /**PAYPAL POC **/ selectedPaymentInfoList[i].payMethodId !==
          PAYMENT.paymentMethodName.paypal /**PAYPAL POC **/
        ) {
       ```
       and add the IF condition on adding the extra fields in paypload for the paypal 
       ```ruby
          /**PAYPAL POC **/
          if ( selectedPaymentInfoList[i].payMethodId === PAYMENT.paymentMethodName.paypal) {
            body = {
              ...body,
              ...paypalPayload
            };
          }
       /**PAYPAL POC **/
          const payload = {
            ...payloadBase,
            body,
          };
       ```
       
 5. Add the below methods inside the payment component.
       ```ruby
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
      const node: any = React.useRef(null);
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
       ```
                
6. Add the props(paypaladressdetails and onsuccesstransaction) for the paypal component in PaymentMethodContainer.  
      ```ruby
          <PaymentMethodContainer
              paymentInfo={selectedPaymentInfoList[currentPaymentNumber]}
              currentPaymentNumber={currentPaymentNumber}
              usableBillAddresses={usableBillAddresses}
              setSelectedAddressId={setSelectedBillingAddressId}
              setCreateNewAddress={setCreateNewAddress}
              createNewAddress={createNewAddress}
              editAddress={editAddress}
              setEditAddress={setEditAddress}
              togglePayOption={togglePayOption}
              handleCreditCardChange={handleCreditCardChange}
              isValidCardNumber={isValidCardNumber}
              isValidCode={isValidCode}
              useMultiplePayment={useMultiplePayment}
              paymentsList={payMethods}
              isPersonalAddressAllowed={isPersonalAddressAllowed}
              orgAddressDetails={orgAddressDetails}
           /**PAYPAL POC **/
              paypaladressDetails={paypalAddressdetails}
              onSucessTransactionOfPaypal={onSucessTransactionOfPaypal}
           /**PAYPAL POC **/
            />
      ```
 

   
