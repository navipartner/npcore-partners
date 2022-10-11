# Ticket pricing

Tickets can be priced either via the ERP pricing model, or via time-based pricing. The methods can be combined or used individually.

## ERP price model

The ERP price model is based on item, date, quantity, and customers. It is capable of:

- Quantity and date based price ladders;
- Quantity and date based discount ladders;
- Item discount groups;
- Customer discount groups;
- Campaigns.

 The learn more about the ERP price model, see the following article on [managing sales prices in Dynamics 365 Business Central](https://docs.microsoft.com/en-us/learn/modules/manage-sales-prices-dynamics-365-business-central/).

## Time-based pricing

The ticket time-based model is based on admissions and their schedules. It is capable of overruling the ERP price model with a different price, based on the time slot the ticket is selected for.

- By selecting a fixed price that differs from the the calculated ERP price.
- By adding or subtracting either a fixed amount or a percentage from the selected price. With the relative price method, it’s possible to change the base price with a relative amount. 

With the time-based pricing you create rules defining when a price change is valid. The rules can consider the **booking date** (the date on which you are performing the booking) and **event date** (the date on which you want to participate in the event), the characteristics of those dates (for example which weekday it is) and the number of days between the **booking date** and **event date**.

A rule consists of two sections. The first section describes when the rule is applicable, and the second section describes how to calculate a price deviation.

### Rule Selection

To define when a rule is valid, there are 4-date and 3-date formula fields to identify the **booking date** and the **event date**. These fields can be used in any combination to construct the selection part of the rule.

> [!Note]
> Rules can overlap, and if that happens the most precise rule wins. If multiple rules are found to be equally precise, the rule with the highest line number is persists. 

### Booking Date

The booking date is usually the day when the booking is placed, but since rules can be created ahead of time, the booking date indicates when the rule becomes active. The booking date is expressed as two dates, one being the start date, and one being the end date. If both dates are left blank, the rule will always be valid, and if there is an end date specified, the rule will be not valid after that date.

### Relative Booking Date

Date formulas can be used to define specific characteristics of the booking date. The following relative date formulas are supported:

- D(Number 1-31), f.ex. `D15` will evaluate as true when the booking date is the 15th of the month.
- WD(Number 1-7), f.ex. `WD1` will evaluate as true when the booking date falls on a Monday.
- W(Number 1-53), f.ex. `W17` will evaluate as true when the booking date is in week 17.
- M(Number 1-12), f.ex. `M5` will evaluate as true when the booking date is in May.
- Q(Number 1-4), f.ex, `Q3` will evaluate as true when the booking date is in Quarter 3.

You can also add or subtract date components to calculate a specific date. However, when using `+` and `-` in your formula, it will be parsed to a specific date including the year. For example, to make an exception for December 25, this date formula could be used:
`CY-1Y+1D+M12+D25`

### Event Date

Event booking happens on the current date (today) but since rules can be created ahead of time, the event date specifies when the rule becomes active. The event date is expressed as two dates, one being the start date and one being the end date. If both dates are left blank, the rule will always be valid, and if there is an end date specified, the rule will be not valid after that date.

### Relative Event Date

Date formulas can be used to define specific characteristics of the relative event date. The following relative date formulas are supported:

- D(Number 1-31), f.ex. `D7` will evaluate as true when the event date is the 7th of the month.
- WD(Number 1-7), f.ex. `WD2` will evaluate as true when the event date falls on a Tuesday.
- W(Number 1-53), f.ex. `W17` will evaluate as true when the event date is in week 17.
- M(Number 1-12), f.ex. `M5` will evaluate as true when the event date is in May.
- Q(Number 1-4), f.ex, `Q3` will evaluate as true when the event date is in Quarter 3.

### Relative Until Date

When the sum of the booking date and relative until date exceeds the event date, the rule will be valid. All summation date formulas are valid although it's easiest to predict the result when using `D` (for days).

- +(Number >= 0)D, f.ex. `+14D` will be true when booking date + 14 days is greater than or equal to the event date.
- +(Number >= 0)M, f.ex. `+1M` will be true when booking date + 1 month is greater than or equal to the event date. Note that January 29, 30, 31, + 1 month results in the last day of February being specified (either 28th or 29th). 

> [!Note]
> When multiple rules use the relative-until-date calculation, the rule that overshoots the event date by the narrowest margin is considered the most precise.

### Price Calculation

The second part of the rule is the price calculation. The original amount calculated by the ERP system, can be modified in 3 ways:

- Fixed Amount - The new price is governed by the price rule alone.
- Relative Amount - The new price is reduced or increased with the amount specified by the rule.
- Percentage - A percentage of the original amount is added or subtracted to set the new amount.

## Examples

#### Example 1

When the booking date is in May 2022, the rule 20 will be selected. There are no rules selected when the booking date comes before 2022-04-01 or after 2022-06-30.

|**Line No.**|**Booking Date From**|**Booking Date Until**|**Relative Booking Date Formula**|**Event Date From**|**Event Date Until**|**Relative Event Date Formula**|**Relative Until Date Formula**|
| ----------- | ----------- | ----------- | ----------- | ----------- | ----------- | ----------- | ----------- |
|10|2022-04-01|2022-04-30| | | | | |
|20|2022-05-01|2022-05-31| | | | | |
|30|2022-06-01|2022-06-30| | | | | |

#### Example 2

In order for any of the rules to be true, **booking date** must be during May or June and the selected **event date** in July. 

|**Line No.**|**Booking Date From**|**Booking Date Until**|**Relative Booking Date Formula**|**Event Date From**|**Event Date Until**|**Relative Event Date Formula**|**Relative Until Date Formula**|
| ----------- | ----------- | ----------- | ----------- | ----------- | ----------- | ----------- | ----------- |
|10|2022-04-01|2022-04-30| |2022-07-01|2022-07-31| | |
|20|2022-05-01|2022-05-31| |2022-07-01|2022-07-31| | |
|30|2022-06-01|2022-06-30| |2022-07-01|2022-07-31| | |


#### Example 3

This rule is true when all of the following statements are true.

- the booking date is sometime during May.
- the booking date is a Friday (WeekDay 5).
- the event date is sometime during July.
- the event date falls on Saturday (WeekDay 6).

|**Line No.**|**Booking Date From**|**Booking Date Until**|**Relative Booking Date Formula**|**Event Date From**|**Event Date Until**|**Relative Event Date Formula**|**Relative Until Date Formula**|
| ----------- | ----------- | ----------- | ----------- | ----------- | ----------- | ----------- | ----------- |
|40|2022-05-01|2022-05-31|WD5|2022-07-01|2022-07-31|WD6| |


#### Example 4

This set of rules could be used to increase the price in steps as you are getting closer to the event date. When the event date is more than 28 days away, no rule applies. When the event date is between 22 and 28 days away, rule 50 applies, and so on. When the booking date is the same as the event date (rule 90), the price could be reduced in order to encourage the sellout.

|**Line No.**|**Booking Date From**|**Booking Date Until**|**Relative Booking Date Formula**|**Event Date From**|**Event Date Until**|**Relative Event Date Formula**|**Relative Until Date Formula**|
| ----------- | ----------- | ----------- | ----------- | ----------- | ----------- | ----------- | ----------- |
|50| | | | | | |+28D|
|60| | | | | | |+21D|
|70| | | | | | |+14D|
|80| | | | | | |+7D|
|90| | | | | | |+0D|


### Related links

- [Create a ticket price profile](../howto/CreatePriceProfile.md)