# Admission schedule lines

In the **Admission Schedule Lines** administrative section, you can combine the admission object with schedule definitions, which makes it possible to define when a specific admission object is accessible. It is also possible to check beyond a single schedule and admission, and limit the sales or an admission to a specific date across multiple admissions and schedules with the concurrency-related options.

> [!Important]
> Bear in mind that some options defined here can be overridden based on the **Capacity Limits By** option defined for the [admission](admission.md).

> [!Note]
> You can state which date the schedule has been proceeded to in the **Schedule Generated Until** field, but note that this is the date the schedule will continue generating entries from. Even though this date is set, there may be no entries created due to the constraint induced by the schedule definition. Thus, creating this date if there are entries created for the admission will result in rescheduling. If the schedule definition is changed, the entries may consequently be cancelled. The rescheduled entries which occur on the same date will retain the external ID they have been initially assigned. 

### Related links

- [Ticket admissions](admission.md)
- [Admission dependency code](AdmissionDependencyCode.md)
- [Admit an issued ticket](../howto/admit_issued_ticket.md)