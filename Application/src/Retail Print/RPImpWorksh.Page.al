page 6014632 "NPR RP Imp. Worksh."
{
    Extensible = False;
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
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("New Template"; Rec."New Template")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the New Template field';
                    ApplicationArea = NPRRetail;
                }
                field(Template; Rec.Template)
                {
                    Editable = false;
                    StyleExpr = Style;
                    Width = 80;
                    ToolTip = 'Specifies the value of the Template field';
                    ApplicationArea = NPRRetail;
                }
                field("Action"; Rec.Action)
                {

                    ToolTip = 'Specifies the value of the Action field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        Style := Rec.SetStyle();
                    end;
                }
                field("Existing Version"; Rec."Existing Version")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Existing Version field';
                    ApplicationArea = NPRRetail;
                }
                field("Existing Description"; Rec."Existing Description")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Existing Description field';
                    ApplicationArea = NPRRetail;
                }
                field("Existing Last Modified At"; Rec."Existing Last Modified At")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Existing Last Modified At field';
                    ApplicationArea = NPRRetail;
                }
                field("New Version"; Rec."New Version")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the New Version field';
                    ApplicationArea = NPRRetail;
                }
                field("New Description"; Rec."New Description")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the New Description field';
                    ApplicationArea = NPRRetail;
                }
                field("New Last Modified At"; Rec."New Last Modified At")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the New Last Modified At field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ToggleDefaultAction)
            {
                Caption = 'Set new templates to Create/Replace';
                ToolTip = 'Executes the Set new templates to Create/Replace';
                ApplicationArea = NPRRetail;
                Image = RefreshLines;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    if Rec.FindSet(true) then
                        repeat
                            Rec.SetDefaultAction();
                            Rec.Modify()
                        until Rec.Next() = 0;
                end;
            }
            action(ToggleSkipAction)
            {
                Caption = 'Set all templates to Skip';
                ToolTip = 'Executes the Set all templates to Skip';
                ApplicationArea = NPRRetail;
                Image = RefreshLines;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    Rec.ModifyAll(Action, Rec.Action::Skip)
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        Style := Rec.SetStyle();
    end;

    var
        Style: Text;
}

