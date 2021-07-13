page 6150736 "NPR POS Theme Dependencies"
{
    // NPR5.49/VB  /20181106 CASE 335141 Introducing the POS Theme functionality

    AutoSplitKey = true;
    Caption = 'POS Theme Dependencies';
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR POS Theme Dependency";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Target Type"; Rec."Target Type")
                {

                    ToolTip = 'Specifies the value of the Target Type field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        CalculateEditables();
                    end;
                }
                field("Target Code"; Rec."Target Code")
                {

                    Enabled = TargetCodeEditable;
                    ToolTip = 'Specifies the value of the Target Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Target View Type"; Rec."Target View Type")
                {

                    Enabled = TargetViewTypeEditable;
                    ToolTip = 'Specifies the value of the Target View Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Dependency Type"; Rec."Dependency Type")
                {

                    ToolTip = 'Specifies the value of the Dependency Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Dependency Code"; Rec."Dependency Code")
                {

                    ToolTip = 'Specifies the value of the Dependency Code field';
                    ApplicationArea = NPRRetail;
                }
                field(Blocked; Rec.Blocked)
                {

                    ToolTip = 'Specifies the value of the Blocked field';
                    ApplicationArea = NPRRetail;
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
        if (Rec.GetRangeMax("POS Theme Code") <> Rec.GetRangeMin("POS Theme Code")) or (Rec.GetFilter("POS Theme Code") = '') then
            Error(Text001, Rec.FieldCaption("POS Theme Code"));
    end;

    var
        Text001: Label 'There is no filter on %1. You must not access this page directly.';
        TargetCodeEditable: Boolean;
        TargetViewTypeEditable: Boolean;

    local procedure CalculateEditables()
    begin
        TargetViewTypeEditable := Rec."Target Type" = Rec."Target Type"::"View Type";
        TargetCodeEditable := Rec."Target Type" = Rec."Target Type"::View;
    end;
}

