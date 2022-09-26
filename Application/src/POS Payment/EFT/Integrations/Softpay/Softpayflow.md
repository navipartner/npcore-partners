# Softpay POS Protocol
## Setup: BC Configurations
To use the Softpay integration, you need to set it up according to these instructions. Some of the steps are general for Electronic Funds Transfer (EFT) and some are specific for the softpay protocol.
### Page: EFT Setup
In this page, each row corresponds to a setup for a POS unit. If Softpay needs to be set up for multiple POS units, new lines need to be created. 

Payment type: **T**  
POS Unit No.: ***select pos***  
EFT Integration type: **SOFTPAY**  
Integration: **HardwareConnector**

After these parameters has been set, you need to select the POS UNIT Parameters, to set up specific merchant accounts and pair them with POS machines.

### Page: Softpay POS
This page has rows that correspond to exactly one POS (the same POS can only have one configuration) and one merchant. Create new ones to configure each POS.

POS Unit No.: ***select pos***  
Softpay Merchant ID: ***select merchant***

### Page: Softpay Merchants
Softpay uses two types of credentials, those that correspond to a merchant, which is typically store-specific or privilege-based, and the integrator credentials which are app-specific. The integrator ID and credentials are stored in the Azure vault, but Merchant ID and Merchant Password are provided by Softpay. 

Softpay Merchant ID: **Username - by Softpay**  
Softpay Merchant Password: **Password - by Softpay**  
Merchant Description: ***write description to differentiate between mercant profiles***

### Page: Menu Buttons Setup: *MOBILE-PAYMENT*
The POS needs a specific payment option for Softpay, and this is done by navigating to the menu group and adding a new button, there are multiple configurations but only the relevant ones are mentioned here: 

Caption: ***Softpay (or like that)***
Action Type: **PaymentType**
Action Code: **T**  

### Page: POS Unit Card
On the specific POS, you need to set the PaymentV2 option by navigating to the POS Named Action field, selecting from the full list, and then using a *POS Named Actions Profile* that has the *Payment Action Code* set to ***PAYMENT_2***.

## Implementation details
This section describes how the overall protocol of Softpay works, to give the reader a quick overview.  

### Protocol flow

### Streamlining data objects
The following two objects represent the data form of how BC, JS, and C# communicate with one another context-wise.
The overall flow is from the EFT framework, where the majority is already done, so that each integration like Softpay just needs to implement protocol-specific information. 

### Softpay Response JSON
{  
>   **StatusCode**: *{ OK | ERROR }*,  
>   **StatusMsg**: *string*,  
>   **ExternalResultKnown**: *boolean*,  
>   **AquirerID**: *string*,  
>   **AquirerStoreID**: *string*,  
>   **IntegratorID**: *string*,  
>   **TerminalID**: *string*,  
>   **RequestID**: *string*,  
>   **BatchNumber**: *string*,  
>   **AuditNumber**: *string*,  
>   **Amount**: *decimal*,  
}

### Softpay Request JSON
{  
>   **Protocolaction**: *{ Start | Advance | Cancel }*,  
>   **SoftpayAction**: *{ Payment | Refund | Cancellation }*,  
>   **RequestID**: *string*,  
>   **Amount**: *decimal*,  
>   **Currency**: *string*,  
>   **IntegratorID**: *string*,  
>   **IntegratorCredentials**: *char[]*,  
>   **SoftpayUsername**: *string*,  
>   **SoftpayPassword**: *char[]*,  
>       
}


