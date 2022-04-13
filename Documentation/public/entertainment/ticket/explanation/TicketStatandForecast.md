# Ticket Statistics and Forecast

There are several ways to generate ticket-related statistics.
For this purpose, two flexible multidimensional access statistics pages are available in the **Report and Analysis** section.

- **Ticket Access Statistics Matrix**
- **Admission Forecast Matrix**

The two reports will give an overview on *what has happened* and predictions for what *will happen*.

## Ticket Access Statistics Matrix

The Ticket Access Statistics Matrix is a precise method for determining the exact number for valid admissions recorded (e.g. scanning the ticket upon arrival).
The aggregated data is permanent, and will not change over time, as opposed to how the flow filters work (like **Admission Forecast Matrix** underneath), so you need to create a new sum every time to execute a new report.

> [!IMPORTANT]
> If you do not scan the tickets no data will be available. 

In the **Matrix** you choose x (lines) and y (columns) axis. Available data present are ticket **items** and data from the ticket module (**Ticket type, Admission Data, Admission Hour, Period, Admission Code and Variant Code**)

In **Metrics** you will see the **Metrix Total** calculated when the report is generated or updated, as well as settings for the components that provide the specifications for the quantitative measurements, for example how the admission count, time specifications, and trend periods should be defined.

In **Matrix Filters** you can filter the General data with setting a specific **item** filter, **ticket type** and **date and hour**, as well as **Admission Codes** and **Variants**. 

## Admission Forecast Matrix

The **Admission Forecast Matrix** is a quick and precise tool for getting an overview on how your ticket admission is doing according to sales, reservations, utilization, and capacity.

You can choose the admission code for the ticket you wish to see admission data for.

> [!NOTE]
> All ticket schedules connected to the **Admission Code** show up in the list.

In **Display Options** you can choose between:

- **Sales** - shows the amount of sold tickets posted.
- **Reservations** - shows the confirmed reservations.
- **Utilization pct.** - shows what percentage of the admission has been utilized (0% to 100%).
- **Capacity pct.** - shows what percentage of the admissions capacity is left (100% to 0%).

In **Periodtype** you then choose between:  

- **Actual** - only the days visible with admissions set.
- **Day** - all calendar days.
- **Week** - all tickets cumulated by week numbers.
- **Month** - all tickets cumulated by month.
- **Quarter** - all tickets cumulated by quarter.
- **Year** - all tickets cumulated by year.


### Related links

- [Tickets](../intro.md)
- [Ticket admission](./admission.md)
- [Issue tickets from Business Central](../howto/issue_ticket.md)