page 6151211 "NPR NpCs Arch. Doc. List"
{
    Caption = 'Archived Collect Document List';
    InsertAllowed = false;
    PageType = List;
    SourceTable = "NPR NpCs Arch. Document";
    UsageCategory = History;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Document No. field';
                }
                field("Reference No."; Rec."Reference No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Reference No. field';
                }
                field("Inserted at"; Rec."Inserted at")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Inserted at field';
                }
                field("Sell-to Customer Name"; Rec."Sell-to Customer Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sell-to Customer Name field';
                }
                field("Archived at"; Rec."Archived at")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Archived at field';
                }
                field(Type; Rec.Type)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Type field';
                }
                field("Workflow Code"; Rec."Workflow Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Workflow Code field';
                }
                field("Next Workflow Step"; Rec."Next Workflow Step")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Next Workflow Step field';
                }
                field("From Document No."; Rec."From Document No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the From Document No. field';
                }
                field("From Store Code"; Rec."From Store Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the From Store Code field';
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Location Code field';
                }
                field("To Document Type"; Rec."To Document Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the To Document Type field';
                }
                field("To Document No."; Rec."To Document No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the To Document No. field';
                }
                field("To Store Code"; Rec."To Store Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the To Store Code field';
                }
                field("Processing Status"; Rec."Processing Status")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Processing Status field';
                }
                field("Processing updated at"; Rec."Processing updated at")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Processing updated at field';
                }
                field("Processing updated by"; Rec."Processing updated by")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Processing updated by field';
                }
                field("Customer E-mail"; Rec."Customer E-mail")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Customer E-mail field';
                }
                field("Customer Phone No."; Rec."Customer Phone No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Customer Phone No. field';
                }
                field("Send Notification from Store"; Rec."Send Notification from Store")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Send Notification from Store field';
                }
                field("Notify Customer via E-mail"; Rec."Notify Customer via E-mail")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Notify Customer via E-mail field';
                }
                field("Notify Customer via Sms"; Rec."Notify Customer via Sms")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Notify Customer via Sms field';
                }
                field("Delivery Status"; Rec."Delivery Status")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Delivery Status field';
                }
                field("Delivery updated at"; Rec."Delivery updated at")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Delivery updated at field';
                }
                field("Delivery updated by"; Rec."Delivery updated by")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Delivery updated by field';
                }
                field("Store Stock"; Rec."Store Stock")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Store Stock field';
                }
                field("Prepaid Amount"; Rec."Prepaid Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Prepaid Amount field';
                }
                field("Prepayment Account No."; Rec."Prepayment Account No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Prepayment Account No. field';
                }
                field("Delivery Document Type"; Rec."Delivery Document Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Delivery Document Type field';
                }
                field("Delivery Document No."; Rec."Delivery Document No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Delivery Document No. field';
                }
                field("Archive on Delivery"; Rec."Archive on Delivery")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Archive on Delivery field';
                }
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Entry No. field';
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
                ToolTip = 'Executes the Log Entries action';
            }
        }
    }
}

