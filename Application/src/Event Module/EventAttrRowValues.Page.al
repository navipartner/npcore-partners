page 6060163 "NPR Event Attr. Row Values"
{
    AutoSplitKey = true;
    Caption = 'Attribute Row Values';
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR Event Attr. Row Value";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Line No."; Rec."Line No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = FormulaLookupMode;
                    ToolTip = 'Specifies the value of the Line No. field';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field(Type; Rec.Type)
                {
                    ApplicationArea = All;
                    Visible = NOT FormulaLookupMode;
                    ToolTip = 'Specifies the value of the Type field';
                }
                field(Formula; Rec.Formula)
                {
                    ApplicationArea = All;
                    AssistEdit = true;
                    Visible = NOT FormulaLookupMode;
                    ToolTip = 'Specifies the value of the Formula field';

                    trigger OnAssistEdit()
                    begin
                        Rec.FormulaAssistEdit();
                    end;
                }
                field(Promote; Rec.Promote)
                {
                    ApplicationArea = All;
                    Visible = NOT FormulaLookupMode;
                    ToolTip = 'Specifies the value of the Promote field';
                }
            }
        }
    }

    var
        [InDataSet]
        FormulaLookupMode: Boolean;

    procedure SetVisibility()
    begin
        FormulaLookupMode := true;
    end;

    procedure SetSelection(var EventAttributeRowValue: Record "NPR Event Attr. Row Value")
    begin
        CurrPage.SetSelectionFilter(EventAttributeRowValue);
    end;
}

