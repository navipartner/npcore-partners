page 6151110 "NPR NpRi Sales Inv. Setup"
{
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
                    field("Customer No."; Rec."Customer No.")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Customer No. field';
                    }
                    field("Salesperson Code"; Rec."Salesperson Code")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Salesperson Code field';
                    }
                }
                group(Control6014408)
                {
                    ShowCaption = false;
                    field("Invoice per"; Rec."Invoice per")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Invoice per field';
                    }
                    group(Control6014406)
                    {
                        ShowCaption = false;
                        Visible = Rec."Invoice per" = Rec."Invoice per"::Document;
                        field("Invoice Posting Date"; Rec."Invoice Posting Date")
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies the value of the Invoice Posting Date field';
                        }
                    }
                    field("Post Immediately"; Rec."Post Immediately")
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
}

