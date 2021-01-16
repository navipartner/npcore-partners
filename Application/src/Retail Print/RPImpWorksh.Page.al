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
                field(Template; Template)
                {
                    ApplicationArea = All;
                    Editable = false;
                    StyleExpr = Style;
                    Width = 80;
                    ToolTip = 'Specifies the value of the Template field';
                }
                field("New Template"; "New Template")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the New Template field';
                }
                field("Action"; Action)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Action field';

                    trigger OnValidate()
                    begin
                        Style := SetStyle();
                    end;
                }
                field("Existing Version"; "Existing Version")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Existing Version field';
                }
                field("Existing Description"; "Existing Description")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Existing Description field';
                }
                field("Existing Last Modified At"; "Existing Last Modified At")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Existing Last Modified At field';
                }
                field("New Version"; "New Version")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the New Version field';
                }
                field("New Description"; "New Description")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the New Description field';
                }
                field("New Last Modified At"; "New Last Modified At")
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
        Style := SetStyle();
    end;

    var
        Style: Text;
}

