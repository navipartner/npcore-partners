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
                }
                field("New Template"; "New Template")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Action"; Action)
                {
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        Style := SetStyle();
                    end;
                }
                field("Existing Version"; "Existing Version")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Existing Description"; "Existing Description")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Existing Last Modified At"; "Existing Last Modified At")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("New Version"; "New Version")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("New Description"; "New Description")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("New Last Modified At"; "New Last Modified At")
                {
                    ApplicationArea = All;
                    Editable = false;
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

