# CS Logs

There are several types of logs that are maintained in the NP WMS:

## Communication Log (Troubleshooting)

This log can be accessed from [**CS Setup**](cs-setup.md), and it is used to track any unforeseen issues that may occur in the environment. 

If something goes wrong, and you're not sure what caused it, it's possible to activate the **Log Communication** toggle switch in the **General** section of the **CS Setup**. Once active, the necessary data will be gathered from the devices and sent to the **CS Communication Log List** in XML format. This data is used to learn what exactly had caused the issue, which greatly helps in resolving it. 


> [!Video https://www.youtube.com/embed/y7dvMQfFIX4]
## Posting Buffer

The posting buffer keeps track of all transactions handled by the NP WMS module. Every time a user posts a sales order, inventory pick etc. the record of the transaction will be logged in the **Posting Buffer** along with the user ID and timestamp. This log also records failed transactions. 

> [!Note]
> Failed transactions are usually recorded in the Role Center as well. 


> [!Video https://www.youtube.com/embed/n65bodoD-fA]

## Print Buffer 

During the inventory pick, you have the option to post a document. If you choose to do so, a shipping note with all necessary data will be created and ready for printing, so that it can be sent to the shipping company. 

The documents containing this data are preserved in the **Print Buffer** log, so that they can be reprinted if needed. 

> [!Video https://www.youtube.com/embed/1Bq4jv8hAGo]

### Related links

- [CS setup](cs-setup.md)
- [Inventory adjustments](inventory_adjustments.md)