page 6151015 "NPR NpRv Vouchers"
{
    // NPR5.37/MHA /20171023  CASE 267346 Object created - NaviPartner Retail Voucher
    // NPR5.48/MHA /20180921  CASE 302179 Added field 1007 "Issue Document Type", 1013 "Issue External Document No."
    // NPR5.49/MHA /20190228  CASE 342811 Added Retail Voucher Partner fields used with Cross Company Vouchers
    // NPR5.53/MHA /20191212  CASE 380284 Added hidden "Initial Amount"
    // NPR5.55/BHR /20200511  CASE 404115 Added Page Arch.Vouchers
    // NPR5.55/MHA /20200702  CASE 407070 Added Sending Log

    Caption = 'Retail Vouchers';
    CardPageID = "NPR NpRv Voucher Card";
    Editable = false;
    PageType = List;
    SourceTable = "NPR NpRv Voucher";
    UsageCategory = Lists;

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
                field(Open; Open)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Open field';
                }
                field("Initial Amount"; "Initial Amount")
                {
                    ApplicationArea = All;
                    Visible = false;
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
        area(processing)
        {
            group(ArchiveGroup)
            {
                Caption = '&Archive';
                Image = Post;
                action("Arch. Vouchers")
                {
                    Caption = 'Archive Vouchers';
                    Image = Post;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Archive Vouchers action';

                    trigger OnAction()
                    var
                        Voucher: Record "NPR NpRv Voucher";
                        NpRvVoucherMgt: Codeunit "NPR NpRv Voucher Mgt.";
                    begin
                        CurrPage.SetSelectionFilter(Voucher);
                        if not Confirm(Text000, false, Voucher.Count) then
                            exit;

                        NpRvVoucherMgt.ArchiveVouchers(Voucher);
                    end;
                }
                action("Show Expired Vouchers")
                {
                    Caption = 'Show Expired Vouchers';
                    Image = "Filter";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Show Expired Vouchers action';

                    trigger OnAction()
                    begin
                        SetFilter("Ending Date", '<%1', CurrentDateTime);
                    end;
                }
            }
        }
        area(navigation)
        {
            action("Voucher Entries")
            {
                Caption = 'Voucher Entries';
                Image = Entries;
                RunObject = Page "NPR NpRv Voucher Entries";
                RunPageLink = "Voucher No." = FIELD("No.");
                ShortCutKey = 'Ctrl+F7';
                ApplicationArea = All;
                ToolTip = 'Executes the Voucher Entries action';
            }
            action("Sending Log")
            {
                Caption = 'Sending Log';
                Image = Log;
                RunObject = Page "NPR NpRv Sending Log";
                RunPageLink = "Voucher No." = FIELD("No.");
                ShortCutKey = 'Shift+Ctrl+F7';
                ApplicationArea = All;
                ToolTip = 'Executes the Sending Log action';
            }
            action("Show Archived Vouchers")
            {
                Caption = 'Show Archived Vouchers';
                Image = PostedPutAway;
                RunObject = Page "NPR NpRv Arch. Vouchers";
                ApplicationArea = All;
                ToolTip = 'Executes the Show Archived Vouchers action';
            }
        }
    }

    var
        Text000: Label 'Archive %1 selected Vouchers Manually?';
}

