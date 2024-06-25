codeunit 6184848 "NPR AT Audit Mgt."
{
    Access = Internal;
    SingleInstance = true;

    var
        Enabled: Boolean;
        Initialized: Boolean;

    #region AT Fiscal - POS Handling Subscribers
    [EventSubscriber(ObjectType::Page, Page::"NPR POS Audit Profiles", 'OnHandlePOSAuditProfileAdditionalSetup', '', true, true)]
    local procedure OnHandlePOSAuditProfileAdditionalSetup(POSAuditProfile: Record "NPR POS Audit Profile")
    begin
        if not IsATAuditEnabled(POSAuditProfile.Code) then
            exit;

        OnActionShowSetup();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Audit Log Mgt.", 'OnLookupAuditHandler', '', true, true)]
    local procedure OnLookupAuditHandler(var tmpRetailList: Record "NPR Retail List")
    begin
        AddATAuditHandler(tmpRetailList);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Audit Log Mgt.", 'OnHandleAuditLogBeforeInsert', '', true, true)]
    local procedure OnHandleAuditLogBeforeInsert(var POSAuditLog: Record "NPR POS Audit Log")
    begin
        HandleOnHandleAuditLogBeforeInsert(POSAuditLog);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Store", 'OnBeforeRenameEvent', '', false, false)]
    local procedure OnBeforeRenamePOSStore(var Rec: Record "NPR POS Store"; var xRec: Record "NPR POS Store"; RunTrigger: Boolean)
    begin
        ErrorOnRenameOfPOSStoreIfAlreadyUsed(xRec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Unit", 'OnBeforeRenameEvent', '', false, false)]
    local procedure OnBeforeRenamePOSUnit(var Rec: Record "NPR POS Unit"; var xRec: Record "NPR POS Unit"; RunTrigger: Boolean)
    begin
        ErrorOnRenameOfPOSUnitIfAlreadyUsed(xRec);
    end;
    #endregion

    #region AT Fiscal - Audit Profile Mgt
    internal procedure CreateControlReceipt(ATCashRegister: Record "NPR AT Cash Register")
    var
        ATPOSAuditLogAuxInfo: Record "NPR AT POS Audit Log Aux. Info";
        ATFiskalyCommunication: Codeunit "NPR AT Fiskaly Communication";
    begin
        ATCashRegister.TestField(State, ATCashRegister.State::INITIALIZED);
        CheckCanControlReceiptBeCreated();
        InsertATPOSAuditLogAuxInfo(ATCashRegister, ATPOSAuditLogAuxInfo);
        ATFiskalyCommunication.SignControlReceipt(ATPOSAuditLogAuxInfo);
    end;

    local procedure CheckCanControlReceiptBeCreated()
    var
        ATFiscalizationSetup: Record "NPR AT Fiscalization Setup";
        ControlReceiptCannotBeCreatedErr: Label 'Control receipt cannot be created when the fiscalization is in training mode.';
    begin
        ATFiscalizationSetup.Get();
        if ATFiscalizationSetup.Training then
            Error(ControlReceiptCannotBeCreatedErr);
    end;

    local procedure InsertATPOSAuditLogAuxInfo(ATCashRegister: Record "NPR AT Cash Register"; var ATPOSAuditLogAuxInfo: Record "NPR AT POS Audit Log Aux. Info")
    var
        ATSCU: Record "NPR AT SCU";
        POSUnit: Record "NPR POS Unit";
    begin
        ATPOSAuditLogAuxInfo.Init();
        ATPOSAuditLogAuxInfo."Audit Entry Type" := ATPOSAuditLogAuxInfo."Audit Entry Type"::"Control Transaction";
        ATPOSAuditLogAuxInfo."Entry Date" := Today();
        POSUnit.Get(ATCashRegister."POS Unit No.");
        ATPOSAuditLogAuxInfo."POS Store Code" := POSUnit."POS Store Code";
        ATPOSAuditLogAuxInfo."POS Unit No." := ATCashRegister."POS Unit No.";
        ATPOSAuditLogAuxInfo."Receipt Type" := ATPOSAuditLogAuxInfo."Receipt Type"::NORMAL;
        ATSCU.Get(ATCashRegister."AT SCU Code");
        ATPOSAuditLogAuxInfo."AT Organization Code" := ATSCU."AT Organization Code";
        ATPOSAuditLogAuxInfo."AT SCU Code" := ATSCU.Code;
        ATPOSAuditLogAuxInfo."AT SCU Id" := ATSCU.SystemId;
        ATPOSAuditLogAuxInfo."AT Cash Register Id" := ATCashRegister.SystemId;
        ATPOSAuditLogAuxInfo."AT Cash Register Serial Number" := ATCashRegister."Serial Number";
        ATPOSAuditLogAuxInfo.Insert(true);
    end;

    local procedure AddATAuditHandler(var tmpRetailList: Record "NPR Retail List")
    begin
        tmpRetailList.Number += 1;
        tmpRetailList.Choice := CopyStr(HandlerCode(), 1, MaxStrLen(tmpRetailList.Choice));
        tmpRetailList.Insert();
    end;

    local procedure HandleOnHandleAuditLogBeforeInsert(var POSAuditLog: Record "NPR POS Audit Log")
    var
        POSEntry: Record "NPR POS Entry";
        POSStore: Record "NPR POS Store";
        POSUnit: Record "NPR POS Unit";
    begin
        if POSAuditLog."Active POS Unit No." = '' then
            POSAuditLog."Active POS Unit No." := POSAuditLog."Acted on POS Unit No.";

        if not POSUnit.Get(POSAuditLog."Active POS Unit No.") then
            exit;

        if not IsATAuditEnabled(POSUnit."POS Audit Profile") then
            exit;

        if not POSStore.Get(POSUnit."POS Store Code") then
            exit;

        if not (POSAuditLog."Action Type" in [POSAuditLog."Action Type"::DIRECT_SALE_END]) then
            exit;

        POSEntry.Get(POSAuditLog."Record ID");

        if not (POSEntry."Post Item Entry Status" in [POSEntry."Post Item Entry Status"::"Not To Be Posted"]) then
            InsertATPOSAuditLogAuxInfo(POSEntry, POSStore, POSUnit);
    end;

    local procedure InsertATPOSAuditLogAuxInfo(POSEntry: Record "NPR POS Entry"; POSStore: Record "NPR POS Store"; POSUnit: Record "NPR POS Unit")
    var
        ATCashRegister: Record "NPR AT Cash Register";
        ATPOSAuditLogAuxInfo: Record "NPR AT POS Audit Log Aux. Info";
        ATSCU: Record "NPR AT SCU";
    begin
        ATPOSAuditLogAuxInfo.Init();
        ATPOSAuditLogAuxInfo."Audit Entry Type" := ATPOSAuditLogAuxInfo."Audit Entry Type"::"POS Entry";
        ATPOSAuditLogAuxInfo."POS Entry No." := POSEntry."Entry No.";
        ATPOSAuditLogAuxInfo."Entry Date" := POSEntry."Entry Date";
        ATPOSAuditLogAuxInfo."POS Store Code" := POSStore.Code;
        ATPOSAuditLogAuxInfo."POS Unit No." := POSUnit."No.";
        ATPOSAuditLogAuxInfo."Source Document No." := POSEntry."Document No.";
        ATPOSAuditLogAuxInfo."Amount Incl. Tax" := POSEntry."Amount Incl. Tax";
        ATPOSAuditLogAuxInfo."Salesperson Code" := POSEntry."Salesperson Code";

        SetReceiptTypeOnATPOSAuditLogAuxInfo(POSEntry."Entry No.", ATPOSAuditLogAuxInfo);

        ATCashRegister.Get(ATPOSAuditLogAuxInfo."POS Unit No.");
        ATSCU.Get(ATCashRegister."AT SCU Code");
        ATPOSAuditLogAuxInfo."AT Organization Code" := ATSCU."AT Organization Code";
        ATPOSAuditLogAuxInfo."AT SCU Code" := ATSCU.Code;
        ATPOSAuditLogAuxInfo."AT SCU Id" := ATSCU.SystemId;
        ATPOSAuditLogAuxInfo."AT Cash Register Id" := ATCashRegister.SystemId;
        ATPOSAuditLogAuxInfo."AT Cash Register Serial Number" := ATCashRegister."Serial Number";

        ATPOSAuditLogAuxInfo.Insert(true);
    end;

    local procedure SetReceiptTypeOnATPOSAuditLogAuxInfo(POSEntryNo: Integer; var ATPOSAuditLogAuxInfo: Record "NPR AT POS Audit Log Aux. Info")
    var
        ATFiscalizationSetup: Record "NPR AT Fiscalization Setup";
        ATPOSAuditLogAuxInfoToRefund: Record "NPR AT POS Audit Log Aux. Info";
        OriginalPOSEntrySalesLine: Record "NPR POS Entry Sales Line";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
    begin
        ATFiscalizationSetup.Get();
        if ATFiscalizationSetup.Training then begin
            ATPOSAuditLogAuxInfo."Receipt Type" := ATPOSAuditLogAuxInfo."Receipt Type"::TRAINING;
            exit;
        end;

        case true of
            ATPOSAuditLogAuxInfo."Amount Incl. Tax" > 0:
                ATPOSAuditLogAuxInfo."Receipt Type" := ATPOSAuditLogAuxInfo."Receipt Type"::NORMAL;
            ATPOSAuditLogAuxInfo."Amount Incl. Tax" < 0:
                ATPOSAuditLogAuxInfo."Receipt Type" := ATPOSAuditLogAuxInfo."Receipt Type"::CANCELLATION;
            ATPOSAuditLogAuxInfo."Amount Incl. Tax" = 0:
                begin
                    POSEntrySalesLine.SetRange("POS Entry No.", POSEntryNo);
                    POSEntrySalesLine.FindFirst();

                    if not OriginalPOSEntrySalesLine.GetBySystemId(POSEntrySalesLine."Orig.POS Entry S.Line SystemId") then
                        ATPOSAuditLogAuxInfo."Receipt Type" := ATPOSAuditLogAuxInfo."Receipt Type"::NORMAL
                    else
                        if not ATPOSAuditLogAuxInfoToRefund.FindAuditLog(OriginalPOSEntrySalesLine."POS Entry No.") then
                            ATPOSAuditLogAuxInfo."Receipt Type" := ATPOSAuditLogAuxInfo."Receipt Type"::NORMAL
                        else
                            ATPOSAuditLogAuxInfo."Receipt Type" := ATPOSAuditLogAuxInfo."Receipt Type"::CANCELLATION;
                end;
        end;
    end;
    #endregion

    #region Subscribers - POS Management
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Sale", 'OnBeforeInitSale', '', false, false)]
    local procedure HandleOnBeforeInitSale(SaleHeader: Record "NPR POS Sale"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        POSUnit: Record "NPR POS Unit";
        POSSession: Codeunit "NPR POS Session";
        POSSetup: Codeunit "NPR POS Setup";
    begin
        FrontEnd.GetSession(POSSession);
        POSSession.GetSetup(POSSetup);
        POSSetup.GetPOSUnit(POSUnit);
        if not IsATAuditEnabled(POSUnit."POS Audit Profile") then
            exit;

        TestIsProfileSetAccordingToCompliance(POSUnit."POS Audit Profile");
        CheckATCashRegister(POSUnit);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Sale", 'OnBeforeEndSale', '', false, false)]
    local procedure HandleOnBeforeEndSale(var Sender: Codeunit "NPR POS Sale"; SaleHeader: Record "NPR POS Sale");
    var
        POSUnit: Record "NPR POS Unit";
    begin
        if not POSUnit.Get(SaleHeader."Register No.") then
            exit;

        if not IsATAuditEnabled(POSUnit."POS Audit Profile") then
            exit;

        CheckSalesAndReturnsInSameTransaction(SaleHeader, POSUnit."POS Audit Profile");
        CheckAreMandatoryMappingsPopulated(SaleHeader);
        DoNotAllowHavingBlankItemDescriptions(SaleHeader);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Sale", 'OnAfterEndSale', '', false, false)]
    local procedure HandleOnAfterEndSale(var Sender: Codeunit "NPR POS Sale"; SalePOS: Record "NPR POS Sale");
    var
        ATPOSAuditLogAuxInfo: Record "NPR AT POS Audit Log Aux. Info";
        POSEntry: Record "NPR POS Entry";
        POSUnit: Record "NPR POS Unit";
        ATFiscalThermalPrint: Codeunit "NPR AT Fiscal Thermal Print";
        ATFiskalyCommunication: Codeunit "NPR AT Fiskaly Communication";
        IsHandled: Boolean;
    begin
        if not POSUnit.Get(SalePOS."Register No.") then
            exit;

        if not IsATAuditEnabled(POSUnit."POS Audit Profile") then
            exit;

        if not FindPOSEntry(SalePOS."Sales Ticket No.", POSEntry) then
            exit;

        if not ATPOSAuditLogAuxInfo.FindAuditLog(POSEntry."Entry No.") then
            exit;

        ATFiskalyCommunication.SignReceipt(ATPOSAuditLogAuxInfo);

        OnBeforePrintReceiptOnHandleOnAfterEndSale(IsHandled);
        if IsHandled then
            exit;

        ATFiscalThermalPrint.PrintReceipt(ATPOSAuditLogAuxInfo);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Action: Rev. Dir. Sale", 'OnBeforeHendleReverse', '', false, false)]
    local procedure HandleOnBeforeHendleReverse(Setup: Codeunit "NPR POS Setup"; var SalesTicketNo: Code[20]);
    var
        POSUnit: Record "NPR POS Unit";
        NewSalesTicketNo: Code[20];
    begin
        Setup.GetPOSUnit(POSUnit);
        if not IsATAuditEnabled(POSUnit."POS Audit Profile") then
            exit;

        NewSalesTicketNo := GetSourceDocumentNoForReceiptNo(SalesTicketNo);
        if NewSalesTicketNo <> '' then
            SalesTicketNo := NewSalesTicketNo;
    end;
    #endregion

    #region Subscribers - Fiskaly Communication
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR AT Fiskaly Communication", 'OnAfterRetrieveCashRegister', '', false, false)]
    local procedure HandleOnAfterRetrieveCashRegister(var ATCashRegister: Record "NPR AT Cash Register")
    begin
        InsertStateRelatedReceiptsToATPOSAuditLogAuxInfo(ATCashRegister);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR AT Fiskaly Communication", 'OnAfterUpdateCashRegister', '', false, false)]
    local procedure HandleOnAfterUpdateCashRegister(var ATCashRegister: Record "NPR AT Cash Register")
    begin
        InsertStateRelatedReceiptsToATPOSAuditLogAuxInfo(ATCashRegister);
    end;

    local procedure InsertStateRelatedReceiptsToATPOSAuditLogAuxInfo(var ATCashRegister: Record "NPR AT Cash Register")
    var
        ATPOSAuditLogAuxInfo: Record "NPR AT POS Audit Log Aux. Info";
    begin
        if IsNullGuid(ATCashRegister."Initialization Receipt Id") and IsNullGuid(ATCashRegister."Decommission Receipt Id") then
            exit;

        if not IsNullGuid(ATCashRegister."Initialization Receipt Id") then
            if not ATPOSAuditLogAuxInfo.GetBySystemId(ATCashRegister."Initialization Receipt Id") then
                InsertATPOSAuditLogAuxInfo(ATCashRegister, Enum::"NPR AT Receipt Type"::INITIALIZATION, ATCashRegister."Initialization Receipt Id");

        if not IsNullGuid(ATCashRegister."Decommission Receipt Id") then
            if not ATPOSAuditLogAuxInfo.GetBySystemId(ATCashRegister."Decommission Receipt Id") then
                InsertATPOSAuditLogAuxInfo(ATCashRegister, Enum::"NPR AT Receipt Type"::DECOMMISSION, ATCashRegister."Decommission Receipt Id");
    end;

    local procedure InsertATPOSAuditLogAuxInfo(ATCashRegister: Record "NPR AT Cash Register"; ReceiptType: Enum "NPR AT Receipt Type"; ReceiptId: Guid)
    var
        ATPOSAuditLogAuxInfo: Record "NPR AT POS Audit Log Aux. Info";
        ATSCU: Record "NPR AT SCU";
        POSUnit: Record "NPR POS Unit";
        ATFiskalyCommunication: Codeunit "NPR AT Fiskaly Communication";
    begin
        ATPOSAuditLogAuxInfo.Init();
        ATPOSAuditLogAuxInfo."Audit Entry Type" := ATPOSAuditLogAuxInfo."Audit Entry Type"::"Control Transaction";
        ATPOSAuditLogAuxInfo."Entry Date" := Today();
        POSUnit.Get(ATCashRegister."POS Unit No.");
        ATPOSAuditLogAuxInfo."POS Store Code" := POSUnit."POS Store Code";
        ATPOSAuditLogAuxInfo."POS Unit No." := ATCashRegister."POS Unit No.";
        ATPOSAuditLogAuxInfo."Receipt Type" := ReceiptType;
        ATSCU.Get(ATCashRegister."AT SCU Code");
        ATPOSAuditLogAuxInfo."AT Organization Code" := ATSCU."AT Organization Code";
        ATPOSAuditLogAuxInfo."AT SCU Code" := ATSCU.Code;
        ATPOSAuditLogAuxInfo."AT SCU Id" := ATSCU.SystemId;
        ATPOSAuditLogAuxInfo."AT Cash Register Id" := ATCashRegister.SystemId;
        ATPOSAuditLogAuxInfo."AT Cash Register Serial Number" := ATCashRegister."Serial Number";
        ATPOSAuditLogAuxInfo.SystemId := ReceiptId;
        ATPOSAuditLogAuxInfo.Insert(false, true);

        ATFiskalyCommunication.RetrieveReceipt(ATPOSAuditLogAuxInfo);
        ATFiskalyCommunication.UpdateReceiptMetadata(ATPOSAuditLogAuxInfo);
    end;
    #endregion

    #region Job Queue Management
    internal procedure InitATFiscalJobQueues(ATFiscalizationEnabled: Boolean)
    begin
        InitATValidateReceiptsJobQueue(ATFiscalizationEnabled);
        InitATImportOtherControlReceiptsJobQueue(ATFiscalizationEnabled);
    end;

    local procedure InitATValidateReceiptsJobQueue(ATFiscalizationEnabled: Boolean)
    var
        JobQueueEntry: Record "Job Queue Entry";
        JobQueueManagement: Codeunit "NPR Job Queue Management";
        JobDescriptionLbl: Label 'AT Validate Receipts', MaxLength = 250;
    begin
        if ATFiscalizationEnabled then begin
            JobQueueManagement.SetJobTimeout(4, 0);  // 4 hours
            JobQueueManagement.SetAutoRescheduleAndNotifyOnError(true, 1800, ''); // reschedule to run again in 30 minutes
            if JobQueueManagement.InitRecurringJobQueueEntry(
                JobQueueEntry."Object Type to Run"::Codeunit,
                Codeunit::"NPR AT Validate Receipts JQ",
                '',
                JobDescriptionLbl,
                JobQueueManagement.NowWithDelayInSeconds(300),
                60,
                DefaultATFiscalJobQueueCategoryCode(),
                JobQueueEntry)
            then
                JobQueueManagement.StartJobQueueEntry(JobQueueEntry);
        end else
            if JobQueueEntry.FindJobQueueEntry(JobQueueEntry."Object Type to Run"::Codeunit, Codeunit::"NPR AT Validate Receipts JQ") then begin
                JobQueueEntry.FindSet(true);
                repeat
                    JobQueueEntry.Cancel();
                until JobQueueEntry.Next() = 0;
            end;
    end;

    local procedure InitATImportOtherControlReceiptsJobQueue(ATFiscalizationEnabled: Boolean)
    var
        JobQueueEntry: Record "Job Queue Entry";
        JobQueueManagement: Codeunit "NPR Job Queue Management";
        JobDescriptionLbl: Label 'AT Import Other Control Receipts', MaxLength = 250;
    begin
        if ATFiscalizationEnabled then begin
            JobQueueManagement.SetJobTimeout(4, 0);  // 4 hours
            JobQueueManagement.SetAutoRescheduleAndNotifyOnError(true, 300, ''); // reschedule to run again in 5 minutes
            if JobQueueManagement.InitRecurringJobQueueEntry(
                JobQueueEntry."Object Type to Run"::Codeunit,
                Codeunit::"NPR AT Imp Other Ctrl Rcpt JQ",
                '',
                JobDescriptionLbl,
                JobQueueManagement.NowWithDelayInSeconds(300),
                2,
                DefaultATFiscalJobQueueCategoryCode(),
                JobQueueEntry)
            then
                JobQueueManagement.StartJobQueueEntry(JobQueueEntry);
        end else
            if JobQueueEntry.FindJobQueueEntry(JobQueueEntry."Object Type to Run"::Codeunit, Codeunit::"NPR AT Imp Other Ctrl Rcpt JQ") then begin
                JobQueueEntry.FindSet(true);
                repeat
                    JobQueueEntry.Cancel();
                until JobQueueEntry.Next() = 0;
            end;
    end;

    local procedure DefaultATFiscalJobQueueCategoryCode(): Code[10]
    var
        JobQueueCategory: Record "Job Queue Category";
        ImportListJQCategoryCode: Label 'FISCAL', MaxLength = 10, Locked = true;
        ImportListJQCategoryDescrLbl: Label 'POS Audit Fiscal Processing', MaxLength = 30;
    begin
        JobQueueCategory.InsertRec(ImportListJQCategoryCode, ImportListJQCategoryDescrLbl);
        exit(JobQueueCategory.Code);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Job Queue Management", 'OnRefreshNPRJobQueueList', '', false, false)]
    local procedure RunInitATValidateReceiptsJobQueue()
    begin
        InitATValidateReceiptsJobQueue(IsATFiscalizationEnabled());
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Job Queue Management", 'OnRefreshNPRJobQueueList', '', false, false)]
    local procedure RunInitATImportOtherControlReceiptsJobQueue()
    begin
        InitATImportOtherControlReceiptsJobQueue(IsATFiscalizationEnabled());
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Job Queue Management", 'OnCheckIfIsNPRecurringJob', '', false, false)]
    local procedure HandleOnCheckIfIsNPRecurringJob(JobQueueEntry: Record "Job Queue Entry"; var IsNpJob: Boolean; var Handled: Boolean)
    begin
        if Handled then
            exit;

        if (JobQueueEntry."Object Type to Run" = JobQueueEntry."Object Type to Run"::Codeunit) and
           (JobQueueEntry."Object ID to Run" in [Codeunit::"NPR AT Validate Receipts JQ", Codeunit::"NPR AT Imp Other Ctrl Rcpt JQ"])
        then begin
            IsNpJob := true;
            Handled := true;
        end;
    end;
    #endregion

    #region AT Fiscal - Procedures/Helper Functions
    internal procedure IsATFiscalizationEnabled(): Boolean
    var
        ATFiscalizationSetup: Record "NPR AT Fiscalization Setup";
    begin
        if not ATFiscalizationSetup.Get() then
            exit(false);

        exit(ATFiscalizationSetup."AT Fiscal Enabled");
    end;

    local procedure IsATAuditEnabled(POSAuditProfileCode: Code[20]): Boolean
    var
        POSAuditProfile: Record "NPR POS Audit Profile";
    begin
        if not POSAuditProfile.Get(POSAuditProfileCode) then
            exit(false);

        if POSAuditProfile."Audit Handler" <> HandlerCode() then
            exit(false);

        if Initialized then
            exit(Enabled);

        Initialized := true;
        Enabled := true;
        exit(true);
    end;

    internal procedure HandlerCode(): Code[20]
    var
        HandlerCodeTxt: Label 'AT_FISKALY', Locked = true, MaxLength = 20;
    begin
        exit(HandlerCodeTxt);
    end;

    internal procedure GetControlReceiptItemText(): Text
    var
        ControlReceiptItemTextLbl: Label 'Nullbeleg', Locked = true;
    begin
        exit(ControlReceiptItemTextLbl);
    end;

    local procedure OnActionShowSetup()
    var
        ATFiscalizationSetup: Page "NPR AT Fiscalization Setup";
    begin
        ATFiscalizationSetup.RunModal();
    end;

    local procedure ErrorOnRenameOfPOSStoreIfAlreadyUsed(OldPOSStore: Record "NPR POS Store")
    var
        ATPOSAuditLogAuxInfo: Record "NPR AT POS Audit Log Aux. Info";
        CannotRenameErr: Label 'You cannot rename %1 %2 since there is at least one related %3 record and it can cause data discrepancy since it is being used for fiscalization.', Comment = '%1 - POS Store table caption, %2 - POS Store Code value, %3 - AT POS Audit Log Aux. Info table caption';
    begin
        if not IsATFiscalizationEnabled() then
            exit;

        ATPOSAuditLogAuxInfo.SetRange("POS Store Code", OldPOSStore.Code);
        if not ATPOSAuditLogAuxInfo.IsEmpty() then
            Error(CannotRenameErr, OldPOSStore.TableCaption(), OldPOSStore.Code, ATPOSAuditLogAuxInfo.TableCaption());
    end;

    local procedure ErrorOnRenameOfPOSUnitIfAlreadyUsed(OldPOSUnit: Record "NPR POS Unit")
    var
        ATCashRegister: Record "NPR AT Cash Register";
        ATPOSAuditLogAuxInfo: Record "NPR AT POS Audit Log Aux. Info";
        CannotRename2Err: Label 'You cannot rename %1 %2 since there is at least one related %3 created at Fiskaly and it can cause data discrepancy.', Comment = '%1 - POS Unit table caption, %2 - POS Unit No. value, %3 - AT Cash Register table caption';
        CannotRenameErr: Label 'You cannot rename %1 %2 since there is at least one related %3 record and it can cause data discrepancy since it is being used for fiscalization.', Comment = '%1 - POS Unit table caption, %2 - POS Unit No. value, %3 - AT POS Audit Log Aux. Info table caption';
    begin
        if not IsATAuditEnabled(OldPOSUnit."POS Audit Profile") then
            exit;

        ATPOSAuditLogAuxInfo.SetRange("POS Unit No.", OldPOSUnit."No.");
        if not ATPOSAuditLogAuxInfo.IsEmpty() then
            Error(CannotRenameErr, OldPOSUnit.TableCaption(), OldPOSUnit."No.", ATPOSAuditLogAuxInfo.TableCaption());

        ATCashRegister.SetRange("POS Unit No.", OldPOSUnit."No.");
        ATCashRegister.SetFilter("Created At", '<>%1', 0DT);
        if not ATCashRegister.IsEmpty() then
            Error(CannotRename2Err, OldPOSUnit.TableCaption(), OldPOSUnit."No.", ATCashRegister.TableCaption());
    end;

    local procedure FindPOSEntry(DocumentNo: Code[20]; var POSEntry: Record "NPR POS Entry"): Boolean
    begin
        POSEntry.SetCurrentKey("Document No.");
        POSEntry.SetRange("Document No.", DocumentNo);
        exit(POSEntry.FindFirst());
    end;

    local procedure GetSourceDocumentNoForReceiptNo(ReceiptNo: Text[30]): Code[20]
    var
        ATPOSAuditLogAuxInfo: Record "NPR AT POS Audit Log Aux. Info";
    begin
        ATPOSAuditLogAuxInfo.FilterGroup(10);
        ATPOSAuditLogAuxInfo.SetRange("Receipt Number", ReceiptNo);
        ATPOSAuditLogAuxInfo.FilterGroup(0);

        case ATPOSAuditLogAuxInfo.Count() of
            0:
                exit('');
            1:
                begin
                    if ATPOSAuditLogAuxInfo.FindFirst() then
                        exit(ATPOSAuditLogAuxInfo."Source Document No.");

                    exit('');
                end;
            else begin
                if Page.RunModal(0, ATPOSAuditLogAuxInfo) <> Action::LookupOK then
                    exit('');

                exit(ATPOSAuditLogAuxInfo."Source Document No.");
            end;
        end;
    end;
    #endregion

    #region Procedures - Validations
    local procedure TestIsProfileSetAccordingToCompliance(POSAuditProfileCode: Code[20])
    var
        POSAuditProfile: Record "NPR POS Audit Profile";
    begin
        POSAuditProfile.Get(POSAuditProfileCode);
        POSAuditProfile.TestField("Sale Fiscal No. Series");
        POSAuditProfile.TestField("Credit Sale Fiscal No. Series");
        POSAuditProfile.TestField("Balancing Fiscal No. Series");
        POSAuditProfile.TestField("Fill Sale Fiscal No. On", POSAuditProfile."Fill Sale Fiscal No. On"::Successful);
        POSAuditProfile.TestField("Print Receipt On Sale Cancel", false);
        POSAuditProfile.TestField("Do Not Print Receipt on Sale", false);
        POSAuditProfile.TestField(AllowSalesAndReturnInSameTrans, false);
    end;

    local procedure CheckATCashRegister(POSUnit: Record "NPR POS Unit")
    var
        ATCashRegister: Record "NPR AT Cash Register";
    begin
        ATCashRegister.GetWithCheck(POSUnit."No.");
    end;

    local procedure CheckSalesAndReturnsInSameTransaction(SaleHeader: Record "NPR POS Sale"; POSAuditProfileCode: Code[20])
    var
        POSAuditProfile: Record "NPR POS Audit Profile";
        POSSaleLine: Record "NPR POS Sale Line";
        SalesAndReturnsNotAllowedInSameTransactionErr: Label 'It is not allowed to sale and return item(s) in same transaction.';
    begin
        POSAuditProfile.Get(POSAuditProfileCode);
        if POSAuditProfile.AllowSalesAndReturnInSameTrans then
            exit;

        POSSaleLine.SetCurrentKey("Register No.", "Sales Ticket No.", "Line Type");
        POSSaleLine.SetRange("Register No.", SaleHeader."Register No.");
        POSSaleLine.SetRange("Sales Ticket No.", SaleHeader."Sales Ticket No.");
        POSSaleLine.SetRange("Line Type", POSSaleLine."Line Type"::Item);
        POSSaleLine.SetFilter(Quantity, '>0');
        if POSSaleLine.IsEmpty() then
            exit;

        POSSaleLine.SetFilter(Quantity, '<0');
        if POSSaleLine.IsEmpty() then
            exit;

        Error(SalesAndReturnsNotAllowedInSameTransactionErr);
    end;

    local procedure CheckAreMandatoryMappingsPopulated(SaleHeader: Record "NPR POS Sale")
    var
        ATPOSPaymentMethodMap: Record "NPR AT POS Payment Method Map";
        ATVATPostingSetupMap: Record "NPR AT VAT Posting Setup Map";
        POSSaleLine: Record "NPR POS Sale Line";
    begin
        POSSaleLine.SetCurrentKey("Register No.", "Sales Ticket No.", "Line Type");
        POSSaleLine.SetRange("Register No.", SaleHeader."Register No.");
        POSSaleLine.SetRange("Sales Ticket No.", SaleHeader."Sales Ticket No.");
        POSSaleLine.SetFilter("Line Type", '%1|%2', POSSaleLine."Line Type"::Item, POSSaleLine."Line Type"::"POS Payment");
        if POSSaleLine.FindSet() then
            repeat
                case POSSaleLine."Line Type" of
                    POSSaleLine."Line Type"::Item:
                        begin
                            ATVATPostingSetupMap.Get(POSSaleLine."VAT Bus. Posting Group", POSSaleLine."VAT Prod. Posting Group");
                            ATVATPostingSetupMap.CheckIsATVATRatePopulated();
                        end;
                    POSSaleLine."Line Type"::"POS Payment":
                        begin
                            ATPOSPaymentMethodMap.Get(POSSaleLine."No.");
                            ATPOSPaymentMethodMap.CheckIsATPaymentTypePopulated();
                        end;
                end;
            until POSSaleLine.Next() = 0;
    end;

    local procedure DoNotAllowHavingBlankItemDescriptions(SaleHeader: Record "NPR POS Sale")
    var
        POSSaleLine: Record "NPR POS Sale Line";
        BlankItemDescriptionErr: Label '%1 related to %2 %3 cannot have blank %4.', Comment = '%1 - POS Sale Line table caption, %2 - Line Type Item value, %3 - Item No. value, %4 - Description value';
    begin
        POSSaleLine.SetCurrentKey("Register No.", "Sales Ticket No.", "Line Type");
        POSSaleLine.SetRange("Register No.", SaleHeader."Register No.");
        POSSaleLine.SetRange("Sales Ticket No.", SaleHeader."Sales Ticket No.");
        POSSaleLine.SetRange("Line Type", POSSaleLine."Line Type"::Item);
        POSSaleLine.SetRange(Description, '');
        if POSSaleLine.FindFirst() then
            Error(BlankItemDescriptionErr, POSSaleLine.TableCaption(), Format(POSSaleLine."Line Type"::Item), POSSaleLine."No.", POSSaleLine.FieldCaption(Description));
    end;
    #endregion

    #region Automation Test Mockup Helpers
    [IntegrationEvent(false, false)]
    local procedure OnBeforePrintReceiptOnHandleOnAfterEndSale(var IsHandled: Boolean)
    begin
    end;
    #endregion
}