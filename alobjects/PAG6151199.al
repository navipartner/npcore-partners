page 6151199 "NpCs Workflow Modules"
{
    // NPR5.50/MHA /20190531  CASE 345261 Object created - Collect in Store

    Caption = 'Collect Workflow Modules';
    InsertAllowed = false;
    PageType = List;
    SourceTable = "NpCs Workflow Module";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Type;Type)
                {
                }
                field("Code";Code)
                {
                }
                field(Description;Description)
                {
                }
                field("Event Codeunit ID";"Event Codeunit ID")
                {
                }
                field("Event Codeunit Name";"Event Codeunit Name")
                {
                }
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    var
        NpCsWorkflowMgt: Codeunit "NpCs Workflow Mgt.";
    begin
        NpCsWorkflowMgt.OnInitWorkflowModules(Rec);
    end;
}

