# Ticket Admission

A **Ticket Admission** defines what a ticket is valid for. 

The admission **Type** determines whether it can be used for a location or an event. 
A location is typically physical, like a museum, while an event is something within the location, such as a guided tour.
Ticket types work in the same way, but there are a few exceptions. A key difference is that a ticket for an event admission is valid for a specific time only, while location admissions are open and thus valid for any time within a larger timeframe.

> [!NOTE]
> Each ticket needs to include at least one ticket admission.

The following fields and options are available for setup: 

| Field name      | Description |
| ----------- | ----------- |
| **Admission Code** | Specifies the location (along with the description); you can also define the  |
| **Type** | Specifies whether it is an event or a fixed location. |
| **Capacity Control** | If you wish to specify the capacity on admission, you can either provide a specific number, or add **Sales** which means that the sales govern how many tickets can be sold. |
| **Default Schedule** | If you wish to schedule the entry, enable **Scheduled Entry Required** (e.g. if a museum has an audio guide, they have a limited number of headphones, which means that their usage needs to be scheduled). |
|  **Capacity Limits By** | The available options are **Admission** (the column is going to look into the **Max Capacity Per Sch. Entry**) and **Schedule** (the column is going to look into the configured schedules). Each admission can have multiple schedules, which are opening hours. |
| **Prebook From** | Configure how far in the future the ticket is going to be created; how much in advance you can prebook the product. |


### Related links

- [Ticket module](../intro.md)
- [Dynamic Ticket](./DynamicTicket.md)