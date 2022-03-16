# PaymentMethodContainer

## Follow the below steps

1. Add the below props elements in the interface PaymentMethodContainerProps
    ```ruby
        interface PaymentMethodContainerProps {
          paymentInfo: PaymentInfoType;
          currentPaymentNumber: number;
          usableBillAddresses: any[] | null;
          setSelectedAddressId: Function; //setter fn to set selected billing address id
          createNewAddress: boolean;
          setCreateNewAddress: Function;
          setEditAddress: Function;
          editAddress: boolean;
          togglePayOption: Function;
          handleCreditCardChange: Function;
          isValidCardNumber: Function;
          isValidCode: Function;
          useMultiplePayment: boolean;
          paymentsList: any[];
          isPersonalAddressAllowed: string;
          orgAddressDetails: any[];
          /**PAYPAL POC **/
          paypaladressDetails : Object;
          onSucessTransactionOfPaypal: Function;
          /**PAYPAL POC **/
        }
    ```
    
 2. Extract the props values inside the components
      ```ruby
       const {
        usableBillAddresses,
        paymentInfo,
        currentPaymentNumber,
        setSelectedAddressId,
        createNewAddress,
        setCreateNewAddress,
        setEditAddress,
        editAddress,
        togglePayOption,
        handleCreditCardChange,
        isValidCardNumber,
        isValidCode,
        useMultiplePayment,
        paymentsList,
        isPersonalAddressAllowed,
        orgAddressDetails,
      /**PAYPAL POC **/
        paypaladressDetails,
        onSucessTransactionOfPaypal
      /**PAYPAL POC **/
      } = props;
      ```
      
 3. Pass the props in the PaymentMethodSelection component used in this component as below
      ```ruby
         <PaymentMethodSelection
            paymentInfo={paymentInfo}
            currentPaymentNumber={currentPaymentNumber}
            togglePayOption={togglePayOption}
            handleCreditCardChange={handleCreditCardChange}
            isValidCardNumber={isValidCardNumber}
            isValidCode={isValidCode}
            useMultiplePayment={useMultiplePayment}
            paymentsList={paymentsList}
			      /**PAYPAL POC **/
            paypaladressDetails={paypaladressDetails}
            onSucessTransactionOfPaypal={onSucessTransactionOfPaypal}
			      /**PAYPAL POC **/
          />
      ```
