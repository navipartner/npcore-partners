page 6151327 "NPR DK SAF-T Cash Exports"
{
    Extensible = False;
    ApplicationArea = NPRDKFiscal;
    Caption = 'SAF-T Cash Register Exports';
    CardPageId = "NPR DK SAF-T Cash Export Card";
    Editable = false;
    PageType = List;
    RefreshOnActivate = true;
    SourceTable = "NPR DK SAF-T Cash Exp. Header";
    UsageCategory = ReportsAndAnalysis;

    layout
    {
        area(Content)
        {
            repeater(General)
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
                    ToolTip = 'Specifies if the change will be processed by parallel background jobs.';
                }
                field("Max No. Of Jobs"; Rec."Max No. Of Jobs")
                {
                    ApplicationArea = NPRDKFiscal;
                    ToolTip = 'Specifies the maximum number of background jobs that can be processed at the same time.';
                }
                field(SplitByMonth; Rec."Split By Month")
                {
                    ApplicationArea = NPRDKFiscal;
                    ToolTip = 'Specifies if multiple SAF-T files will be generated per each month.';
                }
                field(SplitByDate; Rec."Split By Date")
                {
                    ApplicationArea = NPRDKFiscal;
                    ToolTip = 'Specifies whether multiple SAF-T files will be generated for each day.';
                }
                field(EarliestStartDateTime; Rec."Earliest Start Date/Time")
                {
                    ApplicationArea = NPRDKFiscal;
                    ToolTip = 'Specifies the earliest date and time when the background job must be run.';
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
            action(DownloadFile)
            {
                ApplicationArea = NPRDKFiscal;
                Caption = 'Download File';
                Image = ExportFile;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Download the generated SAF-T file.';

                trigger OnAction()
                var
                    SAFTExportMgt: Codeunit "NPR DK SAF-T Cash Export Mgt.";
                begin
                    SAFTExportMgt.DownloadZipFileFromExportHeader(Rec);
                end;
            }
        }
    }
}
