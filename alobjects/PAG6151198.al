page 6151198 "NpCs Workflow Card"
{
    // NPR5.50/MHA /20190531  CASE 345261 Object created - Collect in Store
    // NPR5.51/MHA /20190723  CASE 362443 Removed "Auto Post Order on" and added "Archive on Delivery"
    // NPR5.51/MHA /20190819  CASE 364557 Added fields 350 "Store Stock", 360 "Post on", 380 "Bill via"
    // NPR5.54/MHA /20200130  CASE 378956 Added Store Notification Fields

    Caption = 'Collect Workflow Card';
    PageType = Card;
    SourceTable = "NpCs Workflow";

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
                    }
                    field(Description; Description)
                    {
                        ApplicationArea = All;
                    }
                }
            }
            group("Send Order")
            {
                Caption = 'Send Order';
                field("Send Order Module"; "Send Order Module")
                {
                    ApplicationArea = All;
                }
                field("Shipment Method Code"; "Shipment Method Code")
                {
                    ApplicationArea = All;
                }
                field("Payment Method Code"; "Payment Method Code")
                {
                    ApplicationArea = All;
                }
                group(Control6014429)
                {
                    ShowCaption = false;
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
                }
                group(Control6014430)
                {
                    ShowCaption = false;
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
                }
                field("Customer Mapping"; "Customer Mapping")
                {
                    ApplicationArea = All;
                }
                field("Fixed Customer No."; "Fixed Customer No.")
                {
                    ApplicationArea = All;
                }
                field("Processing Expiry Duration"; "Processing Expiry Duration")
                {
                    ApplicationArea = All;
                }
                field("Delivery Expiry Days (Qty.)"; "Delivery Expiry Days (Qty.)")
                {
                    ApplicationArea = All;
                }
                field("Archive on Delivery"; "Archive on Delivery")
                {
                    ApplicationArea = All;
                }
                field("Store Stock"; "Store Stock")
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
            group("Order Status")
            {
                Caption = 'Order Status';
                field("Order Status Module"; "Order Status Module")
                {
                    ApplicationArea = All;
                }
                field("Send Notification from Store"; "Send Notification from Store")
                {
                    ApplicationArea = All;
                }
                group(Control6014427)
                {
                    ShowCaption = false;
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
                }
                group(Control6014428)
                {
                    ShowCaption = false;
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
                }
            }
            group("IC Clearing")
            {
                Caption = 'IC Clearing';
                field("Post Processing Module"; "Post Processing Module")
                {
                    ApplicationArea = All;
                }
                field("Post on"; "Post on")
                {
                    ApplicationArea = All;
                }
                field("Bill via"; "Bill via")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
    }
}

