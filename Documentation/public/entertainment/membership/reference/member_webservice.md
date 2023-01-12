# Membership web services

The following membership web services are available for creating, editing, blocking, and performing other actions via API in regards to memberships.

## Setting up memberships

The following web services can be used for creating memberships and members, updating the member information, and temporarily blocking the memberships from usage, if needed.

| Web Service     | Description |
| ----------- | ----------- |
| **CreateMembership** | Creates an empty membership using a sales item from the membership sales setup table. |
| **AddMembershipMember** | Adds members to an existing membership. |
| **UpdateMember** | Updates an existing member. |
| **UpdateMemberImages** | Updates an existing member's pictures. |
| **BlockMembership** | Blocks an existing membership. | 

## Querying memberships and members

The following web services can be used for the retrieval of membership and member information:

| Web Service     | Description |
| ----------- | ----------- |
| **GetMembership** | Searches for and retrieves information about a membership. |
| **GetMembershipMembers** | Searches for and retrieves a member connected to a specified membership. |
| **GetMemberImage** | Retrieves the image of a specified member. |
| **MembershipValidation** | Checks if a membership is active. |
| **MemberValidation** |  Checks if a member is blocked, and if a membership is active. |
| **MemberCardNumberValidation** | Checks if a member card is valid, and if a membership is active. | 
| **MemberEmailExists** | Checks if an email address has been used on an already existing and active member. |

## Managing the membership product and duration

You can alter memberships' validity via web services.

| Web Service     | Description |
| ----------- | ----------- |
| **GetMembershipChangeItemsList** | Retrieves a list of items that can be used to alter a membership. The membership time frame and price are calculated in the context of the active membership. |  
| **ChangeMembership** | Modifies the membership as described by the item selected from the **GetMembershipChangeItemsList** web service.   | 

## Tickets and registering member integration

Members and tickets are integrated. It's possible to define guest tickets for members. 

| Web Service     | Description |
| ----------- | ----------- |
| **GetMembershipTicketList** | Returns a list of valid ticket items that the member can choose from to accommodate a self-service check-in for themselves, including guests. This is a two-step process - the second half (registering the ticket and the arrival) is provided by the ticket management web service. |
| **MemberCardRegisterArrival** | Used for handling self-service scanning of the member card number, and allowing member entry. This process consists of a single step. |
| **MemberRegisterArrival** | Used for handling self-service scanning of the member number, and allowing members to enter the venue. This process consists of a single step. | 

### Related links

- [Set up Membership module web services](../howto/webservice_setup.md)
- [Set up auto-renewal process](../howto/auto_renewal.md)