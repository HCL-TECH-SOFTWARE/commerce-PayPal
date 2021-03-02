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
package com.hcl.commerce.braintree.vault.commands;

import java.sql.Connection;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.util.LinkedList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
import com.braintreegateway.BraintreeGateway;
import com.braintreegateway.PaymentMethod;
import com.braintreegateway.Result;
import com.braintreegateway.exceptions.NotFoundException;
import com.hcl.commerce.braintree.objects.SavedPayments;
import com.hcl.commerce.braintree.persistence.SavedPaymentsDaoImpl;
import com.hcl.commerce.payments.braintree.util.HCLBrainTreeUtility;
import com.ibm.commerce.base.helpers.BaseJDBCHelper;
import com.ibm.commerce.command.CommandContext;
import com.ibm.commerce.command.ControllerCommandImpl;
import com.ibm.commerce.datatype.TypedProperty;
import com.ibm.commerce.exception.ECApplicationException;
import com.ibm.commerce.exception.ECException;
import com.ibm.commerce.foundation.persistence.EntityDao;
import com.ibm.commerce.ras.ECMessage;
import com.ibm.commerce.ras.ECTrace;
import com.ibm.commerce.ras.ECTraceIdentifiers;


public class HCLDeletePaymentDetailsOfBTVaultCmdImpl extends ControllerCommandImpl
		implements HCLDeletePaymentDetailsOfBTVaultCmd {
	private String store_Id;
	private Integer markForDelete = 1;
	private Integer addInAuth = 1;
	private TypedProperty requestProperties = new TypedProperty();
	private static final String CLASS_NAME = "HCLDeletePaymentDetailsOfBTVaultCmdImpl";
	private static final Logger LOGGER = Logger.getLogger(CLASS_NAME);

	Timestamp currTimestamp = new Timestamp(System.currentTimeMillis());
	private static final long ONE_DAY_IN_MILLISECCONDS = 24 * 60 * 60 * 1000;
	 //give the key name here
	private static final String NUMBER_OF_DAYS="days"; 
	long deleteUnusedAfterNumberOfDays;
	
	

	public void performExecute() throws ECException {
		String METHOD_NAME = "performExecute";
		LOGGER.entering(CLASS_NAME, METHOD_NAME);
		try {
			System.out.println("inside job");
			 boolean deleteFlag = false;
			EntityDao savedPaymentsDao = new SavedPaymentsDaoImpl();
			// addedInAuth is 1
			List<SavedPayments> savedPaymentsListToBeDeleted = savedPaymentsDao.query(
					"SavedPayments.getSavedPaymentsByAddedInAuth", addInAuth);
			//markForDelete is 1
			List<SavedPayments> savedPaymentsListMarkedForDelete = savedPaymentsDao.query("SavedPayments.getSavedPaymentsByMarkForDelete",markForDelete);
			
			//whole list
			savedPaymentsListToBeDeleted.addAll(savedPaymentsListMarkedForDelete);
			System.out.println("savedPaymentsListToBeDeleted.size()::"+savedPaymentsListToBeDeleted.size());
			for (int i = 0; i < savedPaymentsListToBeDeleted.size(); i++) {
				deleteFlag=false;
				SavedPayments savedPaymentInfo = (SavedPayments) savedPaymentsListToBeDeleted.get(i);
				String payToken = savedPaymentInfo.getPaymentToken();
				String customerId = Long.toString(savedPaymentInfo.getMemberId());
				Integer markForDelete = savedPaymentInfo.getMarkForDelete();
				Integer addedInAuth = savedPaymentInfo.getAddedInAuth();
				Integer markAsProcessed = savedPaymentInfo.getMarkAsProcessed();
				Timestamp markForDeleteDate = savedPaymentInfo.getMarkForDeleteDate();
				Timestamp addedInAuthDate = savedPaymentInfo.getAddedInAuthDate();

				Long savedPaymentId = savedPaymentInfo.getSavedPaymentsId();

				long currTimeInMillis = currTimestamp.getTime();
				long timeSpan=currTimeInMillis-addedInAuthDate.getTime();

				if(markForDelete == 1){
					if ((currTimeInMillis - markForDeleteDate.getTime()) >= (deleteUnusedAfterNumberOfDays * ONE_DAY_IN_MILLISECCONDS)) {
						deleteFlag = true;
					}
				}else if(addedInAuth == 1 && markAsProcessed == 1 ){
					deleteFlag = true;
					
				}
				else if((currTimeInMillis - addedInAuthDate.getTime()) >= (deleteUnusedAfterNumberOfDays * ONE_DAY_IN_MILLISECCONDS)){
						 
					deleteFlag = true;
				
				} 
				
				if(deleteFlag){
					 deletePaymentInfoFromBrainTreeVault(customerId, payToken,savedPaymentId);
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	public void deletePaymentInfoFromBrainTreeVault(String customerId, String payToken, Long savedPaymentId){
		  final String METHOD_NAME="deletePaymentInfoFromBrainTreeVault"; 
		try{
			
			BraintreeGateway gateway = HCLBrainTreeUtility.getInstance(new Integer("1"))
					.getGatewayObject(new Integer("1"));
			Result<? extends PaymentMethod> result = gateway.paymentMethod().delete(payToken);
			if(result.isSuccess()){
				deleteSavedPayment(savedPaymentId); //TODO undo it before full testing or commiting
			}else{
				//TODO test it
				LOGGER.logp(Level.FINE, CLASS_NAME, METHOD_NAME, "Failed to delete this paytoken from Braintree :"+payToken);
			}
		}catch (NotFoundException e) {
			LOGGER.logp(Level.FINE, CLASS_NAME, METHOD_NAME, "As this pay token is not found in Braintree,couldn't delete:"+payToken, e);
			
		}
		catch(Exception e){
			// SQL exception
			e.printStackTrace();
		}
	}
	
	
	public void deleteSavedPayment(Long savedPaymentId) throws SQLException {
		final String METHOD_NAME="deleteSavedPayment"; 
		
		// create connection run query
		final String methodName = "deleteCardInformationInDB";
		ECTrace.entry(ECTraceIdentifiers.COMPONENT_EXTERN, CLASS_NAME, methodName);

		Connection connection = null;
		   Statement stmt = null;
		ResultSet results = null;
		try {
			connection = BaseJDBCHelper.getDataSource().getConnection();
			stmt = connection.createStatement();
		      String sql = "DELETE FROM X_SAVEDPAYMENTS WHERE X_SAVEDPAYMENTS_ID = " + savedPaymentId;
		      stmt.executeUpdate(sql);
			
		} catch ( SQLException se) {
			System.out.println("sql exception");
			LOGGER.logp(Level.SEVERE, CLASS_NAME, METHOD_NAME, "Encountered exception [" + se.toString() + "]", se);
			// throw it and continue for remaining records TODO
			
		}
		catch( Exception e){
		      //Handle errors for JDBC
		      e.printStackTrace();
		      System.out.println("other exceptions");
		      LOGGER.logp(Level.SEVERE, CLASS_NAME, METHOD_NAME, "Encountered exception [" + e.toString() + "]", e);
		}
		 finally {
			if (results != null)
				results.close();
			if (stmt != null)
				stmt.close();
			if (connection != null)
				connection.close();

		}

	}

	public void validateParameters() {
		String METHOD_NAME = "validateParameters";
		LOGGER.entering(CLASS_NAME, METHOD_NAME);
		try {
				if (LOGGER.isLoggable(Level.FINEST)) {
					LOGGER.logp(Level.FINEST, CLASS_NAME, METHOD_NAME,
							"request Properties are: " + getCommandContext().getRequestProperties());
				}
	
				requestProperties = getCommandContext().getRequestProperties();
				store_Id = requestProperties.getString("storeId", null);
				String  numberOfDays= requestProperties.getString(NUMBER_OF_DAYS, "0"); //TODO check it
				
				System.out.println("from req prop, storeId is::"+store_Id);
				System.out.println("nunmebr of days from job is days=:"+numberOfDays);
				
					try{ 
					deleteUnusedAfterNumberOfDays=new Long(numberOfDays);
					}
					catch(NumberFormatException ne){
						LOGGER.logp(Level.SEVERE, CLASS_NAME, METHOD_NAME, "numberOfDays value is invaild.Give a valid number to run job");
						throw new NumberFormatException();
					}
				
				
				if (LOGGER.isLoggable(Level.FINEST)) {
					LOGGER.logp(Level.FINEST, CLASS_NAME, METHOD_NAME, "StoreId is " + store_Id + "numberOfDays:"+ numberOfDays);
				}
		} catch (Exception e) {
			LOGGER.info(e.getMessage());
		}
		LOGGER.exiting(CLASS_NAME, METHOD_NAME);
	}

	

	public String getStore_Id() {
		return store_Id;
	}

	public void setStore_Id(String store_Id) {
		this.store_Id = store_Id;
	}


	public TypedProperty getRequestProperties() {
		return requestProperties;
	}

	public void setRequestProperties(TypedProperty requestProperties) {
		this.requestProperties = requestProperties;
	}

	public Integer getMarkForDelete() {
		return markForDelete;
	}

	public void setMarkForDelete(Integer markForDelete) {
		this.markForDelete = markForDelete;
	}

	public long getDeleteUnusedAfterNumberOfDays() {
		return deleteUnusedAfterNumberOfDays;
	}

	public void setDeleteUnusedAfterNumberOfDays(long deleteUnusedAfterNumberOfDays) {
		this.deleteUnusedAfterNumberOfDays = deleteUnusedAfterNumberOfDays;
	}

}
