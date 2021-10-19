All development work is tracked primarily in the case system. This is where all NP employees can send work to each other, log time spent and communicate with each other across departments and directly with the customers.

# Core Development
Core development refers to all non-customer work, i.e. work on the NPRetail .app or auxiliary projects like major tom, internal azure functions etc.
For BC development, we use azure devops work items on pull requests to coordinate. We also use devops work items to maintain a backlog.

We have a very basic integration between case system and azure devops: The BC Job Card page has actions for creating new work item based on the case. This will automatically link them together which means the work item will be set to "Closed" when case is closed, moved to "Active" when someone starts a timer on the linked case and otherwise left under "New" in devops.

# Backlog Management
Since NaviPartner has a pretty flat heirarchy you can quickly end up with too many cases assigned to you with different parties interested in the completion of different cases, where these different parties are not coordinating with each other.
As a rule of thumb, you will be expected to align your priorities with stakeholders such as Mark, PMs on customer projects etc.

For **internal** cases (assigned to Customer 70220322 meaning NaviPartner) that you do not expect to have time to work on within the near-term future (i.e. the next month), these are OK to put on the backlog unless something else has been agreed upon.
This is done by using the action on the job card to create a "User Story" work item in Azure Devops and assigning the case to ressource 350 so it is gone from your list.
This is preferable to keeping internal cases assigned to a specific developer for months at a time without any progress as that approach creates a distributed backlog in practice making it harder to prioritize between core development cases.

In other words, strive to keep your case list contained to internal cases you expect to be working on within the next month + any customer projects you are assigned to.

# Customer Development
There are no universal guidelines for case management for customer projects. Ask the assigned PM or Mark for input if prioritization input is needed.


