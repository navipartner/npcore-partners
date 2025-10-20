codeunit 6184866 "NPR ES Audit Mgt."
{
    Access = Internal;
    Permissions = TableData "Tenant Media" = rd;

    var
        Enabled: Boolean;
        Initialized: Boolean;

    #region ES Fiscal - POS Handling Subscribers
    [EventSubscriber(ObjectType::Page, Page::"NPR POS Audit Profiles", 'OnHandlePOSAuditProfileAdditionalSetup', '', true, true)]
    local procedure OnHandlePOSAuditProfileAdditionalSetup(POSAuditProfile: Record "NPR POS Audit Profile")
    begin
        if not IsESAuditEnabled(POSAuditProfile.Code) then
            exit;

        OnActionShowSetup();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Audit Log Mgt.", 'OnLookupAuditHandler', '', true, true)]
    local procedure OnLookupAuditHandler(var tmpRetailList: Record "NPR Retail List")
    begin
        AddESAuditHandler(tmpRetailList);
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

    #region ES Fiscal - Sandbox Env. Cleanup

#if not (BC17 or BC18 or BC19)
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Environment Cleanup", 'OnClearCompanyConfig', '', false, false)]
    local procedure OnClearCompanyConfig(CompanyName: Text; SourceEnv: Enum "Environment Type"; DestinationEnv: Enum "Environment Type")
    var
        ESFiscalizationSetup: Record "NPR ES Fiscalization Setup";
    begin
        if DestinationEnv <> DestinationEnv::Sandbox then
            exit;

        ESFiscalizationSetup.ChangeCompany(CompanyName);
        if ESFiscalizationSetup.Get() then
            ESFiscalizationSetup.Delete();
    end;
#endif

    #endregion

    #region ES Fiscal - Audit Profile Mgt
    local procedure AddESAuditHandler(var tmpRetailList: Record "NPR Retail List")
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
        SalePOS: Record "NPR POS Sale";
    begin
        if POSAuditLog."Active POS Unit No." = '' then
            POSAuditLog."Active POS Unit No." := POSAuditLog."Acted on POS Unit No.";

        if not POSUnit.Get(POSAuditLog."Active POS Unit No.") then
            exit;

        if not IsESAuditEnabled(POSUnit."POS Audit Profile") then
            exit;

        if not POSStore.Get(POSUnit."POS Store Code") then
            exit;

        case true of
            POSAuditLog."Action Type" = POSAuditLog."Action Type"::CUSTOMER_INFORMATION:
                begin
                    SalePOS.GetBySystemId(POSAuditLog."Active POS Sale SystemId");
                    InsertESPOSAuditLogAuxInfo(SalePOS, POSStore, POSUnit);
                end;
            POSAuditLog."Action Type" = POSAuditLog."Action Type"::DIRECT_SALE_END:
                begin
                    POSEntry.Get(POSAuditLog."Record ID");

                    if not (POSEntry."Post Item Entry Status" in [POSEntry."Post Item Entry Status"::"Not To Be Posted"]) then
                        InsertESPOSAuditLogAuxInfo(POSEntry, POSStore, POSUnit);
                end;
        end;
    end;

    local procedure InsertESPOSAuditLogAuxInfo(SalePOS: Record "NPR POS Sale"; POSStore: Record "NPR POS Store"; POSUnit: Record "NPR POS Unit")
    var
        ESPOSAuditLogAuxInfo: Record "NPR ES POS Audit Log Aux. Info";
    begin
        ESPOSAuditLogAuxInfo.Init();
        ESPOSAuditLogAuxInfo."Audit Entry Type" := ESPOSAuditLogAuxInfo."Audit Entry Type"::"Customer Information";
        ESPOSAuditLogAuxInfo."POS Store Code" := POSStore.Code;
        ESPOSAuditLogAuxInfo."POS Unit No." := POSUnit."No.";
        ESPOSAuditLogAuxInfo."Source Document No." := SalePOS."Sales Ticket No.";
        ESPOSAuditLogAuxInfo."Salesperson Code" := SalePOS."Salesperson Code";

        SetInvoiceRecipientFieldsOnESPOSAuditLogAuxInfo(ESPOSAuditLogAuxInfo);
        ESPOSAuditLogAuxInfo.Insert(true);
    end;

    local procedure InsertESPOSAuditLogAuxInfo(POSEntry: Record "NPR POS Entry"; POSStore: Record "NPR POS Store"; POSUnit: Record "NPR POS Unit")
    var
        ESClient: Record "NPR ES Client";
        ESPOSAuditLogAuxInfo: Record "NPR ES POS Audit Log Aux. Info";
        ESSigner: Record "NPR ES Signer";
    begin
        ESPOSAuditLogAuxInfo.Init();
        ESPOSAuditLogAuxInfo."Audit Entry Type" := ESPOSAuditLogAuxInfo."Audit Entry Type"::"POS Entry";
        ESPOSAuditLogAuxInfo."POS Entry No." := POSEntry."Entry No.";
        ESPOSAuditLogAuxInfo."Entry Date" := POSEntry."Entry Date";
        ESPOSAuditLogAuxInfo."POS Store Code" := POSStore.Code;
        ESPOSAuditLogAuxInfo."POS Unit No." := POSUnit."No.";
        ESPOSAuditLogAuxInfo."Source Document No." := POSEntry."Document No.";
        ESPOSAuditLogAuxInfo."Amount Incl. Tax" := POSEntry."Amount Incl. Tax";
        ESPOSAuditLogAuxInfo."Salesperson Code" := POSEntry."Salesperson Code";

        ESClient.Get(ESPOSAuditLogAuxInfo."POS Unit No.");
        ESSigner.Get(ESClient."ES Signer Code");
        ESPOSAuditLogAuxInfo."ES Organization Code" := ESSigner."ES Organization Code";
        ESPOSAuditLogAuxInfo."ES Signer Code" := ESSigner.Code;
        ESPOSAuditLogAuxInfo."ES Signer Id" := ESSigner.SystemId;
        ESPOSAuditLogAuxInfo."ES Client Id" := ESClient.SystemId;

        SetInvoiceFieldsOnESPOSAuditLogAuxInfo(POSEntry."Entry No.", ESPOSAuditLogAuxInfo);
        ESPOSAuditLogAuxInfo.Insert(true);
    end;

    local procedure SetInvoiceRecipientFieldsOnESPOSAuditLogAuxInfo(var ESPOSAuditLogAuxInfo: Record "NPR ES POS Audit Log Aux. Info")
    var
        ESInvoiceRecipient: Page "NPR ES Invoice Recipient";
    begin
        if ESInvoiceRecipient.RunModal() <> Action::OK then
            ESInvoiceRecipient.ThrowMustEnterNecessaryCompleteInvoiceDataError();

        ESPOSAuditLogAuxInfo."Recipient Type" := ESInvoiceRecipient.GetRecipientType();
        ESPOSAuditLogAuxInfo."Recipient Legal Name" := ESInvoiceRecipient.GetRecipientLegalName();
        ESPOSAuditLogAuxInfo."Recipient Address" := ESInvoiceRecipient.GetRecipientAddress();
        ESPOSAuditLogAuxInfo."Recipient Post Code" := ESInvoiceRecipient.GetRecipientPostCode();

        case ESPOSAuditLogAuxInfo."Recipient Type" of
            ESPOSAuditLogAuxInfo."Recipient Type"::National:
                ESPOSAuditLogAuxInfo."Recipient VAT Registration No." := ESInvoiceRecipient.GetRecipientVATRegistrationNo();
            ESPOSAuditLogAuxInfo."Recipient Type"::International:
                begin
                    ESPOSAuditLogAuxInfo."Recipient Identification Type" := ESInvoiceRecipient.GetRecipientIdentificationType();
                    ESPOSAuditLogAuxInfo."Recipient Identification No." := ESInvoiceRecipient.GetRecipientIdentificationNo();
                    ESPOSAuditLogAuxInfo."Recipient Country/Region Code" := ESInvoiceRecipient.GetRecipientCountryRegionCode();
                end;
        end;
    end;

    local procedure SetInvoiceFieldsOnESPOSAuditLogAuxInfo(POSEntryNo: Integer; var ESPOSAuditLogAuxInfo: Record "NPR ES POS Audit Log Aux. Info")
    var
        ESFiscalizationSetup: Record "NPR ES Fiscalization Setup";
        ESPOSAuditLogAuxInfoToRefund: Record "NPR ES POS Audit Log Aux. Info";
        OriginalPOSEntrySalesLine: Record "NPR POS Entry Sales Line";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
    begin
        ESFiscalizationSetup.Get();

        case true of
            (ESPOSAuditLogAuxInfo."Amount Incl. Tax" > 0) and (ESPOSAuditLogAuxInfo."Amount Incl. Tax" <= ESFiscalizationSetup."Simplified Invoice Limit"):
                ESPOSAuditLogAuxInfo."Invoice Type" := ESPOSAuditLogAuxInfo."Invoice Type"::SIMPLIFIED;
            (ESPOSAuditLogAuxInfo."Amount Incl. Tax" > 0) and (ESPOSAuditLogAuxInfo."Amount Incl. Tax" > ESFiscalizationSetup."Simplified Invoice Limit"):
                ESPOSAuditLogAuxInfo."Invoice Type" := ESPOSAuditLogAuxInfo."Invoice Type"::COMPLETE;
            ESPOSAuditLogAuxInfo."Amount Incl. Tax" < 0:
                ESPOSAuditLogAuxInfo."Invoice Type" := ESPOSAuditLogAuxInfo."Invoice Type"::CORRECTING;
            ESPOSAuditLogAuxInfo."Amount Incl. Tax" = 0:
                begin
                    POSEntrySalesLine.SetRange("POS Entry No.", POSEntryNo);
                    POSEntrySalesLine.FindFirst();

                    if OriginalPOSEntrySalesLine.GetBySystemId(POSEntrySalesLine."Orig.POS Entry S.Line SystemId") then
                        if ESPOSAuditLogAuxInfoToRefund.FindAuditLog(OriginalPOSEntrySalesLine."POS Entry No.") then
                            ESPOSAuditLogAuxInfo."Invoice Type" := ESPOSAuditLogAuxInfo."Invoice Type"::CORRECTING
                        else
                            ESPOSAuditLogAuxInfo."Invoice Type" := ESPOSAuditLogAuxInfo."Invoice Type"::SIMPLIFIED
                    else
                        ESPOSAuditLogAuxInfo."Invoice Type" := ESPOSAuditLogAuxInfo."Invoice Type"::SIMPLIFIED;
                end;
        end;
    end;
    #endregion

    #region Subscribers - POS Management
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Sale", 'OnBeforeInitSale', '', false, false)]
    local procedure OnBeforeInitSale(SaleHeader: Record "NPR POS Sale"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        POSUnit: Record "NPR POS Unit";
        POSSession: Codeunit "NPR POS Session";
        POSSetup: Codeunit "NPR POS Setup";
    begin
        FrontEnd.GetSession(POSSession);
        POSSession.GetSetup(POSSetup);
        POSSetup.GetPOSUnit(POSUnit);
        if not IsESAuditEnabled(POSUnit."POS Audit Profile") then
            exit;

        TestIsProfileSetAccordingToCompliance(POSUnit."POS Audit Profile");
        CheckESFiscalizationSetup();
        CheckESClientAndESOrganization(POSUnit);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Front End Management", 'OnBeforeChangeToPaymentView', '', false, false)]
    local procedure OnBeforeChangeToPaymentView(sender: Codeunit "NPR POS Front End Management"; POSSession: Codeunit "NPR POS Session")
    var
        SaleHeader: Record "NPR POS Sale";
        POSUnit: Record "NPR POS Unit";
        POSSale: Codeunit "NPR POS Sale";
        POSSetup: Codeunit "NPR POS Setup";
    begin
        POSSession.GetSetup(POSSetup);
        POSSetup.GetPOSUnit(POSUnit);
        if not IsESAuditEnabled(POSUnit."POS Audit Profile") then
            exit;

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SaleHeader);

        ShowCustomerInformationRequiredWarningIfTotalSalesAmountAboveThreshold(SaleHeader);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Sale", 'OnAfterValidateSaleBeforeEnd', '', false, false)]
    local procedure OnAfterValidateSaleBeforeEnd(var SalePOS: Record "NPR POS Sale")
    var
        POSUnit: Record "NPR POS Unit";
        ESFiscalizationSetup: Record "NPR ES Fiscalization Setup";
        POSAuditLog: Record "NPR POS Audit Log";
        POSAuditLogMgt: Codeunit "NPR POS Audit Log Mgt.";
        TotalSalesAmount: Decimal;
    begin
        if not POSUnit.Get(SalePOS."Register No.") then
            exit;

        if not IsESAuditEnabled(POSUnit."POS Audit Profile") then
            exit;

        TotalSalesAmount := CalcTotalSalesAmount(SalePOS);
        if TotalSalesAmount <= 0 then
            exit;

        ESFiscalizationSetup.Get();

        if IsTotalSalesAmountAboveThreshold(TotalSalesAmount, ESFiscalizationSetup."Simplified Invoice Limit") then begin
            POSAuditLog.SetRange("Active POS Sale SystemId", SalePOS.SystemId);
            POSAuditLog.SetRange("Action Type", POSAuditLog."Action Type"::CUSTOMER_INFORMATION);
            if POSAuditLog.IsEmpty() then
                POSAuditLogMgt.CreateEntry(SalePOS.RecordId(), POSAuditLog."Action Type"::CUSTOMER_INFORMATION, 0, '', SalePOS."Register No.");
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Sale", 'OnBeforeEndSale', '', false, false)]
    local procedure OnBeforeEndSale(var Sender: Codeunit "NPR POS Sale"; SaleHeader: Record "NPR POS Sale");
    var
        POSUnit: Record "NPR POS Unit";
    begin
        if not POSUnit.Get(SaleHeader."Register No.") then
            exit;

        if not IsESAuditEnabled(POSUnit."POS Audit Profile") then
            exit;

        CheckAreMandatoryMappingsPopulated(SaleHeader);
        CheckItemDescriptions(SaleHeader);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Sale", 'OnAfterEndSale', '', false, false)]
    local procedure OnAfterEndSale(var Sender: Codeunit "NPR POS Sale"; SalePOS: Record "NPR POS Sale");
    var
        ESPOSAuditLogAuxInfo: Record "NPR ES POS Audit Log Aux. Info";
        POSEntry: Record "NPR POS Entry";
        POSUnit: Record "NPR POS Unit";
        ESFiskalyCommunication: Codeunit "NPR ES Fiskaly Communication";
        ESFiscalThermalPrint: Codeunit "NPR ES Fiscal Thermal Print";
    begin
        if not POSUnit.Get(SalePOS."Register No.") then
            exit;

        if not IsESAuditEnabled(POSUnit."POS Audit Profile") then
            exit;

        if not FindPOSEntry(SalePOS."Sales Ticket No.", POSEntry) then
            exit;

        if not ESPOSAuditLogAuxInfo.FindAuditLog(POSEntry."Entry No.") then
            exit;

        ESFiskalyCommunication.CreateInvoice(ESPOSAuditLogAuxInfo);

        if IsPrintReceiptEnabled() then
            ESFiscalThermalPrint.Run(POSEntry);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Action: Rev. Dir. Sale", 'OnBeforeHendleReverse', '', false, false)]
    local procedure OnBeforeHendleReverse(Setup: Codeunit "NPR POS Setup"; var SalesTicketNo: Code[20])
    var
        POSUnit: Record "NPR POS Unit";
        NewSalesTicketNo: Code[20];
    begin
        Setup.GetPOSUnit(POSUnit);
        if not IsESAuditEnabled(POSUnit."POS Audit Profile") then
            exit;

        NewSalesTicketNo := GetSourceDocumentNoForInvoiceNo(SalesTicketNo);
        if NewSalesTicketNo <> '' then
            SalesTicketNo := NewSalesTicketNo;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Sale Line", 'OnAfterInsertPOSSaleLineBeforeCommit', '', false, false)]
    local procedure OnAfterInsertPOSSaleLineBeforeCommit(var SaleLinePOS: Record "NPR POS Sale Line")
    var
        POSUnit: Record "NPR POS Unit";
        POSSaleLine2: Record "NPR POS Sale Line";
        SameSignErr: Label 'Cannot have sale and return in the same transaction';
    begin
        if not IsESFiscalizationEnabled() then
            exit;
        POSUnit.Get(SaleLinePOS."Register No.");
        if not IsESAuditEnabled(POSUnit."POS Audit Profile") then
            exit;

        if SaleLinePOS."Line No." = 10000 then
            exit;
        if not (SaleLinePOS."Line Type" in [SaleLinePOS."Line Type"::Item, SaleLinePOS."Line Type"::"Issue Voucher"]) then
            exit;
        if not GetFirstSaleLinePOSOfTypeItemOrVoucher(POSSaleLine2, SaleLinePOS) then
            exit;
        if (POSSaleLine2.Quantity > 0) and (SaleLinePOS.Quantity > 0) then
            exit;
        if (POSSaleLine2.Quantity < 0) and (SaleLinePOS.Quantity < 0) then
            exit;
        if not ChangeQtyOnPOSSaleLine(SaleLinePOS) then
            Error(SameSignErr);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Sale Line", 'OnBeforeSetQuantity', '', false, false)]
    local procedure OnBeforeSetQuantity(var SaleLinePOS: Record "NPR POS Sale Line"; var NewQuantity: Decimal)
    var
        POSUnit: Record "NPR POS Unit";
        POSSaleLine2: Record "NPR POS Sale Line";
        SameSignErr: Label 'Cannot have sale and return in the same transaction';
    begin
        if not IsESFiscalizationEnabled() then
            exit;
        POSUnit.Get(SaleLinePOS."Register No.");
        if not IsESAuditEnabled(POSUnit."POS Audit Profile") then
            exit;

        if SaleLinePOS.Quantity = NewQuantity then
            exit;
        if not (SaleLinePOS."Line Type" in [SaleLinePOS."Line Type"::Item, SaleLinePOS."Line Type"::"Issue Voucher"]) then
            exit;
        if not GetFirstSaleLinePOSOfTypeItemOrVoucher(POSSaleLine2, SaleLinePOS) then
            exit;
        if (POSSaleLine2.Quantity > 0) and (NewQuantity > 0) then
            exit;
        if (POSSaleLine2.Quantity < 0) and (NewQuantity < 0) then
            exit;
        if not ChangeQtyOnAllPOSSaleLines(SaleLinePOS) then
            Error(SameSignErr);
    end;

    #endregion

    #region Subscribers - Fiskaly Communication
    [EventSubscriber(ObjectType::Table, Database::"Company Information", 'OnAfterValidateEvent', 'Name', false, false)]
    local procedure OnAfterValidateNameOnCompanyInformation(var Rec: Record "Company Information"; var xRec: Record "Company Information"; CurrFieldNo: Integer)
    begin
        if Rec.IsTemporary() then
            exit;

        if Rec.Name = xRec.Name then
            exit;

        if not IsESFiscalizationEnabled() then
            exit;

        DisableESOrganizations();
    end;

    [EventSubscriber(ObjectType::Table, Database::"Company Information", 'OnAfterValidateEvent', 'VAT Registration No.', false, false)]
    local procedure OnAfterValidateVATRegistrationNoOnCompanyInformation(var Rec: Record "Company Information"; var xRec: Record "Company Information"; CurrFieldNo: Integer)
    var
        VATRegistrationNoLenghtErr: Label '%1 cannot be longer than 9 characters.', Comment = '%1 - VAT Registration No. field caption';
    begin
        if Rec.IsTemporary() then
            exit;

        if Rec."VAT Registration No." = xRec."VAT Registration No." then
            exit;

        if not IsESFiscalizationEnabled() then
            exit;

        if StrLen(Rec."VAT Registration No.") > 9 then
            Error(VATRegistrationNoLenghtErr, Rec.FieldCaption("VAT Registration No."));

        DisableESOrganizations();
    end;
    #endregion

    #region Job Queue Management
    internal procedure InitESFiscalJobQueues(ESFiscalizationEnabled: Boolean)
    begin
        InitESRetrieveSoftwareJobQueue(ESFiscalizationEnabled);
        InitESRetrievePendingInvoicesJobQueue(ESFiscalizationEnabled);
    end;

    local procedure InitESRetrieveSoftwareJobQueue(ATFiscalizationEnabled: Boolean)
    var
        JobQueueEntry: Record "Job Queue Entry";
        JobQueueManagement: Codeunit "NPR Job Queue Management";
        JobDescriptionLbl: Label 'ES Retrieve Software', MaxLength = 250;
    begin
        if ATFiscalizationEnabled then begin
            JobQueueManagement.SetJobTimeout(4, 0);  // 4 hours
            JobQueueManagement.SetAutoRescheduleAndNotifyOnError(true, 1800, ''); // reschedule to run again in 30 minutes
            if JobQueueManagement.InitRecurringJobQueueEntry(
                JobQueueEntry."Object Type to Run"::Codeunit,
                Codeunit::"NPR ES Retrieve Software JQ",
                '',
                JobDescriptionLbl,
                JobQueueManagement.NowWithDelayInSeconds(300),
                1440,
                DefaultESFiscalJobQueueCategoryCode(),
                JobQueueEntry)
            then
                JobQueueManagement.StartJobQueueEntry(JobQueueEntry);
        end else
            JobQueueManagement.CancelNpManagedJobs(JobQueueEntry."Object Type to Run"::Codeunit, Codeunit::"NPR ES Retrieve Software JQ");
    end;

    local procedure InitESRetrievePendingInvoicesJobQueue(ATFiscalizationEnabled: Boolean)
    var
        JobQueueEntry: Record "Job Queue Entry";
        JobQueueManagement: Codeunit "NPR Job Queue Management";
        JobDescriptionLbl: Label 'ES Retrieve Pending Invoices', MaxLength = 250;
    begin
        if ATFiscalizationEnabled then begin
            JobQueueManagement.SetJobTimeout(4, 0);  // 4 hours
            JobQueueManagement.SetAutoRescheduleAndNotifyOnError(true, 300, ''); // reschedule to run again in 5 minutes
            if JobQueueManagement.InitRecurringJobQueueEntry(
                JobQueueEntry."Object Type to Run"::Codeunit,
                Codeunit::"NPR ES Retrieve Pending Inv JQ",
                '',
                JobDescriptionLbl,
                JobQueueManagement.NowWithDelayInSeconds(300),
                5,
                DefaultESFiscalJobQueueCategoryCode(),
                JobQueueEntry)
            then
                JobQueueManagement.StartJobQueueEntry(JobQueueEntry);
        end else
            JobQueueManagement.CancelNpManagedJobs(JobQueueEntry."Object Type to Run"::Codeunit, Codeunit::"NPR ES Retrieve Pending Inv JQ");
    end;

    local procedure DefaultESFiscalJobQueueCategoryCode(): Code[10]
    var
        JobQueueCategory: Record "Job Queue Category";
        ImportListJQCategoryCode: Label 'FISCAL', MaxLength = 10, Locked = true;
        ImportListJQCategoryDescrLbl: Label 'POS Audit Fiscal Processing', MaxLength = 30;
    begin
        JobQueueCategory.InsertRec(ImportListJQCategoryCode, ImportListJQCategoryDescrLbl);
        exit(JobQueueCategory.Code);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Job Queue Management", 'OnRefreshNPRJobQueueList', '', false, false)]
    local procedure RunInitESRetrieveSoftwareJobQueue()
    begin
        InitESRetrieveSoftwareJobQueue(IsESFiscalizationEnabled());
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Job Queue Management", 'OnRefreshNPRJobQueueList', '', false, false)]
    local procedure RunInitESRetrievePendingInvoicesJobQueue()
    begin
        InitESRetrievePendingInvoicesJobQueue(IsESFiscalizationEnabled());
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Job Queue Management", 'OnCheckIfIsNPRecurringJob', '', false, false)]
    local procedure OnCheckIfIsNPRecurringJob(JobQueueEntry: Record "Job Queue Entry"; var IsNpJob: Boolean; var Handled: Boolean)
    begin
        if Handled then
            exit;

        if (JobQueueEntry."Object Type to Run" = JobQueueEntry."Object Type to Run"::Codeunit) and
           (JobQueueEntry."Object ID to Run" in [Codeunit::"NPR ES Retrieve Software JQ", Codeunit::"NPR ES Retrieve Pending Inv JQ"])
        then begin
            IsNpJob := true;
            Handled := true;
        end;
    end;
    #endregion

    #region ES Fiscal - Procedures/Helper Functions
    internal procedure IsESFiscalizationEnabled(): Boolean
    var
        ESFiscalizationSetup: Record "NPR ES Fiscalization Setup";
    begin
        if not ESFiscalizationSetup.Get() then
            exit(false);

        exit(ESFiscalizationSetup."ES Fiscal Enabled");
    end;

    local procedure IsESAuditEnabled(POSAuditProfileCode: Code[20]): Boolean
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
        HandlerCodeTxt: Label 'ES_FISKALY', Locked = true, MaxLength = 20;
    begin
        exit(HandlerCodeTxt);
    end;

    local procedure OnActionShowSetup()
    var
        ESFiscalisationSetup: Page "NPR ES Fiscalization Setup";
    begin
        ESFiscalisationSetup.RunModal();
    end;

    local procedure ErrorOnRenameOfPOSStoreIfAlreadyUsed(OldPOSStore: Record "NPR POS Store")
    var
        ESPOSAuditLogAuxInfo: Record "NPR ES POS Audit Log Aux. Info";
        CannotRenameErr: Label 'You cannot rename %1 %2 since there is at least one related %3 record and it can cause data discrepancy since it is being used for fiscalization.', Comment = '%1 - POS Store table caption, %2 - POS Store Code value, %3 - ES POS Audit Log Aux. Info table caption';
    begin
        if not IsESFiscalizationEnabled() then
            exit;

        ESPOSAuditLogAuxInfo.SetRange("POS Store Code", OldPOSStore.Code);
        if not ESPOSAuditLogAuxInfo.IsEmpty() then
            Error(CannotRenameErr, OldPOSStore.TableCaption(), OldPOSStore.Code, ESPOSAuditLogAuxInfo.TableCaption());
    end;

    local procedure ErrorOnRenameOfPOSUnitIfAlreadyUsed(OldPOSUnit: Record "NPR POS Unit")
    var
        ESClient: Record "NPR ES Client";
        ESPOSAuditLogAuxInfo: Record "NPR ES POS Audit Log Aux. Info";
        CannotRename2Err: Label 'You cannot rename %1 %2 since there is at least one related %3 created at Fiskaly and it can cause data discrepancy.', Comment = '%1 - POS Unit table caption, %2 - POS Unit No. value, %3 - ES Client table caption';
        CannotRenameErr: Label 'You cannot rename %1 %2 since there is at least one related %3 record and it can cause data discrepancy since it is being used for fiscalization.', Comment = '%1 - POS Unit table caption, %2 - POS Unit No. value, %3 - ES POS Audit Log Aux. Info table caption';
    begin
        if not IsESAuditEnabled(OldPOSUnit."POS Audit Profile") then
            exit;

        ESPOSAuditLogAuxInfo.SetRange("POS Unit No.", OldPOSUnit."No.");
        if not ESPOSAuditLogAuxInfo.IsEmpty() then
            Error(CannotRenameErr, OldPOSUnit.TableCaption(), OldPOSUnit."No.", ESPOSAuditLogAuxInfo.TableCaption());

        ESClient.SetRange("POS Unit No.", OldPOSUnit."No.");
        ESClient.SetFilter(State, '<>%1', ESClient.State::" ");
        if not ESClient.IsEmpty() then
            Error(CannotRename2Err, OldPOSUnit.TableCaption(), OldPOSUnit."No.", ESClient.TableCaption());
    end;

    local procedure FindPOSEntry(DocumentNo: Code[20]; var POSEntry: Record "NPR POS Entry"): Boolean
    begin
        POSEntry.SetCurrentKey("Document No.");
        POSEntry.SetRange("Document No.", DocumentNo);
        exit(POSEntry.FindFirst());
    end;

    local procedure GetSourceDocumentNoForInvoiceNo(InvoiceNo: Code[20]): Code[20]
    var
        ESPOSAuditLogAuxInfo: Record "NPR ES POS Audit Log Aux. Info";
    begin
        ESPOSAuditLogAuxInfo.FilterGroup(10);
        ESPOSAuditLogAuxInfo.SetRange("Invoice No.", InvoiceNo);
        ESPOSAuditLogAuxInfo.FilterGroup(0);

        case ESPOSAuditLogAuxInfo.Count() of
            0:
                exit('');
            1:
                begin
                    if ESPOSAuditLogAuxInfo.FindFirst() then
                        exit(ESPOSAuditLogAuxInfo."Source Document No.");

                    exit('');
                end;
            else begin
                if Page.RunModal(0, ESPOSAuditLogAuxInfo) <> Action::LookupOK then
                    exit('');

                exit(ESPOSAuditLogAuxInfo."Source Document No.");
            end;
        end;
    end;

    local procedure DisableESOrganizations()
    var
        ESOrganization: Record "NPR ES Organization";
        ConfirmManagement: Codeunit "Confirm Management";
        ConfirmDisableQst: Label 'Are you sure that you want to perform this change, since it will disable related %1(s) and it is irreversible?', Comment = '%1 - ES Organization table caption';
    begin
        ESOrganization.SetRange("Taxpayer Created", true);
        ESOrganization.SetRange(Disabled, false);
        if ESOrganization.IsEmpty() then
            exit;

        if not ConfirmManagement.GetResponse(StrSubstNo(ConfirmDisableQst, ESOrganization.TableCaption()), false) then
            Error('');

        ESOrganization.ModifyAll(Disabled, true);
    end;

    local procedure CalcTotalSalesAmount(SaleHeader: Record "NPR POS Sale") TotalSalesAmount: Decimal
    var
        POSSaleLine: Record "NPR POS Sale Line";
    begin
        POSSaleLine.SetCurrentKey("Register No.", "Sales Ticket No.", "Line Type");
        POSSaleLine.SetRange("Register No.", SaleHeader."Register No.");
        POSSaleLine.SetRange("Sales Ticket No.", SaleHeader."Sales Ticket No.");
        POSSaleLine.SetRange("Line Type", POSSaleLine."Line Type"::"Item");
        POSSaleLine.CalcSums("Amount Including VAT");
        TotalSalesAmount := POSSaleLine."Amount Including VAT";
    end;

    local procedure IsTotalSalesAmountAboveThreshold(TotalSalesAmount: Decimal; TotalSalesAmountAboveThreshold: Decimal): Boolean
    var
        ESFiscalizationSetup: Record "NPR ES Fiscalization Setup";
    begin
        if TotalSalesAmount <= 0 then
            exit(false);

        ESFiscalizationSetup.Get();

        exit(TotalSalesAmount > TotalSalesAmountAboveThreshold);
    end;

    local procedure GetFirstSaleLinePOSOfTypeItemOrVoucher(var POSSaleLine2: Record "NPR POS Sale Line"; POSSaleLine: Record "NPR POS Sale Line"): Boolean
    begin
        POSSaleLine2.SetFilter("Line Type", '%1|%2', POSSaleLine2."Line Type"::Item, POSSaleLine2."Line Type"::"Issue Voucher");
        POSSaleLine2.SetRange("Sales Ticket No.", POSSaleLine."Sales Ticket No.");
        POSSaleLine2.SetFilter("Line No.", '<>%1', POSSaleLine."Line No.");
        exit(POSSaleLine2.FindFirst());
    end;

    local procedure ChangeQtyOnAllPOSSaleLines(var POSSaleLine: Record "NPR POS Sale Line"): Boolean
    var
        POSSaleLine2: Record "NPR POS Sale Line";
        ConfirmManagement: Codeunit "Confirm Management";
        ChangeQuantityQst: Label 'Sales and Return are not allowed in the same transaction. Do you want to set negative Quantity for all existing Sales Lines?';
    begin
        if not (ConfirmManagement.GetResponseOrDefault(ChangeQuantityQst, false)) then
            exit(false);
        POSSaleLine2.SetFilter("Line Type", '%1|%2', POSSaleLine2."Line Type"::Item, POSSaleLine2."Line Type"::"Issue Voucher");
        POSSaleLine2.SetRange("Sales Ticket No.", POSSaleLine."Sales Ticket No.");
        POSSaleLine2.SetFilter("Line No.", '<>%1', POSSaleLine."Line No.");
        if POSSaleLine2.FindSet(true) then
            repeat
                POSSaleLine2.Validate(Quantity, -POSSaleLine2.Quantity);
                POSSaleLine2.Modify(true);
            until POSSaleLine2.Next() = 0;
        exit(true);
    end;

    local procedure ChangeQtyOnPOSSaleLine(var POSSaleLine: Record "NPR POS Sale Line"): Boolean
    var
        ConfirmManagement: Codeunit "Confirm Management";
        ChangeQuantityQst: Label 'Sales and Return are not allowed in the same transaction. Do you want to change the Quantity of the line you''re about to add?';
    begin
        if not (ConfirmManagement.GetResponseOrDefault(ChangeQuantityQst, false)) then
            exit(false);

        POSSaleLine.Validate(Quantity, -POSSaleLine.Quantity);
        exit(POSSaleLine.Modify(true));
    end;

    internal procedure ClearTenantMedia(MediaId: Guid)
    var
        TenantMedia: Record "Tenant Media";
    begin
        if TenantMedia.Get(MediaId) then
            TenantMedia.Delete(true);
    end;

    local procedure IsPrintReceiptEnabled(): Boolean
    var
        ESFiscalizationSetup: Record "NPR ES Fiscalization Setup";
    begin
        if not ESFiscalizationSetup.Get() then
            exit(false);
        exit(ESFiscalizationSetup."Print Thermal Receipt On Sale");
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
        POSAuditProfile.TestField("Require Item Return Reason", true);
    end;

    local procedure CheckESFiscalizationSetup()
    var
        ESFiscalizationSetup: Record "NPR ES Fiscalization Setup";
#IF BC17
        RegEx: Codeunit DotNet_Regex;
#ELSE
        Regex: Codeunit Regex;
#ENDIF
        InvoiceDescriptionErr: Label '%1 %2 is not according to pattern %3.', Comment = '%1 - Invoice Description field caption, %2 - Invoice Description value, %3 - allowed pattern value';
        InvoiceDescriptionPatternLbl: Label '^( *[0-9A-Za-zñÑáÁàÀéÉíÍïÏóÓòÒúÚüÜçÇ°ºª.,:"()¿?¡!\-_/] *)*$', Locked = true;
    begin
        ESFiscalizationSetup.Get();
        ESFiscalizationSetup.TestField("Simplified Invoice Limit");
        ESFiscalizationSetup.TestField("Invoice Description");

        if not Regex.IsMatch(ESFiscalizationSetup."Invoice Description", InvoiceDescriptionPatternLbl) then
            Error(InvoiceDescriptionErr, ESFiscalizationSetup.FieldCaption("Invoice Description"), ESFiscalizationSetup."Invoice Description", InvoiceDescriptionPatternLbl);
    end;

    local procedure CheckESClientAndESOrganization(POSUnit: Record "NPR POS Unit")
    var
        ESClient: Record "NPR ES Client";
        ESOrganization: Record "NPR ES Organization";
    begin
        ESClient.GetWithCheck(POSUnit."No.");
        ESClient.TestField("Invoice No. Series");
        ESClient.TestField("Complete Invoice No. Series");
        ESClient.TestField("Correction Invoice No. Series");
        ESOrganization.GetWithCheck(ESClient."ES Organization Code");
        ESOrganization.TestField(Disabled, false);
    end;

    local procedure ShowCustomerInformationRequiredWarningIfTotalSalesAmountAboveThreshold(var SaleHeader: Record "NPR POS Sale")
    var
        ESFiscalizationSetup: Record "NPR ES Fiscalization Setup";
        TotalSalesAmount: Decimal;
        CustomerInformationRequiredMsg: Label 'Since total sales amount of this sale is above the threshold of %1, customer''s personal information will be required in order to finish the sale.', Comment = '%1 - Sales Amount Threshold value';
    begin
        TotalSalesAmount := CalcTotalSalesAmount(SaleHeader);
        if TotalSalesAmount <= 0 then
            exit;

        ESFiscalizationSetup.Get();

        if IsTotalSalesAmountAboveThreshold(TotalSalesAmount, ESFiscalizationSetup."Simplified Invoice Limit") then
            Message(CustomerInformationRequiredMsg, ESFiscalizationSetup."Simplified Invoice Limit");
    end;

    local procedure CheckAreMandatoryMappingsPopulated(SaleHeader: Record "NPR POS Sale")
    var
        ESReturnReasonMapping: Record "NPR ES Return Reason Mapping";
        POSSaleLine: Record "NPR POS Sale Line";
    begin
        POSSaleLine.SetCurrentKey("Register No.", "Sales Ticket No.", "Line Type");
        POSSaleLine.SetRange("Register No.", SaleHeader."Register No.");
        POSSaleLine.SetRange("Sales Ticket No.", SaleHeader."Sales Ticket No.");
        POSSaleLine.SetRange("Line Type", POSSaleLine."Line Type"::Item);
        POSSaleLine.SetFilter("Return Reason Code", '<>%1', '');
        if POSSaleLine.FindSet() then
            repeat
                ESReturnReasonMapping.Get(POSSaleLine."Return Reason Code");
                ESReturnReasonMapping.CheckIsESReturnReasonPopulated();
            until POSSaleLine.Next() = 0;
    end;

    local procedure CheckItemDescriptions(SaleHeader: Record "NPR POS Sale")
    var
        POSSaleLine: Record "NPR POS Sale Line";
#IF BC17
        RegEx: Codeunit DotNet_Regex;
#ELSE
        Regex: Codeunit Regex;
#ENDIF
        BlankItemDescriptionErr: Label '%1 related to %2 %3 cannot have blank %4.', Comment = '%1 - POS Sale Line table caption, %2 - Line Type Item value, %3 - Item No. value, %4 - Description field caption';
        ItemDescriptionErr: Label '%1 %2 %3 is not according to pattern %4.', Comment = '%1 - Line Type Item value, %2 - Description field caption, %3 - Description value, %4 - allowed pattern value';
        ItemDescriptionPatternLbl: Label '^( *[0-9A-Za-zñÑáÁàÀéÉíÍïÏóÓòÒúÚüÜçÇ°ºª.,:"()¿?¡!\-_/] *)*$', Locked = true;
    begin
        POSSaleLine.SetCurrentKey("Register No.", "Sales Ticket No.", "Line Type");
        POSSaleLine.SetRange("Register No.", SaleHeader."Register No.");
        POSSaleLine.SetRange("Sales Ticket No.", SaleHeader."Sales Ticket No.");
        POSSaleLine.SetRange("Line Type", POSSaleLine."Line Type"::Item);

        if POSSaleLine.FindSet() then
            repeat
                if POSSaleLine.Description = '' then
                    Error(BlankItemDescriptionErr, POSSaleLine.TableCaption(), Format(POSSaleLine."Line Type"::Item), POSSaleLine."No.", POSSaleLine.FieldCaption(Description));

                if not Regex.IsMatch(POSSaleLine.Description, ItemDescriptionPatternLbl) then
                    Error(ItemDescriptionErr, Format(POSSaleLine."Line Type"::Item), POSSaleLine.FieldCaption(Description), POSSaleLine.Description, ItemDescriptionPatternLbl);
            until POSSaleLine.Next() = 0;
    end;
    #endregion
}