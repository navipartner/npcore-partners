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
                field("No.";"No.")
                {
                }
                field(Description;Description)
                {
                }
                field("Salesperson Code";"Salesperson Code")
                {
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

