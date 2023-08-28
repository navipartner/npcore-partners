codeunit 6059948 "NPR NpCs POSAction Cr. Order B"
{
    Access = Internal;

    procedure SelectPOSRelation() StoreCode: Code[20];
    var
        NpCsStore: Record "NPR NpCs Store";
        TempNpCsStore: Record "NPR NpCs Store" temporary;
        NpCsStorePOSRelation: Record "NPR NpCs Store POS Relation";
        POSUnit: Record "NPR POS Unit";
        POSStore: Record "NPR POS Store";
        POSSetup: Codeunit "NPR POS Setup";
        POSSession: Codeunit "NPR POS Session";
        LastRec: Text;
    begin
        POSSession.GetSetup(POSSetup);
        POSSetup.GetPOSUnit(POSUnit);
        NpCsStorePOSRelation.SetRange(Type, NpCsStorePOSRelation.Type::"POS Unit");
        NpCsStorePOSRelation.SetRange("No.", POSUnit."No.");
        if not NpCsStorePOSRelation.FindLast() then begin
            POSSetup.GetPOSStore(POSStore);
            NpCsStorePOSRelation.SetRange(Type, NpCsStorePOSRelation.Type::"POS Store");
            NpCsStorePOSRelation.SetRange("No.", POSStore.Code);
        end;

        NpCsStorePOSRelation.FindLast();
        LastRec := Format(NpCsStorePOSRelation);
        StoreCode := NpCsStorePOSRelation."Store Code";

        NpCsStorePOSRelation.FindSet();
        if LastRec <> Format(NpCsStorePOSRelation) then begin
            repeat
                if NpCsStore.Get(NpCsStorePOSRelation."Store Code") and NpCsStore."Local Store" and not TempNpCsStore.Get(NpCsStore.Code) then begin
                    TempNpCsStore.Init();
                    TempNpCsStore := NpCsStore;
                    TempNpCsStore.Insert();
                end;
            until NpCsStorePOSRelation.Next() = 0;

            if TempNpCsStore.FindFirst() then;
            if Page.RunModal(0, TempNpCsStore) <> Action::LookupOK then
                exit;

            StoreCode := TempNpCsStore.Code;
        end;
    end;

    procedure FindItemPosLines(SalePOS: Record "NPR POS Sale"; var TempSaleLinePOS: Record "NPR POS Sale Line" temporary)
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        Sku: Text[50];
    begin
        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLinePOS.SetRange("Sale Type", SaleLinePOS."Sale Type"::Sale);
        SaleLinePOS.SetRange("Line Type", SaleLinePOS."Line Type"::Item);
        SaleLinePOS.SetFilter(Quantity, '>%1', 0);
        SaleLinePOS.FindSet();
        repeat
            Sku := SaleLinePOS."No.";
            if SaleLinePOS."Variant Code" <> '' then
                Sku += '_' + SaleLinePOS."Variant Code";

            TempSaleLinePOS.SetRange(Reference, Sku);
            if not TempSaleLinePOS.FindFirst() then begin
                TempSaleLinePOS.Init();
                TempSaleLinePOS := SaleLinePOS;
                TempSaleLinePOS.Reference := CopyStr(Sku, 1, MaxStrLen(TempSaleLinePOS.Reference));
                TempSaleLinePOS.Insert();
            end else begin
                TempSaleLinePOS.Quantity += SaleLinePOS.Quantity;
                TempSaleLinePOS.Modify();
            end;
        until SaleLinePOS.Next() = 0;
        Clear(TempSaleLinePOS);
    end;

    procedure SelectCustomer(WorkflowCode: Code[20]) CustomerNo: Code[20]
    var
        SalePOS: Record "NPR POS Sale";
        Customer: Record Customer;
        POSSession: Codeunit "NPR POS Session";
        POSSale: Codeunit "NPR POS Sale";
        NpCsPOSActionEvents: Codeunit "NPR NpCs POS Action Events";
        IsHandled: Boolean;
    begin
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        if (SalePOS."Customer No." <> '') then
            if Customer.Get(SalePOS."Customer No.") then;
        NpCsPOSActionEvents.OnBeforeSelectCustomer(Customer."No.", WorkflowCode, IsHandled);
        if not IsHandled then
            if Customer."No." = '' then begin
                if Page.RunModal(0, Customer) <> Action::LookupOK then
                    exit;
            end;

        CustomerNo := Customer."No.";
    end;

    procedure SelectWorkflow(StoreCode: Text) WorkflowCode: Code[20]
    var
        NpCsStore: Record "NPR NpCs Store";
        NpCsStoreWorkflowRelation: Record "NPR NpCs Store Workflow Rel.";
        NpCsWorkflow: Record "NPR NpCs Workflow";
        TempNpCsWorkflow: Record "NPR NpCs Workflow" temporary;

        LastRec: Text;

    begin
        NpCsStore.Get(StoreCode);

        NpCsStoreWorkflowRelation.SetRange("Store Code", NpCsStore.Code);
        NpCsStoreWorkflowRelation.FindLast();
        LastRec := Format(NpCsStoreWorkflowRelation);
        WorkflowCode := NpCsStoreWorkflowRelation."Workflow Code";

        NpCsStoreWorkflowRelation.FindFirst();
        if LastRec <> Format(NpCsStoreWorkflowRelation) then begin
            NpCsStoreWorkflowRelation.FindSet();
            repeat
                if NpCsWorkflow.Get(NpCsStoreWorkflowRelation."Workflow Code") and not TempNpCsWorkflow.Get(NpCsWorkflow.Code) then begin
                    TempNpCsWorkflow.Init();
                    TempNpCsWorkflow := NpCsWorkflow;
                    TempNpCsWorkflow.Insert();
                end;
            until NpCsStoreWorkflowRelation.Next() = 0;

            if TempNpCsWorkflow.FindFirst() then;
            if Page.RunModal(0, TempNpCsWorkflow) <> Action::LookupOK then
                exit;

            WorkflowCode := TempNpCsWorkflow.Code;
        end;
    end;

    procedure CreateCollectOrder(FromStoreCode: Code[20]; ToStoreCode: Code[20]; WorkflowCode: Code[20]; PrepaymentPct: Decimal; RetailSalesDocMgt: Codeunit "NPR Sales Doc. Exp. Mgt."; PrepaymentIsAmount: Boolean)
    var
        NpCsDocument: Record "NPR NpCs Document";
        FromNpCsStore: Record "NPR NpCs Store";
        ToNpCsStore: Record "NPR NpCs Store";
        NpCsWorkflow: Record "NPR NpCs Workflow";
        SalesHeader: Record "Sales Header";
        SalePOS: Record "NPR POS Sale";
        NpCsCollectMgt: Codeunit "NPR NpCs Collect Mgt.";
        NpCsWorkflowMgt: Codeunit "NPR NpCs Workflow Mgt.";
        POSPrepaymentMgt: Codeunit "NPR POS Prepayment Mgt.";
        POSSale: Codeunit "NPR POS Sale";
        POSSession: Codeunit "NPR POS Session";
        NpCsPOSActionEvents: Codeunit "NPR NpCs POS Action Events";
    begin
        FromNpCsStore.Get(FromStoreCode);
        ToNpCsStore.Get(ToStoreCode);
        NpCsWorkflow.Get(WorkflowCode);

        RetailSalesDocMgt.GetCreatedSalesHeader(SalesHeader);
        NpCsPOSActionEvents.CreateOrderOnAfterGetCreatedSalesHeader(SalesHeader);
        NpCsCollectMgt.InitSendToStoreDocument(SalesHeader, ToNpCsStore, NpCsWorkflow, NpCsDocument);
        NpCsPOSActionEvents.OnAfterInitSendToStoreDocument(SalesHeader, ToNpCsStore, NpCsWorkflow, NpCsDocument);
        NpCsDocument."From Store Code" := FromNpCsStore.Code;
        NpCsDocument."To Document Type" := NpCsDocument."To Document Type"::Order;
        NpCsDocument.Modify(true);

        POSSession.GetSale(POSSale);

        if PrepaymentPct > 0 then begin
            //End sale, auto start new sale, and insert prepayment line.
            POSSale.GetCurrentSale(SalePOS);
            POSSession.StartTransaction();
            POSSession.ChangeViewSale();
            HandlePrepayment(RetailSalesDocMgt, PrepaymentPct, true, SalePOS, PrepaymentIsAmount);
            NpCsDocument."Prepaid Amount" := POSPrepaymentMgt.GetPrepaymentAmountToPay(SalesHeader);
            NpCsDocument.Modify();
        end else
            //End sale
            POSSale.SelectViewForEndOfSale();
        NpCsPOSActionEvents.OnCreateCollectOrderBeforeScheduleRunWorkflow(NpCsDocument);
        NpCsWorkflowMgt.ScheduleRunWorkflow(NpCsDocument);
    end;

    procedure HandlePrepayment(RetailSalesDocMgt: Codeunit "NPR Sales Doc. Exp. Mgt."; PrepaymentPct: Decimal; PrintPrepaymentInvoice: Boolean; PreviousSalePOS: Record "NPR POS Sale"; PrepaymentIsAmount: Boolean) Success: Boolean
    var
        HandlePrepmtCU: Codeunit "NPR NpCs Cr.Ord: Handle Prepmt";
        POSSession: Codeunit "NPR POS Session";
    begin
        //An error after sale end, before front end sync, is not allowed.
        Commit();
        ClearLastError();
        Clear(HandlePrepmtCU);
        HandlePrepmtCU.SetParameters(POSSession, RetailSalesDocMgt, PrepaymentPct, PrintPrepaymentInvoice, PreviousSalePOS, PrepaymentIsAmount);
        if not HandlePrepmtCU.Run() then
            Success := false;
    end;

    procedure ExportToDocument(CustomerNo: Text; RetailSalesDocMgt: Codeunit "NPR Sales Doc. Exp. Mgt."; checkCustomerCredit: Boolean)
    var
        SalePOS: Record "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSSale: Codeunit "NPR POS Sale";
        POSSession: Codeunit "NPR POS Session";
        PrevRec: Text;
    begin
        POSSession.GetSale(POSSale);
        POSSession.GetSaleLine(POSSaleLine);
        POSSale.GetCurrentSale(SalePOS);

        PrevRec := Format(SalePOS);

        SalePOS."External Document No." := SalePOS."Sales Ticket No.";
        SalePOS.Reference := SalePOS."Sales Ticket No.";
        SalePOS.Validate("Customer No.", CustomerNo);
        SalePOS.TestField("Customer No.");

        if PrevRec <> Format(SalePOS) then
            SalePOS.Modify(true);
        POSSale.RefreshCurrent();
        Commit();

        SetParameters(POSSaleLine, RetailSalesDocMgt, checkCustomerCredit);
        RetailSalesDocMgt.TestSalePOS(SalePOS);
        RetailSalesDocMgt.ProcessPOSSale(POSSale);
    end;

    local procedure SetParameters(var POSSaleLine: Codeunit "NPR POS Sale Line"; var RetailSalesDocMgt: Codeunit "NPR Sales Doc. Exp. Mgt."; checkCustomerCredit: Boolean)
    var
        AmountExclVAT: Decimal;
        VATAmount: Decimal;
        AmountInclVAT: Decimal;
    begin
        RetailSalesDocMgt.SetAsk(false);
        RetailSalesDocMgt.SetPrint(false);
        RetailSalesDocMgt.SetInvoice(false);
        RetailSalesDocMgt.SetReceive(false);
        RetailSalesDocMgt.SetShip(false);
        RetailSalesDocMgt.SetSendPostedPdf2Nav(false);
        RetailSalesDocMgt.SetRetailPrint(false);
        RetailSalesDocMgt.SetAutoReserveSalesLine(false);
        RetailSalesDocMgt.SetTransferSalesPerson(true);
        RetailSalesDocMgt.SetTransferPostingsetup(true);
        RetailSalesDocMgt.SetTransferDimensions(true);
        RetailSalesDocMgt.SetTransferTaxSetup(true);
        RetailSalesDocMgt.SetOpenSalesDocAfterExport(false);
        RetailSalesDocMgt.SetCustomerCreditCheck(checkCustomerCredit);

        POSSaleLine.CalculateBalance(AmountExclVAT, VATAmount, AmountInclVAT);
        RetailSalesDocMgt.SetDocumentTypeOrder();
    end;

    procedure SelectToStoreCode(var TempNpCsStore: Record "NPR NpCs Store" temporary; FromStoreCode: Code[20]): Boolean
    var
        FromNpCsStore: Record "NPR NpCs Store";
        TempNpCsStoreInventoryBuffer: Record "NPR NpCs Store Inv. Buffer" temporary;
        SalePOS: Record "NPR POS Sale";
        TempSaleLinePOS: Record "NPR POS Sale Line" temporary;
        ToNpCsStore: Record "NPR NpCs Store";
        NpCsStoreMgt: Codeunit "NPR NpCs Store Mgt.";
        POSSession: Codeunit "NPR POS Session";
        POSSale: Codeunit "NPR POS Sale";
        NpCsStoresbyDistance: Page "NPR NpCs Stores by Distance";
        PrevRec: Text;
        NpCsPOSActionCreOrderB: Codeunit "NPR NpCs POSAction Cr. Order B";
    begin
        FromNpCsStore.Get(FromStoreCode);

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        NpCsPOSActionCreOrderB.FindItemPosLines(SalePOS, TempSaleLinePOS);

        ToNpCsStore.SetFilter(Code, '<>%1', FromNpCsStore.Code);
        ToNpCsStore.FindSet();
        repeat
            TempNpCsStore.Init();
            TempNpCsStore := ToNpCsStore;
            TempNpCsStore."Distance (km)" := NpCsStoreMgt.CalcDistance(FromNpCsStore, ToNpCsStore);
            TempNpCsStore.Insert();

            TempSaleLinePOS.FindSet();
            repeat
                TempNpCsStoreInventoryBuffer.Init();
                TempNpCsStoreInventoryBuffer."Store Code" := TempNpCsStore.Code;
                TempNpCsStoreInventoryBuffer.Sku := TempSaleLinePOS.Reference;
                TempNpCsStoreInventoryBuffer.Description := CopyStr(TempSaleLinePOS.Description, 1, MaxStrLen(TempNpCsStoreInventoryBuffer.Description));
                TempNpCsStoreInventoryBuffer."Description 2" := TempSaleLinePOS."Description 2";
                TempNpCsStoreInventoryBuffer.Quantity := TempSaleLinePOS.Quantity;
                TempNpCsStoreInventoryBuffer.Insert();
            until TempSaleLinePOS.Next() = 0;
        until ToNpCsStore.Next() = 0;

        NpCsStoreMgt.SetBufferInventory(TempNpCsStoreInventoryBuffer);
        TempNpCsStore.FindSet();
        repeat
            PrevRec := Format(TempNpCsStore);

            Clear(TempNpCsStoreInventoryBuffer);
            TempNpCsStoreInventoryBuffer.SetRange("Store Code", TempNpCsStore.Code);
            TempNpCsStoreInventoryBuffer.SetRange("In Stock", false);
            TempNpCsStore."In Stock" := TempNpCsStoreInventoryBuffer.IsEmpty();
            TempNpCsStoreInventoryBuffer.SetRange("In Stock");
            if TempNpCsStoreInventoryBuffer.FindSet() then
                repeat
                    if TempNpCsStoreInventoryBuffer.Quantity > 0 then begin
                        TempNpCsStore."Requested Qty." += TempNpCsStoreInventoryBuffer.Quantity;
                        if TempNpCsStoreInventoryBuffer.Inventory < 0 then
                            TempNpCsStoreInventoryBuffer.Inventory := 0;
                        if TempNpCsStoreInventoryBuffer.Inventory > TempNpCsStoreInventoryBuffer.Quantity then
                            TempNpCsStoreInventoryBuffer.Inventory := TempNpCsStoreInventoryBuffer.Quantity;
                        TempNpCsStore."Fullfilled Qty." += TempNpCsStoreInventoryBuffer.Inventory;
                    end;
                until TempNpCsStoreInventoryBuffer.Next() = 0;

            if PrevRec <> Format(TempNpCsStore) then
                TempNpCsStore.Modify();
        until TempNpCsStore.Next() = 0;

        Clear(NpCsStoresbyDistance);
        Clear(TempNpCsStore);
        Clear(TempNpCsStoreInventoryBuffer);
        NpCsStoresbyDistance.SetSourceTables(TempNpCsStore, TempNpCsStoreInventoryBuffer);
        NpCsStoresbyDistance.SetShowInventory(true);
        NpCsStoresbyDistance.SetFromStoreCode(FromNpCsStore.Code);
        NpCsStoresbyDistance.LookupMode(true);
        if NpCsStoresbyDistance.RunModal() <> Action::LookupOK then
            exit(false);

        NpCsStoresbyDistance.GetRecord(TempNpCsStore);
        TempNpCsStore.Find();
        exit(true);
    end;


}