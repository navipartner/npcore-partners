# Ticket Admission

A **Ticket Admission** defines what a ticket is valid for. 

The admission can be either tied to a location or an event. 
A location is typically physical, like a museum, while an event is something within the location, such as a guided tour.

A ticket for an event admission is valid for a specific time only, while location admissions are open and thus valid for any time within a larger timeframe.

> [!NOTE]
> Each ticket needs to include at least one ticket admission.

The following fields and options are available for setup: 

| Field name      | Description |
| ----------- | ----------- |
| **Admission Code** | Specifies the code which represents the type of venue (along with the description); you can also define whether it's an event or a fixed location.   |
| **Type** | Specifies whether this is an event or a fixed location. If a reservation is required on the ticket, the type has to be **Event**. |
| **Capacity Limits By** | The available options are: **Admission** - the column is going to look into the **Max Capacity Per Sch. Entry**; **Schedule** - the column is going to look into the configured schedules. Each admission can have multiple schedules, which are opening hours. |
| **Default Schedule** | This controls how a schedule is selected. **Today** - selects the next available schedule for the current day; **Next available** - selects the next available schedule regardless of whether this schedule is valid for the current day; **Scheduled Entry Required** - forces a prompt to select a specific schedule. |
| **Prebook From** | Configure how far in the future the ticket is going to be created; how much in advance you can prebook the product. |
| **Capacity Control** | This controls how the capacity is handled: **None** - offers no capacity control; **Sales** - enables the sale of tickets equal to the amount stated in **Max Capacity**; **Admitted** - enables admission of tickets equal to the amount stated in **Max Capacity**; **Admitted and Depart** - enables admission of tickets equal to the amount stated in **Max Capacity**, but also allows for departure to be registered, freeing up the capacity. |


### Related links

- [Ticket module](../intro.md)
- [Dynamic Ticket](./DynamicTicket.md)