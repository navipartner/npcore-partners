codeunit 6150619 "POS Audit Log Mgt."
{
    // NPR5.48/MMV /20190121 CASE 318028 Created object


    trigger OnRun()
    begin
    end;

    var
        ERROR_NO_LOG_VALIDATION: Label 'No log validation routine found';

    local procedure IsEnabled(POSAuditProfileCode: Code[20]): Boolean
    var
        POSAuditProfile: Record "POS Audit Profile";
    begin
        if not POSAuditProfile.Get(POSAuditProfileCode) then
          exit(false);
        exit(POSAuditProfile."Audit Log Enabled");
    end;

    procedure ValidateLog(var POSAuditLog: Record "POS Audit Log")
    var
        Handled: Boolean;
        BlankRecordID: RecordID;
    begin
        CreateEntry(BlankRecordID, POSAuditLog."Action Type"::AUDIT_VERIFY, 0, '', '');
        Commit;
        OnValidateLogRecords(POSAuditLog,Handled);
        if not Handled then
          Error(ERROR_NO_LOG_VALIDATION);
    end;

    procedure ArchiveWorkshiftPeriod(POSWorkshiftCheckpoint: Record "POS Workshift Checkpoint")
    var
        POSAuditLog: Record "POS Audit Log";
        POSEntry: Record "POS Entry";
    begin
        POSEntry.Get(POSWorkshiftCheckpoint."POS Entry No.");
        CreateEntry(POSWorkshiftCheckpoint.RecordId, POSAuditLog."Action Type"::ARCHIVE_ATTEMPT,POSEntry."Entry No.",POSEntry."Fiscal No.", POSEntry."POS Unit No.");
        Commit;
        OnArchiveWorkshiftPeriod(POSWorkshiftCheckpoint);
    end;

    procedure CreateEntry(RecordIDIn: RecordID;Type: Integer;ActedOnPOSEntryNo: Integer;ActedOnPOSEntryFiscalNo: Code[20];ActedOnPOSUnitNo: Code[10])
    begin
        CreateEntryExtended(RecordIDIn, Type, ActedOnPOSEntryNo, ActedOnPOSEntryFiscalNo, ActedOnPOSUnitNo, '', '');
    end;

    procedure CreateEntryExtended(RecordIDIn: RecordID;Type: Integer;ActedOnPOSEntryNo: Integer;ActedOnPOSEntryFiscalNo: Code[20];ActedOnPOSUnitNo: Code[10];Description: Text[250];AddInfo: Text)
    var
        POSAuditLog: Record "POS Audit Log";
        RecRef: RecordRef;
        PreviousEventLog: Record "POS Audit Log";
        POSSession: Codeunit "POS Session";
        FrontEnd: Codeunit "POS Front End Management";
        POSSetup: Codeunit "POS Setup";
        POSUnit: Record "POS Unit";
        POSSale: Codeunit "POS Sale";
        SalePOS: Record "Sale POS";
        POSEntry: Record "POS Entry";
    begin
        POSAuditLog.Init;

        if POSSession.IsActiveSession(FrontEnd) then begin
          FrontEnd.GetSession(POSSession);
          POSSession.GetSetup(POSSetup);
          POSSession.GetSale(POSSale);
          POSSale.GetCurrentSale(SalePOS);

          POSAuditLog."Active POS Unit No." := POSSetup.Register;
          POSAuditLog."Active Salesperson Code" := POSSetup.Salesperson;
          POSAuditLog."Active POS Sale ID" := SalePOS."POS Sale ID";
        end;

        if not POSUnit.Get(POSAuditLog."Active POS Unit No.") then
          if not POSUnit.Get(ActedOnPOSUnitNo) then
            exit;  //Not done from a POS Unit or acted on a POS Unit -> not relevant for a POS audit log.
        if not IsEnabled(POSUnit."POS Audit Profile") then
          exit;

        POSAuditLog."Record ID" := RecordIDIn;
        POSAuditLog."Action Type" := Type;
        POSAuditLog."Acted on POS Entry No." := ActedOnPOSEntryNo;
        POSAuditLog."Acted on POS Entry Fiscal No." := ActedOnPOSEntryFiscalNo;
        POSAuditLog."Acted on POS Unit No." := ActedOnPOSUnitNo;
        POSAuditLog."Log Timestamp" := CurrentDateTime;
        POSAuditLog."User ID" := UserId;
        POSAuditLog."External Description" := CopyStr(Description,1,MaxStrLen(POSAuditLog."External Description"));
        POSAuditLog."Additional Information" := CopyStr(AddInfo,1,MaxStrLen(POSAuditLog."Additional Information"));
        if Format(RecordIDIn) <> '' then begin
          RecRef.Get(RecordIDIn);
          POSAuditLog."Table ID" := RecRef.Number;
        end;

        OnHandleAuditLogBeforeInsert(POSAuditLog);

        POSAuditLog.Insert(true);
    end;

    procedure ShowAuditLogForRecord(RecordIDIn: RecordID)
    var
        POSAuditLog: Record "POS Audit Log";
    begin
        POSAuditLog.SetRange("Record ID", RecordIDIn);
        PAGE.RunModal(0, POSAuditLog);
    end;

    procedure ShowAuditLogForPOSEntry(POSEntry: Record "POS Entry")
    var
        POSAuditLog: Record "POS Audit Log";
    begin
        POSAuditLog.SetRange("Acted on POS Entry No.", POSEntry."Entry No.");
        PAGE.RunModal(0, POSAuditLog);
    end;

    procedure LookupAuditHandler(var POSAuditProfile: Record "POS Audit Profile")
    var
        tmpRetailList: Record "Retail List" temporary;
    begin
        OnLookupAuditHandler(tmpRetailList);
        if PAGE.RunModal(0, tmpRetailList) <> ACTION::LookupOK then
          exit;
        POSAuditProfile."Audit Handler" := tmpRetailList.Choice;
    end;

    local procedure "---Publishers"()
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnHandleAuditLogBeforeInsert(var POSAuditLog: Record "POS Audit Log")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnArchiveWorkshiftPeriod(POSWorkshiftCheckpoint: Record "POS Workshift Checkpoint")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnValidateLogRecords(var POSAuditLog: Record "POS Audit Log";var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnLookupAuditHandler(var tmpRetailList: Record "Retail List" temporary)
    begin
    end;
}

