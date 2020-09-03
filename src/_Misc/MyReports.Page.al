page 6014618 "NPR My Reports"
{
    // #6014618/JC/20160110  CASE 258075 Created Object My Reports
    // NPR5.29/NPKNAV/20170127  CASE 258075 Transport NPR5.29 - 27 januar 2017
    // NPR5.46/BHR /20180824  CASE 322752 Replace record Object to Allobj
    // NPR5.51/ZESO/20190705 CASE 358284 Use AllObjWithCaption instead to have report captions translated as per language being used.

    Caption = 'My Reports';
    PageType = ListPart;
    SourceTable = "NPR My Report";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Report No."; "Report No.")
                {
                    ApplicationArea = All;
                    AssistEdit = true;

                    trigger OnAssistEdit()
                    begin
                        RunReport;
                    end;

                    trigger OnValidate()
                    begin
                        GetReport;
                    end;
                }
                field(ReportName; AllObjwithCap."Object Caption")
                {
                    ApplicationArea = All;
                    AssistEdit = true;
                    Caption = 'Name';

                    trigger OnAssistEdit()
                    begin
                        RunReport;
                    end;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Run Report")
            {
                Caption = 'Run Report';
                Image = Report2;

                trigger OnAction()
                begin
                    RunReport;
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        GetReport;
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Clear(ReportObj);
    end;

    trigger OnOpenPage()
    begin
        SetRange("User ID", UserId);
    end;

    var
        ReportObj: Record "Object";
        AllObj: Record AllObj;
        AllObjwithCap: Record AllObjWithCaption;

    local procedure GetReport()
    begin
        //-NPR5.46 [322752]
        // CLEAR(ReportObj);
        // ReportObj.SETRANGE(Type, ReportObj.Type::Report);
        // ReportObj.SETRANGE(ID, "Report No.");
        // IF ReportObj.FINDFIRST THEN;

        Clear(AllObjwithCap);
        AllObjwithCap.SetRange("Object Type", AllObjwithCap."Object Type"::Report);
        AllObjwithCap.SetRange("Object ID", "Report No.");
        if AllObjwithCap.FindFirst then;
        //+NPR5.46 [322752]
    end;

    local procedure RunReport()
    begin
        // CLEAR(ReportObj);
        // ReportObj.SETRANGE(Type, ReportObj.Type::Report);
        // ReportObj.SETRANGE(ID, "Report No.");
        // IF ReportObj.FINDFIRST THEN
        //  REPORT.RUN("Report No.");
        Clear(AllObjwithCap);
        AllObjwithCap.SetRange("Object Type", AllObjwithCap."Object Type"::Report);
        AllObjwithCap.SetRange("Object ID", "Report No.");
        if AllObjwithCap.FindFirst then
            REPORT.Run("Report No.");
    end;
}

