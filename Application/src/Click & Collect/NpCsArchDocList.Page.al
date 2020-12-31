page 6151211 "NPR NpCs Arch. Doc. List"
{
    Caption = 'Archived Collect Document List';
    InsertAllowed = false;
    PageType = List;
    SourceTable = "NPR NpCs Arch. Document";
    UsageCategory = History;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Document No."; "Document No.")
                {
                    ApplicationArea = All;
                }
                field("Reference No."; "Reference No.")
                {
                    ApplicationArea = All;
                }
                field("Inserted at"; "Inserted at")
                {
                    ApplicationArea = All;
                }
                field("Sell-to Customer Name"; "Sell-to Customer Name")
                {
                    ApplicationArea = All;
                }
                field("Archived at"; "Archived at")
                {
                    ApplicationArea = All;
                }
                field(Type; Type)
                {
                    ApplicationArea = All;
                }
                field("Workflow Code"; "Workflow Code")
                {
                    ApplicationArea = All;
                }
                field("Next Workflow Step"; "Next Workflow Step")
                {
                    ApplicationArea = All;
                }
                field("From Document No."; "From Document No.")
                {
                    ApplicationArea = All;
                }
                field("From Store Code"; "From Store Code")
                {
                    ApplicationArea = All;
                }
                field("Location Code"; "Location Code")
                {
                    ApplicationArea = All;
                }
                field("To Document Type"; "To Document Type")
                {
                    ApplicationArea = All;
                }
                field("To Document No."; "To Document No.")
                {
                    ApplicationArea = All;
                }
                field("To Store Code"; "To Store Code")
                {
                    ApplicationArea = All;
                }
                field("Processing Status"; "Processing Status")
                {
                    ApplicationArea = All;
                }
                field("Processing updated at"; "Processing updated at")
                {
                    ApplicationArea = All;
                }
                field("Processing updated by"; "Processing updated by")
                {
                    ApplicationArea = All;
                }
                field("Customer E-mail"; "Customer E-mail")
                {
                    ApplicationArea = All;
                }
                field("Customer Phone No."; "Customer Phone No.")
                {
                    ApplicationArea = All;
                }
                field("Send Notification from Store"; "Send Notification from Store")
                {
                    ApplicationArea = All;
                }
                field("Notify Customer via E-mail"; "Notify Customer via E-mail")
                {
                    ApplicationArea = All;
                }
                field("Notify Customer via Sms"; "Notify Customer via Sms")
                {
                    ApplicationArea = All;
                }
                field("Delivery Status"; "Delivery Status")
                {
                    ApplicationArea = All;
                }
                field("Delivery updated at"; "Delivery updated at")
                {
                    ApplicationArea = All;
                }
                field("Delivery updated by"; "Delivery updated by")
                {
                    ApplicationArea = All;
                }
                field("Store Stock"; "Store Stock")
                {
                    ApplicationArea = All;
                }
                field("Prepaid Amount"; "Prepaid Amount")
                {
                    ApplicationArea = All;
                }
                field("Prepayment Account No."; "Prepayment Account No.")
                {
                    ApplicationArea = All;
                }
                field("Delivery Document Type"; "Delivery Document Type")
                {
                    ApplicationArea = All;
                }
                field("Delivery Document No."; "Delivery Document No.")
                {
                    ApplicationArea = All;
                }
                field("Archive on Delivery"; "Archive on Delivery")
                {
                    ApplicationArea = All;
                }
                field("Entry No."; "Entry No.")
                {
                    ApplicationArea = All;
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
                RunObject = Page "NPR NpCs Arch.Doc.Log Entries";
                RunPageLink = "Document Entry No." = FIELD("Entry No.");
                RunPageView = SORTING("Entry No.")
                              ORDER(Descending);
                ShortCutKey = 'Ctrl+F7';
                ApplicationArea = All;
            }
        }
    }
}

