page 6014497 "Retail Journal List"
{
    Caption = 'Retail Journal List';
    CardPageID = "Retail Journal Header";
    Editable = false;
    PageType = List;
    SourceTable = "Retail Journal Header";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Control6150613)
            {
                ShowCaption = false;
                field("No."; "No.")
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("Salesperson Code"; "Salesperson Code")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
    }

    procedure GetSelectionFilter(var RetailJournalHeader: Record "Retail Journal Header")
    begin
        CurrPage.SetSelectionFilter(RetailJournalHeader);
    end;
}

