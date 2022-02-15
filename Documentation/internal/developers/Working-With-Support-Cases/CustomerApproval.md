# Customer Approval
Depending on which NAV/BC version customer is using, you can:
- Send them an URL for a web client pointing to restore/container

    Some customers may not like this approach as they might be using windows client so may be confused with look of a web client

- Ask hosting to create ClickOnce installation

    This way, customers can install windows client locally and have same experience as with their live windows client. Downside of this is that some customers may confuse test environment with live. It is important to let them know to remove windows client for test environment after they're done testing

If a customer has trouble testing, you may offer a joined session to help them.

Only after customer approves test, you can proceed to next step. This approval needs to be clearly visible on the case. If this is not clear, ask them directly if testing is complete and if you can proceed to deploy to live environment.