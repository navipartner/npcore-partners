page 6014618 "NPR My Reports"
{
    Extensible = False;
    Caption = 'My Reports';
    PageType = ListPart;
    UsageCategory = Administration;

    SourceTable = "NPR My Report";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Report No."; Rec."Report No.")
                {

                    AssistEdit = true;
                    ToolTip = 'Specifies the value of the Report No. field';
                    ApplicationArea = NPRRetail;

                    trigger OnAssistEdit()
                    begin
                        RunReport();
                    end;

                    trigger OnValidate()
                    begin
                        GetReport();
                    end;
                }
                field(ReportName; AllObjwithCap."Object Caption")
                {

                    AssistEdit = true;
                    Caption = 'Name';
                    ToolTip = 'Specifies the value of the Name field';
                    ApplicationArea = NPRRetail;

                    trigger OnAssistEdit()
                    begin
                        RunReport();
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

                ToolTip = 'Executes the Run Report action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                begin
                    RunReport();
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        GetReport();
    end;

    trigger OnOpenPage()
    begin
        Rec.SetRange("User ID", UserId);
    end;

    var
        AllObjwithCap: Record AllObjWithCaption;

    local procedure GetReport()
    begin
        Clear(AllObjwithCap);
        AllObjwithCap.SetRange("Object Type", AllObjwithCap."Object Type"::Report);
        AllObjwithCap.SetRange("Object ID", Rec."Report No.");
        if AllObjwithCap.FindFirst() then;
    end;

    local procedure RunReport()
    begin
        Clear(AllObjwithCap);
        AllObjwithCap.SetRange("Object Type", AllObjwithCap."Object Type"::Report);
        AllObjwithCap.SetRange("Object ID", Rec."Report No.");
        if AllObjwithCap.FindFirst() then
            REPORT.Run(Rec."Report No.");
    end;
}
