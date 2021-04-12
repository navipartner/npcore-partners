page 6151022 "NPR NpRv Arch. Vouchers"
{
    Caption = 'Archived Retail Vouchers';
    CardPageID = "NPR NpRv Arch. Voucher Card";
    Editable = false;
    PageType = List;
    SourceTable = "NPR NpRv Arch. Voucher";
    UsageCategory = History;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No. field';
                }
                field("Voucher Type"; Rec."Voucher Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Voucher Type field';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Issue Date"; Rec."Issue Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Issue Date field';
                }
                field("Initial Amount"; Rec."Initial Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Initial Amount field';
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Amount field';
                }
                field("Starting Date"; Rec."Starting Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Starting Date field';
                }
                field("Ending Date"; Rec."Ending Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Ending Date field';
                }
                field("Reference No."; Rec."Reference No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Reference No. field';
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Name field';
                }
                field("Issue Register No."; Rec."Issue Register No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Issue Register No. field';
                }
                field("Issue Document Type"; Rec."Issue Document Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Issue Document Type field';
                }
                field("Issue Document No."; Rec."Issue Document No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Issue Document No. field';
                }
                field("Issue External Document No."; Rec."Issue External Document No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Issue External Document No. field';
                }
                field("Issue User ID"; Rec."Issue User ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Issue User ID field';
                }
                field("Issue Partner Code"; Rec."Issue Partner Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Issue Partner Code field';
                }
                field("Partner Clearing"; Rec."Partner Clearing")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Partner Clearing field';
                }
                field("No. Send"; Rec."No. Send")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the No. Send field';
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action("Arch. Voucher Entries")
            {
                Caption = 'Archived Voucher Entries';
                Image = Entries;
                RunObject = Page "NPR NpRv Arch. Voucher Entries";
                RunPageLink = "Arch. Voucher No." = FIELD("No.");
                ShortCutKey = 'Ctrl+F7';
                ApplicationArea = All;
                Promoted = true;
                PromotedOnly = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                ToolTip = 'Executes the Archived Voucher Entries action';
            }
            action("Arch. Sending Log")
            {
                Caption = 'Archived Sending Log';
                Image = Log;
                RunObject = Page "NPR NpRv Arch. Sending Log";
                RunPageLink = "Arch. Voucher No." = FIELD("No.");
                ShortCutKey = 'Shift+Ctrl+F7';
                ApplicationArea = All;
                ToolTip = 'Executes the Archived Sending Log action';

            }
        }
    }
}

