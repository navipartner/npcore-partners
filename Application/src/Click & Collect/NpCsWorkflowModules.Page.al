page 6151199 "NPR NpCs Workflow Modules"
{
    Caption = 'Collect Workflow Modules';
    InsertAllowed = false;
    PageType = List;
    SourceTable = "NPR NpCs Workflow Module";
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Type; Rec.Type)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Type field';
                }
                field("Code"; Rec.Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Event Codeunit ID"; Rec."Event Codeunit ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Event Codeunit ID field';
                }
                field("Event Codeunit Name"; Rec."Event Codeunit Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Event Codeunit Name field';
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        NpCsWorkflowMgt: Codeunit "NPR NpCs Workflow Mgt.";
    begin
        NpCsWorkflowMgt.OnInitWorkflowModules(Rec);
    end;
}

