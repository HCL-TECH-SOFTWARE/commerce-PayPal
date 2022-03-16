## UI component

**Follow below steps for PayPal Component to Work On UI**

1. Need to install below packages and import in your project 

   - paypal-checkout
 `npm install paypal-checkout`
 
   - braintree-web
  `npm install braintree-web`
  
   - country-list
 `npm install country-list`
 
2. Add **paypal** folder inside the component folder.It has payapal.tsx file which renders the PayPal button on UI.
  
3. Refer the readme file for the Changes in Payment.tsx placed inside 'component/pages/checkout/payment' folder     
            
4. Refer the readme file for the Changes in PaymentMethodContainer.tsx placed inside 'UI/components/widgets/payment-method-container' folder

5. Refer the readme file for the Changes in PaymentMethodSelection.tsx placed inside 'UI/components/widgets/payment-method-selection' folder
 
 6. Add **paypal** folder inside the 'UI/components/foundation/apis' folder.It contains paypal.service.tsx file
 
7. Add the below entry of PayPal in src/constant/order.js
      ```ruby
      export const PAYMENT = {
        paymentMethodName: {
          cod: "COD",
          mc: "Master Card",
          visa: "VISA",
          amex: "AMEX",
         /**PAYPAL POC **/
          paypal:"BT_PayPal"
         /**PAYPAL POC **/
        },
        paymentDisplayName: {
          mc: "Mastercard",
          visa: "Visa",
          amex: "American Express",
        },
        payOptions: { cod: "COD", cc: "CC",/**PAYPAL POC **/paypal:"BT_PayPal" /**PAYPAL POC **/},
      };
      ```
      
 8. Update the below changes in the  file UI/redux/reducers/order.ts file
    Inside the case "ACTIONS.PAYMETHODS_GET_SUCCESS" update the below code for the paypal option 
     **add the statements inside the comment "PAYPAL POC"
      ```ruby
       builder.addCase(
    ACTIONS.PAYMETHODS_GET_SUCCESS,
    (state: OrderReducerState, action: AnyAction) => {
      const response = action.response;
      if (response && response.usablePaymentInformation) {
        let cardsList: any[] = [];
        let cashList: any[] = [];
		/**PAYPAL POC **/
        let walletList: any[] = [];
		/**PAYPAL POC **/

        for (let payment of response.usablePaymentInformation) {
          if (
            payment.paymentMethodName === PAYMENT.paymentMethodName.amex ||
            payment.paymentMethodName === PAYMENT.paymentMethodName.mc ||
            payment.paymentMethodName === PAYMENT.paymentMethodName.visa
          ) {
            cardsList.push(payment);
          } else if (
            payment.paymentMethodName === PAYMENT.paymentMethodName.cod
          ) {
            cashList.push(payment);
          }/**PAYPAL POC **/else if (
            payment.paymentMethodName === PAYMENT.paymentMethodName.paypal
          ) {
            walletList.push(payment);
          }/**PAYPAL POC **/
        }

        if (cardsList.length > 0) {
          state.payMethods = cardsList.concat(cashList);
        }else {
          state.payMethods = cashList;
        }
		/**PAYPAL POC **/
        state.payMethods =[...state.payMethods,...walletList];
		/**PAYPAL POC **/
      }
      ```
 
