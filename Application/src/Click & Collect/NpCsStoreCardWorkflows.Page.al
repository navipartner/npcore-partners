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
                    ToolTip = 'Specifies the value of the Store Code field';
                }
                field("Workflow Code"; "Workflow Code")
                {
                    ApplicationArea = All;
                    Visible = (NOT StoreCodeVisible);
                    ToolTip = 'Specifies the value of the Workflow Code field';
                }
                field("Workflow Description"; "Workflow Description")
                {
                    ApplicationArea = All;
                    Visible = (NOT StoreCodeVisible);
                    ToolTip = 'Specifies the value of the Workflow Description field';
                }
                field("Send Notification from Store"; "Send Notification from Store")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Send Notification from Store field';
                }
                field("Notify Store via E-mail"; "Notify Store via E-mail")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Notify Store via E-mail field';
                }
                field("Store E-mail Temp. (Pending)"; "Store E-mail Temp. (Pending)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Store E-mail Template (Pending) field';
                }
                field("Store E-mail Temp. (Expired)"; "Store E-mail Temp. (Expired)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Store E-mail Template (Expired) field';
                }
                field("Notify Store via Sms"; "Notify Store via Sms")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Notify Store via Sms field';
                }
                field("Store Sms Template (Pending)"; "Store Sms Template (Pending)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Store Sms Template (Pending) field';
                }
                field("Store Sms Template (Expired)"; "Store Sms Template (Expired)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Store Sms Template (Expired) field';
                }
                field("Notify Customer via E-mail"; "Notify Customer via E-mail")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Notify Customer via E-mail field';
                }
                field("E-mail Template (Pending)"; "E-mail Template (Pending)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the E-mail Template (Pending) field';
                }
                field("E-mail Template (Confirmed)"; "E-mail Template (Confirmed)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the E-mail Template (Confirmed) field';
                }
                field("E-mail Template (Rejected)"; "E-mail Template (Rejected)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the E-mail Template (Rejected) field';
                }
                field("E-mail Template (Expired)"; "E-mail Template (Expired)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the E-mail Template (Expired) field';
                }
                field("Notify Customer via Sms"; "Notify Customer via Sms")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Notify Customer via Sms field';
                }
                field("Sms Template (Pending)"; "Sms Template (Pending)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sms Template (Pending) field';
                }
                field("Sms Template (Confirmed)"; "Sms Template (Confirmed)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sms Template (Confirmed) field';
                }
                field("Sms Template (Rejected)"; "Sms Template (Rejected)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sms Template (Rejected) field';
                }
                field("Sms Template (Expired)"; "Sms Template (Expired)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sms Template (Expired) field';
                }
                field("Processing Print Template"; "Processing Print Template")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Processing Print Template field';
                }
                field("Delivery Print Template (POS)"; "Delivery Print Template (POS)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Delivery Print Template (POS) field';
                }
                field("Delivery Print Template (S.)"; "Delivery Print Template (S.)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Delivery Template (Sales Document) field';
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

