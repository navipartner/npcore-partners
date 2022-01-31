page 6151202 "NPR NpCs Store Card Workflows"
{
    Extensible = False;
    Caption = 'Store Workflow Relations';
    DelayedInsert = true;
    PageType = ListPart;
    UsageCategory = None;
    SourceTable = "NPR NpCs Store Workflow Rel.";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Store Code"; Rec."Store Code")
                {

                    Visible = StoreCodeVisible;
                    ToolTip = 'Specifies the value of the Store Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Workflow Code"; Rec."Workflow Code")
                {

                    Visible = (NOT StoreCodeVisible);
                    ToolTip = 'Specifies the value of the Workflow Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Workflow Description"; Rec."Workflow Description")
                {

                    Visible = (NOT StoreCodeVisible);
                    ToolTip = 'Specifies the value of the Workflow Description field';
                    ApplicationArea = NPRRetail;
                }
                field("Send Notification from Store"; Rec."Send Notification from Store")
                {

                    ToolTip = 'Specifies the value of the Send Notification from Store field';
                    ApplicationArea = NPRRetail;
                }
                field("Notify Store via E-mail"; Rec."Notify Store via E-mail")
                {

                    ToolTip = 'Specifies the value of the Notify Store via E-mail field';
                    ApplicationArea = NPRRetail;
                }
                field("Store E-mail Temp. (Pending)"; Rec."Store E-mail Temp. (Pending)")
                {

                    ToolTip = 'Specifies the value of the Store E-mail Template (Pending) field';
                    ApplicationArea = NPRRetail;
                }
                field("Store E-mail Temp. (Expired)"; Rec."Store E-mail Temp. (Expired)")
                {

                    ToolTip = 'Specifies the value of the Store E-mail Template (Expired) field';
                    ApplicationArea = NPRRetail;
                }
                field("Notify Store via Sms"; Rec."Notify Store via Sms")
                {

                    ToolTip = 'Specifies the value of the Notify Store via Sms field';
                    ApplicationArea = NPRRetail;
                }
                field("Store Sms Template (Pending)"; Rec."Store Sms Template (Pending)")
                {

                    ToolTip = 'Specifies the value of the Store Sms Template (Pending) field';
                    ApplicationArea = NPRRetail;
                }
                field("Store Sms Template (Expired)"; Rec."Store Sms Template (Expired)")
                {

                    ToolTip = 'Specifies the value of the Store Sms Template (Expired) field';
                    ApplicationArea = NPRRetail;
                }
                field("Notify Customer via E-mail"; Rec."Notify Customer via E-mail")
                {

                    ToolTip = 'Specifies the value of the Notify Customer via E-mail field';
                    ApplicationArea = NPRRetail;
                }
                field("E-mail Template (Pending)"; Rec."E-mail Template (Pending)")
                {

                    ToolTip = 'Specifies the value of the E-mail Template (Pending) field';
                    ApplicationArea = NPRRetail;
                }
                field("E-mail Template (Confirmed)"; Rec."E-mail Template (Confirmed)")
                {

                    ToolTip = 'Specifies the value of the E-mail Template (Confirmed) field';
                    ApplicationArea = NPRRetail;
                }
                field("E-mail Template (Rejected)"; Rec."E-mail Template (Rejected)")
                {

                    ToolTip = 'Specifies the value of the E-mail Template (Rejected) field';
                    ApplicationArea = NPRRetail;
                }
                field("E-mail Template (Expired)"; Rec."E-mail Template (Expired)")
                {

                    ToolTip = 'Specifies the value of the E-mail Template (Expired) field';
                    ApplicationArea = NPRRetail;
                }
                field("Notify Customer via Sms"; Rec."Notify Customer via Sms")
                {

                    ToolTip = 'Specifies the value of the Notify Customer via Sms field';
                    ApplicationArea = NPRRetail;
                }
                field("Sms Template (Pending)"; Rec."Sms Template (Pending)")
                {

                    ToolTip = 'Specifies the value of the Sms Template (Pending) field';
                    ApplicationArea = NPRRetail;
                }
                field("Sms Template (Confirmed)"; Rec."Sms Template (Confirmed)")
                {

                    ToolTip = 'Specifies the value of the Sms Template (Confirmed) field';
                    ApplicationArea = NPRRetail;
                }
                field("Sms Template (Rejected)"; Rec."Sms Template (Rejected)")
                {

                    ToolTip = 'Specifies the value of the Sms Template (Rejected) field';
                    ApplicationArea = NPRRetail;
                }
                field("Sms Template (Expired)"; Rec."Sms Template (Expired)")
                {

                    ToolTip = 'Specifies the value of the Sms Template (Expired) field';
                    ApplicationArea = NPRRetail;
                }
                field("Processing Print Template"; Rec."Processing Print Template")
                {

                    ToolTip = 'Specifies the value of the Processing Print Template field';
                    ApplicationArea = NPRRetail;
                }
                field("Delivery Print Template (POS)"; Rec."Delivery Print Template (POS)")
                {

                    ToolTip = 'Specifies the value of the Delivery Print Template (POS) field';
                    ApplicationArea = NPRRetail;
                }
                field("Delivery Print Template (S.)"; Rec."Delivery Print Template (S.)")
                {

                    ToolTip = 'Specifies the value of the Delivery Template (Sales Document) field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    var
        StoreCodeVisible: Boolean;

    procedure SetStoreCodeVisible(NewStoreCodeVisible: Boolean)
    begin
        StoreCodeVisible := NewStoreCodeVisible;
    end;
}

