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
                }
                field("Voucher Type"; "Voucher Type")
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("Issue Date"; "Issue Date")
                {
                    ApplicationArea = All;
                }
                field(Open; Open)
                {
                    ApplicationArea = All;
                }
                field("Initial Amount"; "Initial Amount")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field(Amount; Amount)
                {
                    ApplicationArea = All;
                }
                field("Starting Date"; "Starting Date")
                {
                    ApplicationArea = All;
                }
                field("Ending Date"; "Ending Date")
                {
                    ApplicationArea = All;
                }
                field("Reference No."; "Reference No.")
                {
                    ApplicationArea = All;
                }
                field(Name; Name)
                {
                    ApplicationArea = All;
                }
                field("Issue Register No."; "Issue Register No.")
                {
                    ApplicationArea = All;
                }
                field("Issue Document Type"; "Issue Document Type")
                {
                    ApplicationArea = All;
                }
                field("Issue Document No."; "Issue Document No.")
                {
                    ApplicationArea = All;
                }
                field("Issue External Document No."; "Issue External Document No.")
                {
                    ApplicationArea = All;
                }
                field("Issue User ID"; "Issue User ID")
                {
                    ApplicationArea = All;
                }
                field("Issue Partner Code"; "Issue Partner Code")
                {
                    ApplicationArea = All;
                }
                field("Partner Clearing"; "Partner Clearing")
                {
                    ApplicationArea = All;
                }
                field("No. Send"; "No. Send")
                {
                    ApplicationArea = All;
                    Visible = false;
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
            }
            action("Sending Log")
            {
                Caption = 'Sending Log';
                Image = Log;
                RunObject = Page "NPR NpRv Sending Log";
                RunPageLink = "Voucher No." = FIELD("No.");
                ShortCutKey = 'Shift+Ctrl+F7';
            }
            action("Show Archived Vouchers")
            {
                Caption = 'Show Archived Vouchers';
                Image = PostedPutAway;
                RunObject = Page "NPR NpRv Arch. Vouchers";
            }
        }
    }

    var
        Text000: Label 'Archive %1 selected Vouchers Manually?';
}

