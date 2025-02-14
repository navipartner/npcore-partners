page 6151171 "NPR NpGp Global POSSalesSetups"
{
    Extensible = False;
    Caption = 'Global POS Sales Setups';
    ContextSensitiveHelpPage = 'docs/retail/pos_profiles/how-to/global_profile/global_profile/';
    CardPageID = "NPR NpGp POS Sales Setup Card";
    Editable = false;
    PageType = List;
    SourceTable = "NPR NpGp POS Sales Setup";
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;


    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {
                    ToolTip = 'Specifies the code for the global POS sales setup';
                    ApplicationArea = NPRRetail;
                }
                field("Company Name"; Rec."Company Name")
                {
                    ToolTip = 'Specifies the company name for the global POS sales setup';
                    ApplicationArea = NPRRetail;
                }
                field("Service Url"; Rec."Service Url")
                {
                    ToolTip = 'Specifies the service URL for the global POS sales setup';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
            action(SetupJobQueue)
            {
                Caption = 'Setup Job Queue';
                Image = Setup;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Sets up a Job Queue Entry to automate export of POS Entries to Global Sales endpoints';
                ApplicationArea = NPRNaviConnect;
                Visible = Rec."Use api";

                trigger OnAction()
                var
                    JobQueueEntry: Record "Job Queue Entry";
                    NpGpExporttoAPI: Codeunit "NPR NpGp Export to API";
                begin
                    CurrPage.SaveRecord();
                    NpGpExporttoAPI.CreateExportProcessingJobQueueEntry(JobQueueEntry);
                    if not IsNullGuid(JobQueueEntry.ID) then
                        Page.Run(Page::"Job Queue Entry Card", JobQueueEntry);
                end;
            }
#endif
        }
        area(Navigation)
        {
#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
            action(ExportLog)
            {
                Caption = 'Export Log';
                ToolTip = 'Shows the log of exported POS Entries for this setup';
                Image = Log;
                RunObject = page "NPR NpGp Export Log";
                RunPageLink = "POS Sales Setup Code" = field(Code);
                ApplicationArea = NPRRetail;
                Visible = Rec."Use api";
            }
#endif            
        }
    }
}

