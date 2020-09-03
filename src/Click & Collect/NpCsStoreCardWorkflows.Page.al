page 6151202 "NPR NpCs Store Card Workflows"
{
    // NPR5.50/MHA /20190531  CASE 345261 Object created - Collect in Store
    // NPR5.51/MHA /20190822  CASE 364557 Added field 300 "Processing Print Template"
    // NPR5.54/MHA /20200130  CASE 378956 Added Store Notification Fields
    // NPR5.55/MHA /20200526  CASE 406591 Added function SetStoreCodeVisible() to enable Page to be used from Magento Setup

    Caption = 'Store Workflow Relations';
    DelayedInsert = true;
    PageType = ListPart;
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

    actions
    {
    }

    var
        StoreCodeVisible: Boolean;

    procedure SetStoreCodeVisible(NewStoreCodeVisible: Boolean)
    var
        i: Integer;
    begin
        //-NPR5.55 [406591]
        StoreCodeVisible := NewStoreCodeVisible;
        //+NPR5.55 [406591]
    end;
}

