query 6014408 "NPR APIV1 - TM Item Query"
{
    Access = Internal;
    APIGroup = 'core';
    APIPublisher = 'navipartner';
    APIVersion = 'v1.0';
    EntityName = 'tmItemRead';
    EntitySetName = 'tmItemsRead';
    //OrderBy = ascending(replicationCounter);
    QueryType = API;
    ReadState = ReadShared;

    elements
    {
        dataitem(item; Item)
        {
            column(no; "No.")
            {
                Caption = 'No.', Locked = true;
            }
            column(ticketType; "NPR Ticket Type")
            {
                Caption = 'Ticket Type', Locked = true;
            }
        }
    }
}
