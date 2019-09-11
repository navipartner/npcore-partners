codeunit 6150619 "POS Audit Log Mgt."
{
    // NPR5.48/MMV /20190121 CASE 318028 Created object
    // NPR5.51/MMV /20190611 CASE 356076 French regulation, 2nd audit.


    trigger OnRun()
    begin
    end;

    var
        ERROR_NO_LOG_VALIDATION: Label 'No log validation routine found';
        ERROR_MOD_DESC: Label 'A description of the modification is required';

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
        //-NPR5.51 [356076]
        CreateEntry(POSWorkshiftCheckpoint.RecordId,POSAuditLog."Action Type"::ARCHIVE_CREATE,POSEntry."Entry No.",POSEntry."Fiscal No.",POSWorkshiftCheckpoint."POS Unit No.");
        //+NPR5.51 [356076]
        OnArchiveWorkshiftPeriod(POSWorkshiftCheckpoint);
    end;

    procedure CreateEntry(RecordIDIn: RecordID;Type: Integer;ActedOnPOSEntryNo: Integer;ActedOnPOSEntryFiscalNo: Code[20];ActedOnPOSUnitNo: Code[10])
    begin
        //-NPR5.51 [356076]
        CreateEntryFull(RecordIDIn, Type, ActedOnPOSEntryNo, ActedOnPOSEntryFiscalNo, ActedOnPOSUnitNo, '', '', '');
        //+NPR5.51 [356076]
    end;

    procedure CreateEntryExtended(RecordIDIn: RecordID;Type: Integer;ActedOnPOSEntryNo: Integer;ActedOnPOSEntryFiscalNo: Code[20];ActedOnPOSUnitNo: Code[10];Description: Text[250];AddInfo: Text)
    begin
        //-NPR5.51 [356076]
        CreateEntryFull(RecordIDIn, Type, ActedOnPOSEntryNo, ActedOnPOSEntryFiscalNo, ActedOnPOSUnitNo, Description, AddInfo, '');
        //+NPR5.51 [356076]
    end;

    procedure CreateEntryCustom(RecordIDIn: RecordID;Subtype: Text[250];ActedOnPOSEntryNo: Integer;ActedOnPOSEntryFiscalNo: Code[20];ActedOnPOSUnitNo: Code[10];Description: Text[250];AddInfo: Text)
    var
        POSAuditLog: Record "POS Audit Log";
    begin
        //-NPR5.51 [356076]
        CreateEntryFull(RecordIDIn, POSAuditLog."Action Type"::CUSTOM, ActedOnPOSEntryNo, ActedOnPOSEntryFiscalNo, ActedOnPOSUnitNo, Description, AddInfo, Subtype);
        //+NPR5.51 [356076]
    end;

    local procedure CreateEntryFull(RecordIDIn: RecordID;Type: Integer;ActedOnPOSEntryNo: Integer;ActedOnPOSEntryFiscalNo: Code[20];ActedOnPOSUnitNo: Code[10];Description: Text[250];AddInfo: Text;CustomType: Text)
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
        //-NPR5.51 [356076]
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
        POSAuditLog."Action Custom Subtype" := CustomType;
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
        //+NPR5.51 [356076]
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

    procedure LogPartnerModification(POSUnitNo: Text;Description: Text[250])
    var
        POSAuditLogMgt: Codeunit "POS Audit Log Mgt.";
        RecordID: RecordID;
        POSAuditLog: Record "POS Audit Log";
    begin
        //-NPR5.51 [356076]
        //Some regulations require POS specific partner modification log flow.

        POSAuditLogMgt.CreateEntryExtended(RecordID, POSAuditLog."Action Type"::PARTNER_MODIFICATION, 0, '', POSUnitNo, '', Description);
        //+NPR5.51 [356076]
    end;

    procedure InitializeLog(POSUnitNo: Text)
    var
        POSAuditLog: Record "POS Audit Log";
        POSAuditLogMgt: Codeunit "POS Audit Log Mgt.";
        ERROR_AUDIT_LOG: Label '%1 for %2 %3 already contains data';
        POSUnit: Record "POS Unit";
    begin
        //-NPR5.51 [356076]
        //Some regulations require POS specific log init event.

        POSAuditLog.SetRange("Active POS Unit No.", POSUnitNo);
        if not POSAuditLog.IsEmpty then
          Error(ERROR_AUDIT_LOG, POSAuditLog.TableCaption, POSUnit.TableCaption, POSUnitNo);

        POSUnit.Get(POSUnitNo);

        POSAuditLogMgt.CreateEntry(POSUnit.RecordId, POSAuditLog."Action Type"::LOG_INIT, 0, '', POSUnitNo);
        //-NPR5.51 [356076]
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

