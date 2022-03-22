# Location vs. reservation/Event:

Admission objects define what tickets are valid for. 
Admission objects can be either a type **location** or an **event** and are defined in **Ticket Admission**:
- **Locations** are typically physical, such as a museum, while events are something within the location, such as a guided tour.
With a few exceptions they work the same. 
-	**Events** admissions, for example, are valid for specific time, while location admissions are valid for any time within a timeframe.

You also have to set **Schedule type** in **Ticket Schedule** where you define when a location is accessible or when an event occurs:

**Location** does not have any capacity control and do not require reservation.

**Event** creates a reservation entry which is relevant for capacity control.
