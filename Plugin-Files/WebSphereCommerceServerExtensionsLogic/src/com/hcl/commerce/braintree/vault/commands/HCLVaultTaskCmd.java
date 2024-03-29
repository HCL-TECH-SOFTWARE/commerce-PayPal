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

import com.ibm.commerce.command.TaskCommand;
import com.ibm.commerce.datatype.TypedProperty;

public interface HCLVaultTaskCmd extends TaskCommand {
	public static final String defaultCommandClassName = "com.hcl.commerce.braintree.vault.commands.HCLVaultTaskCmdImpl";
	
	public String getPayToken();
	public void setRequestProperties(TypedProperty requestProperties);
}
