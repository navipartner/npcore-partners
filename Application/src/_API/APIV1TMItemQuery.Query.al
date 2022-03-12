query 6014408 "NPR APIV1 - TM Item Query"
{
    Access = Internal;
    APIGroup = 'core';
    APIPublisher = 'navipartner';
    APIVersion = 'v1.0';
    EntityName = 'tmItemRead';
    EntitySetName = 'tmItemsRead';
    QueryType = API;
    ReadState = ReadShared;

    elements
    {
        dataitem(auxItem; "NPR Aux Item")
        {
            column(no; "Item No.")
            {
                Caption = 'No.', Locked = true;
            }
            column(ticketType; "TM Ticket Type")
            {
                Caption = 'Ticket Type', Locked = true;
            }
        }
    }
}
