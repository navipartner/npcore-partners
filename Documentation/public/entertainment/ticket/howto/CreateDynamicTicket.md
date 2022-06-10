# Create Dynamic Ticket

Dynamic Ticket is ticket with flexible admission setup.  
To create a dynamic ticket, follow the provided steps.

> [!IMPORTANT]
If you don't know how to create ticket setup and tickets, please read related links first.

1. Create desired Ticket Item in **Items**
2. Create desired Admissions in **Ticket Admission** list
3. Create **Ticket BOM** with one default Admission
4. Specify Required Admissions by setting Admission Inclusion to:
   - Required - This will add the Admission to be required.
   - Optional and Not selected - This will set the admission as optional but not selected.
   - Optional and Selected - This will set the admission as Optional, but selected by default.
5. If optional Admission requires separate charge, create new Item and assign it to optional Admission in **Additional Experience Item No.** in **Ticket Admission** list
> [!NOTE]
Item created for optional Admission must **NOT** have **Ticket Type** populated


### Related links
- [Ticket module](../intro.md)
- [Tickets](../explanation/ticket.md)