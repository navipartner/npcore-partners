page 6014497 "NPR Retail Journal List"
{
    Caption = 'Retail Journal List';
    CardPageID = "NPR Retail Journal Header";
    Editable = false;
    PageType = List;
    SourceTable = "NPR Retail Journal Header";
    UsageCategory = Lists;
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Control6150613)
            {
                ShowCaption = false;
                field("No."; Rec."No.")
                {

                    ToolTip = 'Specifies the code of the retail journal type.';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the description of the retail journal type.';
                    ApplicationArea = NPRRetail;
                }
                field("Salesperson Code"; Rec."Salesperson Code")
                {

                    ToolTip = 'Specifies the salesperson of the retail journal type.';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
    }

    internal procedure GetSelectionFilter(var RetailJournalHeader: Record "NPR Retail Journal Header")
    begin
        CurrPage.SetSelectionFilter(RetailJournalHeader);
    end;
}

