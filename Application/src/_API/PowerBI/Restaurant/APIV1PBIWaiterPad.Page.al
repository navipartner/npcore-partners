page 6059998 "NPR APIV1 PBIWaiterPad"
{
    APIGroup = 'powerBI';
    APIPublisher = 'navipartner';
    APIVersion = 'v1.0';
    PageType = API;
    EntityName = 'waiterPad';
    EntitySetName = 'waiterPads';
    Caption = 'PowerBI Waiter Pads';
    DataAccessIntent = ReadOnly;
    ODataKeyFields = SystemId;
    DelayedInsert = true;
    SourceTable = "NPR NPRE Waiter Pad";
    Extensible = false;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'SystemId', Locked = true;
                }
                field(no; Rec."No.")
                {
                    Caption = 'No.', Locked = true;
                }
                field(description; Rec.Description)
                {
                    Caption = 'Description', Locked = true;
                }
                field(openedDateTime; Rec.SystemCreatedAt)
                {
                    Caption = 'Opened Date-Time', Locked = true;
                }
                field(closeDate; Rec."Close Date")
                {
                    Caption = 'Close Date', Locked = true;
                }
                field(closeTime; Rec."Close Time")
                {
                    Caption = 'Close Time', Locked = true;
                }
                field(numberOfGuests; Rec."Number of Guests")
                {
                    Caption = 'Number of Guests', Locked = true;
                }
                field(billedNumberOfGuests; Rec."Billed Number of Guests")
                {
                    Caption = 'Billed Number of Guests', Locked = true;
                }
            }
        }
    }
}