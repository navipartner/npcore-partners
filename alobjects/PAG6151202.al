page 6151202 "NpCs Store Card Workflows"
{
    // NPR5.50/MHA /20190531  CASE 345261 Object created - Collect in Store
    // NPR5.51/MHA /20190822  CASE 364557 Added field 300 "Processing Print Template"
    // NPR5.54/MHA /20200130  CASE 378956 Added Store Notification Fields
    // NPR5.55/MHA /20200526  CASE 406591 Added function SetStoreCodeVisible() to enable Page to be used from Magento Setup

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
                field("Store Code";"Store Code")
                {
                    Visible = StoreCodeVisible;
                }
                field("Workflow Code";"Workflow Code")
                {
                    Visible = (NOT StoreCodeVisible);
                }
                field("Workflow Description";"Workflow Description")
                {
                    Visible = (NOT StoreCodeVisible);
                }
                field("Send Notification from Store";"Send Notification from Store")
                {
                }
                field("Notify Store via E-mail";"Notify Store via E-mail")
                {
                }
                field("Store E-mail Temp. (Pending)";"Store E-mail Temp. (Pending)")
                {
                }
                field("Store E-mail Temp. (Expired)";"Store E-mail Temp. (Expired)")
                {
                }
                field("Notify Store via Sms";"Notify Store via Sms")
                {
                }
                field("Store Sms Template (Pending)";"Store Sms Template (Pending)")
                {
                }
                field("Store Sms Template (Expired)";"Store Sms Template (Expired)")
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

