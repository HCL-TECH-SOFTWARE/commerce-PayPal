/**
*==================================================
Copyright [2022] [HCL Technologies]

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
package com.hcl.commerce.integration.braintree.commands;

import com.ibm.commerce.command.ControllerCommand;

public interface HCLReturnFromPaypalCmd extends ControllerCommand {

	/** 
	 * Class name of default implementation class used by command factory to 
	 * instantiate this command if this interface is not defined in CMDREG table.
	 */
	public static final String defaultCommandClassName = "com.hcl.commerce.integration.braintree.commands.HCLReturnFromPaypalCmdImpl";
    

}
