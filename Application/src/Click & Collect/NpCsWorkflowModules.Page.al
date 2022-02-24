page 6151199 "NPR NpCs Workflow Modules"
{
    Extensible = False;
    Caption = 'Collect Workflow Modules';
    InsertAllowed = false;
    PageType = List;
    SourceTable = "NPR NpCs Workflow Module";
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;


    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Type; Rec.Type)
                {

                    ToolTip = 'Specifies the Type of Workflow Module.';
                    ApplicationArea = NPRRetail;
                }
                field("Code"; Rec.Code)
                {

                    ToolTip = 'Specifies the Code of the Workflow Module.';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the Description of the Workflow Module.';
                    ApplicationArea = NPRRetail;
                }
                field("Event Codeunit ID"; Rec."Event Codeunit ID")
                {

                    ToolTip = 'Specifies the Event Codeunit ID to be used with the Workflow Module selected.';
                    ApplicationArea = NPRRetail;
                }
                field("Event Codeunit Name"; Rec."Event Codeunit Name")
                {

                    ToolTip = 'Specifies the Description of the Event Codeunit used with the Workflow Module.';
                    ApplicationArea = NPRRetail;
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

