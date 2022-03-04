# Create a capture service user

All users working on the [mobile apps](/Documentation/public/wms/howto/install-mobile-apps) should be first created as CS Users.

1. Click the ![Lightbulb that opens the Tell Me feature](../../images/Icons/Lightbulb_icon.png "Tell Me what you want to do") button, enter **CS Users** and choose the related link.        
   The list of the configured users is displayed.     
 
2. Click **New** located in the ribbon in the top part of the screen.
3. Fill out the necessary fields with the following information:
    - **Name** - select the name of a valid Business Central user from the dropdown list.
    - **Password** - provide the password that the user needs to log into Business Central. 
    - **View Documents** - provide the user with access to all warehouse documents or only those assigned to them.     

        - **Assigned** - you can only see the documents that are assigned to you.
        - **Assigned and Unassigned** - you can only see the documents that are assigned to you and all documents that have no user assigned to them.
        - **All** - you can see the documents that are assigned to you, all documents that have no user assigned to them, and all documents assigned to other users.
        - **Super** - you can see all documents and change the status on them.    

    - **Logon Method** - select whether the logon method is automatic or if you're prompted to provide credentials.
    - **User group** - enter or select a valid User Group Code which determines which group the employee belongs to. 
    - **Device Id** - enter or select the device Id of the mobile device attached to the user.  


### Related links
- [CS Logging](../explanation/cs-logging.md)
- [CS Users](../explanation/cs-users.md)
- [CS UIs](../explanation/cs-uis.md)
