page 6151016 "NpRv Voucher Entries"
{
    // NPR5.37/MHA /20171023  CASE 267346 Object created - NaviPartner Retail Voucher
    // NPR5.48/MHA /20180921  CASE 302179 Renamed field 55 "Sales Ticket No." to "Document No." and added fields 53 "Document Type", 60 "External Document No."
    // NPR5.49/MHA /20190228  CASE 342811 Added Retail Voucher Partner fields used with Cross Company Vouchers
    // NPR5.54/ALST/20200220  CASE 387465 added navigation action

    Caption = 'Retail Voucher Entries';
    Editable = false;
    PageType = List;
    SourceTable = "NpRv Voucher Entry";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry Type";"Entry Type")
                {
                }
                field("Posting Date";"Posting Date")
                {
                }
                field(Amount;Amount)
                {
                }
                field("Remaining Amount";"Remaining Amount")
                {
                }
                field(Positive;Positive)
                {
                }
                field(Open;Open)
                {
                }
                field("Register No.";"Register No.")
                {
                }
                field("Document Type";"Document Type")
                {
                }
                field("Document No.";"Document No.")
                {
                }
                field("External Document No.";"External Document No.")
                {
                }
                field("User ID";"User ID")
                {
                }
                field("Partner Code";"Partner Code")
                {
                }
                field("Entry No.";"Entry No.")
                {
                }
                field("Closed by Entry No.";"Closed by Entry No.")
                {
                }
                field("Closed by Partner Code";"Closed by Partner Code")
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
        area(creation)
        {
            action("Navi&gate")
            {
                Caption = 'Navi&gate';
                Image = Navigate;
                Promoted = true;
                PromotedIsBig = true;
                RunObject = Page Navigate;
            }
        }
    }
}

