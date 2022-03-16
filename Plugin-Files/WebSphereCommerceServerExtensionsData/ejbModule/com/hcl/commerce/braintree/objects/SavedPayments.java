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

package com.hcl.commerce.braintree.objects;

import java.io.Serializable;
import java.sql.Timestamp;

import javax.persistence.Basic;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.EntityManager;
import javax.persistence.Id;
import javax.persistence.NamedQueries;
import javax.persistence.NamedQuery;
import javax.persistence.PersistenceContext;
import javax.persistence.Table;

import com.hcl.commerce.braintree.objsrc.SavedPaymentsAccessHelper;
import com.ibm.commerce.base.objects.EntityBase;
import com.ibm.commerce.security.AccessHelper;
import com.ibm.commerce.security.Protectable;



/**
 * Entity class for saved payments .
 */
@Entity
@Table(name = "X_SAVEDPAYMENTS")
@NamedQueries({
		@NamedQuery(name = "SavedPayments.getSavedPaymentsByMemberId", query = "select c from SavedPayments c where c.memberId = :memberId") , 
		@NamedQuery(name = "SavedPayments.getSavedPaymentsByMemberIdAndPaymentToken", query = "select c from SavedPayments c where c.memberId = :memberId and c.paymentToken = :paymentToken"),
		@NamedQuery(name = "SavedPayments.getSavedPaymentsByMemberIdAndMarkForDeleteAndAddedInPIAuth", query = "select c from SavedPayments c where c.memberId = :memberId and c.markForDelete = :markForDelete and c.addedInPIAuth = :addedInPIAuth"),
		@NamedQuery(name = "SavedPayments.getSavedPaymentsByMarkForDeleteOrAddedInAuth", query = "select c from SavedPayments c where c.markForDelete = :markForDelete or c.addedInAuth = :addedInAuth"),
		@NamedQuery(name = "SavedPayments.getSavedPaymentsByMarkForDelete", query = "select c from SavedPayments c where c.markForDelete = :markForDelete"),
		@NamedQuery(name = "SavedPayments.getSavedPaymentsByMarkForDeleteAddedInAuthOrCondition", query = "select c from SavedPayments c where c.markForDelete = :markForDelete or c.addedInAuth = :addedInAuth"),
		@NamedQuery(name = "SavedPayments.getSavedPaymentsByAddedInAuth", query = "select c from SavedPayments c where c.addedInAuth = :addedInAuth")
})

public class SavedPayments extends EntityBase implements Serializable, Protectable {
	@PersistenceContext
	private EntityManager manager;
	  
	private static final long serialVersionUID = 1L;

	private Long savedPaymentsId;
	private Long memberId;
	private Integer storeId;
	private String status;
	
	private String paymentType;
	private String paymentAccount;
	private String expiryDate;
	private String paymentToken;
	private String paymentMethodId;

	private Integer markForDelete ;
	private Timestamp markForDeleteDate ;
	
	private Integer markAsProcessed;
	private Integer addedInPIAuth;
	private Integer addedInAuth;
	private Timestamp addedInAuthDate ;
	
	
	
	/**
	 * Default constructor.
	 */
	public SavedPayments() {
	}

	
	/**
	 * Returns the saved payments information  id.
	 * 
	 * @return The saved payments information  id.
	 */
	@Column(name = "X_SAVEDPAYMENTS_ID", nullable = false)
	@Basic(optional = false)
	@Id
	public Long getSavedPaymentsId() {
		return savedPaymentsId;
	}
	
	/**
	 * Sets the saved payments id. 
	 * 
	 * @param saved payments id. 
	 *            The saved payments id.
	 */
	public void setSavedPaymentsId(Long savedPaymentsId) {
		this.savedPaymentsId = savedPaymentsId;
	}
	

	/**
	 * Returns the store id.
	 * 
	 * @return The store id.
	 */
	@Column(name = "STORE_ID")

	public Integer getStoreId() {
		return storeId;
	}

	/**
	 * Sets the store id. 
	 * 
	 * @param store id. 
	 *            The store id.
	 */
	public void setStoreId(Integer storeId) {
		this.storeId = storeId;
	}


	/**
	 * Returns the member id.
	 * 
	 * @return The member id.
	 */
	@Column(name = "MEMBER_ID")
	public Long getMemberId() {
		return memberId;
	}
	
	/**
	 * Sets the member id.
	 * 
	 * @param memberId
	 *            the member id.
	 */
	public void setMemberId(Long memberId) {
		this.memberId = memberId;
	}

	/**
	 * Returns the status
	 * 
	 * @return The status
	 */
	@Column(name = "STATUS")
	public String getStatus() {
		return status;
	}
	
	/**
	 * Sets the status
	 * 
	 * @param status
	 *            The status
	 */
	public void setStatus(String status) {
		this.status = status;
	}

	/**
	 * Returns the payment type
	 * 
	 * @return The payment type
	 */
	@Column(name = "PAYMENT_TYPE")
	public String getPaymentType() {
		return paymentType;
	}
	
	/**
	 * Sets the  payment type
	 * 
	 * @param paymentType
	 *            the  payment type
	 */
	public void setPaymentType(String paymentType) {
		this.paymentType = paymentType;
	}

	
	
	/**
	 * Returns the payment account
	 * 
	 * @return The payment account
	 */
	@Column(name = "PAYMENT_ACCOUNT")
	public String getPaymentAccount() {
		return paymentAccount;
	}
	
	/**
	 * Sets the payment account
	 * 
	 * @param paymentAccount
	 *            the payment account
	 */
	public void setPaymentAccount(String paymentAccount) {
		this.paymentAccount = paymentAccount;
	}

	/**
	 * Returns the expiry date
	 * 
	 * @return The  expiry date
	 */
	@Column(name = "EXPIRY_DATE")
	public String getExpiryDate() {
		return expiryDate;
	}

	/**
	 * Sets the expiry date
	 * 
	 * @param expiryDate
	 *            the expiry date
	 */
	public void setExpiryDate(String expiryDate) {
		this.expiryDate = expiryDate;
	}

	/**
	 * Returns the payment token
	 * 
	 * @return The  payment token
	 */
	@Column(name = "PAYMENT_TOKEN")
	public String getPaymentToken() {
		return paymentToken;
	}

	/**
	 * Sets the payment token
	 * 
	 * @param paymentToken
	 *            the payment token
	 */
	public void setPaymentToken(String paymentToken) {
		this.paymentToken = paymentToken;
	}

	/**
	 * Returns the mark for delete
	 * 
	 * @return The mark for delete
	 */
	@Column(name = "MARK_FOR_DELETE")
	public Integer getMarkForDelete() {
		return markForDelete;
	}

	/**
	 * Sets the mark for delete.
	 * 
	 * @param markForDelete
	 *            the mark for delete.
	 */
	public void setMarkForDelete(Integer markForDelete) {
		this.markForDelete = markForDelete;
	}

	/**
	 * Returns the mark for delete date
	 * 
	 * @return The mark for delete date
	 */
	@Column(name = "MARK_FOR_DELETE_DATE")
	public Timestamp getMarkForDeleteDate() {
		return markForDeleteDate;
	}

	/**
	 * Sets the mark for delete date.
	 * 
	 * @param markForDeleteDate
	 *            the mark for delete date
	 */
	public void setMarkForDeleteDate(Timestamp markForDeleteDate) {
		this.markForDeleteDate = markForDeleteDate;
	}

	

	/**
	 * Returns the mark as processed
	 * 
	 * @return The mark as processed
	 */
	@Column(name = "MARK_AS_PROCESSED")
	public Integer getMarkAsProcessed() {
		return markAsProcessed;
	}

	/**
	 * Sets the mark as processed
	 * 
	 * @param markAsProcessed
	 *            the mark as processed
	 */
	public void setMarkAsProcessed(Integer markAsProcessed) {
		this.markAsProcessed = markAsProcessed;
	}

	/**
	 * Returns the added in PI auth
	 * 
	 * @return The added in PI auth
	 */
	@Column(name = "ADDED_IN_PI_AUTH")
	public Integer getAddedInPIAuth() {
		return addedInPIAuth;
	}

	/**
	 * Sets the added in PI auth
	 * 
	 * @param addedInPIAuth
	 *            the added in PI auth
	 */
	public void setAddedInPIAuth(Integer addedInPIAuth) {
		this.addedInPIAuth = addedInPIAuth;
	}

	/**
	 * Returns the added in auth
	 * 
	 * @return The added in auth
	 */
	@Column(name = "ADDED_IN_AUTH")
	public Integer getAddedInAuth() {
		return addedInAuth;
	}

	/**
	 * Sets the added in auth
	 * 
	 * @param addedInAuth
	 *            the added in auth
	 */
	public void setAddedInAuth(Integer addedInAuth) {
		this.addedInAuth = addedInAuth;
	}


	@Column(name = "PAYMENT_METHOD_ID")
	public String getPaymentMethodId() {
		return paymentMethodId;
	}


	public void setPaymentMethodId(String paymentMethodId) {
		this.paymentMethodId = paymentMethodId;
	}


	/**
	 * Returns the added in auth date
	 * 
	 * @return The added in auth date
	 */
	@Column(name = "ADDED_IN_AUTH_DATE")
	public Timestamp getAddedInAuthDate() {
		return addedInAuthDate;
	}

	/**
	 * Sets the added in auth date
	 * 
	 * @param addedInAuthDate
	 *            the added in auth date
	 */
	public void setAddedInAuthDate(Timestamp addedInAuthDate) {
		this.addedInAuthDate = addedInAuthDate;
	}

	

	@Override
	protected AccessHelper getAccessHelper() {
		if (accessHelper == null) {
			accessHelper = new SavedPaymentsAccessHelper();
		}
		return accessHelper;
	}
	
	

	
}
