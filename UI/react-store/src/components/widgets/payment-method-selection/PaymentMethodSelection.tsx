/*
 *==================================================
 * Licensed Materials - Property of HCL Technologies
 *
 * HCL Commerce
 *
 * (C) Copyright HCL Technologies Limited 2020
 *
 *==================================================
 */
//Standard libraries
import React, { Fragment, useEffect, useState, useMemo } from "react";
import { useTranslation } from "react-i18next";
import { useSelector } from "react-redux";
//Custom libraries
import { PAYMENT, EXPIRY } from "../../../constants/order";
import { EMPTY_STRING } from "../../../constants/common";
import { PaymentInfoType } from "../../../_foundation/hooks/use-checkout-payment";
import FormattedPriceDisplay from "../formatted-price-display";
//Redux
import { cartSelector, payMethodsSelector } from "../../../redux/selectors/order";
//UI
import { Divider } from "@material-ui/core";
import PaymentIcon from "@material-ui/icons/Payment";
import {
  StyledGrid,
  StyledTypography,
  StyledTextField,
  StyledRadio,
  StyledRadioGroup,
  StyledFormControl,
  StyledFormControlLabel,
  StyledInputLabel,
  StyledNumberInput,
  StyledSelect,
  StyledBox,
  StyledIconLabel,
  StyledCircularProgress,
} from "@hcl-commerce-store-sdk/react-component";
import PaypalComponent from "../../paypal/paypal";

interface PaymentMethodSelectionProps {
  paymentInfo: PaymentInfoType;
  currentPaymentNumber: number;
  togglePayOption: (v?: any, v2?: any) => void;
  handleCreditCardChange: (e?: any, v?: any) => void;
  isValidCardNumber: (v?: any) => boolean;
  isValidCode: (v?: any) => boolean;
  useMultiplePayment: boolean;
  handlePiAmountChange: (v?: any, v2?: any) => void;
  getMaximumPiAmount: (v?: any) => void;
   /**PAYPAL POC **/
   paypaladressDetails: Record<string, unknown>;
   onSucessTransactionOfPaypal: (v?:any)=>void;
   /**PAYPAL POC **/
}

/**
 * PaymentMethodSelection component
 * displays payment method type selection and credit card form
 * @param props
 */
const PaymentMethodSelection: React.FC<PaymentMethodSelectionProps> = (props: PaymentMethodSelectionProps) => {
  const {
    paymentInfo,
    currentPaymentNumber,
    togglePayOption,
    handleCreditCardChange,
    isValidCardNumber,
    isValidCode,
    useMultiplePayment,
    handlePiAmountChange,
    getMaximumPiAmount,
    /**PAYPAL POC **/
   paypaladressDetails,
   onSucessTransactionOfPaypal
 /**PAYPAL POC **/
  } = props;
  const { t } = useTranslation();
  const cart = useSelector(cartSelector);
  const payMethods = useSelector(payMethodsSelector);
  const [loading, setLoading] = useState(true);

  const maxPiAmount = useMemo(
    () => getMaximumPiAmount(currentPaymentNumber),
    // eslint-disable-next-line react-hooks/exhaustive-deps
    [paymentInfo]
  );
  const policyIdValue = useMemo(
    () => (paymentInfo && paymentInfo.policyId ? paymentInfo.policyId : EMPTY_STRING),
    // eslint-disable-next-line react-hooks/exhaustive-deps
    [paymentInfo]
  );
  useEffect(() => {
    if (payMethods && payMethods.length > 0) {
      setLoading(false);
    }
  }, [paymentInfo, payMethods]);

  return (
    <StyledGrid container spacing={4} className="bottom-margin-2">
      <StyledGrid item container direction="row" justifyContent="space-between" alignItems="center">
        <StyledIconLabel icon={<PaymentIcon />} label={t("PaymentMethodSelection.Title")} />
      </StyledGrid>

      <StyledGrid item xs={12} md={6}>
        {loading ? (
          <div className="horizontal-padding-13">
            <StyledCircularProgress />
          </div>
        ) : (
          <StyledBox className="basic-border" border={1}>
            <StyledFormControl component="fieldset">
              <StyledRadioGroup
                name="payOption"
                value={policyIdValue}
                onChange={(event) => togglePayOption(event.target.value, currentPaymentNumber)}>
                {payMethods &&
                  payMethods.length > 0 &&
                  payMethods.map((payment: any) => (
                    <Fragment key={payment.xumet_policyId}>
                      <StyledFormControlLabel
                        value={payment.xumet_policyId}
                        control={<StyledRadio />}
                        label={<StyledTypography variant="body1">{payment.description}</StyledTypography>}
                        className="vertical-padding-1 pay-option"
                      />

                      {paymentInfo &&
                        paymentInfo.payMethodId !== PAYMENT.paymentMethodName.cod &&
                        paymentInfo.payMethodId !== PAYMENT.paymentMethodName.paypal &&
                        paymentInfo.policyId === payment.xumet_policyId &&
                        paymentInfo.paymentTermConditionId === EMPTY_STRING && (
                          <>
                            <Divider className="horizontal-margin-2" />
                            <StyledGrid container spacing={2} className="horizontal-padding-2 vertical-padding-3">
                              <StyledGrid item xs={12}>
                                <StyledTextField
                                  required
                                  name="account"
                                  value={paymentInfo.creditCardFormData?.account}
                                  label={t("PaymentMethodSelection.Labels.CCNumber")}
                                  type="tel"
                                  onChange={(event) => handleCreditCardChange(event, currentPaymentNumber)}
                                  error={!isValidCardNumber(paymentInfo.creditCardFormData?.account)}
                                  helperText={
                                    !isValidCardNumber(paymentInfo.creditCardFormData?.account)
                                      ? t("PaymentMethodSelection.Msgs.InvalidCardNumber")
                                      : EMPTY_STRING
                                  }
                                  inputProps={{ maxLength: 19 }}
                                  fullWidth
                                />
                              </StyledGrid>

                              <StyledGrid item xs={12} sm={8}>
                                <StyledGrid container spacing={2} alignItems="flex-end">
                                  <StyledGrid item xs={6} sm={5}>
                                    <StyledFormControl variant="outlined">
                                      <StyledInputLabel shrink htmlFor="expire_month">
                                        {t("PaymentMethodSelection.Labels.ExpiryDate")}
                                      </StyledInputLabel>

                                      <StyledSelect
                                        required
                                        native
                                        id="expire_month"
                                        name="expire_month"
                                        value={paymentInfo.creditCardFormData?.expire_month}
                                        onChange={(event) => handleCreditCardChange(event, currentPaymentNumber)}
                                        fullWidth>
                                        {EXPIRY.MONTHS.map((month: any, index: number) => (
                                          <option value={month} key={month}>
                                            {month}
                                          </option>
                                        ))}
                                      </StyledSelect>
                                    </StyledFormControl>
                                  </StyledGrid>
                                  <StyledGrid item xs={6} sm={5}>
                                    <StyledFormControl variant="outlined">
                                      <StyledSelect
                                        native
                                        required
                                        name="expire_year"
                                        value={paymentInfo.creditCardFormData?.expire_year}
                                        onChange={(event) => handleCreditCardChange(event, currentPaymentNumber)}
                                        fullWidth>
                                        {EXPIRY.YEARS.map((year: any, index: number) => (
                                          <option value={year} key={year}>
                                            {year}
                                          </option>
                                        ))}
                                      </StyledSelect>
                                    </StyledFormControl>
                                  </StyledGrid>
                                </StyledGrid>
                              </StyledGrid>

                              <StyledGrid item xs={12} sm={4}>
                                <StyledTextField
                                  required
                                  name="cc_cvc"
                                  value={paymentInfo.creditCardFormData?.cc_cvc}
                                  label={t("PaymentMethodSelection.Labels.CVV")}
                                  type="tel"
                                  onChange={(event) => handleCreditCardChange(event, currentPaymentNumber)}
                                  error={!isValidCode(paymentInfo.creditCardFormData?.cc_cvc)}
                                  helperText={
                                    !isValidCode(paymentInfo.creditCardFormData?.cc_cvc)
                                      ? t("PaymentMethodSelection.Msgs.CVV")
                                      : EMPTY_STRING
                                  }
                                  inputProps={{ maxLength: 4 }}
                                  fullWidth
                                />
                              </StyledGrid>
                            </StyledGrid>
                          </>
                        )}
                    </Fragment>
                  ))}
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
              </StyledRadioGroup>
            </StyledFormControl>
          </StyledBox>
        )}
      </StyledGrid>

      {useMultiplePayment && (
        <StyledGrid item xs={12} md={6}>
          <StyledTypography variant="body2" className="full-width shipment-group-heading">
            {t("PaymentMethodSelection.Labels.OrderTotal")}
          </StyledTypography>
          <StyledTypography variant="body1" className="bottom-margin-2">
            <FormattedPriceDisplay min={parseFloat(cart.grandTotal)} currency={cart.grandTotalCurrency} />
          </StyledTypography>

          <StyledTypography variant="body2" className="full-width shipment-group-heading">
            {t("PaymentMethodSelection.Labels.RemainingAmount")}
          </StyledTypography>
          <StyledTypography variant="body1" className="bottom-margin-2">
            <FormattedPriceDisplay min={maxPiAmount} currency={cart.grandTotalCurrency} />
          </StyledTypography>

          <StyledTypography variant="body2" className="full-width shipment-group-heading">
            {t("PaymentMethodSelection.Labels.AmountToPay")}
          </StyledTypography>
          <StyledNumberInput
            value={parseFloat(paymentInfo.piAmount)}
            min={0.01}
            max={maxPiAmount}
            precision={2}
            onChange={(valueAsNumber) => handlePiAmountChange(valueAsNumber, currentPaymentNumber)}
            strict={true}
          />
        </StyledGrid>
      )}
    </StyledGrid>
  );
};

export { PaymentMethodSelection };
