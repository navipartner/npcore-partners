page 6150699 "NPR Retail Data Model Upg.Log"
{
    // NPR5.32/AP/20170501  CASE 274285  Added page for viewing data upgrade log entries
    // NPR5.48/TS  /20181206 CASE 338656 Added Missing Picture to Action

    Caption = 'Retail Data Model Upgrade Log';
    Editable = false;
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
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
                    ToolTip = 'Specifies the value of the Data Model Build field';
                }
                field(Type; Type)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Type field';
                }
                field("Text"; Text)
                {
                    ApplicationArea = All;
                    Style = Strong;
                    StyleExpr = TextEmphasize;
                    ToolTip = 'Specifies the value of the Text field';
                }
                field("User ID"; "User ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the User ID field';
                }
                field("Date and Time"; "Date and Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Date and Time field';
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
				    PromotedOnly = true;
                    PromotedCategory = Process;
                    RunPageMode = View;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Re-run Build Step action';

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
                    ApplicationArea = All;
                    ToolTip = 'Executes the Re-run Build Steps action';
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

