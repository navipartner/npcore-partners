page 6150889 "NPR DE Data Exports"
{
    ApplicationArea = NPRDEFiscal;
    Caption = 'DE Data Exports';
    ContextSensitiveHelpPage = 'docs/fiscalization/germany/how-to/setup/';
    Extensible = false;
    PageType = List;
    SourceTable = "NPR DE Data Export";
    PromotedActionCategories = 'New,Process,Report,Download,Navigate';
    UsageCategory = History;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = NPRDEFiscal;
                    ToolTip = 'Specifies the entry number.';
                    DrillDown = true;
                    DrillDownPageId = "NPR DE Data Export Card";
                }
                field("TSS Code"; Rec."TSS Code")
                {
                    ApplicationArea = NPRDEFiscal;
                    ToolTip = 'Specifies the TSS code for which this data export is created.';
                }
                field("TSS Id"; Rec."TSS ID")
                {
                    ApplicationArea = NPRDEFiscal;
                    ToolTip = 'Specifies the TSS identifier for which this data export is created.';
                }
                field(State; Rec.State)
                {
                    ApplicationArea = NPRDEFiscal;
                    ToolTip = 'Specifies the current state of the export operation.';
                }
                field(Exception; Rec.Exception)
                {
                    ApplicationArea = NPRDEFiscal;
                    ToolTip = 'Specifies the error description if the state is ERROR.';
                }
                field("Time Request DateTime"; Rec.GetTimeRequestAsDateTime())
                {
                    ApplicationArea = NPRDEFiscal;
                    Caption = 'Time Request';
                    ToolTip = 'Specifies the time of the initial request.';
                }
                field("Time Start DateTime"; Rec.GetTimeStartAsDateTime())
                {
                    ApplicationArea = NPRDEFiscal;
                    Caption = 'Time Start';
                    ToolTip = 'Specifies the time of the start of the export operation.';
                }
                field("Time End DateTime"; Rec.GetTimeEndAsDateTime())
                {
                    ApplicationArea = NPRDEFiscal;
                    Caption = 'Time End';
                    ToolTip = 'Specifies the time of the end of the export operation.';
                }
                field("Time Expiration DateTime"; Rec.GetTimeExpirationAsDateTime())
                {
                    ApplicationArea = NPRDEFiscal;
                    Caption = 'Time Expiration';
                    ToolTip = 'Specifies the time of the expiration of the generated TAR file.';
                }
                field("Estimated Time Of Completion DateTime"; Rec.GetEstimatedTimeOfCompletionAsDateTime())
                {
                    ApplicationArea = NPRDEFiscal;
                    Caption = 'Estimated Completion';
                    ToolTip = 'Specifies the estimated point in time when the state will change to COMPLETED.';
                }
                field("Client Id"; Rec."Client Id")
                {
                    ApplicationArea = NPRDEFiscal;
                    ToolTip = 'Specifies the client ID filter for the export.';
                }
                field("Maximum Number Records"; Rec."Maximum Number Records")
                {
                    ApplicationArea = NPRDEFiscal;
                    ToolTip = 'Specifies the maximum number of records to export.';
                }
                field("Created At"; Rec.SystemCreatedAt)
                {
                    ApplicationArea = NPRDEFiscal;
                    ToolTip = 'Specifies when this export record was created locally.';
                }
                field("Created By"; Rec.SystemCreatedBy)
                {
                    ApplicationArea = NPRDEFiscal;
                    ToolTip = 'Specifies who created this export record.';
                }
                field(SystemId; Rec.SystemId)
                {
                    ApplicationArea = NPRDEFiscal;
                    ToolTip = 'Specifies the unique identifier of this export at Fiskaly.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(TriggerExport)
            {
                ApplicationArea = NPRDEFiscal;
                Caption = 'Trigger Export';
                Image = SendElectronicDocument;
                Enabled = Rec.State = Rec.State::" ";
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Triggers a new data export at Fiskaly or updates an existing export request.';

                trigger OnAction()
                var
                    DEFiskalyCommunication: Codeunit "NPR DE Fiskaly Communication";
                begin
                    DEFiskalyCommunication.TriggerExport(Rec);
                    CurrPage.Update(false);
                end;
            }
            action(RetrieveExport)
            {
                ApplicationArea = NPRDEFiscal;
                Caption = 'Retrieve Status';
                Image = Refresh;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Retrieves the latest status information about the export from Fiskaly.';

                trigger OnAction()
                var
                    DEFiskalyCommunication: Codeunit "NPR DE Fiskaly Communication";
                begin
                    DEFiskalyCommunication.RetrieveExport(Rec);
                    CurrPage.Update(false);
                end;
            }
            action(CancelExport)
            {
                ApplicationArea = NPRDEFiscal;
                Caption = 'Cancel Export';
                Enabled = (Rec.State = Rec.State::PENDING) or (Rec.State = Rec.State::WORKING);
                Image = VoidElectronicDocument;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Cancels an ongoing export operation. You can cancel the export when it is in PENDING or WORKING state.';

                trigger OnAction()
                var
                    DEFiskalyCommunication: Codeunit "NPR DE Fiskaly Communication";
                begin
                    DEFiskalyCommunication.CancelExport(Rec);
                    CurrPage.Update(false);
                end;
            }
            action(ListExports)
            {
                ApplicationArea = NPRDEFiscal;
                Caption = 'Refresh Exports';
                Image = RefreshLines;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Retrieves the list of all exports from Fiskaly and updates the local records.';

                trigger OnAction()
                var
                    DEFiskalyCommunication: Codeunit "NPR DE Fiskaly Communication";
                begin
                    DEFiskalyCommunication.ListExports('');
                    CurrPage.Update(false);
                end;
            }
            action(DownloadTARFile)
            {
                ApplicationArea = NPRDEFiscal;
                Caption = 'Download TAR File';
                Enabled = Rec.State = Rec.State::COMPLETED;
                Image = ExportFile;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedOnly = true;
                ToolTip = 'Downloads the TAR file generated by the export operation. This action is only available when the export is completed.';

                trigger OnAction()
                var
                    DEFiskalyCommunication: Codeunit "NPR DE Fiskaly Communication";
                begin
                    DEFiskalyCommunication.DownloadExportTARFile(Rec);
                end;
            }
        }
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        // Initialize with default values
        Rec."Maximum Number Records" := 1000000;
    end;
}