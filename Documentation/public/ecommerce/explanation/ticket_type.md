# Ticket Type

Ticketing is one of the cardinal concepts of the NaviPartner's mission - to provide entertainment clients with easy-to-use logistics that lays behind their business. 

The most important thing for a ticket is its setup. The first thing that needs to be configured is the **Ticket Type**, which is located in the **NPR Properties** tab in the ticket's **Item Card**.  Defining this field is mandatory if you wish the item to be treated as a ticket entity. 

As the ticket isn't an actual product, rather an entry into that "product", you need to establish how that product will be handed over. By setting up the **Ticket Type** in Business Central, you're setting up the ticket logistics - some of the POS aspect included (such as **RP Template Code**, **Print Object ID**, etc.).

Important fields

- **Activation Method** - determines how the ticket is going to be activated; whether it's going to be scanned at the entrance (if the **Activation Method** is set to **Scan**), or the ticket is going to be purchased and validated at the entrance (in which scenario the **Activation Method** is set to **POS**).
- **Ticket Entry Validation** - specifies how often the ticket can be activated; for example there are some museums that require the option where the ticket can be used for the entire day, in which case the field should be set to **Same Day**, or if the ticket is going to be scanned only once, the field should be set up to **Single**; the **Multiple** option is going to allow the ticket holder to scan the ticket multiple times, in which scenario the **Max No. of Entries** also needs to be specified.
- **Duration Formula** - specifies for how long the ticket will be valid. All tickets are valid from the day they were purchased, and for the duration expressed in the provided formula.
- **Ticket Configuration Source** - if set up to **Ticket BOM**, the **Activation Method**, **Duration Formula**, **Ticket Entry Validation**, and **Max No. of Entries** won't be valid on the **Ticket Type**. The system is going to look at the **Ticket BOM** for information. 
- **Code** - this code is taken from the Ticket Designer, and it presents a link between the Ticket Designer and Business Central.

### Related links

- [Ticket Admission](../../entertainment/ticket/explanation/admission.md)
