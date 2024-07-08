page 6151280 "NPR SAF-T Cash Export Subpage"
{
    Extensible = False;
    Caption = 'SAF-T Cash Export Lines';
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = ListPart;
    SourceTable = "NPR SAF-T Cash Export Line";
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            repeater(SAFTExportLine)
            {
                field(Description; Rec.Description)
                {
                    ApplicationArea = NPRNOFiscal;
                    ToolTip = 'Specifies the description of the selected SAF-T file.';
                }
                field(Progress; Rec.Progress)
                {
                    ApplicationArea = NPRNOFiscal;
                    ToolTip = 'Specifies the progress of the selected SAF-T file.';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = NPRNOFiscal;
                    ToolTip = 'Specifies the status of the selected SAF-T file.';
                }
                field("Created Date/Time"; Rec."Created Date/Time")
                {
                    ApplicationArea = NPRNOFiscal;
                    ToolTip = 'Specifies the date and time when the generation of the selected SAF-T file was completed.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(RestartTask)
            {
                ApplicationArea = NPRNOFiscal;
                Caption = 'Restart';
                Image = PostingEntries;
                ToolTip = 'Restart the generation of the selected SAF-T file.';
                trigger OnAction();
                var
                    SAFTExportLine: Record "NPR SAF-T Cash Export Line";
                    SAFTExportMgt: Codeunit "NPR SAF-T Cash Export Mgt.";
                begin
                    CurrPage.SetSelectionFilter(SAFTExportLine);
                    SAFTExportMgt.RestartTaskOnExportLine(SAFTExportLine);
                    CurrPage.Update();
                end;
            }
            action(ShowError)
            {
                ApplicationArea = NPRNOFiscal;
                Caption = 'Show Error';
                Image = Error;
                ToolTip = 'Show the error that occurred when generating the selected SAF-T file.';
                trigger OnAction();
                var
                    SAFTExportMgt: Codeunit "NPR SAF-T Cash Export Mgt.";
                begin
                    SAFTExportMgt.ShowErrorOnExportLine(Rec);
                    CurrPage.Update();
                end;
            }
            action(LogEntries)
            {
                ApplicationArea = NPRNOFiscal;
                Caption = 'Activity Log';
                Image = Log;
                ToolTip = 'Show the activity log for the generation of the selected SAF-T file.';

                trigger OnAction()
                var
                    SAFTExportMgt: Codeunit "NPR SAF-T Cash Export Mgt.";
                begin
                    SAFTExportMgt.ShowActivityLog(Rec);
                end;
            }
        }
    }
}
