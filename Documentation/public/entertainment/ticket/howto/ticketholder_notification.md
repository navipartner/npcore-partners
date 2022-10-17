# Generate ticket-holder notifications

Notifications for ticketholders can be created and sent from the ticket management module. Notifications are generated from the admission schedule entries that have reservations.

There are three types of notifications:

- **Reminder** - used when there is one admission schedule entry for the event, and it's open; 
- **Reschedule** - used when there is more than one schedule entry for the same event, the first entry is closed, and the last isn't; 
- **Cancellation** - applied when the last scheduled entry for the event is closed. 

1. Click the ![Lightbulb that opens the Tell Me feature](../../../images/Icons/Lightbulb_icon.png "Tell Me what you want to do") button, enter **Ticket Admissions**, and choose the related link.
2. Select an event, and click **Navigate** in the ribbon, followed by **Admission Schedules**.
3. From here, click **Process** in the ribbon, and then **Schedule Entries**.
4. From the admission entry you wish to notify the ticketholders for, click **Create Ticketholders List**.    
   If the list already exists, there will be prompts regarding actions to append or recreate the list. The ticketholder list is displayed regardless of whether there is someone to notify or not. 
5. If you click **Send Notification**, the system will attempt to send a notification to the selected list of ticketholders that have the **Pending** status, and aren't blocked. 

![send_notification](../images/send_notification.png)

> [!Note]
> The notification method needs to be specified. Currently, only email method is supported.

### Related links

- [Ticketholder notifications](../explanation/TicketHolderNotification.md)