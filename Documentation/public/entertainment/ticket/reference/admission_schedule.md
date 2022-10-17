# Admission schedule

Admission schedules define when a location will be open or when an event will be occurring. Multiple schedules can be applied to the same admission object. The setup defines how these entries should be generated based on available rules. Only one entry per date is permitted, so automatic rescheduling is possible if the schedule definition changes. To enable multiple timeslots for the same admission on the same date, multiple schedules need to be created.    


| Field Name      | Description |
| ----------- | ----------- |
| **Schedule Code** | Specifies the code of the schedule. | 
| **Schedule Type** | Specifies whether the scheduled object is a [**location** or **event**](../explanation/LocationVsReservation.md). **Event** needs to be selected for ticket reservation. You can set **Location** for a basic entrance ticket. | 
| **Admission Is** | Specifies whether the schedule generates **Open** or **Closed** time slots. This option is most commonly used in relation to multiple schedules, to ensure the admission is closed on certain holidays. |
| **Description** | Specifies additional information about the schedule. |
| **Start From** | Specifies the start date/base date of the schedule. |
| **Recurrence Until Pattern** | Specifies if or when the schedule is going to stop generating entries. If **End By** is selected, you need to provide the end date in the **End After Date** column. **No End Date** means that recurrence will be unlimited. If you know the exact number of times the event will occur, then you can provide that number in the **End After Occurrence Count** field. However, it's not recommended to do so often. |
| **End After Occurrences** | Specifies the maximum number of occurrences for the scheduled object. |
| **End After Date** | Specifies the final date for the available time slots. |
| **Recurrence Pattern** | Specifies the recurrence pattern, if any. The available options are **Weekly** and **Daily**. |
| **Recur Every N on** | Specifies after how many days or weeks (depending on the selection in **Recurrence Pattern**) the admission to the scheduled object will be possible. |
| **Start Time** | Specifies when the event is going to start or when the location is going to be opened. |
| **Stop Time** | Specifies when the event is going to end or when the location is going to be closed. | 
| **Event Duration** | Specifies the duration of the event. |
| **Event Arrival From Time** | Specifies how long before the event starts it is possible to arrive at earliest. |
| **Event Arrival Until Time** | Specifies how long before the event starts it is possible to arrive at latest. | 
| **Sales From Date (Rel.)** | Specifies a formula relative to the end date of the event which indicates how long before the event's end you can start selling tickets for it. |
| **Sales From Time** | Specifies when you can start selling tickets for the event. | 
| **Sales Until Date (Rel.)** | Specifies a formula relative to the end date of the event, which indicates how long before the event's end you can stop selling tickets for it. |
| **Sales Until Time** | Specifies the time when you need to stop selling tickets for the event. |
| **Monday** - **Sunday** | Generates an entry that is either **Open** or **Closed** if the current date corresponds to the weekdays selected here. |
| **Prebook Is Required** | If enabled, a reservation will be required, and created on sale. An admission will only be allowed at the time specified on the reservation entry (the default schedule rules apply). The actual value can be overridden based on the **Capacity Limits By** option defined for the admission. |
| **Max Capacity Per Sch. Entry** | The defined number indicates the maximum capacity in the admission objects. The number can be overridden based on the **Capacity Limits By** option defined for the admission. |
| **Capacity Control** | Specifies the method for admission control. The following options are available: **None** - no capacity control is required when the admission is recorded; **Sales** - the sum of sold tickets is compared to the **Max Capacity Per Sch. Entry** value; **Admitted** - when admission is recorded, the sum is compared to the **Max Capacity Per Sch. Entry** value; **Admitted & Departed** - specifies how many people are leaving, so that the same amount of people can enter the scheduled object. The selected value can be overridden based on the **Capacity Limits By** option defined for the admission. |
| **Prebook From** | Specifies the date formula which determines how far into the future the time slot can be generated. This, in turn, controls how far ahead the reservation can be made. The value can be overridden based on the **Capacity Limits By** option defined for the admission. |

## Admission schedule usage examples

### Schedule generates open entries for every weekday

To create a schedule that generates open entries for every weekday, you should select the following options:


| Field Name      | Selected Value |
| ----------- | ----------- |
| **Admission Is** | **Open** |
| **Start From** | **2022-10-11** (Tuesday) |
| **Recurrence End Pattern** | **No End Date** |
| **Recurrence Pattern** | **Weekly** |
| **Recur Every N On** | **1** (the same pattern every week) |
| **Monday** | ✓ |
| **Tuesday** | ✓ |
| **Wednesday** | ✓ |
| **Thursday** | ✓ |
| **Friday** | ✓ |
| **Saturday** | X |
| **Sunday** | X |

### Schedule generates closed entries on a specific date

| Field Name      | Selected Value |
| ----------- | ----------- |
| **Admission Is** | **Closed** |
| **Start From** | **2022-12-24** (Saturday) |
| **Recurrence End Pattern** | **End After N Occurrences** |
| **Recurrence Pattern** | **Daily** |
| **End After Occurrences** | **1** |
| **Monday** | ✓ |
| **Tuesday** | ✓ |
| **Wednesday** | ✓ |
| **Thursday** | ✓ |
| **Friday** | ✓ |
| **Saturday** | ✓ |
| **Sunday** | ✓ |

> [!Note]
> All days are checked in this case, because it's not important which weekday December 24th is. However, if you wish the admission to be closed only if 24th is on a weekend, you should check Saturday and Sunday only.

### Related links

- [Ticket admissions](../explanation/admission.md)
- [Admission schedule lines](../explanation/admission_schedule_lines.md)
- [Admission dependency code](../explanation/AdmissionDependencyCode.md)