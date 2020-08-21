page 6060163 "Event Attribute Row Values"
{
    // NPR5.31/NPKNAV/20170502  CASE 269162 Transport NPR5.31 - 2 May 2017

    AutoSplitKey = true;
    Caption = 'Attribute Row Values';
    PageType = List;
    SourceTable = "Event Attribute Row Value";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Line No."; "Line No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = FormulaLookupMode;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field(Type; Type)
                {
                    ApplicationArea = All;
                    Visible = NOT FormulaLookupMode;
                }
                field(Formula; Formula)
                {
                    ApplicationArea = All;
                    AssistEdit = true;
                    Visible = NOT FormulaLookupMode;

                    trigger OnAssistEdit()
                    begin
                        FormulaAssistEdit();
                    end;
                }
                field(Promote; Promote)
                {
                    ApplicationArea = All;
                    Visible = NOT FormulaLookupMode;
                }
            }
        }
    }

    actions
    {
    }

    var
        [InDataSet]
        FormulaLookupMode: Boolean;

    procedure SetVisibility()
    begin
        FormulaLookupMode := true;
    end;

    procedure SetSelection(var EventAttributeRowValue: Record "Event Attribute Row Value")
    begin
        CurrPage.SetSelectionFilter(EventAttributeRowValue);
    end;
}

