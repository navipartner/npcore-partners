page 6151110 "NPR NpRi Sales Inv. Setup"
{
    // NPR5.53/MHA /20191104  CASE 364131 Object Created - NaviPartner Reimbursement - Sales Invoice

    Caption = 'Sales Invoice Reimbursement Setup';
    PageType = Card;
    UsageCategory = Administration;
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
                        ToolTip = 'Specifies the value of the Customer No. field';
                    }
                    field("Salesperson Code"; "Salesperson Code")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Salesperson Code field';
                    }
                }
                group(Control6014408)
                {
                    ShowCaption = false;
                    field("Invoice per"; "Invoice per")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Invoice per field';
                    }
                    group(Control6014406)
                    {
                        ShowCaption = false;
                        Visible = "Invoice per" = "Invoice per"::Document;
                        field("Invoice Posting Date"; "Invoice Posting Date")
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies the value of the Invoice Posting Date field';
                        }
                    }
                    field("Post Immediately"; "Post Immediately")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Post Immediately field';
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

