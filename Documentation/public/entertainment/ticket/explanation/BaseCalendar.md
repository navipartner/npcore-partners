# Base Calendar for Ticketing

When managing a complex time-slot setup within ticketing, it can be rather cumbersome to handle the exceptions while using the regular schedule definitions. To overcome this issue, ticketing can use the base calendar and customizable exceptions much the same way Business Central uses base calendars.

With the base calendar setup it is possible to pinpoint specific dates, and mark them as non-working. The reverse is not true - a date starts as working, and the exceptions are handled by the base calendar.

Ticketing has implemented two distinct base calendars intended for different purposes:

- The Admission Base Calendar affects the generated admission schedule entries. Therefore, it's also necessary to (manually) recalculate those entries when the admission base calendar is customized. The result is visible among the **Admission Schedule Entries**, where the admission is marked as **Closed**;
- The Ticket Base Calendar is ad-hoc, and it doesn't require any recalculation. This has a different effect on the listed content of time-slots. Normally, when closed, the time-slot isn't shown, but in this case, the time-slot will be listed as non-selectable. The reason why it's closed will be displayed instead of the capacity;

> [!Note]
> Different base calendars can be assigned to all points of configuration within ticketing. This is intended, but not required. For example, there can be one base calendar per a country, or per a site. The base calendar can be empty or contain general exceptions for common holidays such as Christmas and Easter. The customizations are added on top of the base calendar, and are applied per admission code, schedule code, etc. 

## Admission Base Calendar

Customization to the Admission Base Calendar can done on the following entities:

- **Admission** - the customization will apply to all time-slots using this admission code;
- **Admission Schedule** - the customization will apply to all time-slots using this schedule code;
- **Admission Schedule Line** - the customization will apply to all time-slots using both the admission and the schedule code.

## Ticket Base Calendar

As mentioned before, changes to the Ticket Base Calendar are applied ad-hoc to the time-slot availability. Customization to the Ticket Base Calendar can done on the following entities:

- **TicketBom** - the customization will apply to all time-slots using this ticket item number and the admission code;
- **Admission** - the customization will apply to all time-slots using this admission code.

## Admission Schedules vs. Base Calendar with customizations

The admission and schedules are required in order to generate the time-slots available for an admission. The time-slot generator is rule-based and can generate entries for open and closed time-slots. In order to make rule-based exceptions to a specific time-slot, the different schedules (rules) need be processed in a specific order. For that purpose, there is a field **Process Order** in **Admission Schedule Lines** used for controlling that order.

The automation within the base calendar is low - it supports only two rules for recurring entries - weekly and annually. **Weekly** is good for closing a specific weekday (such as Sunday), and **Annually** can take care of December 25th. Other than that, the non-working days need to be manually maintained. 

One approach to managing complex schedules is to have admission/schedule setup create all the open entries, and handle all the closing entries with the base calendar and date customizations.

### Related links

- [Create and customize base calendar for Admission](../howto/CreateCustomizedCalendar.md)