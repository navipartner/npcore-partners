page 6151202 "NpCs Store Card Workflows"
{
    // NPR5.50/MHA /20190531  CASE 345261 Object created - Collect in Store
    // NPR5.51/MHA /20190822  CASE 364557 Added field 300 "Processing Print Template"

    Caption = 'Store Workflow Relations';
    DelayedInsert = true;
    PageType = ListPart;
    SourceTable = "NpCs Store Workflow Relation";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Workflow Code";"Workflow Code")
                {
                }
                field("Workflow Description";"Workflow Description")
                {
                }
                field("Send Notification from Store";"Send Notification from Store")
                {
                }
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
        }
    }

    actions
    {
    }
}

