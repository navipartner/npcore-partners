page 6014513 "Custom Object Selection List"
{
    // NPR4.02/TR/20150401  CASE 207094 Page displays the Custom Object Selection menu.

    Caption = 'Brugerdefineret objektvalg liste';
    DelayedInsert = false;
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
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
                field(Description;Description)
                {
                    Editable = false;
                    Enabled = false;
                    Style = Strong;
                    StyleExpr = StrongStyle;
                }
                field("Object ID";"Object ID")
                {
                    BlankZero = true;
                    Editable = false;
                    Enabled = false;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(Run)
            {
                Caption = 'Run';
                Image = Start;
                Promoted = true;
                PromotedCategory = Process;
                ShortCutKey = 'Ctrl+R';

                trigger OnAction()
                begin
                    case "Object Type" of
                      "Object Type"::Table : HyperLink(GetUrl(CLIENTTYPE::Current,CompanyName,OBJECTTYPE::Table,"Object ID"));
                      "Object Type"::Page : PAGE.Run("Object ID");
                      "Object Type"::Report : REPORT.Run("Object ID");
                      "Object Type"::Codeunit : CODEUNIT.Run("Object ID");
                      "Object Type"::XMLPort : XMLPORT.Run("Object ID");
                    end;
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        StrongStyle := "Object Type" = "Object Type"::Title;
    end;

    var
        StrongStyle: Boolean;
}

