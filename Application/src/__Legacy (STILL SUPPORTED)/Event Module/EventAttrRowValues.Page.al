page 6060163 "NPR Event Attr. Row Values"
{
    ObsoleteState = Pending;
    ObsoleteTag = '2026-01-29';
    ObsoleteReason = 'This module is no longer being maintained';
    Extensible = False;
    AutoSplitKey = true;
    Caption = 'Attribute Row Values';
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR Event Attr. Row Value";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Line No."; Rec."Line No.")
                {

                    Editable = false;
                    Visible = FormulaLookupMode;
                    ToolTip = 'Specifies the value of the Line No. field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field(Type; Rec.Type)
                {

                    Visible = NOT FormulaLookupMode;
                    ToolTip = 'Specifies the value of the Type field';
                    ApplicationArea = NPRRetail;
                }
                field(Formula; Rec.Formula)
                {

                    AssistEdit = true;
                    Visible = NOT FormulaLookupMode;
                    ToolTip = 'Specifies the value of the Formula field';
                    ApplicationArea = NPRRetail;

                    trigger OnAssistEdit()
                    begin
                        Rec.FormulaAssistEdit();
                    end;
                }
                field(Promote; Rec.Promote)
                {

                    Visible = NOT FormulaLookupMode;
                    ToolTip = 'Specifies the value of the Promote field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    var

        FormulaLookupMode: Boolean;

    internal procedure SetVisibility()
    begin
        FormulaLookupMode := true;
    end;

    internal procedure SetSelection(var EventAttributeRowValue: Record "NPR Event Attr. Row Value")
    begin
        CurrPage.SetSelectionFilter(EventAttributeRowValue);
    end;
}

