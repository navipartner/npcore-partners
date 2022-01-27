page 6014497 "NPR Retail Journal List"
{
    Extensible = False;
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

                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field("Salesperson Code"; Rec."Salesperson Code")
                {

                    ToolTip = 'Specifies the value of the Salesperson field';
                    ApplicationArea = NPRRetail;
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

