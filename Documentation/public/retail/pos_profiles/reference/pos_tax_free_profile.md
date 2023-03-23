# POS tax-free profile (reference guide)

If a shop is tax-free, all sales performed in it are exempt from the payment of certain taxes/duties. In the tax-free profile, it's necessary to set a handler for the Global Blue or the Premier Tax Free interface. The POS Tax Free Profile is used for setting up the tax-free integration when POS sales are performed. When established, it ensures that certain types of goods aren't taxed. 

Global Blue and Premier are both companies that provide tax-free shipping services. Their IC2 solution is available on POS terminals, as well as on other channels. It's possible to set up [Global Blue Tax Free](../../postaxfree/howto/globalblue.md) and Premier Tax Free services in NP Retail.

The following tax-free parameters are linked to each POS unit, and can be configured to suit your business needs:

| Field Name      | Description |
| ----------- | ----------- |
| **POS Unit No.** | Specifies the POS unit for which the tax-free service is set. |
| **Handler ID** | Specifies the specific tax-free solution that the POS unit should use. If you wish to use the Global Blue Tax-free solution, you need to provide **GLOBALBLUE_I2** in this field. |
| **Mode** |  Specifies whether the tax-free actions will connect to a production environment or not. If you're setting up the solution for customers, you can select **PROD** in this field. |
| **Log Level** | Specifies the log level for all tax-free activities. The default value is **ERROR**, i.e. all unsuccessful requests are logged. If you're setting up the tax-free solution for the production environment, make sure you don't select **NONE. |
| **Check POS Terminal IIN** | Enables IIN matching for all EFT payment transactions. You can use this option to suggest the tax-free voucher when the source of the IIN is a region eligible for the tax-free solution. |
| **Request Timeout (ms)** | Specifies how long you need to wait before cancelling the tax-free action. This option is relevant if temporary connection issues occur in the tax-free solution environment. The suggested value is 10000 (10 seconds). |
| **Store Voucher Prints** | Specifies whether to store tax-free prints on the voucher records. If the Global Blue tax-free solution is used, this option should be disabled. |

### Related links

- [Set up Global Blue tax-free solution](../../postaxfree/howto/globalblue.md)
