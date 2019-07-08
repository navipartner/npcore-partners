page 6014512 "Custom Object Selection Setup"
{
    // NPR4.02/TR/20150401  CASE 207094 Page make it possible to setup the Custom Object Selection.
    // NPR5.41/TS  /20180105 CASE 300893 Removed Caption on ActionContainer
    // NPR5.43/JDH /20180604 CASE 317971 Changed Object Caption to ENU

    AutoSplitKey = true;
    Caption = 'Custom Object Selection Setup';
    PageType = Worksheet;
    PromotedActionCategories = 'Edit,Action,Reports_caption,Category4_caption,Category5_caption,Category6_caption,Category7_caption,Category8_caption,Category9_caption,Category10_caption';
    SourceTable = "Custom Object Selection";
    SourceTableView = SORTING("Entry No.");

    layout
    {
        area(content)
        {
            repeater(Control6150614)
            {
                IndentationColumn = Level;
                IndentationControls = Description;
                ShowCaption = false;
                field("Object Type";"Object Type")
                {

                    trigger OnValidate()
                    begin
                        EvaluateObjectType;
                    end;
                }
                field("Object ID";"Object ID")
                {
                    Enabled = DisableObjectID;
                }
                field(Description;Description)
                {
                    Style = Strong;
                    StyleExpr = StrongStyle;
                }
                field("Group Code";"Group Code")
                {
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Decrement Level")
            {
                Caption = 'Decrement Level';
                Image = PreviousRecord;
                Promoted = true;

                trigger OnAction()
                begin
                    if Level > 0 then begin
                      Level -=1;
                      Modify(true);
                    end;
                end;
            }
            action("Increment Level")
            {
                Caption = 'Increment Level';
                Image = NextRecord;
                Promoted = true;

                trigger OnAction()
                begin
                    Level +=1;
                    Modify(true);
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        EvaluateObjectType;
    end;

    var
        DisableObjectID: Boolean;
        StrongStyle: Boolean;

    procedure EvaluateObjectType()
    begin
        StrongStyle := "Object Type" = "Object Type"::Title;
        DisableObjectID := "Object Type" <> "Object Type"::Title;
    end;
}

