page 6014497 "NPR Retail Journal List"
{
    Caption = 'Retail Journal List';
    CardPageID = "NPR Retail Journal Header";
    Editable = false;
    PageType = List;
    SourceTable = "NPR Retail Journal Header";
    UsageCategory = Lists;
    ApplicationArea = All;

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
                    ToolTip = 'Specifies the value of the Code field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Salesperson Code"; "Salesperson Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Salesperson field';
                }
            }
        }
    }

    actions
    {
    }

    procedure GetSelectionFilter(var RetailJournalHeader: Record "NPR Retail Journal Header")
    begin
        CurrPage.SetSelectionFilter(RetailJournalHeader);
    end;
}

