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

import java.util.ArrayList;
import java.util.List;
import java.util.logging.Logger;
import javax.persistence.criteria.CriteriaBuilder;
import javax.persistence.criteria.CriteriaQuery;
import javax.persistence.criteria.Predicate;
import javax.persistence.criteria.Root;

import com.hcl.commerce.braintree.objects.SavedPayments;
import com.ibm.commerce.foundation.common.util.logging.LoggingHelper;
import com.ibm.commerce.foundation.persistence.AbstractJPAEntityDaoImpl;


public class SavedPaymentsDaoImpl extends AbstractJPAEntityDaoImpl<SavedPayments, Long>{

	private static final Logger LOGGER = LoggingHelper.getLogger(SavedPaymentsDaoImpl.class);
	private static final String CLASS_NAME = SavedPaymentsDaoImpl.class.getName();

	/**
	 * Default constructor.
	 */
	public SavedPaymentsDaoImpl() {
		super(SavedPayments.class);
	}
	
	@Override
	protected Predicate[] buildPredicates(CriteriaBuilder cb, CriteriaQuery<?> cq, Root<SavedPayments> root,
			String query, Object... queryParameters) {
		List<Predicate> predicateList = new ArrayList<Predicate>();
		if (query != null) {
			if ("SavedPayments.getSavedPaymentsByMemberId".equals(query)) {
				if (queryParameters != null && queryParameters.length == 1) {
						Long memberId = (Long) queryParameters[0];
						if (memberId != null) {
							predicateList.add(cb.equal(root.get("memberId"), memberId));
						}
					}
				}
				else if ("SavedPayments.getSavedPaymentsByMemberIdAndPaymentToken".equals(query)){
					if (queryParameters != null && queryParameters.length == 2) {
							Long memberId =  (Long)queryParameters[0];
							String paymentToken= (String)queryParameters[1];
							if (memberId != null) {
								predicateList.add(cb.equal(root.get("memberId"), memberId));
							}
							if (paymentToken != null) {
								predicateList.add(cb.equal(root.get("paymentToken"), paymentToken));
							}
						}
				}
				else if("SavedPayments.getSavedPaymentsByMemberIdAndMarkForDeleteAndAddedInPIAuth".equals(query)){
					
					if (queryParameters != null && queryParameters.length == 3) {
							Long memberId =  (Long)queryParameters[0];
							Integer markForDelete =  (Integer)queryParameters[1];
							Integer addedInPIAuth =  (Integer)queryParameters[2];
							
							if (memberId != null) {
								predicateList.add(cb.equal(root.get("memberId"), memberId));
							}
							if (markForDelete != null) {
								predicateList.add(cb.equal(root.get("markForDelete"), markForDelete));
							}
							if (addedInPIAuth != null) {
								predicateList.add(cb.equal(root.get("addedInPIAuth"), addedInPIAuth));
							}
						}
				}
				else if("SavedPayments.getSavedPaymentsByMarkForDeleteOrAddedInAuth".equals(query)){
					if (queryParameters != null && queryParameters.length == 2) {
							Integer markForDelete =  (Integer)queryParameters[0];
							Integer addedInAuth =  (Integer)queryParameters[1];
							if (markForDelete != null) {
								predicateList.add(cb.equal(root.get("markForDelete"), markForDelete));
							}
							if (addedInAuth != null) {
								predicateList.add(cb.equal(root.get("addedInAuth"), addedInAuth));
							}
						}
				}
				else if ("SavedPayments.getSavedPaymentsByMarkForDelete".equals(query)){
					if (queryParameters != null && queryParameters.length == 1) {
						Integer markForDelete =  (Integer)queryParameters[0];
						if (markForDelete != null) {
							predicateList.add(cb.equal(root.get("markForDelete"), markForDelete));
						}
					}
				}
				else if ("SavedPayments.getSavedPaymentsByAddedInAuth".equals(query)){
					if (queryParameters != null && queryParameters.length == 1) {
						Integer addedInAuth =  (Integer)queryParameters[0];
						if (addedInAuth != null) {
							predicateList.add(cb.equal(root.get("addedInAuth"), addedInAuth));
						}
					}
				}
				else if ("SavedPayments.getSavedPaymentsByMarkForDeleteAddedInAuthOrCondition".equals(query)){
				if (queryParameters != null && queryParameters.length == 2) {
						Integer markForDelete =  (Integer)queryParameters[0];
						Integer addedInAuth =  (Integer)queryParameters[1];
						if (markForDelete != null) {
							predicateList.add(cb.equal(root.get("markForDelete"), markForDelete));
						}
						if (addedInAuth != null) {
							predicateList.add(cb.equal(root.get("addedInAuth"), addedInAuth));
						}
					} 
					
		          
		          
				}
			
		}
		Predicate[] predicates = new Predicate[predicateList.size()];
		predicateList.toArray(predicates);
		return predicates;
	}
}
