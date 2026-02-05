page 6150796 "NPR NpCs Task Processor Setup"
{
    ObsoleteState = Pending;
    ObsoleteTag = '2026-01-29';
    ObsoleteReason = 'This module is no longer being maintained';
    Caption = 'Collect Task Processor Setup';
    PageType = Card;
    SourceTable = "NPR NpCs Task Processor Setup";
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Run Workflow Code"; Rec."Run Workflow Code")
                {
                    ToolTip = 'Specifies the value of the Task Processor used for the Running Workflows.';
                    ApplicationArea = NPRRetail;
                }
                field("Document Posting Code"; Rec."Document Posting Code")
                {
                    ToolTip = 'Specifies the value of the Task Processor used for the Posting of Collect Documents.';
                    ApplicationArea = NPRRetail;
                }
                field("Expiration Code"; Rec."Expiration Code")
                {
                    ToolTip = 'Specifies the value of the Task Processor used for updating the Expiration of Collect Documents.';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(InitializeTaskProcessor)
            {
                Caption = 'Initialize Task Processors';
                ToolTip = 'Executes functionality that fill the setup fields on this page, add setup in Task processors and add job queue entries that process the Collect Document updates. The Job Queue entries can be adjusted from Job Queue Entries page afterwards';
                ApplicationArea = NPRRetail;
                Image = Setup;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                trigger OnAction()
                var
                    NpCsTaskProcessorSetup: Codeunit "NPR NpCs Task Processor Setup";
                begin
                    NpCsTaskProcessorSetup.InitializeTaskProcessors(Rec);
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert(true);
        end;
    end;

}
