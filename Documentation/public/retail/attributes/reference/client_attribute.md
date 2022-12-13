# Client attributes (reference guide)

The following fields and options are available in the **Client Attributes** administrative sections:

| Field     | Description |
| ----------- | ----------- |
| **Code** | Specifies the unique code that is used to identify a client attribute. |
| **Description** | Specifies additional information about this client attribute. |
| **Name** | Specifies the name of the attribute. |
| **Code Caption** | Specifies the name which will be displayed on the page as a caption. |
| **Filter Caption** | Specifies the filter caption which will be displayed on the page. |
| **Blocked** | Block the attribute if you don't want it to be referenced. | 
| **Global** | Specifies whether the attribute can be used globally. | 
| **Value Datatype** | Specifies the data format that the attribute will be displayed as (e.g. integer, Boolean). |
| **On Validate** | The validation is used when there is a set of values that needs to be displayed, and if **Value Datatype** is set to **Code**. Otherwise, this field isn't used. The selected or input data is validated against a set of values that can be in an existing table or predefined in the **Client Attribute Value Lookup** page (reached via the **Related** dropdown in the ribbon of the **Client Attributes** page). |
| **On Format** | You can choose between **Native**, **User's Culture**, and **Custom**. |
| **Lookup Table** | The lookup table is enabled if we want to use the values from an existing table. |
| **Lookup Table ID** | When we're using an existing table for lookup values, we can define which one it will be by providing its ID.  |
| **Lookup Value Field ID** | As there are multiple fields in a table, it's necessary to identify which field will be used for client attributes by providing its ID. |
| **Lookup Description Field ID** | Specifies the description of the field that has been selected in **Lookup Value Field ID**. |

## Client attribute IDs (reference guide)

It's necessary to establish the connection between the attribute code and the IDs of the tables from which values will be extracted. This is done in the **Client Attribute IDs** administrative section, which can be opened from the **Client Attributes** ribbon. 

The following fields and options are available:

| Field     | Description |
| ----------- | ----------- |
| **Table ID** | Specifies the ID used for referencing the table in Business Central. |
| **Attribute Code** | Specifies the code used for referencing the specific client attribute. |
| **Shortcut Attribute ID** | There can be a maximum of 20 attribute IDs that can be predefined. You can choose between **Not Assigned** and **Number from 1 to 20**. For example, in the **Extra Fields** section in the **Item Card**, there is available space for 20 fields, and these fields are referred to as shortcut attributes. By providing them with respective numbers, you establishing their display order on the page. |
| **Entity Attribute ID** | Leave the value of this field set to **Not Assigned**, as it will have no impact on the overall configuration. |

### Related links

- [Set up client attributes](../howto/create_client_atr.md)