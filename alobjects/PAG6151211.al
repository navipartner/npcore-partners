page 6151211 "NpCs Arch. Document List"
{
    // NPR5.50/MHA /20190531  CASE 345261 Object created - Collect in Store

    Caption = 'Archived Collect Document List';
    InsertAllowed = false;
    PageType = List;
    SourceTable = "NpCs Arch. Document";
    UsageCategory = History;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Document No.";"Document No.")
                {
                }
                field("Reference No.";"Reference No.")
                {
                }
                field(Type;Type)
                {
                }
                field("Workflow Code";"Workflow Code")
                {
                }
                field("Next Workflow Step";"Next Workflow Step")
                {
                }
                field("From Document No.";"From Document No.")
                {
                }
                field("From Store Code";"From Store Code")
                {
                }
                field("To Document Type";"To Document Type")
                {
                }
                field("To Document No.";"To Document No.")
                {
                }
                field("To Store Code";"To Store Code")
                {
                }
                field("Processing Status";"Processing Status")
                {
                }
                field("Processing updated at";"Processing updated at")
                {
                }
                field("Processing updated by";"Processing updated by")
                {
                }
                field("Customer E-mail";"Customer E-mail")
                {
                }
                field("Customer Phone No.";"Customer Phone No.")
                {
                }
                field("Send Notification from Store";"Send Notification from Store")
                {
                }
                field("Notify Customer via E-mail";"Notify Customer via E-mail")
                {
                }
                field("Notify Customer via Sms";"Notify Customer via Sms")
                {
                }
                field("Delivery Status";"Delivery Status")
                {
                }
                field("Delivery updated at";"Delivery updated at")
                {
                }
                field("Delivery updated by";"Delivery updated by")
                {
                }
                field("Delivery Only (Non stock)";"Delivery Only (Non stock)")
                {
                }
                field("Prepaid Amount";"Prepaid Amount")
                {
                }
                field("Prepayment Account No.";"Prepayment Account No.")
                {
                }
                field("Delivery Document Type";"Delivery Document Type")
                {
                }
                field("Delivery Document No.";"Delivery Document No.")
                {
                }
                field("Archive on Delivery";"Archive on Delivery")
                {
                }
                field("Entry No.";"Entry No.")
                {
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action("Log Entries")
            {
                Caption = 'Log Entries';
                Image = Log;
                RunObject = Page "NpCs Arch. Doc. Log Entries";
                RunPageLink = "Document Entry No."=FIELD("Entry No.");
                ShortCutKey = 'Ctrl+F7';
            }
        }
    }
}

