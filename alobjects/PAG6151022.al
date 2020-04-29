page 6151022 "NpRv Arch. Vouchers"
{
    // NPR5.37/MHA /20171023  CASE 267346 Object created - NaviPartner Retail Voucher
    // NPR5.48/MHA /20180921  CASE 302179 Added field 1007 "Issue Document Type", 1013 "Issue External Document No."
    // NPR5.49/MHA /20190228  CASE 342811 Added Retail Voucher Partner fields used with Cross Company Vouchers
    // NPR5.53/MHA /20191212  CASE 380284 Added "Initial Amount" and hidden "Amount"

    Caption = 'Archived Retail Vouchers';
    CardPageID = "NpRv Arch. Voucher Card";
    Editable = false;
    PageType = List;
    SourceTable = "NpRv Arch. Voucher";
    UsageCategory = History;

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
                field("Initial Amount";"Initial Amount")
                {
                }
                field(Amount;Amount)
                {
                    Visible = false;
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
        area(navigation)
        {
            action("Arch. Voucher Entries")
            {
                Caption = 'Archived Voucher Entries';
                Image = Entries;
                RunObject = Page "NpRv Arch. Voucher Entries";
                RunPageLink = "Arch. Voucher No."=FIELD("No.");
                ShortCutKey = 'Ctrl+F7';
            }
        }
    }
}

