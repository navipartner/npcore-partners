page 6059994 "NPR APIV1 PBISeatWaiterPadLink"
{
    APIGroup = 'powerBI';
    APIPublisher = 'navipartner';
    APIVersion = 'v1.0';
    PageType = API;
    EntityName = 'seatWaiterPadLink';
    EntitySetName = 'seatWaiterPadLinks';
    Caption = 'PowerBI Seat WaiterPadLink';
    DataAccessIntent = ReadOnly;
    ODataKeyFields = SystemId;
    DelayedInsert = true;
    SourceTable = "NPR NPRE Seat.: WaiterPadLink";
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
                field(seatingCode; Rec."Seating Code")
                {
                    Caption = 'Seating Code', Locked = true;
                }
                field(waiterPadNo; Rec."Waiter Pad No.")
                {
                    Caption = 'Waiter Pad No.', Locked = true;
                }
                field(closed; Rec.Closed)
                {
                    Caption = 'Closed', Locked = true;
                }
            }
        }
    }
}