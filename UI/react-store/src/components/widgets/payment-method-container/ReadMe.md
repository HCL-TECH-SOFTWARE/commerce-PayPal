### Add the below code in the above mentioned file.
```ruby
/**PAYPAL POC **/
  paypaladressDetails : Object;
  onSucessTransactionOfPaypal: Function;
  /**PAYPAL POC **/
  
   /**PAYPAL POC **/
     paypaladressDetails,
     onSucessTransactionOfPaypal
 /**PAYPAL POC **/
  } = props;
  const payMethods = useSelector(payMethodsSelector);
  const addressDetails: any = useSelector(addressDetailsSelector);
  
   if (paymentTCId && paymentTCId !== EMPTY_STRING && payment.payMethodId !== PAYMENT.paymentMethodName.cod  &&
      payment.payMethodId !== PAYMENT.paymentMethodName.paypal) {
      
      //code for payment as per the above file
      }
