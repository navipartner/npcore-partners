page 6150699 "Retail Data Model Upgrade Log"
{
    // NPR5.32/AP/20170501  CASE 274285  Added page for viewing data upgrade log entries
    // NPR5.48/TS  /20181206 CASE 338656 Added Missing Picture to Action

    Caption = 'Retail Data Model Upgrade Log';
    Editable = false;
    PageType = List;
    SourceTable = "Data Model Upgrade Log Entry";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                IndentationColumn = Indent;
                IndentationControls = Text;
                field("Data Model Build";"Data Model Build")
                {
                }
                field(Type;Type)
                {
                }
                field(Text;Text)
                {
                    Style = Strong;
                    StyleExpr = TextEmphasize;
                }
                field("User ID";"User ID")
                {
                }
                field("Date and Time";"Date and Time")
                {
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            group(Builds)
            {
                Caption = 'Builds';
                Image = History;
                action("Re-run Build Step (Log Entry)")
                {
                    Caption = 'Re-run Build Step';
                    Image = Reuse;
                    Promoted = true;
                    PromotedCategory = Process;
                    RunPageMode = View;

                    trigger OnAction()
                    var
                        RetailDataModelUpgradeMgt: Codeunit "Retail Data Model Upgrade Mgt.";
                    begin
                        RetailDataModelUpgradeMgt.ReRunFromLogEntry(Rec);
                    end;
                }
                action("Re-run Build Steps")
                {
                    Caption = 'Re-run Build Steps';
                    Ellipsis = true;
                    Image = "Action";
                    RunObject = Report "Re-run Data Upg. Build Steps";
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        TextEmphasize := (Indent = 0) and ("Data Model Build" >= 0);
    end;

    var
        TextEmphasize: Boolean;
}

