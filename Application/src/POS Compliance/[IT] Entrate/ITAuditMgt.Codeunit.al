codeunit 6184647 "NPR IT Audit Mgt."
{
    Access = Internal;
    SingleInstance = true;
    Permissions = TableData "Tenant Media" = rd;

    var
        Enabled: Boolean;
        Initialized: Boolean;

    #region IT Fiscal - POS Handling Subscribers

    [EventSubscriber(ObjectType::Page, Page::"NPR POS Audit Profiles", 'OnHandlePOSAuditProfileAdditionalSetup', '', true, true)]
    local procedure OnHandlePOSAuditProfileAdditionalSetup(POSAuditProfile: Record "NPR POS Audit Profile")
    begin
        if not IsITAuditEnabled(POSAuditProfile.Code) then
            exit;
        OnActionShowSetup();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Audit Log Mgt.", 'OnLookupAuditHandler', '', true, true)]
    local procedure OnLookupAuditHandler(var tmpRetailList: Record "NPR Retail List")
    begin
        AddITAuditHandler(tmpRetailList);
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

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Sale", 'OnBeforeInitSale', '', false, false)]
    local procedure OnBeforeInitSale(SaleHeader: Record "NPR POS Sale"; FrontEnd: Codeunit "NPR POS Front End Management")
    begin
        CheckIsDataSetAccordingToCompliance(FrontEnd);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Create Entry", 'OnAfterInsertPOSEntry', '', false, false)]
    local procedure OnAfterInsertPOSEntry(var SalePOS: Record "NPR POS Sale"; var POSEntry: Record "NPR POS Entry");
    begin
        HandleCustomerLotteryCodeOnAuditLogAfterPOSEntryInsert(SalePOS, POSEntry);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Sale", 'OnBeforeEndSale', '', false, false)]
    local procedure HandleOnBeforeEndSale(var Sender: Codeunit "NPR POS Sale"; SaleHeader: Record "NPR POS Sale");
    var
        POSUnit: Record "NPR POS Unit";
    begin
        if not POSUnit.Get(SaleHeader."Register No.") then
            exit;

        if not IsITAuditEnabled(POSUnit."POS Audit Profile") then
            exit;

        CheckIfReturnPaymentMethodIsOnlyCash(SaleHeader);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR End Sale Events", 'OnAddPostWorkflowsToRun', '', false, false)]
    local procedure HandleOnAddPostWorkflowsToRunOnEndSale(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup"; EndSaleSuccess: Boolean; var PostWorkflows: JsonObject)
    var
        POSSale: Record "NPR POS Sale";
        POSUnit: Record "NPR POS Unit";
        ActionParameters: JsonObject;
        CustomParameters: JsonObject;
        MainParameters: JsonObject;
    begin
        if not EndSaleSuccess then
            exit;

        if not IsITFiscalEnabled() then
            exit;

        Sale.GetCurrentSale(POSSale);
        if not POSUnit.Get(POSSale."Register No.") then
            exit;

        if not IsITAuditEnabled(POSUnit."POS Audit Profile") then
            exit;

        MainParameters.Add('Method', 'printReceipt');
        CustomParameters.Add('salesTicketNo', POSSale."Sales Ticket No.");

        ActionParameters.Add('mainParameters', MainParameters);
        ActionParameters.Add('customParameters', CustomParameters);

        PostWorkflows.Add(Format(Enum::"NPR POS Workflow"::IT_PRINT_MGT), ActionParameters);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Action: Rev. Dir. Sale", 'OnBeforeHendleReverse', '', false, false)]
    local procedure OnBeforeHandleReverse(var SalesTicketNo: Code[20]; Setup: Codeunit "NPR POS Setup")
    begin
        if not IsITFiscalEnabled() then
            exit;

        SalesTicketNo := GetSourceDocumentNoFromAuditLog(Setup, SalesTicketNo);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Login Events", 'OnAddPreWorkflowsToRun', '', false, false)]
    local procedure HandleOnAddPreWorkflowsToRunOnPOSLogin(Context: Codeunit "NPR POS JSON Helper"; SalePOS: Record "NPR POS Sale"; var PreWorkflows: JsonObject)
    var
        POSUnit: Record "NPR POS Unit";
        ActionParameters: JsonObject;
        MainParameters: JsonObject;
    begin
        if not POSUnit.Get(SalePOS."Register No.") then
            exit;

        if not IsITAuditEnabled(POSUnit."POS Audit Profile") then
            exit;

        MainParameters.Add('Method', 'logInPrinter');
        ActionParameters.Add('mainParameters', MainParameters);

        PreWorkflows.Add(Format(Enum::"NPR POS Workflow"::IT_PRINT_MGT), ActionParameters);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Action: Cust. Select-B", 'OnAfterAttachCustomer', '', false, false)]
    local procedure HandleOnAttachCustomerToPOSSale(SaleHeader: Record "NPR POS Sale")
    var
        POSUnit: Record "NPR POS Unit";
    begin
        if not POSUnit.Get(SaleHeader."Register No.") then
            exit;

        if not IsITAuditEnabled(POSUnit."POS Audit Profile") then
            exit;

        AddCustomerLotteryCodeToCurrentSale(SaleHeader);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Sale Line", 'OnAfterInsertPOSSaleLineBeforeCommit', '', false, false)]
    local procedure OnAfterInsertPOSSaleLineBeforeCommit(var SaleLinePOS: Record "NPR POS Sale Line")
    var
        POSUnit: Record "NPR POS Unit";
        POSSaleLine2: Record "NPR POS Sale Line";
        SameSignErr: Label 'Cannot have sale and return in the same transaction';
    begin
        if not IsITFiscalEnabled() then
            exit;
        POSUnit.Get(SaleLinePOS."Register No.");
        if not IsITAuditEnabled(POSUnit."POS Audit Profile") then
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
        if not IsITFiscalEnabled() then
            exit;
        POSUnit.Get(SaleLinePOS."Register No.");
        if not IsITAuditEnabled(POSUnit."POS Audit Profile") then
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

    #region IT Fiscal - Aux and Mapping Tables Cleanup

    [EventSubscriber(ObjectType::Table, Database::Customer, 'OnAfterDeleteEvent', '', false, false)]
    local procedure Customer_OnAfterDeleteEvent(var Rec: Record Customer; RunTrigger: Boolean)
    var
        ITAuxCustomer: Record "NPR IT Aux Customer";
    begin
        if Rec.IsTemporary() then
            exit;
        if not RunTrigger then
            exit;
        if not IsITFiscalEnabled() then
            exit;
        if ITAuxCustomer.Get(Rec."No.") then
            ITAuxCustomer.Delete();
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Payment Method", 'OnAfterDeleteEvent', '', false, false)]
    local procedure PaymentMethod_OnAfterDeleteEvent(var Rec: Record "NPR POS Payment Method"; RunTrigger: Boolean)
    var
        ITPaymentMethodMapping: Record "NPR IT POS Paym. Method Mapp.";
    begin
        if Rec.IsTemporary() then
            exit;
        if not RunTrigger then
            exit;
        if not IsITFiscalEnabled() then
            exit;
        ITPaymentMethodMapping.SetRange("Payment Method Code", Rec.Code);
        if not ITPaymentMethodMapping.IsEmpty() then
            ITPaymentMethodMapping.DeleteAll();
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Unit", 'OnAfterDeleteEvent', '', false, false)]
    local procedure POSUnit_OnAfterDeleteEvent(var Rec: Record "NPR POS Unit"; RunTrigger: Boolean)
    var
        ITPOSUnitMapping: Record "NPR IT POS Unit Mapping";
    begin
        if Rec.IsTemporary() then
            exit;
        if not RunTrigger then
            exit;
        if not IsITFiscalEnabled() then
            exit;
        if ITPOSUnitMapping.Get(Rec."No.") then
            ITPOSUnitMapping.Delete();
    end;

    #endregion

    #region IT Fiscal - Sandbox Env. Cleanup

#if not (BC17 or BC18 or BC19)
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Environment Cleanup", 'OnClearCompanyConfig', '', false, false)]
    local procedure OnClearCompanyConfig(CompanyName: Text; SourceEnv: Enum "Environment Type"; DestinationEnv: Enum "Environment Type")
    var
        ITFiscalizationSetup: Record "NPR IT Fiscalization Setup";
        ITPOSUnitMapping: Record "NPR IT POS Unit Mapping";
    begin
        if DestinationEnv <> DestinationEnv::Sandbox then
            exit;

        ITFiscalizationSetup.ChangeCompany(CompanyName);
        if not (ITFiscalizationSetup.Get() and ITFiscalizationSetup."Enable IT Fiscal") then
            exit;
        ITFiscalizationSetup.Delete();

        ITPOSUnitMapping.ChangeCompany(CompanyName);
        ITPOSUnitMapping.SetFilter("Fiscal Printer IP Address", '<>''');
        ITPOSUnitMapping.ModifyAll("Fiscal Printer IP Address", '');
        ITPOSUnitMapping.ModifyAll("Fiscal Printer Password", '');
        ITPOSUnitMapping.ModifyAll("Fiscal Printer Serial No.", '');
        ITPOSUnitMapping.ModifyAll("Fiscal Printer RT Type", '');
    end;
#endif
    #endregion

    #region IT Fiscal - Audit Profile Mgt
    local procedure AddITAuditHandler(var tmpRetailList: Record "NPR Retail List")
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
        if not IsITAuditEnabled(POSUnit."POS Audit Profile") then
            exit;
        if not POSStore.Get(POSUnit."POS Store Code") then
            exit;

        if not (POSAuditLog."Action Type" in [POSAuditLog."Action Type"::DIRECT_SALE_END, POSAuditLog."Action Type"::CREDIT_SALE_END]) then
            exit;

        POSEntry.Get(POSAuditLog."Record ID");
        if not (POSEntry."Post Item Entry Status" in [POSEntry."Post Item Entry Status"::"Not To Be Posted"]) then
            InsertITPOSAuditLogAuxInfo(POSEntry, POSStore, POSUnit);
    end;

    local procedure InsertITPOSAuditLogAuxInfo(POSEntry: Record "NPR POS Entry"; POSStore: Record "NPR POS Store"; POSUnit: Record "NPR POS Unit")
    var
        ITPOSAuditLogAuxInfo: Record "NPR IT POS Audit Log Aux Info";
    begin
        ITPOSAuditLogAuxInfo.Init();
        ITPOSAuditLogAuxInfo."Audit Entry Type" := ITPOSAuditLogAuxInfo."Audit Entry Type"::"POS Entry";
        ITPOSAuditLogAuxInfo."POS Entry No." := POSEntry."Entry No.";
        ITPOSAuditLogAuxInfo."Entry Date" := POSEntry."Entry Date";
        ITPOSAuditLogAuxInfo."POS Store Code" := POSStore.Code;
        ITPOSAuditLogAuxInfo."POS Unit No." := POSUnit."No.";
        ITPOSAuditLogAuxInfo."Source Document No." := POSEntry."Document No.";
        ITPOSAuditLogAuxInfo.Amount := POSEntry."Amount Incl. Tax";
        CheckForTransactionTypeOnPOSEntry(POSEntry, ITPOSAuditLogAuxInfo);

        ITPOSAuditLogAuxInfo.Insert();
    end;

    local procedure HandleCustomerLotteryCodeOnAuditLogAfterPOSEntryInsert(var SalePOS: Record "NPR POS Sale"; var POSEntry: Record "NPR POS Entry")
    var
        ITPOSAuditLogAuxInfo: Record "NPR IT POS Audit Log Aux Info";
        ITPOSSale: Record "NPR IT POS Sale";
    begin
        if not IsITFiscalEnabled() then
            exit;
        if not ITPOSAuditLogAuxInfo.GetAuditFromPOSEntry(POSEntry."Entry No.") then
            exit;
        if not ITPOSSale.Get(SalePOS.SystemId) then
            exit;
        if ITPOSSale."IT Customer Lottery Code" = '' then
            exit;
        ITPOSAuditLogAuxInfo."Customer Lottery Code" := ITPOSSale."IT Customer Lottery Code";
        ITPOSAuditLogAuxInfo.Modify();
    end;

    local procedure AddCustomerLotteryCodeToCurrentSale(SalePOS: Record "NPR POS Sale")
    var
        Customer: Record Customer;
        ITPOSSale: Record "NPR IT POS Sale";
        ITAuxCustomer: Record "NPR IT Aux Customer";
        ConfirmAddLotteryCodeFromCustomerQst: Label 'Do you want to add Customer''s Lottery Code to this sale?';
    begin
        if not Confirm(ConfirmAddLotteryCodeFromCustomerQst, true) then
            exit;

        if not Customer.Get(SalePOS."Customer No.") then
            exit;

        ITAuxCustomer.ReadITAuxCustomerFields(Customer);
        if ITAuxCustomer."NPR IT Customer Lottery Code" = '' then
            exit;

        ITPOSSale."POS Sale SystemId" := SalePOS.SystemId;
        ITPOSSale."IT Customer Lottery Code" := CopyStr(ITAuxCustomer."NPR IT Customer Lottery Code", 1, MaxStrLen(ITPOSSale."IT Customer Lottery Code"));
        if not ITPOSSale.Insert() then
            ITPOSSale.Modify();
    end;

    #endregion

    #region IT Fiscal - Procedures/Helper Functions
    internal procedure IsITFiscalEnabled(): Boolean
    var
        ITFiscalSetup: Record "NPR IT Fiscalization Setup";
    begin
        if ITFiscalSetup.Get() then
            exit(ITFiscalSetup."Enable IT Fiscal");
    end;

    local procedure IsITAuditEnabled(POSAuditProfileCode: Code[20]): Boolean
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

    internal procedure HandlerCode(): Text
    var
        HandlerCodeTxt: Label 'IT_ENTRATE', Locked = true, MaxLength = 20;
    begin
        exit(HandlerCodeTxt);
    end;

    local procedure OnActionShowSetup()
    var
        ITFiscalizationSetup: Page "NPR IT Fiscalization Setup";
    begin
        ITFiscalizationSetup.RunModal();
    end;

    local procedure ErrorOnRenameOfPOSStoreIfAlreadyUsed(OldPOSStore: Record "NPR POS Store")
    var
        ITPOSAuditLogAuxInfo: Record "NPR IT POS Audit Log Aux Info";
        CannotRenameErr: Label 'You cannot rename %1 %2 since there is at least one related %3 record and it can cause data discrepancy since it is being used for digital signature.', Comment = '%1 - POS Store table caption, %2 - POS Store Code value, %3 - IT POS Audit Log Aux. Info table caption';
    begin
        ITPOSAuditLogAuxInfo.SetRange("POS Store Code", OldPOSStore.Code);
        if not ITPOSAuditLogAuxInfo.IsEmpty() then
            Error(CannotRenameErr, OldPOSStore.TableCaption(), OldPOSStore.Code, ITPOSAuditLogAuxInfo.TableCaption());
    end;

    local procedure ErrorOnRenameOfPOSUnitIfAlreadyUsed(OldPOSUnit: Record "NPR POS Unit")
    var
        ITPOSAuditLogAuxInfo: Record "NPR IT POS Audit Log Aux Info";
        CannotRenameErr: Label 'You cannot rename %1 %2 since there is at least one related %3 record and it can cause data discrepancy since it is being used for digital signature.', Comment = '%1 - POS Unit table caption, %2 - POS Unit No. value, %3 - IT POS Audit Log Aux. Info table caption';
    begin
        if not IsITAuditEnabled(OldPOSUnit."POS Audit Profile") then
            exit;

        ITPOSAuditLogAuxInfo.SetRange("POS Unit No.", OldPOSUnit."No.");
        if not ITPOSAuditLogAuxInfo.IsEmpty() then
            Error(CannotRenameErr, OldPOSUnit.TableCaption(), OldPOSUnit."No.", ITPOSAuditLogAuxInfo.TableCaption());
    end;

    local procedure CheckIsDataSetAccordingToCompliance(FrontEnd: Codeunit "NPR POS Front End Management")
    var
        POSAuditProfile: Record "NPR POS Audit Profile";
        POSUnit: Record "NPR POS Unit";
        ITPOSUnitMapping: Record "NPR IT POS Unit Mapping";
        POSSession: Codeunit "NPR POS Session";
        POSSetup: Codeunit "NPR POS Setup";
    begin
        FrontEnd.GetSession(POSSession);
        POSSession.GetSetup(POSSetup);
        POSSetup.GetPOSUnit(POSUnit);
        if not IsITAuditEnabled(POSUnit."POS Audit Profile") then
            exit;

        POSUnit.GetProfile(POSAuditProfile);
        POSAuditProfile.TestField("Do Not Print Receipt on Sale", true);

        ITPOSUnitMapping.Get(POSUnit."No.");
        ITPOSUnitMapping.TestField("Fiscal Printer IP Address");
        ITPOSUnitMapping.TestField("Fiscal Printer RT Type");
        ITPOSUnitMapping.TestField("Fiscal Printer Serial No.");
    end;

    local procedure CheckForTransactionTypeOnPOSEntry(POSEntry: Record "NPR POS Entry"; var ITPOSAuditLogAuxInfo: Record "NPR IT POS Audit Log Aux Info")
    begin
        case POSEntry."Amount Incl. Tax" > 0 of
            true:
                ITPOSAuditLogAuxInfo."Transaction Type" := ITPOSAuditLogAuxInfo."Transaction Type"::SALE;
            false:
                begin
                    ITPOSAuditLogAuxInfo."Transaction Type" := ITPOSAuditLogAuxInfo."Transaction Type"::REFUND;
                    SetRefundSourceDocumentNo(POSEntry, ITPOSAuditLogAuxInfo);
                end;
        end;
    end;

    local procedure GetSourceDocumentNoFromAuditLog(Setup: Codeunit "NPR POS Setup"; SalesTicketNo: Code[20]): Code[20]
    var
        ITPOSAuditLogAuxInfo: Record "NPR IT POS Audit Log Aux Info";
        POSStore: Record "NPR POS Store";
        POSUnit: Record "NPR POS Unit";
        ReceiptNoPart: Text;
        ZReportPart: Text;
    begin
        ZReportPart := CopyStr(SalesTicketNo, 1, 4);
        ReceiptNoPart := CopyStr(SalesTicketNo, 6, StrLen(SalesTicketNo));

        CheckForLettersInText(ZReportPart);
        CheckForLettersInText(ReceiptNoPart);

        Setup.GetPOSStore(POSStore);
        Setup.GetPOSUnit(POSUnit);

        ITPOSAuditLogAuxInfo.SetLoadFields("Source Document No.", "POS Store Code", "POS Unit No.", "Z Report No.", "Receipt No.");
        ITPOSAuditLogAuxInfo.FilterGroup(10);
        ITPOSAuditLogAuxInfo.SetRange("POS Store Code", POSStore.Code);
        ITPOSAuditLogAuxInfo.SetRange("POS Unit No.", POSUnit."No.");
        ITPOSAuditLogAuxInfo.SetRange("Z Report No.", ZReportPart);
        ITPOSAuditLogAuxInfo.SetRange("Receipt No.", ReceiptNoPart);
        ITPOSAuditLogAuxInfo.FilterGroup(0);

        case ITPOSAuditLogAuxInfo.Count() of
            0:
                exit('');
            1:
                begin
                    if ITPOSAuditLogAuxInfo.FindFirst() then
                        exit(ITPOSAuditLogAuxInfo."Source Document No.");

                    exit('');
                end;
            else begin
                if Page.RunModal(0, ITPOSAuditLogAuxInfo) <> Action::LookupOK then
                    exit('');

                exit(ITPOSAuditLogAuxInfo."Source Document No.");
            end;
        end;
    end;

    local procedure SetRefundSourceDocumentNo(POSEntry: Record "NPR POS Entry"; var ITPOSAuditLogAuxInfo: Record "NPR IT POS Audit Log Aux Info")
    var
        POSRMALine: Record "NPR POS RMA Line";
        NpRvArchVoucherEntry: Record "NPR NpRv Arch. Voucher Entry";
        NpRvArchVoucherEntrySource: Record "NPR NpRv Arch. Voucher Entry";
    begin
        POSRMALine.SetRange("POS Entry No.", POSEntry."Entry No.");
        if POSRMALine.FindFirst() then begin
            ITPOSAuditLogAuxInfo."Refund Source Document No." := POSRMALine."Sales Ticket No.";
            exit;
        end;
        NpRvArchVoucherEntry.SetRange("Entry Type", NpRvArchVoucherEntry."Entry Type"::Payment);
        NpRvArchVoucherEntry.SetRange("Document No.", ITPOSAuditLogAuxInfo."Source Document No.");
        if not NpRvArchVoucherEntry.FindFirst() then
            exit;
        NpRvArchVoucherEntrySource.SetRange("Entry Type", NpRvArchVoucherEntrySource."Entry Type"::"Issue Voucher");
        NpRvArchVoucherEntrySource.SetRange("Arch. Voucher No.", NpRvArchVoucherEntry."Arch. Voucher No.");
        if not NpRvArchVoucherEntrySource.FindFirst() then
            exit;
        ITPOSAuditLogAuxInfo."Refund Source Document No." := NpRvArchVoucherEntrySource."Document No.";
    end;

    local procedure CheckForLettersInText(Value: Text)
    var
        i: Integer;
        SalesTicketMustNotContainLettersErr: Label 'Sales Ticket No. must not contain any letters.';
    begin
        for i := 1 to StrLen(Value) do
            case Value[i] of
                'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J',
              'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T',
              'u', 'v', 'w', 'x', 'y', 'z', 'U', 'V', 'W', 'X', 'Y', 'Z', '-', '.':
                    Error(SalesTicketMustNotContainLettersErr);
            end;
    end;

    local procedure CheckIfReturnPaymentMethodIsOnlyCash(SaleHeader: Record "NPR POS Sale")
    var
        ITPOSPaymentMethMapp: Record "NPR IT POS Paym. Method Mapp.";
        POSSaleLine: Record "NPR POS Sale Line";
        ReturnPaymentMethMustBeCashOnlyErr: Label 'Return POS Payment Method must only be Cash';
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
                ITPOSPaymentMethMapp.SetRange("POS Unit No.", POSSaleLine."Register No.");
                ITPOSPaymentMethMapp.SetRange("Payment Method Code", POSSaleLine."No.");
                ITPOSPaymentMethMapp.FindFirst();
                if not (ITPOSPaymentMethMapp."IT Payment Method" in ["NPR IT Payment Method"::"0"]) then
                    Error(ReturnPaymentMethMustBeCashOnlyErr);
            until POSSaleLine.Next() = 0;
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
    #endregion
}