page 6150699 "NPR Retail Data Model Upg.Log"
{
    // NPR5.32/AP/20170501  CASE 274285  Added page for viewing data upgrade log entries
    // NPR5.48/TS  /20181206 CASE 338656 Added Missing Picture to Action

    Caption = 'Retail Data Model Upgrade Log';
    Editable = false;
    PageType = List;
    SourceTable = "NPR Data Model Upg. Log Entry";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                IndentationColumn = Indent;
                IndentationControls = Text;
                field("Data Model Build"; "Data Model Build")
                {
                    ApplicationArea = All;
                }
                field(Type; Type)
                {
                    ApplicationArea = All;
                }
                field("Text"; Text)
                {
                    ApplicationArea = All;
                    Style = Strong;
                    StyleExpr = TextEmphasize;
                }
                field("User ID"; "User ID")
                {
                    ApplicationArea = All;
                }
                field("Date and Time"; "Date and Time")
                {
                    ApplicationArea = All;
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
                        RetailDataModelUpgradeMgt: Codeunit "NPR Retail Data Model Upg Mgt.";
                    begin
                        RetailDataModelUpgradeMgt.ReRunFromLogEntry(Rec);
                    end;
                }
                action("Re-run Build Steps")
                {
                    Caption = 'Re-run Build Steps';
                    Ellipsis = true;
                    Image = "Action";
                    RunObject = Report "NPR Re-run Data Upg. Steps";
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

