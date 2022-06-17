# Create Dynamic Ticket

Dynamic Tickets are tickets with flexible admission setup. To create a dynamic ticket, follow the provided steps.

> [!IMPORTANT]
If you don't know how to create ticket setup and tickets, please read related links first.

1. Create the desired **Ticket Item in **Items**.
2. Create the desired admissions in the **Ticket Admission** list.
3. Create **Ticket BOM** with one default **Admission**.
4. Specify **Required Admissions** by setting **Admission Inclusion** to:
   - **Required** - This will add the Admission to be required.
   - **Optional and Not selected** - This will set the admission as **Optional** but not selected.
   - **Optional and Selected** - This will set the admission as **Optional**, but selected by default.
5. If an optional admission requires a separate charge, create a new **Item** and assign it to an optional **Admission** in the **Additional Experience Item No.** field found in the **Ticket Admission** list.
6. 
> [!NOTE]
An item created for an optional admission must **NOT** have the **Ticket Type** field populated.


### Related links
- [Ticket module](../intro.md)
- [Dynamic tickets](../explanation/DynamicTicket.md)