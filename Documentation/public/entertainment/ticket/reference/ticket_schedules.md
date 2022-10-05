# Ticket schedules (reference guide)

Ticket Schedules represent the opening hours of an event. This topic contains the most important fields and options that should be defined in the **Ticket Schedules** administrative section:

| Field Name      | Description |
| ----------- | ----------- |
| **Schedule Type** | Specifies the admission object the ticket is valid for ([**Location** or **Event**](../explanation/LocationVsReservation.md))
| **Admission Is** | Specifies the admission status. If it's in the **Open** status, that means the ticket is purchasable. |
| **Recurrence Until Pattern** | If **End By** is selected, you need to provide the end date in the **End After Date** column. **No End Date** means that recurrence will be unlimited. If you know the exact number of times the event will occur, then that you can provide that number in the **End After Occurrence Count** field. However, it's not recommended to do this very often. |
| **Recurrence Pattern** | You can configure whether the admission subject is going to occur daily, weekly, or only once. |
| **Start Time and Stop Time** | Used in relation to guided tours, showing the **Event Duration** (automatically calculated). | 
| **Event Arrival From Time/Event Arrival Until Time** | These fields manage when the admission is allowed. By default, the arrival time is between the time frames specified in these fields. |
| **Max Capacity Per Sch. Entry** | Specifies the maximum capacity for the admission. |
| **Capacity Control** | The following options are available: **Sales** - on sales, the sum of the sold tickets is compared with the value provided in **Max Capacity Per Sch. Entry**; **None** - no capacity control is applied when an admission is recorded; **Admitted & Departed** - specifies how many people are leaving, so that the same amount of people can enter the venue. |
