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
package com.hcl.commerce.braintree.persistence;

import javax.persistence.EntityManager;

import com.hcl.commerce.braintree.objects.SavedPayments;

public class SavedPaymentsService {
	protected EntityManager em;

	  public SavedPaymentsService(EntityManager em) {
	    this.em = em;
	  }
	
		  public void removeSavedPayments(int id) {
			  SavedPayments savedPayment = findSavedPayments(id);
		    if (savedPayment != null) {
		      em.remove(savedPayment);
		    }
		  }

		  public SavedPayments findSavedPayments(int id) {
			 
		    return em.find(SavedPayments.class, id);
		  }
}
