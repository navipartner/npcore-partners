page 6060163 "NPR Event Attr. Row Values"
{
    // NPR5.31/NPKNAV/20170502  CASE 269162 Transport NPR5.31 - 2 May 2017

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
                field("Line No."; "Line No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = FormulaLookupMode;
                    ToolTip = 'Specifies the value of the Line No. field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field(Type; Type)
                {
                    ApplicationArea = All;
                    Visible = NOT FormulaLookupMode;
                    ToolTip = 'Specifies the value of the Type field';
                }
                field(Formula; Formula)
                {
                    ApplicationArea = All;
                    AssistEdit = true;
                    Visible = NOT FormulaLookupMode;
                    ToolTip = 'Specifies the value of the Formula field';

                    trigger OnAssistEdit()
                    begin
                        FormulaAssistEdit();
                    end;
                }
                field(Promote; Promote)
                {
                    ApplicationArea = All;
                    Visible = NOT FormulaLookupMode;
                    ToolTip = 'Specifies the value of the Promote field';
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

    procedure SetSelection(var EventAttributeRowValue: Record "NPR Event Attr. Row Value")
    begin
        CurrPage.SetSelectionFilter(EventAttributeRowValue);
    end;
}

