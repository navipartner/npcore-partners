page 6151198 "NPR NpCs Workflow Card"
{
    Caption = 'Collect Workflow Card';
    PageType = Card;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR NpCs Workflow";

    layout
    {
        area(content)
        {
            group(General)
            {
                group(Control6014409)
                {
                    ShowCaption = false;
                    field("Code"; Rec.Code)
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Code field';
                    }
                    field(Description; Rec.Description)
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Description field';
                    }
                }
            }
            group("Send Order")
            {
                Caption = 'Send Order';
                field("Send Order Module"; Rec."Send Order Module")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Send Order Module field';
                }
                field("Shipment Method Code"; Rec."Shipment Method Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Shipment Method Code field';
                }
                field("Payment Method Code"; Rec."Payment Method Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Payment Method Code field';
                }
                group(Control6014429)
                {
                    ShowCaption = false;
                    field("Notify Store via E-mail"; Rec."Notify Store via E-mail")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Notify Store via E-mail field';
                    }
                    field("Store E-mail Temp. (Pending)"; Rec."Store E-mail Temp. (Pending)")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Store E-mail Template (Pending) field';
                    }
                    field("Store E-mail Temp. (Expired)"; Rec."Store E-mail Temp. (Expired)")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Store E-mail Template (Expired) field';
                    }
                }
                group(Control6014430)
                {
                    ShowCaption = false;
                    field("Notify Store via Sms"; Rec."Notify Store via Sms")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Notify Store via Sms field';
                    }
                    field("Store Sms Template (Pending)"; Rec."Store Sms Template (Pending)")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Store Sms Template (Pending) field';
                    }
                    field("Store Sms Template (Expired)"; Rec."Store Sms Template (Expired)")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Store Sms Template (Expired) field';
                    }
                }
                field("Customer Mapping"; Rec."Customer Mapping")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Customer Mapping field';
                }
                field("Fixed Customer No."; Rec."Fixed Customer No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Fixed Customer No. field';
                }
                field("Processing Expiry Duration"; Rec."Processing Expiry Duration")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Processing Expiry Duration field';
                }
                field("Delivery Expiry Days (Qty.)"; Rec."Delivery Expiry Days (Qty.)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Delivery Expiry Days (Qty.) field';
                }
                field("Archive on Delivery"; Rec."Archive on Delivery")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Archive on Delivery field';
                }
                field("Store Stock"; Rec."Store Stock")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Store Stock field';
                }
                field("Processing Print Template"; Rec."Processing Print Template")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Processing Print Template field';
                }
                field("Delivery Print Template (POS)"; Rec."Delivery Print Template (POS)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Delivery Print Template (POS) field';
                }
                field("Delivery Print Template (S.)"; Rec."Delivery Print Template (S.)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Delivery Template (Sales Document) field';
                }
            }
            group("Order Status")
            {
                Caption = 'Order Status';
                field("Order Status Module"; Rec."Order Status Module")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Order Status Module field';
                }
                field("Send Notification from Store"; Rec."Send Notification from Store")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Send Notification from Store field';
                }
                group(Control6014427)
                {
                    ShowCaption = false;
                    field("Notify Customer via E-mail"; Rec."Notify Customer via E-mail")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Notify Customer via E-mail field';
                    }
                    field("E-mail Template (Pending)"; Rec."E-mail Template (Pending)")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the E-mail Template (Pending) field';
                    }
                    field("E-mail Template (Confirmed)"; Rec."E-mail Template (Confirmed)")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the E-mail Template (Confirmed) field';
                    }
                    field("E-mail Template (Rejected)"; Rec."E-mail Template (Rejected)")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the E-mail Template (Rejected) field';
                    }
                    field("E-mail Template (Expired)"; Rec."E-mail Template (Expired)")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the E-mail Template (Expired) field';
                    }
                }
                group(Control6014428)
                {
                    ShowCaption = false;
                    field("Notify Customer via Sms"; Rec."Notify Customer via Sms")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Notify Customer via Sms field';
                    }
                    field("Sms Template (Pending)"; Rec."Sms Template (Pending)")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Sms Template (Pending) field';
                    }
                    field("Sms Template (Confirmed)"; Rec."Sms Template (Confirmed)")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Sms Template (Confirmed) field';
                    }
                    field("Sms Template (Rejected)"; Rec."Sms Template (Rejected)")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Sms Template (Rejected) field';
                    }
                    field("Sms Template (Expired)"; Rec."Sms Template (Expired)")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Sms Template (Expired) field';
                    }
                }
            }
            group("IC Clearing")
            {
                Caption = 'IC Clearing';
                field("Post Processing Module"; Rec."Post Processing Module")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Post Processing Module field';
                }
                field("Post on"; Rec."Post on")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Post on field';
                }
                field("Bill via"; Rec."Bill via")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Bill via field';
                }
            }
        }
    }
}

