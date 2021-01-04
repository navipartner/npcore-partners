page 6150736 "NPR POS Theme Dependencies"
{
    // NPR5.49/VB  /20181106 CASE 335141 Introducing the POS Theme functionality

    AutoSplitKey = true;
    Caption = 'POS Theme Dependencies';
    PageType = List;
    UsageCategory = Administration;
    SourceTable = "NPR POS Theme Dependency";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Target Type"; "Target Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Target Type field';

                    trigger OnValidate()
                    begin
                        CalculateEditables();
                    end;
                }
                field("Target Code"; "Target Code")
                {
                    ApplicationArea = All;
                    Enabled = TargetCodeEditable;
                    ToolTip = 'Specifies the value of the Target Code field';
                }
                field("Target View Type"; "Target View Type")
                {
                    ApplicationArea = All;
                    Enabled = TargetViewTypeEditable;
                    ToolTip = 'Specifies the value of the Target View Type field';
                }
                field("Dependency Type"; "Dependency Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Dependency Type field';
                }
                field("Dependency Code"; "Dependency Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Dependency Code field';
                }
                field(Blocked; Blocked)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Blocked field';
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetCurrRecord()
    begin
        CalculateEditables();
    end;

    trigger OnAfterGetRecord()
    begin
        CalculateEditables();
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        CalculateEditables();
    end;

    trigger OnOpenPage()
    begin
        if (GetRangeMax("POS Theme Code") <> GetRangeMin("POS Theme Code")) or (GetFilter("POS Theme Code") = '') then
            Error(Text001, FieldCaption("POS Theme Code"));
    end;

    var
        Text001: Label 'There is no filter on %1. You must not access this page directly.';
        TargetCodeEditable: Boolean;
        TargetViewTypeEditable: Boolean;

    local procedure CalculateEditables()
    begin
        TargetViewTypeEditable := "Target Type" = "Target Type"::"View Type";
        TargetCodeEditable := "Target Type" = "Target Type"::View;
    end;
}

