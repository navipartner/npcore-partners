page 6151202 "NPR NpCs Store Card Workflows"
{
    Caption = 'Store Workflow Relations';
    DelayedInsert = true;
    PageType = ListPart;
    UsageCategory = Administration;
    SourceTable = "NPR NpCs Store Workflow Rel.";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Store Code"; "Store Code")
                {
                    ApplicationArea = All;
                    Visible = StoreCodeVisible;
                }
                field("Workflow Code"; "Workflow Code")
                {
                    ApplicationArea = All;
                    Visible = (NOT StoreCodeVisible);
                }
                field("Workflow Description"; "Workflow Description")
                {
                    ApplicationArea = All;
                    Visible = (NOT StoreCodeVisible);
                }
                field("Send Notification from Store"; "Send Notification from Store")
                {
                    ApplicationArea = All;
                }
                field("Notify Store via E-mail"; "Notify Store via E-mail")
                {
                    ApplicationArea = All;
                }
                field("Store E-mail Temp. (Pending)"; "Store E-mail Temp. (Pending)")
                {
                    ApplicationArea = All;
                }
                field("Store E-mail Temp. (Expired)"; "Store E-mail Temp. (Expired)")
                {
                    ApplicationArea = All;
                }
                field("Notify Store via Sms"; "Notify Store via Sms")
                {
                    ApplicationArea = All;
                }
                field("Store Sms Template (Pending)"; "Store Sms Template (Pending)")
                {
                    ApplicationArea = All;
                }
                field("Store Sms Template (Expired)"; "Store Sms Template (Expired)")
                {
                    ApplicationArea = All;
                }
                field("Notify Customer via E-mail"; "Notify Customer via E-mail")
                {
                    ApplicationArea = All;
                }
                field("E-mail Template (Pending)"; "E-mail Template (Pending)")
                {
                    ApplicationArea = All;
                }
                field("E-mail Template (Confirmed)"; "E-mail Template (Confirmed)")
                {
                    ApplicationArea = All;
                }
                field("E-mail Template (Rejected)"; "E-mail Template (Rejected)")
                {
                    ApplicationArea = All;
                }
                field("E-mail Template (Expired)"; "E-mail Template (Expired)")
                {
                    ApplicationArea = All;
                }
                field("Notify Customer via Sms"; "Notify Customer via Sms")
                {
                    ApplicationArea = All;
                }
                field("Sms Template (Pending)"; "Sms Template (Pending)")
                {
                    ApplicationArea = All;
                }
                field("Sms Template (Confirmed)"; "Sms Template (Confirmed)")
                {
                    ApplicationArea = All;
                }
                field("Sms Template (Rejected)"; "Sms Template (Rejected)")
                {
                    ApplicationArea = All;
                }
                field("Sms Template (Expired)"; "Sms Template (Expired)")
                {
                    ApplicationArea = All;
                }
                field("Processing Print Template"; "Processing Print Template")
                {
                    ApplicationArea = All;
                }
                field("Delivery Print Template (POS)"; "Delivery Print Template (POS)")
                {
                    ApplicationArea = All;
                }
                field("Delivery Print Template (S.)"; "Delivery Print Template (S.)")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    var
        StoreCodeVisible: Boolean;

    procedure SetStoreCodeVisible(NewStoreCodeVisible: Boolean)
    var
        i: Integer;
    begin
        StoreCodeVisible := NewStoreCodeVisible;
    end;
}

