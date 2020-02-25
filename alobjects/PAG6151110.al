page 6151110 "NpRi Sales Inv. Setup"
{
    // NPR5.53/MHA /20191104  CASE 364131 Object Created - NaviPartner Reimbursement - Sales Invoice

    Caption = 'Sales Invoice Reimbursement Setup';
    PageType = Card;
    SourceTable = "NpRi Sales Inv. Setup";

    layout
    {
        area(content)
        {
            group(General)
            {
                group(Control6014407)
                {
                    ShowCaption = false;
                    field("Customer No.";"Customer No.")
                    {
                    }
                    field("Salesperson Code";"Salesperson Code")
                    {
                    }
                }
                group(Control6014408)
                {
                    ShowCaption = false;
                    field("Invoice per";"Invoice per")
                    {
                    }
                    group(Control6014406)
                    {
                        ShowCaption = false;
                        Visible = "Invoice per" = "Invoice per"::Document;
                        field("Invoice Posting Date";"Invoice Posting Date")
                        {
                        }
                    }
                    field("Post Immediately";"Post Immediately")
                    {
                    }
                }
            }
            part(Lines;"NpRi Sales Inv. Setup Subpage")
            {
                Caption = 'Lines';
                SubPageLink = "Template Code"=FIELD("Template Code");
            }
        }
    }

    actions
    {
    }
}

