page 6151199 "NPR NpCs Workflow Modules"
{
    // NPR5.50/MHA /20190531  CASE 345261 Object created - Collect in Store

    Caption = 'Collect Workflow Modules';
    InsertAllowed = false;
    PageType = List;
    SourceTable = "NPR NpCs Workflow Module";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Type; Type)
                {
                    ApplicationArea = All;
                }
                field("Code"; Code)
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("Event Codeunit ID"; "Event Codeunit ID")
                {
                    ApplicationArea = All;
                }
                field("Event Codeunit Name"; "Event Codeunit Name")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    var
        NpCsWorkflowMgt: Codeunit "NPR NpCs Workflow Mgt.";
    begin
        NpCsWorkflowMgt.OnInitWorkflowModules(Rec);
    end;
}

