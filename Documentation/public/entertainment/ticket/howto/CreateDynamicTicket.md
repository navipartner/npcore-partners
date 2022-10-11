# Create Dynamic Ticket

Dynamic tickets have a flexible [admission](../explanation/admission.md) setup. To create a dynamic ticket, follow the provided steps.

> [!IMPORTANT]
If you don't know how to set up tickets, please read related links first.

1. Create the **Ticket Item** that corresponds to your business needs in **Items**.
2. Create the desired [admissions](../explanation/admission.md) in the **Ticket Admission** list.
3. Create **Ticket BOM** with one default **Admission**.
4. Specify the **Required Admissions** by setting the **Admission Inclusion** to:
   - **Required** - this option makes the admission mandatory;
   - **Optional and Not selected** - this option sets the admission as **Optional**, but not selected;
   - **Optional and Selected** - this option sets the admission as **Optional**, but selected by default.
5. If an optional admission requires a separate charge, create a new **Item** and assign it to an optional **Admission** in the **Additional Experience Item No.** field found in the **Ticket Admission** list.

> [!NOTE]
An item created for an optional admission must **NOT** have the **Ticket Type** field populated.


### Related links

- [Ticket module](../intro.md)
- [Dynamic tickets](../explanation/DynamicTicket.md)