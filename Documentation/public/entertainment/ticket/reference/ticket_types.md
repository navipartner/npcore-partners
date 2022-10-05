# Ticket types (reference guide)

In order for an item to behave like a ticket when the item is sold, we need to specify a value in the **Ticket Type** field on the **Item Card**.

The ticket type controls how the ticket is going to behave. It defines the characteristics of a ticket such as:

 - Timeframe for validity
 - Number series
 - External ticket pattern
 - Printing and design of the ticket
 - How the access control is maintained

When creating a new ticket type, the following options are available: 

| Field Name      | Description |
| ----------- | ----------- |
| **Code** | Specifies the code of the ticket type. |
| **Description** | Specifies the description of the ticket type. |
| **Print Ticket** | If you wish to print an admission ticket on the POS receipt print, this option needs to be enabled. |
| **Print Object Type** | Specifies the type of the object used for printing. |
| **RP Template Code** | Specifies the print template to be used to print the ticket if the **Print Object Type** is set to **Template**. | 
| **Print Object ID** | Specifies the ID of the object (report or codeunit) used for initiating the printing. The system codeunit for printing tickets is 6014571. |
| **Ticket Admission Registration** | When multiple tickets are sold on the same line in the POS, the ticket can either be created as a group ticket or as an individual ticket. This option controls the ticket creation. The following options are available: **Individual** - the printed ticket will correspond to the quantity of tickets sold; **Group** - a single ticket will be printed per a line in the POS with the quantity as per quantity sold. | 
| **No. Series** | There are two identification values for tickets - ticket numbers and external ticket numbers. The ticket primary key will be generated from this number series. When multiple number series are used, it's crucial that they don't overlap. | 
| **External Ticket Pattern** | This field contains a pattern to generate the external ticket number. The pattern can include the fixed text, the original ticket number, and random characters. Any characters not within the [ and ] will be treated as fixed text. The following characters can be provided: **[S]** - the original ticket number from the series; **[N]** - a random number; **[N*4]** - four random numbers; **[A]** - a random character; **[A*4]** - four random characters; Example: TK-[S]-[N*4] results in TK-< ticket number >-< four random numbers > |
| **Ticket Activation Methods** | Defines when the admission entry should be created. The following options are available: **Scan** - indicated that the admission is recorded by a scanning station when entering a location/event; **POS** - this option indicated that the admission is recorded when the ticket is sold in the POS; **Invoice** - reserved for future use. |
| **Ticket Configuration Source** | The following options are available: **Ticket Type** - uses the settings defined on the specific ticket type; **Ticket BOM** - uses the setting defined per a ticket item in the **Ticket BOM** table. The affected fields are **Duration Formula**, **Max No. of Entries**, **Activation Method**, and **Ticket/Admission Entry Validation** |
| **Ticket Duration Formula** | Specifies the timeframe during which a ticket is valid for admission. |
| **Ticket Entry Validation** | Determines how the admission control engine validates the admissions. The following options are available: **Single** - this ticket is valid for one admission only; **Same Day** - this ticket is valid for unlimited re-admissions on the same date as the first admission was recorded; **Multiple** - the ticket allows as many admissions as specified in the **Max No. of Entries** field, regardless of the date of the first admission recorded. |
| **Max No. of Entries** | Specifies the maximum number of admissions allowed when the **Ticket Entry Validation** field is set to **Multiple**. |
| **Membership Sales Item No.** | Specifies the membership sales item number. This is used only for selling tickets as gift memberships where customers exchange them to a specific membership product within the ticket's **Valid To** period. |
| **Ticket Layout Code** | Specifies the ticket layout code from the online **Ticket Designer**. You need to populate this field if you wish to export a ticket URL when creating a prepaid/postpaid ticket or if you want the ticket URL to be published to notifications during creations. This code can be different from the **Ticket Type Code**. |
| **eTicket Activated** | Specifies if the eTicket should be activated on this ticket type. If activated, a **Wallet Template** file needs to be imported under the **Process** tab. |
| **eTicket Type Code** | Specifies the value of the eTicket type code used to create the eTicket. This value should correspond to the template design on the **Pass Server**. |