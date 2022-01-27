page 6151110 "NPR NpRi Sales Inv. Setup"
{
    Extensible = False;
    UsageCategory = None;
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

                        ToolTip = 'Specifies the value of the Customer No. field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Salesperson Code"; Rec."Salesperson Code")
                    {

                        ToolTip = 'Specifies the value of the Salesperson Code field';
                        ApplicationArea = NPRRetail;
                    }
                }
                group(Control6014408)
                {
                    ShowCaption = false;
                    field("Invoice per"; Rec."Invoice per")
                    {

                        ToolTip = 'Specifies the value of the Invoice per field';
                        ApplicationArea = NPRRetail;
                    }
                    group(Control6014406)
                    {
                        ShowCaption = false;
                        Visible = Rec."Invoice per" = Rec."Invoice per"::Document;
                        field("Invoice Posting Date"; Rec."Invoice Posting Date")
                        {

                            ToolTip = 'Specifies the value of the Invoice Posting Date field';
                            ApplicationArea = NPRRetail;
                        }
                    }
                    field("Post Immediately"; Rec."Post Immediately")
                    {

                        ToolTip = 'Specifies the value of the Post Immediately field';
                        ApplicationArea = NPRRetail;
                    }
                }
            }
            part(Lines; "NPR NpRi S. Inv. SetupSubpage")
            {
                Caption = 'Lines';
                SubPageLink = "Template Code" = FIELD("Template Code");
                ApplicationArea = NPRRetail;

            }
        }
    }
}

