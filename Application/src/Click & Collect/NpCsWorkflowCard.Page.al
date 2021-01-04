page 6151198 "NPR NpCs Workflow Card"
{
    Caption = 'Collect Workflow Card';
    PageType = Card;
    UsageCategory = Administration;
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
                    field("Code"; Code)
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Code field';
                    }
                    field(Description; Description)
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Description field';
                    }
                }
            }
            group("Send Order")
            {
                Caption = 'Send Order';
                field("Send Order Module"; "Send Order Module")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Send Order Module field';
                }
                field("Shipment Method Code"; "Shipment Method Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Shipment Method Code field';
                }
                field("Payment Method Code"; "Payment Method Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Payment Method Code field';
                }
                group(Control6014429)
                {
                    ShowCaption = false;
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
                }
                group(Control6014430)
                {
                    ShowCaption = false;
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
                }
                field("Customer Mapping"; "Customer Mapping")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Customer Mapping field';
                }
                field("Fixed Customer No."; "Fixed Customer No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Fixed Customer No. field';
                }
                field("Processing Expiry Duration"; "Processing Expiry Duration")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Processing Expiry Duration field';
                }
                field("Delivery Expiry Days (Qty.)"; "Delivery Expiry Days (Qty.)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Delivery Expiry Days (Qty.) field';
                }
                field("Archive on Delivery"; "Archive on Delivery")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Archive on Delivery field';
                }
                field("Store Stock"; "Store Stock")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Store Stock field';
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
            group("Order Status")
            {
                Caption = 'Order Status';
                field("Order Status Module"; "Order Status Module")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Order Status Module field';
                }
                field("Send Notification from Store"; "Send Notification from Store")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Send Notification from Store field';
                }
                group(Control6014427)
                {
                    ShowCaption = false;
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
                }
                group(Control6014428)
                {
                    ShowCaption = false;
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
                }
            }
            group("IC Clearing")
            {
                Caption = 'IC Clearing';
                field("Post Processing Module"; "Post Processing Module")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Post Processing Module field';
                }
                field("Post on"; "Post on")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Post on field';
                }
                field("Bill via"; "Bill via")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Bill via field';
                }
            }
        }
    }
}

