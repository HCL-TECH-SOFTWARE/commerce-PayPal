## Add the below code mentioned in the above file
```ruby
 /**PAYPAL POC **/
   paypaladressDetails: Object;
   onSucessTransactionOfPaypal: Function;
   /**PAYPAL POC **/
   
    /**PAYPAL POC **/
   paypaladressDetails,
   onSucessTransactionOfPaypal
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
