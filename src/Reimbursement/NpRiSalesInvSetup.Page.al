page 6151110 "NPR NpRi Sales Inv. Setup"
{
    // NPR5.53/MHA /20191104  CASE 364131 Object Created - NaviPartner Reimbursement - Sales Invoice

    Caption = 'Sales Invoice Reimbursement Setup';
    PageType = Card;
    SourceTable = "NPR NpRi Sales Inv. Setup";

    layout
    {
        area(content)
        {
            group(General)
            {
                group(Control6014407)
                {
                    ShowCaption = false;
                    field("Customer No."; "Customer No.")
                    {
                        ApplicationArea = All;
                    }
                    field("Salesperson Code"; "Salesperson Code")
                    {
                        ApplicationArea = All;
                    }
                }
                group(Control6014408)
                {
                    ShowCaption = false;
                    field("Invoice per"; "Invoice per")
                    {
                        ApplicationArea = All;
                    }
                    group(Control6014406)
                    {
                        ShowCaption = false;
                        Visible = "Invoice per" = "Invoice per"::Document;
                        field("Invoice Posting Date"; "Invoice Posting Date")
                        {
                            ApplicationArea = All;
                        }
                    }
                    field("Post Immediately"; "Post Immediately")
                    {
                        ApplicationArea = All;
                    }
                }
            }
            part(Lines; "NPR NpRi S. Inv. SetupSubpage")
            {
                Caption = 'Lines';
                SubPageLink = "Template Code" = FIELD("Template Code");
                ApplicationArea = All;
            }
        }
    }

    actions
    {
    }
}

