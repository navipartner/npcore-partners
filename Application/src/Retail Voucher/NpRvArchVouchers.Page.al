page 6151022 "NPR NpRv Arch. Vouchers"
{
    Extensible = False;
    Caption = 'Archived Retail Vouchers';
    CardPageID = "NPR NpRv Arch. Voucher Card";
    Editable = false;
    PageType = List;
    SourceTable = "NPR NpRv Arch. Voucher";
    UsageCategory = History;
    ApplicationArea = NPRRetail;


    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No."; Rec."No.")
                {

                    ToolTip = 'Specifies the value of the No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Voucher Type"; Rec."Voucher Type")
                {

                    ToolTip = 'Specifies the value of the Voucher Type field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field("Issue Date"; Rec."Issue Date")
                {

                    ToolTip = 'Specifies the value of the Issue Date field';
                    ApplicationArea = NPRRetail;
                }
                field("Initial Amount"; Rec."Initial Amount")
                {

                    ToolTip = 'Specifies the value of the Initial Amount field';
                    ApplicationArea = NPRRetail;
                }
                field(Amount; Rec.Amount)
                {

                    ToolTip = 'Specifies the value of the Amount field';
                    ApplicationArea = NPRRetail;
                }
                field("Starting Date"; Rec."Starting Date")
                {

                    ToolTip = 'Specifies the value of the Starting Date field';
                    ApplicationArea = NPRRetail;
                }
                field("Ending Date"; Rec."Ending Date")
                {

                    ToolTip = 'Specifies the value of the Ending Date field';
                    ApplicationArea = NPRRetail;
                }
                field("Reference No."; Rec."Reference No.")
                {

                    ToolTip = 'Specifies the value of the Reference No. field';
                    ApplicationArea = NPRRetail;
                }
                field(Name; Rec.Name)
                {

                    ToolTip = 'Specifies the value of the Name field';
                    ApplicationArea = NPRRetail;
                }
                field("Issue Register No."; Rec."Issue Register No.")
                {

                    ToolTip = 'Specifies the value of the Issue Register No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Issue Document Type"; Rec."Issue Document Type")
                {

                    ToolTip = 'Specifies the value of the Issue Document Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Issue Document No."; Rec."Issue Document No.")
                {

                    ToolTip = 'Specifies the value of the Issue Document No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Issue External Document No."; Rec."Issue External Document No.")
                {

                    ToolTip = 'Specifies the value of the Issue External Document No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Issue User ID"; Rec."Issue User ID")
                {

                    ToolTip = 'Specifies the value of the Issue User ID field';
                    ApplicationArea = NPRRetail;
                }
                field("Issue Partner Code"; Rec."Issue Partner Code")
                {

                    ToolTip = 'Specifies the value of the Issue Partner Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Partner Clearing"; Rec."Partner Clearing")
                {

                    ToolTip = 'Specifies the value of the Partner Clearing field';
                    ApplicationArea = NPRRetail;
                }
                field("No. Send"; Rec."No. Send")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the No. Send field';
                    ApplicationArea = NPRRetail;
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

                Promoted = true;
                PromotedOnly = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                ToolTip = 'Executes the Archived Voucher Entries action';
                ApplicationArea = NPRRetail;
            }
            action("Arch. Sending Log")
            {
                Caption = 'Archived Sending Log';
                Image = Log;
                RunObject = Page "NPR NpRv Arch. Sending Log";
                RunPageLink = "Arch. Voucher No." = FIELD("No.");
                ShortCutKey = 'Shift+Ctrl+F7';

                ToolTip = 'Executes the Archived Sending Log action';
                ApplicationArea = NPRRetail;

            }
        }
    }
}

