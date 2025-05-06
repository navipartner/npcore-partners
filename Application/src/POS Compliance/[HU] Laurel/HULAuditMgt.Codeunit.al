codeunit 6185037 "NPR HU L Audit Mgt."
{
    Access = Internal;
    Permissions = TableData "Tenant Media" = rd;
    var
        CustomerInfoMandatoryErr: Label 'You must input customer information for this sale.';
        SameSignErr: Label 'Cannot have sale and return in the same transaction.';
        Enabled: Boolean;
        Initialized: Boolean;

    #region HU Laurel Fiscal - POS Handling Subscribers
    [EventSubscriber(ObjectType::Page, Page::"NPR POS Audit Profiles", 'OnHandlePOSAuditProfileAdditionalSetup', '', true, true)]
    local procedure OnHandlePOSAuditProfileAdditionalSetup(POSAuditProfile: Record "NPR POS Audit Profile")
    begin
        if not IsHULaurelAuditEnabled(POSAuditProfile.Code) then
            exit;

        OnActionShowSetup();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Audit Log Mgt.", 'OnLookupAuditHandler', '', true, true)]
    local procedure OnLookupAuditHandler(var tmpRetailList: Record "NPR Retail List")
    begin
        AddHULaurelAuditHandler(tmpRetailList);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Audit Log Mgt.", 'OnHandleAuditLogBeforeInsert', '', true, true)]
    local procedure OnHandleAuditLogBeforeInsert(var POSAuditLog: Record "NPR POS Audit Log")
    begin
        HandleOnHandleAuditLogBeforeInsert(POSAuditLog);
    end;
    #endregion

    #region HU Laurel Fiscal - Sale/Return in same transaction Mgt.
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Sale Line", 'OnAfterInsertPOSSaleLineBeforeCommit', '', false, false)]
    local procedure OnAfterInsertPOSSaleLineBeforeCommit(var SaleLinePOS: Record "NPR POS Sale Line")
    var
        POSUnit: Record "NPR POS Unit";
        POSSaleLine2: Record "NPR POS Sale Line";
    begin
        if not IsHULFiscalizationEnabled() then
            exit;
        POSUnit.Get(SaleLinePOS."Register No.");
        if not IsHULaurelAuditEnabled(POSUnit."POS Audit Profile") then
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
    begin
        if not IsHULFiscalizationEnabled() then
            exit;
        POSUnit.Get(SaleLinePOS."Register No.");
        if not IsHULaurelAuditEnabled(POSUnit."POS Audit Profile") then
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

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Action: Rev. Dir. Sale", 'OnBeforeHendleReverse', '', false, false)]
    local procedure OnBeforeHandleReverse(Setup: Codeunit "NPR POS Setup"; var SalesTicketNo: Code[20]; Context: Codeunit "NPR POS JSON Helper");
    var
        POSUnit: Record "NPR POS Unit";
    begin
        Setup.GetPOSUnit(POSUnit);
        if not IsHULaurelAuditEnabled(POSUnit."POS Audit Profile") then
            exit;

        SalesTicketNo := GetPOSSalesTicketNoFromAuditLog(Context);
    end;
    #endregion

    #region HU Laurel Fiscal - Audit Profile Mgt
    local procedure AddHULaurelAuditHandler(var tmpRetailList: Record "NPR Retail List")
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

        if not IsHULaurelAuditEnabled(POSUnit."POS Audit Profile") then
            exit;

        if not POSStore.Get(POSUnit."POS Store Code") then
            exit;

        if not (POSAuditLog."Action Type" in [POSAuditLog."Action Type"::DIRECT_SALE_END]) then
            exit;

        POSEntry.Get(POSAuditLog."Record ID");
        InsertHULPOSAuditLogAuxInfoBaseData(POSEntry);
    end;

    local procedure HandleCustAndReturnInfoOnAuditLogAfterPOSEntryInsert(POSSale: Record "NPR POS Sale"; POSEntry: Record "NPR POS Entry")
    var
        HULPOSAuditLogAux: Record "NPR HU L POS Audit Log Aux.";
        POSUnit: Record "NPR POS Unit";
    begin
        if not IsHULFiscalizationEnabled() then
            exit;
        if not POSUnit.Get(POSSale."Register No.") then
            exit;
        if not IsHULaurelAuditEnabled(POSUnit."POS Audit Profile") then
            exit;
        if not HULPOSAuditLogAux.FindAuditLog(POSEntry."Entry No.") then
            exit;
        SetCustomerDataToPOSAuditLog(HULPOSAuditLogAux, POSSale);
        SetReturnInfoToPOSAuditLog(HULPOSAuditLogAux, POSSale, POSEntry);
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
        if not IsHULaurelAuditEnabled(POSUnit."POS Audit Profile") then
            exit;

        TestPOSUnitMapping(POSUnit."No.");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Sale", 'OnBeforeEndSale', '', false, false)]
    local procedure HandleOnBeforeEndSale(SaleHeader: Record "NPR POS Sale")
    var
        POSUnit: Record "NPR POS Unit";
        ConfirmManagement: Codeunit "Confirm Management";
        IsReturnSale: Boolean;
        CustomerDataEntered: Boolean;
        AddCustomerDataQst: Label 'Do you want to add customer data to the receipt?';
    begin
        POSUnit.Get(SaleHeader."Register No.");
        if not IsHULaurelAuditEnabled(POSUnit."POS Audit Profile") then
            exit;
        if not GetPOSSaleLine(SaleHeader) then
            exit;
        SaleHeader.CalcFields("Amount Including VAT");
        if SaleHeader."Amount Including VAT" = 0 then
            exit;

        IsReturnSale := SaleHeader."Amount Including VAT" < 0;

        if ConfirmManagement.GetResponseOrDefault(AddCustomerDataQst, false) then
            CustomerDataEntered := AddCustomerDataToSale(SaleHeader, IsReturnSale);

        if IsReturnSale and (not CustomerDataEntered) then
            Error(CustomerInfoMandatoryErr);

        if not IsReturnSale then
            exit;
        if GetOriginalPOSSaleLine(SaleHeader) then
            exit;
        AddOriginalReceiptDataForReturn(SaleHeader);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Create Entry", 'OnAfterInsertPOSEntry', '', false, false)]
    local procedure OnAfterInsertPOSEntry(var SalePOS: Record "NPR POS Sale"; var POSEntry: Record "NPR POS Entry");
    begin
        HandleCustAndReturnInfoOnAuditLogAfterPOSEntryInsert(SalePOS, POSEntry);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR End Sale Events", 'OnAddPostWorkflowsToRun', '', false, false)]
    local procedure HandleOnAddPostWorkflowsToRunOnEndSaleInternal(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup"; EndSaleSuccess: Boolean; var PostWorkflows: JsonObject)
    var
        POSSale: Record "NPR POS Sale";
        POSUnit: Record "NPR POS Unit";
        ActionParameters: JsonObject;
        CustomParameters: JsonObject;
    begin
        if not EndSaleSuccess then
            exit;
        Sale.GetCurrentSale(POSSale);
        if not POSUnit.Get(POSSale."Register No.") then
            exit;
        if not IsHULaurelAuditEnabled(POSUnit."POS Audit Profile") then
            exit;

        CustomParameters.Add('salesTicketNo', POSSale."Sales Ticket No.");
        ActionParameters.Add('customParameters', CustomParameters);

        PostWorkflows.Add(Format(Enum::"NPR POS Workflow"::"HUL_RECEIPT_MGT"), ActionParameters);
    end;
    #endregion

    #region HU Laurel Fiscal - Communication Logging

    local procedure InsertHULPOSAuditLogAuxInfoBaseData(POSEntry: Record "NPR POS Entry")
    var
        HULPOSAuditLogAux: Record "NPR HU L POS Audit Log Aux.";
    begin
        HULPOSAuditLogAux.Init();
        HULPOSAuditLogAux."Audit Entry Type" := HULPOSAuditLogAux."Audit Entry Type"::"POS Entry";
        HULPOSAuditLogAux."POS Entry No." := POSEntry."Entry No.";
        HULPOSAuditLogAux."Source Document No." := POSEntry."Document No.";
        HULPOSAuditLogAux."Entry Date" := POSEntry."Entry Date";
        HULPOSAuditLogAux."POS Store Code" := POSEntry."POS Store Code";
        HULPOSAuditLogAux."POS Unit No." := POSEntry."POS Unit No.";
        HULPOSAuditLogAux."Amount Incl. Tax" := POSEntry."Amount Incl. Tax";
        HULPOSAuditLogAux."Change Amount" := CalculateChangeAmount(POSEntry);
        HULPOSAuditLogAux."Salesperson Code" := POSEntry."Salesperson Code";
        HULPOSAuditLogAux."Rounding Amount" := RoundRoundingAmount(CalculateRounding(POSEntry));

        HULPOSAuditLogAux.Insert();
    end;

    internal procedure InsertHULPOSAuditLogAuxInfoRequestData(var HULPOSAuditLogAux: Record "NPR HU L POS Audit Log Aux."; RequestText: Text)
    begin
        HULPOSAuditLogAux.SetRequestText(RequestText);
        HULPOSAuditLogAux.Modify();
    end;

    internal procedure InsertHULPOSAuditLogAuxResponseData(VoidAuditEntryNo: Integer; Response: JsonObject)
    var
        HULPOSAuditLogAux: Record "NPR HU L POS Audit Log Aux.";
        JsonTok: JsonToken;
        ReceiptDataObj: JsonObject;
        ResponseText: Text;
    begin
        Response.Get('result', JsonTok);
        Response := JsonTok.AsObject();
        Response.Get('receiptData', JsonTok);
        ReceiptDataObj := JsonTok.AsObject();

        HULPOSAuditLogAux.Get(HULPOSAuditLogAux."Audit Entry Type"::"POS Entry", VoidAuditEntryNo);

#pragma warning disable AA0139
        ReceiptDataObj.Get('sBBOXID', JsonTok);
        HULPOSAuditLogAux."FCU BBOX ID" := JsonTok.AsValue().AsCode();

        ReceiptDataObj.Get('iClosureNr', JsonTok);
        HULPOSAuditLogAux."FCU Closure No." := JsonTok.AsValue().AsInteger();

        ReceiptDataObj.Get('iNr', JsonTok);
        HULPOSAuditLogAux."FCU Document No." := JsonTok.AsValue().AsInteger();

        ReceiptDataObj.Get('sTimestamp', JsonTok);
        HULPOSAuditLogAux."FCU Timestamp" := JsonTok.AsValue().AsText();

        ReceiptDataObj.Get('sDocumentNumber', JsonTok);
        HULPOSAuditLogAux."FCU Full Document No." := JsonTok.AsValue().AsText();
#pragma warning restore AA0139

        Response.WriteTo(ResponseText);
        HULPOSAuditLogAux.SetResponseText(ResponseText);

        HULPOSAuditLogAux.Modify();
    end;

    internal procedure InsertHULPOSAuditLogAuxResponseData(POSEntry: Record "NPR POS Entry"; Response: JsonObject)
    var
        HULPOSAuditLogAux: Record "NPR HU L POS Audit Log Aux.";
        JsonTok: JsonToken;
        ReceiptDataObj: JsonObject;
        ResponseText: Text;
    begin
        Response.Get('result', JsonTok);
        Response := JsonTok.AsObject();
        Response.Get('receiptData', JsonTok);
        ReceiptDataObj := JsonTok.AsObject();

        HULPOSAuditLogAux.FindAuditLog(POSEntry."Entry No.");

#pragma warning disable AA0139
        ReceiptDataObj.Get('sBBOXID', JsonTok);
        HULPOSAuditLogAux."FCU BBOX ID" := JsonTok.AsValue().AsCode();

        ReceiptDataObj.Get('iClosureNr', JsonTok);
        HULPOSAuditLogAux."FCU Closure No." := JsonTok.AsValue().AsInteger();

        ReceiptDataObj.Get('iNr', JsonTok);
        HULPOSAuditLogAux."FCU Document No." := JsonTok.AsValue().AsInteger();

        ReceiptDataObj.Get('sTimestamp', JsonTok);
        HULPOSAuditLogAux."FCU Timestamp" := JsonTok.AsValue().AsText();

        ReceiptDataObj.Get('sDocumentNumber', JsonTok);
        HULPOSAuditLogAux."FCU Full Document No." := JsonTok.AsValue().AsText();
#pragma warning restore AA0139

        Response.WriteTo(ResponseText);
        HULPOSAuditLogAux.SetResponseText(ResponseText);

        HULPOSAuditLogAux.Modify();
    end;

    local procedure SetCustomerDataToPOSAuditLog(var HULPOSAuditLogAux: Record "NPR HU L POS Audit Log Aux."; POSSale: Record "NPR POS Sale")
    var
        HULPOSSale: Record "NPR HU L POS Sale";
    begin
        if HULPOSSale.Get(POSSale.SystemId) and (HULPOSSale."Customer Name" <> '') then begin
            HULPOSAuditLogAux."Customer Name" := HULPOSSale."Customer Name";
            HULPOSAuditLogAux."Customer Post Code" := HULPOSSale."Customer Post Code";
            HULPOSAuditLogAux."Customer City" := HULPOSSale."Customer City";
            HULPOSAuditLogAux."Customer Address" := HULPOSSale."Customer Address";
            HULPOSAuditLogAux."Customer VAT Number" := HULPOSSale."Customer VAT Number";
            HULPOSAuditLogAux."Transaction Type" := HULPOSAuditLogAux."Transaction Type"::"Simple Invoice";
        end else
            HULPOSAuditLogAux."Transaction Type" := HULPOSAuditLogAux."Transaction Type"::"Standard Receipt";
        HULPOSAuditLogAux.Modify();
    end;

    local procedure SetReturnInfoToPOSAuditLog(var HULPOSAuditLogAux: Record "NPR HU L POS Audit Log Aux."; POSSale: Record "NPR POS Sale"; POSEntry: Record "NPR POS Entry")
    var
        HULPOSSale: Record "NPR HU L POS Sale";
        ReturnHULPOSAuditLogAux: Record "NPR HU L POS Audit Log Aux.";
        DateList: List of [Text];
        Day: Integer;
        Month: Integer;
        Year: Integer;
    begin
        if POSEntry."Amount Incl. Tax" > 0 then
            exit;
        if GetOriginalAuditEntryForReturn(ReturnHULPOSAuditLogAux, POSEntry) then begin
            DateList := ReturnHULPOSAuditLogAux.GetReceiptDateAsText().Split('.');
            Evaluate(Day, DateList.Get(3));
            Evaluate(Month, DateList.Get(2));
            Evaluate(Year, DateList.Get(1));
            HULPOSAuditLogAux."Original Date" := DMY2Date(Day, Month, Year);
            case ReturnHULPOSAuditLogAux."Transaction Type" of
                ReturnHULPOSAuditLogAux."Transaction Type"::"Standard Receipt":
                    HULPOSAuditLogAux."Original Type" := 'NY';
                ReturnHULPOSAuditLogAux."Transaction Type"::"Simple Invoice":
                    HULPOSAuditLogAux."Original Type" := 'SZ';
            end;
            HULPOSAuditLogAux."Original BBOX ID" := ReturnHULPOSAuditLogAux."FCU BBOX ID";
            HULPOSAuditLogAux."Original Document No." := ReturnHULPOSAuditLogAux."FCU Document No.";
            HULPOSAuditLogAux."Original Closure No." := ReturnHULPOSAuditLogAux."FCU Closure No.";
            HULPOSAuditLogAux.Modify()
        end else
            if HULPOSSale.Get(POSSale.SystemId) then begin
                HULPOSAuditLogAux."Original Date" := HULPOSSale."Original Date";
                HULPOSAuditLogAux."Original Type" := HULPOSSale."Original Type";
                HULPOSAuditLogAux."Original BBOX ID" := HULPOSSale."Original BBOX ID";
                HULPOSAuditLogAux."Original Document No." := HULPOSSale."Original No.";
                HULPOSAuditLogAux."Original Closure No." := HULPOSSale."Original Closure No.";
            end;

        HULPOSAuditLogAux."Return Reason" := GetFirstPOSSaleLineReturnReasonCodeMapping(POSEntry);
        if HULPOSAuditLogAux."Return Reason" in [HULPOSAuditLogAux."Return Reason"::V1, HULPOSAuditLogAux."Return Reason"::V2, HULPOSAuditLogAux."Return Reason"::V3] then
            HULPOSAuditLogAux."Transaction Type" := HULPOSAuditLogAux."Transaction Type"::Return
        else
            HULPOSAuditLogAux."Transaction Type" := HULPOSAuditLogAux."Transaction Type"::Void;
        HULPOSAuditLogAux.Modify();
    end;
    #endregion

    #region HU Laurel Fiscal - Procedures/Helper Functions
    internal procedure IsHULFiscalizationEnabled(): Boolean
    var
        HULFiscalizationSetup: Record "NPR HU L Fiscalization Setup";
    begin
        if not HULFiscalizationSetup.Get() then
            exit(false);

        exit(HULFiscalizationSetup."HU Laurel Fiscal Enabled");
    end;

    internal procedure IsHULaurelAuditEnabled(POSAuditProfileCode: Code[20]): Boolean
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
        HandlerCodeTxt: Label 'HU_LAUREL', Locked = true, MaxLength = 20;
    begin
        exit(HandlerCodeTxt);
    end;

    local procedure OnActionShowSetup()
    var
        HULFiscalisationSetup: Page "NPR HU L Fiscalization Setup";
    begin
        HULFiscalisationSetup.RunModal();
    end;

    internal procedure ClearTenantMedia(MediaId: Guid)
    var
        TenantMedia: Record "Tenant Media";
    begin
        if TenantMedia.Get(MediaId) then
            TenantMedia.Delete(true);
    end;
    #endregion

    #region Procedures - Validations

    local procedure TestPOSUnitMapping(POSUnitNo: Code[10])
    var
        HULPOSUnitMapping: Record "NPR HU L POS Unit Mapping";
        POSUnitMappingNotFoundErr: Label 'POS Unit Mapping not found for POS Unit: %1. Please create a mapping entry.', Comment = '%1 = POS Unit No.';
    begin
        if not HULPOSUnitMapping.Get(POSUnitNo) then
            Error(POSUnitMappingNotFoundErr, POSUnitNo);
        HULPOSUnitMapping.TestField("Laurel License");
    end;
    #endregion

    #region Procedures - Misc
    local procedure GetFirstSaleLinePOSOfTypeItemOrVoucher(var POSSaleLine2: Record "NPR POS Sale Line"; POSSaleLine: Record "NPR POS Sale Line"): Boolean
    begin
        POSSaleLine2.SetRange("Sales Ticket No.", POSSaleLine."Sales Ticket No.");
        POSSaleLine2.SetFilter("Line Type", '%1|%2', POSSaleLine2."Line Type"::Item, POSSaleLine2."Line Type"::"Issue Voucher");
        POSSaleLine2.SetFilter("Line No.", '<>%1', POSSaleLine."Line No.");
        exit(POSSaleLine2.FindFirst());
    end;

    local procedure ChangeQtyOnAllPOSSaleLines(var POSSaleLine: Record "NPR POS Sale Line"): Boolean
    var
        POSSaleLine2: Record "NPR POS Sale Line";
        ConfirmManagement: Codeunit "Confirm Management";
        ChangeQuantityOnAllLinesQst: Label 'Sales and Return are not allowed in the same transaction. Do you want to set negative Quantity for all existing Sales Lines?';
    begin
        if not (ConfirmManagement.GetResponseOrDefault(ChangeQuantityOnAllLinesQst, false)) then
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
        ChangeQuantityQst: Label 'Sales and Return are not allowed in the same transaction. Do you want to change the Quantity of the line you are about to add?';
    begin
        if not (ConfirmManagement.GetResponseOrDefault(ChangeQuantityQst, false)) then
            exit(false);

        POSSaleLine.Validate(Quantity, -POSSaleLine.Quantity);
        exit(POSSaleLine.Modify(true));
    end;

    local procedure RoundRoundingAmount(Amount: Decimal): Decimal
    begin
        if (Round(Amount, 1, '=') > 2) or (Round(Amount, 1, '=') < -2) then
            exit(Round(Amount, 1, '<'))
        else
            exit(Round(Amount, 1, '='));
    end;

    local procedure CalculateRounding(POSEntry: Record "NPR POS Entry"): Decimal
    var
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        POSEntryPaymentLine: Record "NPR POS Entry Payment Line";
        TotalSale: Decimal;
        TotalPaid: Decimal;
        TotalDiscountAmount: Decimal;
    begin
        POSEntrySalesLine.SetLoadFields("Amount Incl. VAT", "Line Discount Amount Incl. VAT", "VAT %");
        POSEntrySalesLine.SetRange("POS Entry No.", POSEntry."Entry No.");
        POSEntrySalesLine.SetFilter(Type, '%1|%2', POSEntrySalesLine.Type::Item, POSEntrySalesLine.Type::Voucher);
        if POSEntrySalesLine.FindSet() then
            repeat
                TotalDiscountAmount += Round(POSEntrySalesLine."Line Discount Amount Incl. VAT", 1, '=');
                TotalSale += Round(POSEntrySalesLine."Amount Incl. VAT" + POSEntrySalesLine."Line Discount Amount Incl. VAT", 1, '=');
            until POSEntrySalesLine.Next() = 0;

        TotalSale -= TotalDiscountAmount;
        POSEntryPaymentLine.SetRange("POS Entry No.", POSEntry."Entry No.");
        POSEntryPaymentLine.CalcSums("Amount (LCY)");
        TotalPaid := Round(POSEntryPaymentLine."Amount (LCY)", 1, '=');

        exit(TotalSale - TotalPaid);
    end;

    local procedure CalculateChangeAmount(POSEntry: Record "NPR POS Entry"): Decimal
    var
        POSEntryPaymentLine: Record "NPR POS Entry Payment Line";
    begin
        if POSEntry."Amount Incl. Tax" < 0 then
            exit;
        POSEntryPaymentLine.SetRange("POS Entry No.", POSEntry."Entry No.");
        POSEntryPaymentLine.SetFilter(Amount, '<0');
        POSEntryPaymentLine.CalcSums(Amount);
        exit(Round(POSEntryPaymentLine.Amount, 1, '='));
    end;

    local procedure GetOriginalPOSSaleLine(POSSale: Record "NPR POS Sale"): Boolean
    var
        POSEntrySaleLine: Record "NPR POS Entry Sales Line";
        POSSaleLine: Record "NPR POS Sale Line";
        OrigPOSEntry: Guid;
    begin
        GetPOSSaleLine(POSSaleLine, POSSale);
        OrigPOSEntry := POSSaleLine."Orig.POS Entry S.Line SystemId";
        POSEntrySaleLine.SetRange(SystemId, OrigPOSEntry);
        exit(not POSEntrySaleLine.IsEmpty());
    end;

    local procedure GetPOSSaleLine(var POSSaleLine: Record "NPR POS Sale Line"; POSSale: Record "NPR POS Sale"): Boolean
    begin
        POSSaleLine.SetRange("Register No.", POSSale."Register No.");
        POSSaleLine.SetRange("Sales Ticket No.", POSSale."Sales Ticket No.");
        exit(POSSaleLine.FindFirst());
    end;

    local procedure GetPOSSaleLine(POSSale: Record "NPR POS Sale"): Boolean
    var
        POSSaleLine: Record "NPR POS Sale Line";
    begin
        POSSaleLine.SetRange("Register No.", POSSale."Register No.");
        POSSaleLine.SetRange("Sales Ticket No.", POSSale."Sales Ticket No.");
        exit(not POSSaleLine.IsEmpty());
    end;

    local procedure AddCustomerDataToSale(POSSale: Record "NPR POS Sale"; Mandatory: Boolean): Boolean
    var
        HULPOSSale: Record "NPR HU L POS Sale";
        Customer: Record Customer;
        InputDialog: Page "NPR Input Dialog";
        CustomerName: Text;
        CustomerAddress: Text;
        CustomerCity: Text;
        CustomerPostCode: Text;
        CustomerVATNumber: Text;
        CustomerNameLbl: Label 'Customer Name';
        CustomerAddressLbl: Label 'Customer Address';
        CustomerCityLbl: Label 'Customer City';
        CustomerPostCodeLbl: Label 'Customer Post Code';
        CustomerVATRegistrationNoLbl: Label 'Customer VAT Number';
        InsufficientDataErr: Label 'Insufficient data entered, please input all necessary data.';
        FoundPOSSale: Boolean;
    begin
        if POSSale."Customer No." <> '' then begin
            Customer.Get(POSSale."Customer No.");
            CustomerName := Customer.Name;
            CustomerAddress := Customer.Address;
            CustomerCity := Customer."City";
            CustomerPostCode := Customer."Post Code";
            CustomerVATNumber := Customer."VAT Registration No.";
        end;
        InputDialog.SetInput(1, CustomerName, CustomerNameLbl);
        InputDialog.SetInput(2, CustomerAddress, CustomerAddressLbl);
        InputDialog.SetInput(3, CustomerCity, CustomerCityLbl);
        InputDialog.SetInput(4, CustomerPostCode, CustomerPostCodeLbl);
        InputDialog.SetInput(5, CustomerVATNumber, CustomerVATRegistrationNoLbl);

        Commit();
        if InputDialog.RunModal() <> Action::OK then
            if Mandatory then
                Error(CustomerInfoMandatoryErr)
            else
                exit(false);

        InputDialog.InputText(1, CustomerName);
        InputDialog.InputText(2, CustomerAddress);
        InputDialog.InputText(3, CustomerCity);
        InputDialog.InputText(4, CustomerPostCode);
        InputDialog.InputText(5, CustomerVATNumber);

        if (CustomerName = '') or (CustomerAddress = '') or (CustomerCity = '') or (CustomerPostCode = '') then
            Error(InsufficientDataErr);

        FoundPOSSale := HULPOSSale.Get(POSSale.SystemId);
        if not FoundPOSSale then
            HULPOSSale."POS Sale SystemId" := POSSale.SystemId;
        HULPOSSale."POS Sale SystemId" := POSSale.SystemId;
        HULPOSSale."Customer Name" := CopyStr(CustomerName, 1, MaxStrLen(HULPOSSale."Customer Name"));
        HULPOSSale."Customer Address" := CopyStr(CustomerAddress, 1, MaxStrLen(HULPOSSale."Customer Address"));
        HULPOSSale."Customer City" := CopyStr(CustomerCity, 1, MaxStrLen(HULPOSSale."Customer City"));
        HULPOSSale."Customer Post Code" := CopyStr(CustomerPostCode, 1, MaxStrLen(HULPOSSale."Customer Post Code"));
        HULPOSSale."Customer VAT Number" := CopyStr(CustomerVATNumber, 1, MaxStrLen(HULPOSSale."Customer VAT Number"));
        if FoundPOSSale then
            exit(HULPOSSale.Modify())
        else
            exit(HULPOSSale.Insert());
    end;

    local procedure AddOriginalReceiptDataForReturn(POSSale: Record "NPR POS Sale")
    var
        HULPOSSale: Record "NPR HU L POS Sale";
        InputDialog: Page "NPR Input Dialog";
        OriginalDate: Date;
        OriginalType: Text;
        OriginalBBOXID: Text;
        OriginalNo: Integer;
        OriginalClosureNo: Integer;
        OriginalDateLbl: Label 'Original Date';
        OriginalTypeLbl: Label 'Original Type (NY - Receipt; SZ - Simplified Invoice)';
        OriginalBBOXIDLbl: Label 'Original BBOX ID';
        OriginalNoLbl: Label 'Original No.';
        OriginalClosureNoLbl: Label 'Original Closure No.';
        OriginalInfoNeededErr: Label 'You must input original receipt information for processing.';
        FoundPOSSale: Boolean;
    begin
        if GetHULPOSSaleAndCheckIfReturnInfoEntered(HULPOSSale, POSSale) then
            exit;

        if HULPOSSale."Original Date" <> 0D then
            OriginalDate := HULPOSSale."Original Date"
        else
            OriginalDate := Today();

        if HULPOSSale."Original Type" <> '' then
            OriginalType := HULPOSSale."Original Type"
        else
            OriginalType := 'NY';

        if HULPOSSale."Original BBOX ID" <> '' then
            OriginalBBOXID := HULPOSSale."Original BBOX ID";

        if HULPOSSale."Original No." <> 0 then
            OriginalNo := HULPOSSale."Original No.";

        if HULPOSSale."Original Closure No." <> 0 then
            OriginalClosureNo := HULPOSSale."Original Closure No.";

        InputDialog.SetInput(1, OriginalDate, OriginalDateLbl);
        InputDialog.SetInput(2, OriginalType, OriginalTypeLbl);
        InputDialog.SetInput(3, OriginalBBOXID, OriginalBBOXIDLbl);
        InputDialog.SetInput(4, OriginalNo, OriginalNoLbl);
        InputDialog.SetInput(5, OriginalClosureNo, OriginalClosureNoLbl);

        Commit();
        if InputDialog.RunModal() <> Action::OK then
            Error(OriginalInfoNeededErr);

        InputDialog.InputDate(1, OriginalDate);
        InputDialog.InputText(2, OriginalType);
        InputDialog.InputText(3, OriginalBBOXID);
        InputDialog.InputInteger(4, OriginalNo);
        InputDialog.InputInteger(5, OriginalClosureNo);

        if (OriginalDate = 0D) or (OriginalType = '') or (OriginalBBOXID = '') or (OriginalNo = 0) or (OriginalClosureNo = 0) then
            Error(OriginalInfoNeededErr);

        FoundPOSSale := HULPOSSale.Get(POSSale.SystemId);
        if not FoundPOSSale then
            HULPOSSale."POS Sale SystemId" := POSSale.SystemId;
        HULPOSSale."Original Date" := OriginalDate;
        HULPOSSale.Validate("Original Type", CopyStr(OriginalType, 1, MaxStrLen(HULPOSSale."Original Type")));
        HULPOSSale."Original BBOX ID" := CopyStr(OriginalBBOXID, 1, MaxStrLen(HULPOSSale."Original BBOX ID"));
        HULPOSSale."Original No." := OriginalNo;
        HULPOSSale."Original Closure No." := OriginalClosureNo;
        if FoundPOSSale then
            HULPOSSale.Modify()
        else
            HULPOSSale.Insert();
    end;

    local procedure GetHULPOSSaleAndCheckIfReturnInfoEntered(var HULPOSSale: Record "NPR HU L POS Sale"; POSSale: Record "NPR POS Sale"): Boolean
    begin
        if not HULPOSSale.Get(POSSale.SystemId) then begin
            HULPOSSale.Init();
            exit(false);
        end;
        exit((HULPOSSale."Original Date" <> 0D) and (HULPOSSale."Original Type" <> '') and (HULPOSSale."Original BBOX ID" <> '')
            and (HULPOSSale."Original No." <> 0) and (HULPOSSale."Original Closure No." <> 0));
    end;

    local procedure GetFirstPOSSaleLineReturnReasonCodeMapping(POSEntry: Record "NPR POS Entry"): Enum "NPR HU L Return Reason Code"
    var
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        HULReturnReasonMapp: Record "NPR HU L Return Reason Mapp.";
    begin
        POSEntrySalesLine.SetRange("POS Entry No.", POSEntry."Entry No.");
        POSEntrySalesLine.SetFilter("Return Reason Code", '<>''''');
        POSEntrySalesLine.FindFirst();
        HULReturnReasonMapp.Get(POSEntrySalesLine."Return Reason Code");
        HULReturnReasonMapp.CheckIsHULReturnReasonPopulated();

        exit(HULReturnReasonMapp."HU L Return Reason Code");
    end;

    local procedure GetOriginalAuditEntryForReturn(var HULPOSAuditLogAux: Record "NPR HU L POS Audit Log Aux."; POSEntry: Record "NPR POS Entry"): Boolean
    var
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        OrigPOSEntrySystemIdSystemId: Guid;
    begin
        POSEntrySalesLine.SetRange("POS Entry No.", POSEntry."Entry No.");
        POSEntrySalesLine.FindFirst();
        OrigPOSEntrySystemIdSystemId := POSEntrySalesLine."Orig.POS Entry S.Line SystemId";
        POSEntrySalesLine.Reset();
        POSEntrySalesLine.SetRange(SystemId, OrigPOSEntrySystemIdSystemId);
        if not POSEntrySalesLine.FindFirst() then
            exit(false);
        exit(HULPOSAuditLogAux.FindAuditLog(POSEntrySalesLine."POS Entry No."));
    end;

    local procedure GetPOSSalesTicketNoFromAuditLog(Context: Codeunit "NPR POS JSON Helper"): Code[20]
    var
        HULPOSAuditLogAux: Record "NPR HU L POS Audit Log Aux.";
        SalesTicketNo: Text[50];
    begin
        SalesTicketNo := CopyStr(UpperCase(Context.GetString('receipt')), 1, MaxStrLen(SalesTicketNo));

        HULPOSAuditLogAux.FilterGroup(10);
        HULPOSAuditLogAux.SetRange("FCU Full Document No.", SalesTicketNo);
        HULPOSAuditLogAux.FilterGroup(0);

        case HULPOSAuditLogAux.Count() of
            0:
                exit('');
            1:
                begin
                    if HULPOSAuditLogAux.FindFirst() then
                        exit(HULPOSAuditLogAux."Source Document No.");

                    exit('');
                end;
            else begin
                if Page.RunModal(0, HULPOSAuditLogAux) <> Action::LookupOK then
                    exit('');

                exit(HULPOSAuditLogAux."Source Document No.");
            end;
        end;
    end;
    #endregion
}