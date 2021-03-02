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
package com.hcl.commerce.braintree.objsrc;

import com.hcl.commerce.braintree.objects.SavedPayments;
import com.ibm.commerce.common.objects.StoreAccessBean;
import com.ibm.commerce.common.objects.StoreEntityAccessBean;
import com.ibm.commerce.registry.StoreRegistry;
import com.ibm.commerce.security.AccessHelper;

public class SavedPaymentsAccessHelper extends AccessHelper {

	public SavedPaymentsAccessHelper() {
	}

	//TODO
	public Long getOwner(Object obj) throws Exception {
		SavedPayments bean = (SavedPayments) obj;
		Integer storeEntId = bean.getStoreId(); //TODO set the storeid here
		StoreAccessBean storeAB = StoreRegistry
				.singleton().find(storeEntId);
		if (storeAB != null) {
			return storeAB.getMemberIdInEntityType();
		} else {
			StoreEntityAccessBean storeEntAB = new StoreEntityAccessBean();
			storeEntAB.setInitKey_storeEntityId(storeEntId.toString());
			return storeEntAB.getMemberIdInEntityType();
		}
	}

	public boolean fulfills(Object obj, Long member, String relationship) throws Exception {
		boolean result=false;
		SavedPayments bean=(SavedPayments)obj;
		if ("creator".equalsIgnoreCase(relationship)) {
			result = member.equals(bean.getMemberId());
		}
		return result;
	}
}
