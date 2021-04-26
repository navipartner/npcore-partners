page 6151500 "NPR Nc Setup"
{
    Caption = 'NaviConnect Setup';
    DeleteAllowed = false;
    InsertAllowed = false;
    SourceTable = "NPR Nc Setup";
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            field("Keep Tasks for"; Rec."Keep Tasks for")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Keep Tasks for field';
            }
            group(General)
            {
                Caption = 'Order Import';
                field("Max Task Count per Batch"; Rec."Max Task Count per Batch")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Max Task Count per batch field';
                }
            }
            group("Task Queue")
            {
                Caption = 'Task Queue';
                field("Task Queue Enabled"; Rec."Task Queue Enabled")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Task Queue Enabled field';
                }
                field("Task Worker Group"; Rec."Task Worker Group")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Task Worker Group field';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Setup Task Queue")
            {
                Caption = 'Setup Task Queue';
                Image = Setup;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;
                ToolTip = 'Executes the Setup Task Queue action';

                trigger OnAction()
                var
                    NaviConnectMgt: Codeunit "NPR Nc Setup Mgt.";
                begin
                    CurrPage.Update(true);
                    NaviConnectMgt.SetupTaskQueue();
                end;
            }
        }
    }

    trigger OnOpenPage()
    var
        NaviConnectMgt: Codeunit "NPR Nc Setup Mgt.";
    begin
        Rec.Reset();
        if not Rec.Get() then
            NaviConnectMgt.InitNaviConnectSetup();
    end;
}

