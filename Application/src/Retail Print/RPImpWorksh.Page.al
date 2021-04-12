page 6014632 "NPR RP Imp. Worksh."
{
    // NPR5.38/MMV /20171212 CASE 294095 Created object.

    Caption = 'Import Worksheet';
    DelayedInsert = false;
    DeleteAllowed = false;
    InsertAllowed = false;
    LinksAllowed = false;
    PageType = Worksheet;
    UsageCategory = Administration;
    ApplicationArea = All;
    ShowFilter = false;
    SourceTable = "NPR RP Imp. Worksh.";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Template; Rec.Template)
                {
                    ApplicationArea = All;
                    Editable = false;
                    StyleExpr = Style;
                    Width = 80;
                    ToolTip = 'Specifies the value of the Template field';
                }
                field("New Template"; Rec."New Template")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the New Template field';
                }
                field("Action"; Rec.Action)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Action field';

                    trigger OnValidate()
                    begin
                        Style := Rec.SetStyle();
                    end;
                }
                field("Existing Version"; Rec."Existing Version")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Existing Version field';
                }
                field("Existing Description"; Rec."Existing Description")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Existing Description field';
                }
                field("Existing Last Modified At"; Rec."Existing Last Modified At")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Existing Last Modified At field';
                }
                field("New Version"; Rec."New Version")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the New Version field';
                }
                field("New Description"; Rec."New Description")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the New Description field';
                }
                field("New Last Modified At"; Rec."New Last Modified At")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the New Last Modified At field';
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        Style := Rec.SetStyle();
    end;

    var
        Style: Text;
}

