page 6151015 "NpRv Vouchers"
{
    // NPR5.37/MHA /20171023  CASE 267346 Object created - NaviPartner Retail Voucher
    // NPR5.48/MHA /20180921  CASE 302179 Added field 1007 "Issue Document Type", 1013 "Issue External Document No."
    // NPR5.49/MHA /20190228  CASE 342811 Added Retail Voucher Partner fields used with Cross Company Vouchers
    // NPR5.53/MHA /20191212  CASE 380284 Added hidden "Initial Amount"

    Caption = 'Retail Vouchers';
    CardPageID = "NpRv Voucher Card";
    Editable = false;
    PageType = List;
    SourceTable = "NpRv Voucher";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No.";"No.")
                {
                }
                field("Voucher Type";"Voucher Type")
                {
                }
                field(Description;Description)
                {
                }
                field("Issue Date";"Issue Date")
                {
                }
                field(Open;Open)
                {
                }
                field("Initial Amount";"Initial Amount")
                {
                    Visible = false;
                }
                field(Amount;Amount)
                {
                }
                field("Starting Date";"Starting Date")
                {
                }
                field("Ending Date";"Ending Date")
                {
                }
                field("Reference No.";"Reference No.")
                {
                }
                field(Name;Name)
                {
                }
                field("Issue Register No.";"Issue Register No.")
                {
                }
                field("Issue Document Type";"Issue Document Type")
                {
                }
                field("Issue Document No.";"Issue Document No.")
                {
                }
                field("Issue External Document No.";"Issue External Document No.")
                {
                }
                field("Issue User ID";"Issue User ID")
                {
                }
                field("Issue Partner Code";"Issue Partner Code")
                {
                }
                field("Partner Clearing";"Partner Clearing")
                {
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
                        Voucher: Record "NpRv Voucher";
                        NpRvVoucherMgt: Codeunit "NpRv Voucher Mgt.";
                    begin
                        CurrPage.SetSelectionFilter(Voucher);
                        if not Confirm(Text000,false,Voucher.Count) then
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
                        SetFilter("Ending Date",'<%1',CurrentDateTime);
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
                RunObject = Page "NpRv Voucher Entries";
                RunPageLink = "Voucher No."=FIELD("No.");
                ShortCutKey = 'Ctrl+F7';
            }
        }
    }

    var
        Text000: Label 'Archive %1 selected Vouchers Manually?';
}

