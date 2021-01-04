page 6151022 "NPR NpRv Arch. Vouchers"
{
    // NPR5.37/MHA /20171023  CASE 267346 Object created - NaviPartner Retail Voucher
    // NPR5.48/MHA /20180921  CASE 302179 Added field 1007 "Issue Document Type", 1013 "Issue External Document No."
    // NPR5.49/MHA /20190228  CASE 342811 Added Retail Voucher Partner fields used with Cross Company Vouchers
    // NPR5.53/MHA /20191212  CASE 380284 Added "Initial Amount" and hidden "Amount"
    // NPR5.55/BHR /20200511  CASE 404114 Set field Amount to visible
    // NPR5.55/MHA /20200702  CASE 407070 Added Sending Log

    Caption = 'Archived Retail Vouchers';
    CardPageID = "NPR NpRv Arch. Voucher Card";
    Editable = false;
    PageType = List;
    SourceTable = "NPR NpRv Arch. Voucher";
    UsageCategory = History;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No."; "No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No. field';
                }
                field("Voucher Type"; "Voucher Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Voucher Type field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Issue Date"; "Issue Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Issue Date field';
                }
                field("Initial Amount"; "Initial Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Initial Amount field';
                }
                field(Amount; Amount)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Amount field';
                }
                field("Starting Date"; "Starting Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Starting Date field';
                }
                field("Ending Date"; "Ending Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Ending Date field';
                }
                field("Reference No."; "Reference No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Reference No. field';
                }
                field(Name; Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Name field';
                }
                field("Issue Register No."; "Issue Register No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Issue Register No. field';
                }
                field("Issue Document Type"; "Issue Document Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Issue Document Type field';
                }
                field("Issue Document No."; "Issue Document No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Issue Document No. field';
                }
                field("Issue External Document No."; "Issue External Document No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Issue External Document No. field';
                }
                field("Issue User ID"; "Issue User ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Issue User ID field';
                }
                field("Issue Partner Code"; "Issue Partner Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Issue Partner Code field';
                }
                field("Partner Clearing"; "Partner Clearing")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Partner Clearing field';
                }
                field("No. Send"; "No. Send")
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

