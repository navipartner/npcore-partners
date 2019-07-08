page 6151167 "NpGp POS Sales Entries"
{
    // NPR5.50/MHA /20190422  CASE 337539 Object created - [NpGp] NaviPartner Global POS Sales

    Caption = 'Global POS Sales Entries';
    Editable = false;
    PageType = List;
    SourceTable = "NpGp POS Sales Entry";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("POS Store Code";"POS Store Code")
                {
                }
                field("POS Unit No.";"POS Unit No.")
                {
                }
                field("Document No.";"Document No.")
                {
                }
                field("Posting Date";"Posting Date")
                {
                }
                field("Fiscal No.";"Fiscal No.")
                {
                }
                field("Salesperson Code";"Salesperson Code")
                {
                }
                field("Currency Code";"Currency Code")
                {
                }
                field("Currency Factor";"Currency Factor")
                {
                }
                field("Sales Amount";"Sales Amount")
                {
                }
                field("Discount Amount";"Discount Amount")
                {
                }
                field("Sales Quantity";"Sales Quantity")
                {
                }
                field("Return Sales Quantity";"Return Sales Quantity")
                {
                }
                field("Total Amount";"Total Amount")
                {
                }
                field("Total Tax Amount";"Total Tax Amount")
                {
                }
                field("Total Amount Incl. Tax";"Total Amount Incl. Tax")
                {
                }
                field("Entry No.";"Entry No.")
                {
                }
                field("Entry Time";"Entry Time")
                {
                }
                field("Entry Type";"Entry Type")
                {
                }
                field("Retail ID";"Retail ID")
                {
                }
            }
            part("POS Sales Lines";"NpGp POS Sales Entry Subpage")
            {
                Caption = 'POS Sales Lines';
                SubPageLink = "POS Entry No."=FIELD("Entry No.");
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action("POS Info")
            {
                Caption = 'POS Info';
                Image = List;
                RunObject = Page "NpGp POS Info POS Entry";
                RunPageLink = "POS Entry No."=FIELD("Entry No.");
            }
        }
    }
}

