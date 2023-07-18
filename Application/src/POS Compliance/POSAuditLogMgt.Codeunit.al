codeunit 6150619 "NPR POS Audit Log Mgt."
{
    Access = Internal;

    internal procedure IsEnabled(POSAuditProfileCode: Code[20]): Boolean
    var
        POSAuditProfile: Record "NPR POS Audit Profile";
    begin
        if not POSAuditProfile.Get(POSAuditProfileCode) then
            exit(false);
        exit(POSAuditProfile."Audit Log Enabled");
    end;

    procedure ValidateLog(var POSAuditLog: Record "NPR POS Audit Log"): Boolean
    var
        BlankRecordID: RecordID;
        POSAuditLogVerify: Codeunit "NPR POS Audit Log Verify";
        Error: Boolean;
    begin
        CreateEntry(BlankRecordID, POSAuditLog."Action Type"::AUDIT_VERIFY, 0, '', '');
        Commit();
        if POSAuditLogVerify.Run(POSAuditLog) then; //will always return false because an error is needed to rollback DB changes while validating

        Error := POSAuditLogVerify.VerificationError();
        if Error then begin
            //The reason we use a global boolean in a codeunit to transfer error flag is because french compliance performs temporary DB re-calculations that HAS to be rolled back even when there is no error. 
            //So it always errors in normal NAV terminology to trigger that rollback. 
            CreateEntry(BlankRecordID, POSAuditLog."Action Type"::AUDIT_VERIFY_ERROR, 0, '', '');
            Message(GetLastErrorText());
        end;
        exit(Error);
    end;

    procedure ArchiveWorkshiftPeriod(POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint")
    var
        POSAuditLog: Record "NPR POS Audit Log";
        POSEntry: Record "NPR POS Entry";
    begin
        POSEntry.Get(POSWorkshiftCheckpoint."POS Entry No.");
        CreateEntry(POSWorkshiftCheckpoint.RecordId, POSAuditLog."Action Type"::ARCHIVE_ATTEMPT, POSEntry."Entry No.", POSEntry."Fiscal No.", POSEntry."POS Unit No.");
        CreateEntry(POSWorkshiftCheckpoint.RecordId, POSAuditLog."Action Type"::ARCHIVE_CREATE, POSEntry."Entry No.", POSEntry."Fiscal No.", POSWorkshiftCheckpoint."POS Unit No.");
        Commit();
        OnArchiveWorkshiftPeriod(POSWorkshiftCheckpoint);
    end;

    procedure CreateEntry(RecordIDIn: RecordID; Type: Integer; ActedOnPOSEntryNo: Integer; ActedOnPOSEntryFiscalNo: Code[20]; ActedOnPOSUnitNo: Code[10])
    begin
        CreateEntryFull(RecordIDIn, Type, ActedOnPOSEntryNo, ActedOnPOSEntryFiscalNo, ActedOnPOSUnitNo, '', '', '');
    end;

    procedure CreateEntryExtended(RecordIDIn: RecordID; Type: Integer; ActedOnPOSEntryNo: Integer; ActedOnPOSEntryFiscalNo: Code[20]; ActedOnPOSUnitNo: Code[10]; Description: Text; AddInfo: Text)
    begin
        CreateEntryFull(RecordIDIn, Type, ActedOnPOSEntryNo, ActedOnPOSEntryFiscalNo, ActedOnPOSUnitNo, Description, AddInfo, '');
    end;

    procedure CreateEntryCustom(RecordIDIn: RecordID; Subtype: Text[250]; ActedOnPOSEntryNo: Integer; ActedOnPOSEntryFiscalNo: Code[20]; ActedOnPOSUnitNo: Code[10]; Description: Text; AddInfo: Text)
    var
        POSAuditLog: Record "NPR POS Audit Log";
    begin
        CreateEntryFull(RecordIDIn, POSAuditLog."Action Type"::CUSTOM, ActedOnPOSEntryNo, ActedOnPOSEntryFiscalNo, ActedOnPOSUnitNo, Description, AddInfo, Subtype);
    end;

    local procedure CreateEntryFull(RecordIDIn: RecordID; Type: Integer; ActedOnPOSEntryNo: Integer; ActedOnPOSEntryFiscalNo: Code[20]; ActedOnPOSUnitNo: Code[10]; Description: Text; AddInfo: Text; CustomType: Text)
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
        POSAuditLog."Action Custom Subtype" := CopyStr(CustomType, 1, MaxStrLen(POSAuditLog."Action Custom Subtype"));
        POSAuditLog."Acted on POS Entry No." := ActedOnPOSEntryNo;
        POSAuditLog."Acted on POS Entry Fiscal No." := ActedOnPOSEntryFiscalNo;
        POSAuditLog."Acted on POS Unit No." := ActedOnPOSUnitNo;
        POSAuditLog."Log Timestamp" := CurrentDateTime;
        POSAuditLog."User ID" := CopyStr(UserId, 1, MaxStrLen(POSAuditLog."User ID"));
        POSAuditLog."External Description" := CopyStr(Description, 1, MaxStrLen(POSAuditLog."External Description"));
        POSAuditLog."Additional Information" := CopyStr(AddInfo, 1, MaxStrLen(POSAuditLog."Additional Information"));
        if Format(RecordIDIn) <> '' then begin
            RecRef.Get(RecordIDIn);
            POSAuditLog."Table ID" := RecRef.Number;
        end;

        OnHandleAuditLogBeforeInsert(POSAuditLog);
        POSAuditLog.Insert(true);
        OnHandleAuditLogAfterInsert(POSAuditLog);
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
        POSAuditLog.SetRange("Active POS Sale SystemId", POSEntry.SystemId);
        PAGE.RunModal(0, POSAuditLog);
    end;

    procedure LookupAuditHandler(var SelectedAuditHandler: Text): Boolean
    var
        TempRetailList: Record "NPR Retail List" temporary;
    begin
        OnLookupAuditHandler(TempRetailList);
        if SelectedAuditHandler <> '' then begin
            TempRetailList.Choice := CopyStr(SelectedAuditHandler, 1, MaxStrLen(TempRetailList.Choice));
            if TempRetailList.Find('=><') then;
        end;
        if PAGE.RunModal(0, TempRetailList) <> ACTION::LookupOK then
            exit(false);
        SelectedAuditHandler := TempRetailList.Choice;
        exit(true);
    end;

    procedure LogPartnerModification(POSUnitNo: Text[10]; Description: Text[250])
    var
        POSAuditLogMgt: Codeunit "NPR POS Audit Log Mgt.";
        RecordID: RecordID;
        POSAuditLog: Record "NPR POS Audit Log";
    begin
        //Some regulations require POS specific partner modification log flow.

        POSAuditLogMgt.CreateEntryExtended(RecordID, POSAuditLog."Action Type"::PARTNER_MODIFICATION, 0, '', POSUnitNo, '', Description);
    end;

    procedure InitializeLog(POSUnitNo: Text[10])
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

    internal procedure PreparePOSActionAuthDescription(WorkflowName: Text; ButtonType: Text; ButtonParameter: Text; POSUnit: Record "NPR POS Unit"; var ActionSystemId: RecordId; var DescriptionLog: Text)
    var
        MissingInfoLbl: Label 'No button information was provided from FrontEnd.';
        POSMenu: Record "NPR POS Menu";
        POSAction: Record "NPR POS Action";
        POSSetup: Record "NPR POS Setup";
    begin
        case true of
            ButtonType = 'ActionType.PopupMenu':
                begin
                    DescriptionLog := StrSubstNo('authorized PopupMenu %1', ButtonParameter);
                    if POSMenu.Get(ButtonParameter) then
                        ActionSystemId := POSMenu.RecordId;
                end;
            ButtonType = 'Payment':
                begin
                    DescriptionLog := StrSubstNo('authorized Payment %1', ButtonParameter);
                    if POSUnit."POS Named Actions Profile" <> '' then
                        POSSetup.Get(POSUnit."POS Named Actions Profile")
                    else
                        POSSetup.FindFirst();
                    if POSAction.Get(POSSetup."Payment Action Code") then
                        ActionSystemId := POSAction.RecordId;
                end;
            ButtonType = 'Item':
                begin
                    DescriptionLog := StrSubstNo('authorized Action Item %1', ButtonParameter);
                    if POSUnit."POS Named Actions Profile" <> '' then
                        POSSetup.Get(POSUnit."POS Named Actions Profile")
                    else
                        POSSetup.FindFirst();
                    if POSAction.Get(POSSetup."Item Insert Action Code") then
                        ActionSystemId := POSAction.RecordId;
                end;
            ButtonType = 'Customer':
                begin
                    DescriptionLog := StrSubstNo('authorized Action Customer %1', ButtonParameter);
                    if POSUnit."POS Named Actions Profile" <> '' then
                        POSSetup.Get(POSUnit."POS Named Actions Profile")
                    else
                        POSSetup.FindFirst();
                    if POSAction.Get(POSSetup."Customer Action Code") then
                        ActionSystemId := POSAction.RecordId;
                end;
            ButtonType = 'Workflow':
                begin
                    DescriptionLog := StrSubstNo('authorized Action %1', WorkflowName);
                    if POSAction.Get(WorkflowName) then
                        ActionSystemId := POSAction.RecordId;
                end;
            ButtonType = 'EditMode':
                begin
                    DescriptionLog := 'authorized entering edit mode in POS Editor'
                end;
            else
                DescriptionLog := MissingInfoLbl;
        end;

    end;

    [IntegrationEvent(false, false)]
    local procedure OnHandleAuditLogBeforeInsert(var POSAuditLog: Record "NPR POS Audit Log")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnHandleAuditLogAfterInsert(var POSAuditLog: Record "NPR POS Audit Log")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnArchiveWorkshiftPeriod(POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnValidateLogRecords(var POSAuditLog: Record "NPR POS Audit Log"; var Handled: Boolean; var Error: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnLookupAuditHandler(var tmpRetailList: Record "NPR Retail List" temporary)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnShowAdditionalInfo(POSAuditLog: Record "NPR POS Audit Log")
    begin
    end;

}
