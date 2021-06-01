codeunit 6150619 "NPR POS Audit Log Mgt."
{
    var
        ERROR_NO_LOG_VALIDATION: Label 'No log validation routine found';

    local procedure IsEnabled(POSAuditProfileCode: Code[20]): Boolean
    var
        POSAuditProfile: Record "NPR POS Audit Profile";
    begin
        if not POSAuditProfile.Get(POSAuditProfileCode) then
            exit(false);
        exit(POSAuditProfile."Audit Log Enabled");
    end;

    procedure ValidateLog(var POSAuditLog: Record "NPR POS Audit Log")
    var
        Handled: Boolean;
        BlankRecordID: RecordID;
    begin
        CreateEntry(BlankRecordID, POSAuditLog."Action Type"::AUDIT_VERIFY, 0, '', '');
        Commit();
        OnValidateLogRecords(POSAuditLog, Handled);
        if not Handled then
            Error(ERROR_NO_LOG_VALIDATION);
    end;

    procedure ArchiveWorkshiftPeriod(POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint")
    var
        POSAuditLog: Record "NPR POS Audit Log";
        POSEntry: Record "NPR POS Entry";
    begin
        POSEntry.Get(POSWorkshiftCheckpoint."POS Entry No.");
        CreateEntry(POSWorkshiftCheckpoint.RecordId, POSAuditLog."Action Type"::ARCHIVE_ATTEMPT, POSEntry."Entry No.", POSEntry."Fiscal No.", POSEntry."POS Unit No.");
        Commit();
        CreateEntry(POSWorkshiftCheckpoint.RecordId, POSAuditLog."Action Type"::ARCHIVE_CREATE, POSEntry."Entry No.", POSEntry."Fiscal No.", POSWorkshiftCheckpoint."POS Unit No.");
        OnArchiveWorkshiftPeriod(POSWorkshiftCheckpoint);
    end;

    procedure CreateEntry(RecordIDIn: RecordID; Type: Integer; ActedOnPOSEntryNo: Integer; ActedOnPOSEntryFiscalNo: Code[20]; ActedOnPOSUnitNo: Code[10])
    begin
        CreateEntryFull(RecordIDIn, Type, ActedOnPOSEntryNo, ActedOnPOSEntryFiscalNo, ActedOnPOSUnitNo, '', '', '');
    end;

    procedure CreateEntryExtended(RecordIDIn: RecordID; Type: Integer; ActedOnPOSEntryNo: Integer; ActedOnPOSEntryFiscalNo: Code[20]; ActedOnPOSUnitNo: Code[10]; Description: Text[250]; AddInfo: Text)
    begin
        CreateEntryFull(RecordIDIn, Type, ActedOnPOSEntryNo, ActedOnPOSEntryFiscalNo, ActedOnPOSUnitNo, Description, AddInfo, '');
    end;

    procedure CreateEntryCustom(RecordIDIn: RecordID; Subtype: Text[250]; ActedOnPOSEntryNo: Integer; ActedOnPOSEntryFiscalNo: Code[20]; ActedOnPOSUnitNo: Code[10]; Description: Text[250]; AddInfo: Text)
    var
        POSAuditLog: Record "NPR POS Audit Log";
    begin
        CreateEntryFull(RecordIDIn, POSAuditLog."Action Type"::CUSTOM, ActedOnPOSEntryNo, ActedOnPOSEntryFiscalNo, ActedOnPOSUnitNo, Description, AddInfo, Subtype);
    end;

    local procedure CreateEntryFull(RecordIDIn: RecordID; Type: Integer; ActedOnPOSEntryNo: Integer; ActedOnPOSEntryFiscalNo: Code[20]; ActedOnPOSUnitNo: Code[10]; Description: Text[250]; AddInfo: Text; CustomType: Text)
    var
        POSAuditLog: Record "NPR POS Audit Log";
        RecRef: RecordRef;
        POSSession: Codeunit "NPR POS Session";
        FrontEnd: Codeunit "NPR POS Front End Management";
        POSSetup: Codeunit "NPR POS Setup";
        POSUnit: Record "NPR POS Unit";
        POSSale: Codeunit "NPR POS Sale";
        SalePOS: Record "NPR POS Sale";
    begin
        POSAuditLog.Init();

        if POSSession.IsActiveSession(FrontEnd) then begin
            FrontEnd.GetSession(POSSession);
            POSSession.GetSetup(POSSetup);
            POSSession.GetSale(POSSale);
            POSSale.GetCurrentSale(SalePOS);

            POSAuditLog."Active POS Unit No." := POSSetup.GetPOSUnitNo();
            POSAuditLog."Active Salesperson Code" := POSSetup.Salesperson();
            POSAuditLog."Active POS Sale SystemId" := SalePOS.SystemId;
        end;

        if not POSUnit.Get(POSAuditLog."Active POS Unit No.") then
            if not POSUnit.Get(ActedOnPOSUnitNo) then
                exit;  //Not done from a POS Unit or acted on a POS Unit -> not relevant for a POS audit log.
        if not IsEnabled(POSUnit."POS Audit Profile") then
            exit;

        POSAuditLog."Record ID" := RecordIDIn;
        POSAuditLog."Action Type" := Type;
        POSAuditLog."Action Custom Subtype" := CustomType;
        POSAuditLog."Acted on POS Entry No." := ActedOnPOSEntryNo;
        POSAuditLog."Acted on POS Entry Fiscal No." := ActedOnPOSEntryFiscalNo;
        POSAuditLog."Acted on POS Unit No." := ActedOnPOSUnitNo;
        POSAuditLog."Log Timestamp" := CurrentDateTime;
        POSAuditLog."User ID" := UserId;
        POSAuditLog."External Description" := CopyStr(Description, 1, MaxStrLen(POSAuditLog."External Description"));
        POSAuditLog."Additional Information" := CopyStr(AddInfo, 1, MaxStrLen(POSAuditLog."Additional Information"));
        if Format(RecordIDIn) <> '' then begin
            RecRef.Get(RecordIDIn);
            POSAuditLog."Table ID" := RecRef.Number;
        end;

        OnHandleAuditLogBeforeInsert(POSAuditLog);

        POSAuditLog.Insert(true, true);
    end;

    procedure ShowAuditLogForRecord(RecordIDIn: RecordID)
    var
        POSAuditLog: Record "NPR POS Audit Log";
    begin
        POSAuditLog.SetRange("Record ID", RecordIDIn);
        PAGE.RunModal(0, POSAuditLog);
    end;

    procedure ShowAuditLogForPOSEntry(POSEntry: Record "NPR POS Entry")
    var
        POSAuditLog: Record "NPR POS Audit Log";
    begin
        POSAuditLog.SetRange("Acted on POS Entry No.", POSEntry."Entry No.");
        PAGE.RunModal(0, POSAuditLog);
    end;

    procedure LookupAuditHandler(var POSAuditProfile: Record "NPR POS Audit Profile")
    var
        tmpRetailList: Record "NPR Retail List" temporary;
    begin
        OnLookupAuditHandler(tmpRetailList);
        if PAGE.RunModal(0, tmpRetailList) <> ACTION::LookupOK then
            exit;
        POSAuditProfile."Audit Handler" := tmpRetailList.Choice;
    end;

    procedure LogPartnerModification(POSUnitNo: Text; Description: Text[250])
    var
        POSAuditLogMgt: Codeunit "NPR POS Audit Log Mgt.";
        RecordID: RecordID;
        POSAuditLog: Record "NPR POS Audit Log";
    begin
        //Some regulations require POS specific partner modification log flow.

        POSAuditLogMgt.CreateEntryExtended(RecordID, POSAuditLog."Action Type"::PARTNER_MODIFICATION, 0, '', POSUnitNo, '', Description);
    end;

    procedure InitializeLog(POSUnitNo: Text)
    var
        POSAuditLog: Record "NPR POS Audit Log";
        POSAuditLogMgt: Codeunit "NPR POS Audit Log Mgt.";
        ERROR_AUDIT_LOG: Label '%1 for %2 %3 already contains data';
        POSUnit: Record "NPR POS Unit";
    begin
        //Some regulations require POS specific log init event.

        POSAuditLog.SetRange("Active POS Unit No.", POSUnitNo);
        if not POSAuditLog.IsEmpty then
            Error(ERROR_AUDIT_LOG, POSAuditLog.TableCaption, POSUnit.TableCaption, POSUnitNo);

        POSUnit.Get(POSUnitNo);

        POSAuditLogMgt.CreateEntry(POSUnit.RecordId, POSAuditLog."Action Type"::LOG_INIT, 0, '', POSUnitNo);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnHandleAuditLogBeforeInsert(var POSAuditLog: Record "NPR POS Audit Log")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnArchiveWorkshiftPeriod(POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnValidateLogRecords(var POSAuditLog: Record "NPR POS Audit Log"; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnLookupAuditHandler(var tmpRetailList: Record "NPR Retail List" temporary)
    begin
    end;
}