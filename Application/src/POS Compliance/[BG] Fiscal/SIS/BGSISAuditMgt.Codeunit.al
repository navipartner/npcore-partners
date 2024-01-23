codeunit 6151610 "NPR BG SIS Audit Mgt."
{
    Access = Internal;

    var
        Enabled: Boolean;
        Initialized: Boolean;

    #region BG SIS Fiscal - POS Handling Subscribers
    [EventSubscriber(ObjectType::Page, Page::"NPR POS Audit Profiles", 'OnHandlePOSAuditProfileAdditionalSetup', '', true, true)]
    local procedure OnHandlePOSAuditProfileAdditionalSetup(POSAuditProfile: Record "NPR POS Audit Profile")
    begin
        if not IsBGSISAuditEnabled(POSAuditProfile.Code) then
            exit;

        OnActionShowSetup();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Audit Log Mgt.", 'OnLookupAuditHandler', '', true, true)]
    local procedure OnLookupAuditHandler(var tmpRetailList: Record "NPR Retail List")
    begin
        AddBGSISAuditHandler(tmpRetailList);
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

    #region BG SIS Fiscal - Audit Profile Mgt
    local procedure AddBGSISAuditHandler(var tmpRetailList: Record "NPR Retail List")
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

        if not IsBGSISAuditEnabled(POSUnit."POS Audit Profile") then
            exit;

        if not POSStore.Get(POSUnit."POS Store Code") then
            exit;

        if not (POSAuditLog."Action Type" in [POSAuditLog."Action Type"::DIRECT_SALE_END]) then
            exit;

        POSEntry.Get(POSAuditLog."Record ID");
        if not (POSEntry."Post Item Entry Status" in [POSEntry."Post Item Entry Status"::"Not To Be Posted"]) then
            InsertBGSISPOSAuditLogAux(POSEntry, POSStore, POSUnit);
    end;

    local procedure InsertBGSISPOSAuditLogAux(POSEntry: Record "NPR POS Entry"; POSStore: Record "NPR POS Store"; POSUnit: Record "NPR POS Unit")
    var
        BGSISPOSAuditLogAux: Record "NPR BG SIS POS Audit Log Aux.";
    begin
        BGSISPOSAuditLogAux.Init();
        BGSISPOSAuditLogAux."Audit Entry Type" := BGSISPOSAuditLogAux."Audit Entry Type"::"POS Entry";
        BGSISPOSAuditLogAux."POS Entry No." := POSEntry."Entry No.";
        BGSISPOSAuditLogAux."Entry Date" := POSEntry."Entry Date";
        BGSISPOSAuditLogAux."POS Store Code" := POSStore.Code;
        BGSISPOSAuditLogAux."POS Unit No." := POSUnit."No.";
        BGSISPOSAuditLogAux."Source Document No." := POSEntry."Document No.";
        BGSISPOSAuditLogAux."Amount Incl. Tax" := POSEntry."Amount Incl. Tax";
        BGSISPOSAuditLogAux."Salesperson Code" := POSEntry."Salesperson Code";

        SetTransactionTypeOnBGSISPOSAuditLogAux(POSEntry."Entry No.", BGSISPOSAuditLogAux);

        BGSISPOSAuditLogAux.Insert();
    end;

    local procedure SetTransactionTypeOnBGSISPOSAuditLogAux(POSEntryNo: Integer; var BGSISPOSAuditLogAux: Record "NPR BG SIS POS Audit Log Aux.")
    var
        BGSISPOSAuditLogAuxToRefund: Record "NPR BG SIS POS Audit Log Aux.";
        OriginalPOSEntrySalesLine: Record "NPR POS Entry Sales Line";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
    begin
        case true of
            BGSISPOSAuditLogAux."Amount Incl. Tax" > 0:
                BGSISPOSAuditLogAux."Transaction Type" := BGSISPOSAuditLogAux."Transaction Type"::Sale;
            BGSISPOSAuditLogAux."Amount Incl. Tax" < 0:
                BGSISPOSAuditLogAux."Transaction Type" := BGSISPOSAuditLogAux."Transaction Type"::Refund;
            BGSISPOSAuditLogAux."Amount Incl. Tax" = 0:
                begin
                    POSEntrySalesLine.SetRange("POS Entry No.", POSEntryNo);
                    POSEntrySalesLine.FindFirst();

                    if not OriginalPOSEntrySalesLine.GetBySystemId(POSEntrySalesLine."Orig.POS Entry S.Line SystemId") then
                        BGSISPOSAuditLogAux."Transaction Type" := BGSISPOSAuditLogAux."Transaction Type"::Sale
                    else
                        if not BGSISPOSAuditLogAuxToRefund.FindAuditLog(OriginalPOSEntrySalesLine."POS Entry No.") then
                            BGSISPOSAuditLogAux."Transaction Type" := BGSISPOSAuditLogAux."Transaction Type"::Sale
                        else
                            BGSISPOSAuditLogAux."Transaction Type" := BGSISPOSAuditLogAux."Transaction Type"::Refund;
                end;
        end;
    end;
    #endregion

    #region Subscribers - POS Management
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Sale", 'OnBeforeInitSale', '', false, false)]
    local procedure HandleOnBeforeInitSale(SaleHeader: Record "NPR POS Sale"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        POSUnit: Record "NPR POS Unit";
        Salesperson: Record "Salesperson/Purchaser";
        POSSession: Codeunit "NPR POS Session";
        POSSetup: Codeunit "NPR POS Setup";
    begin
        FrontEnd.GetSession(POSSession);
        POSSession.GetSetup(POSSetup);
        POSSetup.GetPOSUnit(POSUnit);
        if not IsBGSISAuditEnabled(POSUnit."POS Audit Profile") then
            exit;

        POSSetup.GetSalespersonRecord(Salesperson);

        TestIsProfileSetAccordingToCompliance(POSUnit."POS Audit Profile");
        TestPOSUnitMapping(POSUnit);
        CheckSalesperson(Salesperson);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Action: Rev. Dir. Sale", 'OnBeforeHendleReverse', '', false, false)]
    local procedure HandleOnBeforeHendleReverse(Setup: Codeunit "NPR POS Setup"; var SalesTicketNo: Code[20]);
    var
        POSUnit: Record "NPR POS Unit";
        NewSalesTicketNo: Code[20];
    begin
        Setup.GetPOSUnit(POSUnit);
        if not IsBGSISAuditEnabled(POSUnit."POS Audit Profile") then
            exit;

        NewSalesTicketNo := GetSourceDocumentNoForGrandReceiptNo(SalesTicketNo);
        if NewSalesTicketNo <> '' then
            SalesTicketNo := NewSalesTicketNo;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Sale", 'OnBeforeEndSale', '', false, false)]
    local procedure HandleOnBeforeEndSale(var Sender: Codeunit "NPR POS Sale"; SaleHeader: Record "NPR POS Sale");
    var
        POSUnit: Record "NPR POS Unit";
    begin
        if not POSUnit.Get(SaleHeader."Register No.") then
            exit;

        if not IsBGSISAuditEnabled(POSUnit."POS Audit Profile") then
            exit;

        CheckSalesAndReturnsInSameTransaction(SaleHeader, POSUnit."POS Audit Profile");
        CheckAreMandatoryMappingsPopulated(SaleHeader);
        DoNotAllowUsingOtherPaymentMethodThanCashForReturn(SaleHeader);
        DoNotAllowHavingBlankItemDescriptions(SaleHeader);
    end;
    #endregion

    #region Subscribers - POS Workflows
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Login Events", 'OnAddPreWorkflowsToRun', '', false, false)]
    local procedure HandleOnAddPreWorkflowsToRunOnPOSLoginEvents(Context: Codeunit "NPR POS JSON Helper"; SalePOS: Record "NPR POS Sale"; var PreWorkflows: JsonObject)
    var
        BGFiscalizationSetup: Record "NPR BG Fiscalization Setup";
        POSUnit: Record "NPR POS Unit";
        ActionParameters: JsonObject;
        MainParameters: JsonObject;
    begin
        if not IsBGSISFiscalEnabled() then
            exit;

        if not POSUnit.Get(SalePOS."Register No.") then
            exit;

        if not IsBGSISAuditEnabled(POSUnit."POS Audit Profile") then
            exit;

        BGFiscalizationSetup.Get();
        if BGFiscalizationSetup."BG SIS Auto Set Cashier" then
            MainParameters.Add('Method', 'trySetCashier')
        else
            MainParameters.Add('Method', 'isCashierSet');

        ActionParameters.Add('mainParameters', MainParameters);
        PreWorkflows.Add(Format(Enum::"NPR POS Workflow"::"BG_SIS_FP_CASHIER"), ActionParameters);

        AddPreWorkflowForRefreshFiscalPrinterInfoIfNecessary(PreWorkflows, POSUnit."No.");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR End Sale Events", 'OnAddPostWorkflowsToRun', '', false, false)]
    local procedure HandleOnAddPostWorkflowsToRunOnEndSaleinternal(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup"; EndSaleSuccess: Boolean; var PostWorkflows: JsonObject)
    var
        POSSale: Record "NPR POS Sale";
        POSUnit: Record "NPR POS Unit";
        ActionParameters: JsonObject;
        CustomParameters: JsonObject;
        MainParameters: JsonObject;
    begin
        if not EndSaleSuccess then
            exit;

        if not IsBGSISFiscalEnabled() then
            exit;

        Sale.GetCurrentSale(POSSale);
        if not POSUnit.Get(POSSale."Register No.") then
            exit;

        if not IsBGSISAuditEnabled(POSUnit."POS Audit Profile") then
            exit;

        MainParameters.Add('Method', 'printReceipt');
        CustomParameters.Add('salesTicketNo', POSSale."Sales Ticket No.");

        ActionParameters.Add('mainParameters', MainParameters);
        ActionParameters.Add('customParameters', CustomParameters);

        PostWorkflows.Add(Format(Enum::"NPR POS Workflow"::"BG_SIS_FP_MGT"), ActionParameters);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Action Publishers", 'OnAddPostWorkflowsToRun', '', false, false)]
    local procedure HandleOnAddPostWorkflowsToRunOnPOSActionPublishersEventsForBinTransfer(Context: Codeunit "NPR POS JSON Helper"; SalePOS: Record "NPR POS Sale"; var PostWorkflows: JsonObject)
    var
        POSUnit: Record "NPR POS Unit";
        ActionParameters: JsonObject;
    begin
        if not IsBGSISFiscalEnabled() then
            exit;

        if not POSUnit.Get(SalePOS."Register No.") then
            exit;

        if not IsBGSISAuditEnabled(POSUnit."POS Audit Profile") then
            exit;

        ActionParameters.Add('Method', 'cashHandling');
        PostWorkflows.Add(Format(Enum::"NPR POS Workflow"::"BG_SIS_FP_MGT"), ActionParameters);
    end;
    #endregion

    #region BG SIS Fiscal - Procedures/Helper Functions
    local procedure IsBGSISFiscalEnabled(): Boolean
    var
        BGFiscalizationSetup: Record "NPR BG Fiscalization Setup";
    begin
        if BGFiscalizationSetup.Get() then
            exit(BGFiscalizationSetup."BG SIS Fiscal Enabled");
    end;

    local procedure IsBGSISAuditEnabled(POSAuditProfileCode: Code[20]): Boolean
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

    local procedure AddPreWorkflowForRefreshFiscalPrinterInfoIfNecessary(var PreWorkflows: JsonObject; POSUnitNo: Code[10])
    var
        BGSISPOSUnitMapping: Record "NPR BG SIS POS Unit Mapping";
        ActionParameters: JsonObject;
        MainParameters: JsonObject;
    begin
        BGSISPOSUnitMapping.Get(POSUnitNo);
        if BGSISPOSUnitMapping.ShouldRefreshFiscalPrinterInfo() then begin
            MainParameters.Add('Method', 'getMfcInfo');
            ActionParameters.Add('mainParameters', MainParameters);
            PreWorkflows.Add(Format(Enum::"NPR POS Workflow"::"BG_SIS_FP_MGT"), ActionParameters);
        end;
    end;

    internal procedure HandlerCode(): Text
    var
        HandlerCodeTxt: Label 'BG_SIS', Locked = true, MaxLength = 20;
    begin
        exit(HandlerCodeTxt);
    end;

    local procedure OnActionShowSetup()
    var
        BGFiscalisationSetup: Page "NPR BG Fiscalization Setup";
    begin
        BGFiscalisationSetup.RunModal();
    end;

    local procedure ErrorOnRenameOfPOSStoreIfAlreadyUsed(OldPOSStore: Record "NPR POS Store")
    var
        BGSISPOSAuditLogAux: Record "NPR BG SIS POS Audit Log Aux.";
        CannotRenameErr: Label 'You cannot rename %1 %2 since there is at least one related %3 record and it can cause data discrepancy since it is being used for calculating the seal.', Comment = '%1 - POS Store table caption, %2 - POS Store Code value, %3 - BG POS SIS Audit Log Aux. table caption';
    begin
        BGSISPOSAuditLogAux.SetRange("POS Store Code", OldPOSStore.Code);
        if not BGSISPOSAuditLogAux.IsEmpty() then
            Error(CannotRenameErr, OldPOSStore.TableCaption(), OldPOSStore.Code, BGSISPOSAuditLogAux.TableCaption());
    end;

    local procedure ErrorOnRenameOfPOSUnitIfAlreadyUsed(OldPOSUnit: Record "NPR POS Unit")
    var
        BGSISPOSAuditLogAux: Record "NPR BG SIS POS Audit Log Aux.";
        CannotRenameErr: Label 'You cannot rename %1 %2 since there is at least one related %3 record and it can cause data discrepancy since it is being used for calculating the seal.', Comment = '%1 - POS Unit table caption, %2 - POS Unit No. value, %3 - BG POS SIS Audit Log Aux. table caption';
    begin
        if not IsBGSISAuditEnabled(OldPOSUnit."POS Audit Profile") then
            exit;

        BGSISPOSAuditLogAux.SetRange("POS Unit No.", OldPOSUnit."No.");
        if not BGSISPOSAuditLogAux.IsEmpty() then
            Error(CannotRenameErr, OldPOSUnit.TableCaption(), OldPOSUnit."No.", BGSISPOSAuditLogAux.TableCaption());
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
        POSAuditProfile.TestField("Require Item Return Reason", true);
        POSAuditProfile.TestField(AllowSalesAndReturnInSameTrans, false);
    end;

    local procedure TestPOSUnitMapping(POSUnit: Record "NPR POS Unit")
    var
        BGSISPOSUnitMapping: Record "NPR BG SIS POS Unit Mapping";
    begin
        BGSISPOSUnitMapping.Get(POSUnit."No.");
        BGSISPOSUnitMapping.TestField("Fiscal Printer IP Address");
        BGSISPOSUnitMapping.TestField("Fiscal Printer Device No.");
        BGSISPOSUnitMapping.TestField("Fiscal Printer Memory No.");
    end;

    local procedure CheckSalesperson(Salesperson: Record "Salesperson/Purchaser")
    var
        SalespersonCodeAsInteger: Integer;
        CannotBeConvertedtoIntegerErr: Label '%1 %2 %3 cannot be converted to integer.', Comment = '%1 - Salesperson table caption, %2 - Salesperson Code field caption, %3 - Salesperson Code value';
    begin
        if not Evaluate(SalespersonCodeAsInteger, Salesperson.Code) then
            Error(CannotBeConvertedtoIntegerErr, Salesperson.TableCaption(), Salesperson.FieldCaption(Code), Salesperson.Code);
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
        BGSISPOSPaymMethMap: Record "NPR BG SIS POS Paym. Meth. Map";
        BGSISReturnReasonMap: Record "NPR BG SIS Return Reason Map";
        BGSISVATPostSetupMap: Record "NPR BG SIS VAT Post. Setup Map";
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
                            BGSISVATPostSetupMap.Get(POSSaleLine."VAT Bus. Posting Group", POSSaleLine."VAT Prod. Posting Group");
                            BGSISVATPostSetupMap.CheckIsBGSISVATCategoryPopulated();

                            if POSSaleLine."Return Reason Code" <> '' then begin
                                BGSISReturnReasonMap.Get(POSSaleLine."Return Reason Code");
                                BGSISReturnReasonMap.CheckIsBGSISReturnReasonPopulated();
                            end;
                        end;
                    POSSaleLine."Line Type"::"POS Payment":
                        begin
                            BGSISPOSPaymMethMap.Get(POSSaleLine."No.");
                            BGSISPOSPaymMethMap.CheckIsBGSISPaymentMethodPopulated();
                        end;
                end;
            until POSSaleLine.Next() = 0;
    end;

    local procedure DoNotAllowUsingOtherPaymentMethodThanCashForReturn(SaleHeader: Record "NPR POS Sale")
    var
        BGSISPOSPaymMethMap: Record "NPR BG SIS POS Paym. Meth. Map";
        POSSaleLine: Record "NPR POS Sale Line";
    begin
        POSSaleLine.SetCurrentKey("Register No.", "Sales Ticket No.", "Line Type");
        POSSaleLine.SetRange("Register No.", SaleHeader."Register No.");
        POSSaleLine.SetRange("Sales Ticket No.", SaleHeader."Sales Ticket No.");
        POSSaleLine.SetFilter("Return Sale Sales Ticket No.", '<>%1', '');
        if POSSaleLine.IsEmpty() then
            exit;

        POSSaleLine.SetRange("Return Sale Sales Ticket No.");
        POSSaleLine.SetRange("Line Type", POSSaleLine."Line Type"::"POS Payment");

        if POSSaleLine.FindSet() then
            repeat
                BGSISPOSPaymMethMap.Get(POSSaleLine."No.");
                BGSISPOSPaymMethMap.TestField("BG SIS Payment Method", BGSISPOSPaymMethMap."BG SIS Payment Method"::Cash);
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

    #region Procedures - Misc
    local procedure GetSourceDocumentNoForGrandReceiptNo(GrandReceiptNo: Code[20]): Code[20]
    var
        BGSISPOSAuditLogAux: Record "NPR BG SIS POS Audit Log Aux.";
    begin
        GrandReceiptNo := DelChr(GrandReceiptNo, '<', '0');
        BGSISPOSAuditLogAux.FilterGroup(10);
        BGSISPOSAuditLogAux.SetRange("Grand Receipt No.", GrandReceiptNo);
        BGSISPOSAuditLogAux.FilterGroup(0);

        case BGSISPOSAuditLogAux.Count() of
            0:
                exit('');
            1:
                begin
                    if BGSISPOSAuditLogAux.FindFirst() then
                        exit(BGSISPOSAuditLogAux."Source Document No.");

                    exit('');
                end;
            else begin
                if Page.RunModal(0, BGSISPOSAuditLogAux) <> Action::LookupOK then
                    exit('');

                exit(BGSISPOSAuditLogAux."Source Document No.");
            end;
        end;
    end;
    #endregion
}