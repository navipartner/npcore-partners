# Ticket types (reference guide)

The most important thing for a ticket is its setup. Ticket types can be accessed directly from the Role Center, and are used to establish general grouping of tickets. The first thing that needs to be configured is the **Ticket Type**, which is located in the **NPR Properties** tab in the ticket's **Item Card**.  Defining this field is mandatory if you wish the item to be treated as a ticket entity. 

As the ticket isn't an actual product, rather an entry into that "product", you need to establish how that product will be handed over. By setting up the **Ticket Type** in Business Central, you're setting up the ticket logistics - some of the POS aspect included (such as **RP Template Code**, **Print Object ID**, etc.).

The ticket type controls how the ticket is going to behave. It defines the characteristics of a ticket such as:

 - Timeframe for validity
 - Number series
 - External ticket pattern
 - Printing and design of the ticket
 - How the access control is maintained

When creating a new ticket type, the following options are available: 

| Field Name      | Description |
| ----------- | ----------- |
| **Code** | Specifies the code of the ticket type. It is taken from the Ticket Designer, and connects the item to the ticket module. |
| **Description** | Specifies the description of the ticket type. |
| **Print Ticket** | If you wish to print an admission ticket on the POS receipt print, this option needs to be enabled. |
| **Print Object Type** | Specifies the type of the object used for printing. |
| **RP Template Code** | Specifies the print template to be used to print the ticket if the **Print Object Type** is set to **Template**. | 
| **Print Object ID** | Specifies the ID of the object (report or codeunit) used for initiating the printing. The system codeunit for printing tickets is 6014571. |
| **Ticket Admission Registration** | When multiple tickets are sold on the same line in the POS, the ticket can either be created as a group ticket or as an individual ticket. This option controls the ticket creation. The following options are available: **Individual** - the printed ticket will correspond to the quantity of tickets sold; **Group** - a single ticket will be printed per a line in the POS with the quantity as per quantity sold. | 
| **No. Series** | There are two identification values for tickets - ticket numbers and external ticket numbers. The ticket primary key will be generated from this number series. When multiple number series are used, it's crucial that they don't overlap. | 
| **External Ticket Pattern** | This field contains a pattern to generate the external ticket number. The pattern can include the fixed text, the original ticket number, and random characters. Any characters not within the [ and ] will be treated as fixed text. The following characters can be provided: **[S]** - the original ticket number from the series; **[N]** - a random number; **[N*4]** - four random numbers; **[A]** - a random character; **[A*4]** - four random characters; Example: TK-[S]-[N*4] results in TK-< ticket number >-< four random numbers > | 
| **Ticket Activation Method** | Defines how a ticket is activated, and when an admission entry is created; whether it's going to be scanned at the entrance (if the **Activation Method** is set to **Scan**), or the ticket is going to be purchased and validated at the entrance (in which scenario the **Activation Method** is set to **POS**).|
| **Ticket Configuration Source** | The following options are available: **Ticket Type** - uses the settings defined on the specific ticket type; **Ticket BOM** - uses the setting defined per a ticket item in the **Ticket BOM** table. The affected fields are **Duration Formula**, **Max No. of Entries**, **Activation Method**, and **Ticket/Admission Entry Validation**. If set to **Ticket BOM**, the **Activation Method**, **Duration Formula**, **Ticket Entry Validation**, and **Max No. of Entries** won't be valid on the **Ticket Type**. The system is going to look at the **Ticket BOM** for information. |
| **Ticket Duration Formula** | Specifies the timeframe during which a ticket is valid for admission. All tickets are valid from the day they were purchased, and for the duration expressed in the provided formula. |
| **Ticket Entry Validation** | Determines how the admission control engine validates the admissions. The following options are available: **Single** - this ticket is valid for one admission only; **Same Day** - this ticket is valid for unlimited re-admissions on the same date that the first admission was recorded; **Multiple** - the ticket allows as many admissions as specified in the **Max No. of Entries** field, regardless of the date of the first admission recorded. |
| **Max No. of Entries** | Specifies the maximum number of admissions allowed when the **Ticket Entry Validation** field is set to **Multiple**. |
| **Membership Sales Item No.** | Specifies the membership sales item number. This is used only for selling tickets as gift memberships where customers exchange them to a specific membership product within the ticket's **Valid To** period. |
| **Ticket Layout Code** | Specifies the ticket layout code from the online **Ticket Designer**. You need to populate this field if you wish to export a ticket URL when creating a prepaid/postpaid ticket or if you want the ticket URL to be published to notifications during creations. This code can be different from the **Ticket Type Code**. |
| **eTicket Activated** | Specifies if the eTicket should be activated on this ticket type. If activated, a **Wallet Template** file needs to be imported under the **Process** tab. |
| **eTicket Type Code** | Specifies the value of the eTicket type code used to create the eTicket. This value should correspond to the template design on the **Pass Server**. |