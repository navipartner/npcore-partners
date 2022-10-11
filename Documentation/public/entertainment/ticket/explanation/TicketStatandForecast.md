# Ticket Statistics and Forecast

There are several ways to generate ticket-related statistics.
For this purpose, two flexible multidimensional access statistics pages are available in the **Report and Analysis** section.

- **Ticket Access Statistics Matrix**
- **Admission Forecast Matrix**

The two reports will give an overview on what has happened and predictions for what will happen.

## Ticket Access Statistics Matrix

The Ticket Access Statistics Matrix is a precise method for determining the exact number of valid admissions recorded (e.g. scanning the ticket upon arrival).
The aggregated data is permanent, and will not change over time, as opposed to how the flow filters work (like **Admission Forecast Matrix** underneath), so you need to create a new sum every time you wish to execute a new report.

> [!IMPORTANT]
> If you do not scan the tickets no data will be available. 

In the **Matrix** you choose x (lines) and y (columns) axis. The available data includes ticket **Items**, and the data from the ticket module (**Ticket type, Admission Data, Admission Hour, Period, Admission Code** and **Variant Code**)

In **Metrics** you will see the **Metrix Total** calculated when the report is generated or updated, as well as settings for the components that provide the specifications for the quantitative measurements, for example how the admission count, time specifications, and trend periods should be defined.

In **Matrix Filters** you can filter the general data with setting a specific **Item** filter, **Ticket Type** and **Date and Hour**, as well as **Admission Codes** and **Variants**. 

## Admission Forecast Matrix

The **Admission Forecast Matrix** is a quick and precise tool for getting an overview on how your ticket admission is doing according to sales, reservations, utilization, and capacity.

You can choose the admission code for the ticket you wish to see admission data for.

> [!NOTE]
> All ticket schedules connected to the **Admission Code** show up in the list.

In **Display Options** you can configure the following:

| Field Name      | Description |
| ----------- | ----------- |
| **Sales**       | Specifies the amount of sold tickets posted.  |
| **Reservations**  | Specifies the confirmed reservations.      |
| **Utilization pct.** | Specifies the percentage of the admission has been utilized (0% to 100%). |
| **Capacity pct.** | Specifies the percentage of the admissions capacity is left (100% to 0%). |

In **Period type**, you can choose between the following options:  

| Field Name      | Description |
| ----------- | ----------- |
| **Actual**       | Specifies the days visible with admissions set.  |
| **Day**  | Specifies all calendar days you can choose from.      |
| **Week** | Specifies all tickets cumulated by week numbers. |
| **Month** | Specifies all tickets cumulated by month. |
| **Quarter** | Specifies all tickets cumulated by quarter. |
| **Year** | Specifies all tickets cumulated by year.

### Related links

- [Ticket admission](./admission.md)
- [Issue tickets from Business Central](../howto/issue_ticket.md)