page 6151198 "NpCs Workflow Card"
{
    // NPR5.50/MHA /20190531  CASE 345261 Object created - Collect in Store
    // NPR5.51/MHA /20190723  CASE 362443 Removed "Auto Post Order on" and added "Archive on Delivery"
    // NPR5.51/MHA /20190819  CASE 364557 Added fields 350 "Store Stock", 360 "Post on", 380 "Bill via"

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
                    field("Code";Code)
                    {
                    }
                    field(Description;Description)
                    {
                    }
                }
            }
            group("Send Order")
            {
                Caption = 'Send Order';
                field("Send Order Module";"Send Order Module")
                {
                }
                field("Shipment Method Code";"Shipment Method Code")
                {
                }
                field("Payment Method Code";"Payment Method Code")
                {
                }
                group(Control6014429)
                {
                    ShowCaption = false;
                    field("Notify Store via E-mail";"Notify Store via E-mail")
                    {
                    }
                    field("E-mail Template";"E-mail Template")
                    {
                    }
                }
                group(Control6014430)
                {
                    ShowCaption = false;
                    field("Notify Store via Sms";"Notify Store via Sms")
                    {
                    }
                    field("Sms Template";"Sms Template")
                    {
                    }
                }
                field("Customer Mapping";"Customer Mapping")
                {
                }
                field("Fixed Customer No.";"Fixed Customer No.")
                {
                }
                field("Processing Expiry Duration";"Processing Expiry Duration")
                {
                }
                field("Delivery Expiry Days (Qty.)";"Delivery Expiry Days (Qty.)")
                {
                }
                field("Archive on Delivery";"Archive on Delivery")
                {
                }
                field("Store Stock";"Store Stock")
                {
                }
                field("Processing Print Template";"Processing Print Template")
                {
                }
                field("Delivery Print Template (POS)";"Delivery Print Template (POS)")
                {
                }
                field("Delivery Print Template (S.)";"Delivery Print Template (S.)")
                {
                }
            }
            group("Order Status")
            {
                Caption = 'Order Status';
                field("Order Status Module";"Order Status Module")
                {
                }
                field("Send Notification from Store";"Send Notification from Store")
                {
                }
                group(Control6014427)
                {
                    ShowCaption = false;
                    field("Notify Customer via E-mail";"Notify Customer via E-mail")
                    {
                    }
                    field("E-mail Template (Pending)";"E-mail Template (Pending)")
                    {
                    }
                    field("E-mail Template (Confirmed)";"E-mail Template (Confirmed)")
                    {
                    }
                    field("E-mail Template (Rejected)";"E-mail Template (Rejected)")
                    {
                    }
                    field("E-mail Template (Expired)";"E-mail Template (Expired)")
                    {
                    }
                }
                group(Control6014428)
                {
                    ShowCaption = false;
                    field("Notify Customer via Sms";"Notify Customer via Sms")
                    {
                    }
                    field("Sms Template (Pending)";"Sms Template (Pending)")
                    {
                    }
                    field("Sms Template (Confirmed)";"Sms Template (Confirmed)")
                    {
                    }
                    field("Sms Template (Rejected)";"Sms Template (Rejected)")
                    {
                    }
                    field("Sms Template (Expired)";"Sms Template (Expired)")
                    {
                    }
                }
            }
            group("IC Clearing")
            {
                Caption = 'IC Clearing';
                field("Post Processing Module";"Post Processing Module")
                {
                }
                field("Post on";"Post on")
                {
                }
                field("Bill via";"Bill via")
                {
                }
            }
        }
    }

    actions
    {
    }
}

