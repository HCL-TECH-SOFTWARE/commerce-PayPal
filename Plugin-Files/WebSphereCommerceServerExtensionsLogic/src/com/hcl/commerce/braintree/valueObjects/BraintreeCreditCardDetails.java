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
package com.hcl.commerce.braintree.valueObjects;

public class BraintreeCreditCardDetails {

	public String cardHolderName;
	public String cardType;
	public String expirationDate;
	public String maskedCreditCardNumber;
	public String payTokenId;
	public String paymentAccount;
	public String paymentMethodId;
	
	
	public String getPaymentMethodId() {
		return paymentMethodId;
	}
	public void setPaymentMethodId(String paymentMethodId) {
		this.paymentMethodId = paymentMethodId;
	}
	public String getPaymentAccount() {
		return paymentAccount;
	}
	public void setPaymentAccount(String paymentAccount) {
		this.paymentAccount = paymentAccount;
	}
	public String getCardHolderName() {
		return cardHolderName;
	}
	public void setCardHolderName(String cardHolderName) {
		this.cardHolderName = cardHolderName;
	}
	public String getCardType() {
		return cardType;
	}
	public void setCardType(String cardType) {
		this.cardType = cardType;
	}
	public String getExpirationDate() {
		return expirationDate;
	}
	public void setExpirationDate(String expirationDate) {
		this.expirationDate = expirationDate;
	}
	public String getMaskedCreditCardNumber() {
		return maskedCreditCardNumber;
	}
	public void setMaskedCreditCardNumber(String maskedCreditCardNumber) {
		this.maskedCreditCardNumber = maskedCreditCardNumber;
	}
	public String getPayTokenId() {
		return payTokenId;
	}
	public void setPayTokenId(String payTokenId) {
		this.payTokenId = payTokenId;
	}
	
	
}
