# Sales price maintenance

Sales price can be maintained for all customers, a specific customer, campaign or a group of specified customers. For instance, prices for staff are often based on the **Last Direct Cost** to which a factor is added. Therefore, each time the **Last Direct Cost** changes, the price for staff should be updated as well. This process is maintained by the sales price maintenance feature. 

The following fields and options are available:

| Field Name      | Description |
| ----------- | ----------- |
| **ID** | Specifies the sequential number used for identification of the sales price maintenance entry. |
| **Sales Type** | Specifies the sales type for which the corresponding sales price is created. This is where you select how many entities will be affected by the given sales price (all customers, a specific customer, customer price group or a designated sales price campaign). |
| **Sales Code** | The code used for retrieving specific entities from the **Sales Type** selected in the previous field. |
| **Price List Code** | Specifies the code of the price list that is retrieved and affected by this price maintenance scenario. |
| **Currency Code** | Specifies the code of the currency in which the prices are expressed. |
| **Prices Including VAT** | Specifies whether the prices are VAT-inclusive. |
| **VAT Bus. Posting Gr. (Price)** | Used for retrieving the VAT percentage if the price is VAT-inclusive. |
| **Allow Invoice Disc.** | Specifies if the invoice discount is set on the sales price for this group. |
| **Allow Line Disc.** | Specifies if the line discount is set on the sales price for this group. | 
| **Internal Unit Price** | Specifies the price on which the calculation is based. |
| **Factor** | Specifies the factor for the unit price. | 

### Related links

- [Set up sales price](../howto/sales_price_setup.md)
- [Pricing](../explanation/pricing.md)