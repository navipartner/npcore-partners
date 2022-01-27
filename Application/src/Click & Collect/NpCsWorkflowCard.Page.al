page 6151198 "NPR NpCs Workflow Card"
{
    Extensible = False;
    Caption = 'Collect Workflow Card';
    PageType = Card;
    UsageCategory = None;
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

                        ToolTip = 'Specifies the value of the Code field';
                        ApplicationArea = NPRRetail;
                    }
                    field(Description; Rec.Description)
                    {

                        ToolTip = 'Specifies the value of the Description field';
                        ApplicationArea = NPRRetail;
                    }
                }
            }
            group("Send Order")
            {
                Caption = 'Send Order';
                field("Send Order Module"; Rec."Send Order Module")
                {

                    ToolTip = 'Specifies the value of the Send Order Module field';
                    ApplicationArea = NPRRetail;
                }
                field("Shipment Method Code"; Rec."Shipment Method Code")
                {

                    ToolTip = 'Specifies the value of the Shipment Method Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Payment Method Code"; Rec."Payment Method Code")
                {

                    ToolTip = 'Specifies the value of the Payment Method Code field';
                    ApplicationArea = NPRRetail;
                }
                group(Control6014429)
                {
                    ShowCaption = false;
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
                }
                group(Control6014430)
                {
                    ShowCaption = false;
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
                }
                field("Customer Mapping"; Rec."Customer Mapping")
                {

                    ToolTip = 'Specifies the value of the Customer Mapping field';
                    ApplicationArea = NPRRetail;
                }
                field("Fixed Customer No."; Rec."Fixed Customer No.")
                {

                    ToolTip = 'Specifies the value of the Fixed Customer No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Processing Expiry Duration"; Rec."Processing Expiry Duration")
                {

                    ToolTip = 'Specifies the value of the Processing Expiry Duration field';
                    ApplicationArea = NPRRetail;
                }
                field("Delivery Expiry Days (Qty.)"; Rec."Delivery Expiry Days (Qty.)")
                {

                    ToolTip = 'Specifies the value of the Delivery Expiry Days (Qty.) field';
                    ApplicationArea = NPRRetail;
                }
                field("Archive on Delivery"; Rec."Archive on Delivery")
                {

                    ToolTip = 'Specifies the value of the Archive on Delivery field';
                    ApplicationArea = NPRRetail;
                }
                field("Store Stock"; Rec."Store Stock")
                {

                    ToolTip = 'Specifies the value of the Store Stock field';
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
            group("Order Status")
            {
                Caption = 'Order Status';
                field("Order Status Module"; Rec."Order Status Module")
                {

                    ToolTip = 'Specifies the value of the Order Status Module field';
                    ApplicationArea = NPRRetail;
                }
                field("Send Notification from Store"; Rec."Send Notification from Store")
                {

                    ToolTip = 'Specifies the value of the Send Notification from Store field';
                    ApplicationArea = NPRRetail;
                }
                group(Control6014427)
                {
                    ShowCaption = false;
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
                }
                group(Control6014428)
                {
                    ShowCaption = false;
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
                }
            }
            group("IC Clearing")
            {
                Caption = 'IC Clearing';
                field("Post Processing Module"; Rec."Post Processing Module")
                {

                    ToolTip = 'Specifies the value of the Post Processing Module field';
                    ApplicationArea = NPRRetail;
                }
                field("Post on"; Rec."Post on")
                {

                    ToolTip = 'Specifies the value of the Post on field';
                    ApplicationArea = NPRRetail;
                }
                field("Bill via"; Rec."Bill via")
                {

                    ToolTip = 'Specifies the value of the Bill via field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}

