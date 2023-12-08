page 6151326 "NPR DK SAF-T Cash Export Card"
{
    Extensible = False;
    Caption = 'SAF-T Cash Register Export';
    DataCaptionExpression = '';
    PageType = Card;
    SourceTable = "NPR DK SAF-T Cash Exp. Header";
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            group(General)
            {
                field("Export Name Code"; Rec."Export Name Code")
                {
                    ApplicationArea = NPRDKFiscal;
                    ToolTip = 'Specifies the Export Name Code that represents the SAF-T reporting period.';
                }
                field(StartingDate; Rec."Starting Date")
                {
                    ApplicationArea = NPRDKFiscal;
                    ToolTip = 'Specifies the starting date of the SAF-T reporting period.';
                }
                field(EndingDate; Rec."Ending Date")
                {
                    ApplicationArea = NPRDKFiscal;
                    ToolTip = 'Specifies the ending date of the SAF-T reporting period.';
                }
                field(ParallelProcessing; Rec."Parallel Processing")
                {
                    ApplicationArea = NPRDKFiscal;
                    Enabled = IsParallelProcessingAllowed;
                    ToolTip = 'Specifies if the change will be processed by parallel background jobs.';

                    trigger OnValidate()
                    begin
                        CalcParallelProcessingEnabled();
                        CurrPage.Update();
                    end;
                }
                field("Max No. Of Jobs"; Rec."Max No. Of Jobs")
                {
                    ApplicationArea = NPRDKFiscal;
                    Enabled = IsParallelProcessingEnabled;
                    ToolTip = 'Specifies the maximum number of background jobs processed at the same time.';
                }
                field(SplitByMonth; Rec."Split By Month")
                {
                    ApplicationArea = NPRDKFiscal;
                    ToolTip = 'Specifies if multiple SAF-T files will be generated per month.';
                }
                field(SplitByDate; Rec."Split By Date")
                {
                    ApplicationArea = NPRDKFiscal;
                    ToolTip = 'Specifies whether multiple SAF-T files will be generated for each day.';
                }
                field("Header Comment"; Rec."Header Comment")
                {
                    ApplicationArea = NPRDKFiscal;
                    ToolTip = 'Specifies the comment that is exported to the HeaderComment XML node of the SAF-T file';
                }
                field(EarliestStartDateTime; Rec."Earliest Start Date/Time")
                {
                    ApplicationArea = NPRDKFiscal;
                    Enabled = IsParallelProcessingEnabled;
                    ToolTip = 'Specifies the earliest date and time when the background job must be run.';
                }
                field("Folder Path"; Rec."Folder Path")
                {
                    ApplicationArea = NPRDKFiscal;
                    ToolTip = 'Specifies the complete path of the public folder that the SAF-T file is exported to.';
                    Visible = not IsSaaS;
                }
                field(DisableZipFileGeneration; Rec."Disable Zip File Generation")
                {
                    ApplicationArea = NPRDKFiscal;
                    ToolTip = 'Specifies that the ZIP file would not be generated automatically. This option is available only if the folder path is specified.';
                    Visible = not IsSaaS;
                }
                field(CreateMultipleZipFiles; Rec."Create Multiple Zip Files")
                {
                    ApplicationArea = NPRDKFiscal;
                    ToolTip = 'Specifies that multiple ZIP files will be generated.';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = NPRDKFiscal;
                    ToolTip = 'Specifies the overall status of one or more SAF-T files being generated.';
                }
                field(ExecutionStartDateTime; Rec."Execution Start Date/Time")
                {
                    ApplicationArea = NPRDKFiscal;
                    ToolTip = 'Specifies the date and time when the SAF-T file generation was started.';
                }
                field(ExecutionEndDateTime; Rec."Execution End Date/Time")
                {
                    ApplicationArea = NPRDKFiscal;
                    ToolTip = 'Specifies the date and time when the SAF-T file generation was completed.';
                }
            }
            part(ExportLines; "NPR DK SAF-T Cash Exp. Subpage")
            {
                ApplicationArea = NPRDKFiscal;
                SubPageLink = ID = field(ID);
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Start)
            {
                ApplicationArea = NPRDKFiscal;
                Caption = 'Start';
                Image = Start;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Start the generation of the SAF-T file.';

                trigger OnAction()
                begin
                    Codeunit.Run(Codeunit::"NPR DK SAF-T Cash Export Mgt.", Rec);
                    CurrPage.Update();
                end;
            }
            action(GenerateZipFile)
            {
                ApplicationArea = NPRDKFiscal;
                Caption = 'Regenerate Zip File';
                Image = Archive;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Generate the ZIP file again.';
                Visible = not IsSaaS;

                trigger OnAction()
                var
                    SAFTExportMgt: Codeunit "NPR DK SAF-T Cash Export Mgt.";
                begin
                    SAFTExportMgt.GenerateZipFileWithCheck(Rec);
                end;
            }
            action(DownloadFile)
            {
                ApplicationArea = NPRDKFiscal;
                Caption = 'Download Files';
                Image = ExportFile;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                RunObject = page "NPR DK SAF-T Cash Export Zips";
                RunPageLink = "Export ID" = field(ID);
                ToolTip = 'Download the generated SAF-T files.';
            }
        }
    }

    var
        IsParallelProcessingAllowed: Boolean;
        IsParallelProcessingEnabled: Boolean;
        IsSaaS: Boolean;

    trigger OnOpenPage()
    var
        EnvironmentInformation: Codeunit "Environment Information";
        SAFTExportMgt: Codeunit "NPR DK SAF-T Cash Export Mgt.";
    begin
        IsParallelProcessingAllowed := TaskScheduler.CanCreateTask();
        if not IsParallelProcessingAllowed then
            SAFTExportMgt.ThrowNoParallelExecutionNotification();
        IsSaaS := EnvironmentInformation.IsSaaS();
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        IsParallelProcessingEnabled := TaskScheduler.CanCreateTask();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        CalcParallelProcessingEnabled();
    end;

    local procedure CalcParallelProcessingEnabled()
    begin
        IsParallelProcessingEnabled := Rec."Parallel Processing";
    end;
}
