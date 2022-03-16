# PaymentMethodSelection

## Follow below steps

1. Add the props element declaration in the interface PaymentMethodSelectionprops
     ```ruby
      interface PaymentMethodSelectionProps {
        paymentInfo: PaymentInfoType;
        currentPaymentNumber: number;
        togglePayOption: Function;
        handleCreditCardChange: Function;
        isValidCardNumber: Function;
        isValidCode: Function;
        useMultiplePayment: boolean;
        paymentsList: any[];
        /**PAYPAL POC **/
        paypaladressDetails: Object;
        onSucessTransactionOfPaypal: Function;
        /**PAYPAL POC **/
      }
     ```
     
 2. Access the props value in component as given below
     ```ruby
      const {
        paymentInfo,
        currentPaymentNumber,
        togglePayOption,
        handleCreditCardChange,
        isValidCardNumber,
        isValidCode,
        useMultiplePayment,
        paymentsList,
      /**PAYPAL POC **/
        paypaladressDetails,
        onSucessTransactionOfPaypal
      /**PAYPAL POC **/
      } = props;
     ```
     
 3. Add the below code in the html to render the paypal component when Paypal radio button is checked
      ```ruby
         </Fragment>
                ))}
				/**PAYPAL POC **/
              {paymentInfo && paymentInfo.payMethodId === PAYMENT.paymentMethodName.paypal && (
                <>
                  <Divider className="horizontal-margin-2" />
                  <StyledGrid
                    container
                    spacing={2}
                    className="horizontal-padding-2 vertical-padding-3">
                    <StyledGrid item xs={12}>
                      <PaypalComponent address={paypaladressDetails} onSuccess={onSucessTransactionOfPaypal} />
                    </StyledGrid>
                  </StyledGrid>
                </>
              )}
			  /**PAYPAL POC **/
            </StyledRadioGroup>
      ```
