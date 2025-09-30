page 6150863 "NPR DE Data Export Card"
{
    Caption = 'DE Data Export Card';
    ContextSensitiveHelpPage = 'docs/fiscalization/germany/how-to/setup/';
    Extensible = false;
    UsageCategory = None;
    PageType = Card;
    SourceTable = "NPR DE Data Export";

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
                field("TSS Code"; Rec."TSS Code")
                {
                    ApplicationArea = NPRDEFiscal;
                    ToolTip = 'Specifies the TSS code for which this data export is created.';
                }
                field("TSS Id"; Rec."TSS ID")
                {
                    ApplicationArea = NPRDEFiscal;
                    ToolTip = 'Specifies the TSS identifier for which this data export is created.';
                    Editable = false;
                }
                field(State; Rec.State)
                {
                    ApplicationArea = NPRDEFiscal;
                    ToolTip = 'Specifies the current state of the export operation.';
                    Editable = false;
                }
                field(Exception; Rec.Exception)
                {
                    ApplicationArea = NPRDEFiscal;
                    ToolTip = 'Specifies the error description if the state is ERROR.';
                    Editable = false;
                }
                field(SystemId; Rec.SystemId)
                {
                    ApplicationArea = NPRDEFiscal;
                    ToolTip = 'Specifies the unique identifier of this export at Fiskaly.';
                    Editable = false;
                }
            }
            group(ExportParameters)
            {
                Caption = 'Export Parameters';
                Editable = Rec.State = Rec.State::" ";
                field("Client Id"; Rec."Client Id")
                {
                    ApplicationArea = NPRDEFiscal;
                    ToolTip = 'Only return log messages associated with the given client (other query parameters will be ignored).';
                }
                field("Transaction Number"; Rec."Transaction Number")
                {
                    ApplicationArea = NPRDEFiscal;
                    ToolTip = 'Only return log messages associated with the given transaction number.';
                }
                field("Start Transaction Number"; Rec."Start Transaction Number")
                {
                    ApplicationArea = NPRDEFiscal;
                    ToolTip = 'Only return log messages greater than or equal to the given start transaction number.';
                }
                field("End Transaction Number"; Rec."End Transaction Number")
                {
                    ApplicationArea = NPRDEFiscal;
                    ToolTip = 'Only return log messages less than or equal to the given end transaction number.';
                }
                field("Start Date"; Rec."Start Date")
                {
                    ApplicationArea = NPRDEFiscal;
                    ToolTip = 'Only return log messages with dates larger than or equal to the given start date (Unix timestamp).';
                }
                field("End Date"; Rec."End Date")
                {
                    ApplicationArea = NPRDEFiscal;
                    ToolTip = 'Only return log messages with dates smaller than or equal to the given end date (Unix timestamp).';
                }
                field("Maximum Number Records"; Rec."Maximum Number Records")
                {
                    ApplicationArea = NPRDEFiscal;
                    ToolTip = 'This parameter can be used to limit the amount of signatures to be exported. Maximum value is 1000000.';
                }
                field("Start Signature Counter"; Rec."Start Signature Counter")
                {
                    ApplicationArea = NPRDEFiscal;
                    ToolTip = 'Only return log messages with signature counters larger than or equal to the given value.';
                }
                field("End Signature Counter"; Rec."End Signature Counter")
                {
                    ApplicationArea = NPRDEFiscal;
                    ToolTip = 'Only return log messages with signature counters smaller than or equal to the given value.';
                }
            }
            group(Timing)
            {
                Caption = 'Timing Information';
                field("Time Request DateTime"; Rec.GetTimeRequestAsDateTime())
                {
                    ApplicationArea = NPRDEFiscal;
                    Caption = 'Time Request';
                    ToolTip = 'Specifies the time of the initial request.';
                    Editable = false;
                }
                field("Time Start DateTime"; Rec.GetTimeStartAsDateTime())
                {
                    ApplicationArea = NPRDEFiscal;
                    Caption = 'Time Start';
                    ToolTip = 'Specifies the time of the start of the export operation.';
                    Editable = false;
                }
                field("Time End DateTime"; Rec.GetTimeEndAsDateTime())
                {
                    ApplicationArea = NPRDEFiscal;
                    Caption = 'Time End';
                    ToolTip = 'Specifies the time of the end of the export operation.';
                    Editable = false;
                }
                field("Time Expiration DateTime"; Rec.GetTimeExpirationAsDateTime())
                {
                    ApplicationArea = NPRDEFiscal;
                    Caption = 'Time Expiration';
                    ToolTip = 'Specifies the time of the expiration of the generated TAR file.';
                    Editable = false;
                }
                field("Time Error DateTime"; Rec.GetTimeErrorAsDateTime())
                {
                    ApplicationArea = NPRDEFiscal;
                    Caption = 'Time Error';
                    ToolTip = 'Specifies the time of the error of the export operation.';
                    Editable = false;
                }
                field("Estimated Time Of Completion DateTime"; Rec.GetEstimatedTimeOfCompletionAsDateTime())
                {
                    ApplicationArea = NPRDEFiscal;
                    Caption = 'Estimated Completion';
                    ToolTip = 'Specifies the estimated point in time when the state will change to COMPLETED.';
                    Editable = false;
                }
            }
            group(LocalInformation)
            {
                Caption = 'Local Information';
                field("Created At"; Rec.SystemCreatedAt)
                {
                    ApplicationArea = NPRDEFiscal;
                    ToolTip = 'Specifies when this export record was created locally.';
                    Editable = false;
                }
                field("Created By"; Rec.SystemCreatedBy)
                {
                    ApplicationArea = NPRDEFiscal;
                    ToolTip = 'Specifies who created this export record.';
                    Editable = false;
                }
                field(Environment; Rec.Environment)
                {
                    ApplicationArea = NPRDEFiscal;
                    ToolTip = 'Specifies the Fiskaly environment.';
                    Editable = false;
                }
                field(Version; Rec.Version)
                {
                    ApplicationArea = NPRDEFiscal;
                    ToolTip = 'Specifies the Fiskaly API version.';
                    Editable = false;
                }
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = NPRDEFiscal;
                    ToolTip = 'Specifies the entry number.';
                    Editable = false;
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
                Enabled = Rec.State = Rec.State::" ";
                Image = SendElectronicDocument;
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
            action(DownloadTARFile)
            {
                ApplicationArea = NPRDEFiscal;
                Caption = 'Download TAR File';
                Enabled = Rec.State = Rec.State::COMPLETED;
                Image = ExportFile;
                Promoted = true;
                PromotedCategory = Process;
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