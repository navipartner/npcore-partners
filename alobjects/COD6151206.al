codeunit 6151206 "NpCs POS Action Create Order"
{
    // NPR5.50/MHA /20190531  CASE 345261 Object created - Collect in Store
    // NPR5.51/ALST/20190705  CASE 357848 function prototype changed
    // NPR5.51/MHA /20190719  CASE 362443 It should be possible to send to another local store


    trigger OnRun()
    begin
    end;

    var
        Text000: Label 'Create Collect in Store Order';
        Text001: Label 'All Items might not be in stock in %1\\Do you still wish to continue?';
        Text002: Label 'Sale was exported correctly but prepayment in new sale failed: %1';

    local procedure ActionCode(): Text
    begin
        exit('CREATE_COLLECT_ORD');
    end;

    local procedure ActionVersion(): Text
    begin
        exit('1.0');
    end;

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', true, true)]
    local procedure OnDiscoverActions(var Sender: Record "POS Action")
    begin
        if not Sender.DiscoverAction(
          ActionCode(),
          Text000,
          ActionVersion(),
          Sender.Type::Generic,
          Sender."Subscriber Instances Allowed"::Multiple) then
            exit;

        Sender.RegisterWorkflowStep('select_from_store_code', 'respond();');
        Sender.RegisterWorkflowStep('select_to_store_code', 'if (context.from_store_code) { respond(); }');
        Sender.RegisterWorkflowStep('select_workflow', 'if (context.to_store_code) { respond(); }');
        Sender.RegisterWorkflowStep('select_customer', 'if (context.workflow_code) { respond(); }');
        Sender.RegisterWorkflowStep('create_collect_order', 'if ((context.from_store_code) && (context.to_store_code) && (context.workflow_code) && (context.customer_no)) { respond(); }');
        Sender.RegisterWorkflow(false);
        Sender.RegisterDataSourceBinding('BUILTIN_SALELINE');

        Sender.RegisterOptionParameter('Store Code From', StoreFromCodeOptionString(-1), StoreFromCodeOptionString(0));
        Sender.RegisterTextParameter('Store Code', '');
        Sender.RegisterTextParameter('Location Filter', '');
        Sender.RegisterBooleanParameter('Check Customer Credit', true);
    end;

    [EventSubscriber(ObjectType::Table, 6150705, 'OnLookupValue', '', true, true)]
    local procedure OnLookupStoreCode(var POSParameterValue: Record "POS Parameter Value"; Handled: Boolean)
    var
        NpCsStore: Record "NpCs Store";
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;
        if POSParameterValue.Name <> 'Store Code' then
            exit;
        if POSParameterValue."Data Type" <> POSParameterValue."Data Type"::Text then
            exit;

        Handled := true;

        if StrLen(POSParameterValue.Value) > MaxStrLen(NpCsStore.Code) then
            if NpCsStore.Get(UpperCase(POSParameterValue.Value)) then;

        NpCsStore.SetRange("Local Store", true);
        if PAGE.RunModal(0, NpCsStore) = ACTION::LookupOK then
            POSParameterValue.Value := NpCsStore.Code;
    end;

    [EventSubscriber(ObjectType::Table, 6150705, 'OnValidateValue', '', true, true)]
    local procedure OnValidateStoreCode(var POSParameterValue: Record "POS Parameter Value")
    var
        NpCsStore: Record "NpCs Store";
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;
        if POSParameterValue.Name <> 'Store Code' then
            exit;
        if POSParameterValue."Data Type" <> POSParameterValue."Data Type"::Text then
            exit;
        if POSParameterValue.Value = '' then
            exit;

        POSParameterValue.Value := UpperCase(POSParameterValue.Value);
        if not NpCsStore.Get(POSParameterValue.Value) then begin
            NpCsStore.SetFilter(Code, '%1', POSParameterValue.Value + '*');
            NpCsStore.SetRange("Local Store", true);
            if NpCsStore.FindFirst then
                POSParameterValue.Value := NpCsStore.Code;
        end;

        NpCsStore.Get(POSParameterValue.Value);
        NpCsStore.TestField("Local Store");
    end;

    [EventSubscriber(ObjectType::Table, 6150705, 'OnLookupValue', '', true, true)]
    local procedure OnLookupLocationFilter(var POSParameterValue: Record "POS Parameter Value"; Handled: Boolean)
    var
        Location: Record Location;
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;
        if POSParameterValue.Name <> 'Location Filter' then
            exit;
        if POSParameterValue."Data Type" <> POSParameterValue."Data Type"::Text then
            exit;

        Handled := true;

        if StrLen(POSParameterValue.Value) > MaxStrLen(Location.Code) then
            if Location.Get(UpperCase(POSParameterValue.Value)) then;

        if PAGE.RunModal(0, Location) = ACTION::LookupOK then
            POSParameterValue.Value := Location.Code;
    end;

    [EventSubscriber(ObjectType::Table, 6150705, 'OnValidateValue', '', true, true)]
    local procedure OnValidateLocationFilter(var POSParameterValue: Record "POS Parameter Value")
    var
        Location: Record Location;
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;
        if POSParameterValue.Name <> 'Location Filter' then
            exit;
        if POSParameterValue."Data Type" <> POSParameterValue."Data Type"::Text then
            exit;
        if POSParameterValue.Value = '' then
            exit;

        POSParameterValue.Value := UpperCase(POSParameterValue.Value);
        Location.SetFilter(Code, POSParameterValue.Value);
        if not Location.FindFirst then begin
            Location.SetFilter(Code, '%1', POSParameterValue.Value + '*');
            if Location.FindFirst then
                POSParameterValue.Value := Location.Code;
        end;
    end;

    local procedure "--- OnAction"()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', true, true)]
    local procedure OnAction("Action": Record "POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "POS Session"; FrontEnd: Codeunit "POS Front End Management"; var Handled: Boolean)
    var
        JSON: Codeunit "POS JSON Management";
    begin
        if Handled then
            exit;
        if not Action.IsThisAction(ActionCode()) then
            exit;
        Handled := true;

        JSON.InitializeJObjectParser(Context, FrontEnd);
        case WorkflowStep of
            'select_from_store_code':
                begin
                    OnActionSelectFromStoreCode(JSON, POSSession, FrontEnd);
                end;
            'select_to_store_code':
                begin
                    OnActionSelectToStoreCode(JSON, POSSession, FrontEnd);
                end;
            'select_workflow':
                begin
                    OnActionSelectWorkflowCode(JSON, FrontEnd);
                end;
            'select_customer':
                begin
                    OnActionSelectCustomer(POSSession, FrontEnd);
                end;
            'create_collect_order':
                begin
                    OnActionCreateCollectOrder(JSON, POSSession);
                    POSSession.RequestRefreshData();
                end;
        end;
    end;

    local procedure OnActionSelectFromStoreCode(JSON: Codeunit "POS JSON Management"; POSSession: Codeunit "POS Session"; FrontEnd: Codeunit "POS Front End Management")
    var
        StoreCodeFrom: Text;
    begin
        StoreCodeFrom := StoreFromCodeOptionString(JSON.GetIntegerParameter('Store Code From', false));
        case StoreCodeFrom of
            StoreFromCodeOptionString(0):
                begin
                    OnActionSelectFromStoreCodePOSRelation(POSSession, FrontEnd);
                end;
            StoreFromCodeOptionString(1):
                begin
                    OnActionSelectFromStoreCodeStoreCodeParameter(JSON, FrontEnd);
                end;
            StoreFromCodeOptionString(2):
                begin
                    OnActionSelectFromStoreCodeLocationFilterParameter(JSON, FrontEnd);
                end;
        end;
    end;

    local procedure OnActionSelectFromStoreCodePOSRelation(POSSession: Codeunit "POS Session"; FrontEnd: Codeunit "POS Front End Management")
    var
        NpCsStore: Record "NpCs Store";
        TempNpCsStore: Record "NpCs Store" temporary;
        NpCsStorePOSRelation: Record "NpCs Store POS Relation";
        POSUnit: Record "POS Unit";
        POSStore: Record "POS Store";
        JSON: Codeunit "POS JSON Management";
        POSSetup: Codeunit "POS Setup";
        LastRec: Text;
        StoreCode: Code[20];
    begin
        POSSession.GetSetup(POSSetup);
        POSSetup.GetPOSUnit(POSUnit);
        NpCsStorePOSRelation.SetRange(Type, NpCsStorePOSRelation.Type::"POS Unit");
        NpCsStorePOSRelation.SetRange("No.", POSUnit."No.");
        if not NpCsStorePOSRelation.FindLast then begin
            POSSetup.GetPOSStore(POSStore);

            NpCsStorePOSRelation.SetRange(Type, NpCsStorePOSRelation.Type::"POS Store");
            NpCsStorePOSRelation.SetRange("No.", POSStore.Code);
        end;

        NpCsStorePOSRelation.FindLast;
        LastRec := Format(NpCsStorePOSRelation);
        StoreCode := NpCsStorePOSRelation."Store Code";

        NpCsStorePOSRelation.FindFirst;
        if LastRec <> Format(NpCsStorePOSRelation) then begin
            repeat
                if NpCsStore.Get(NpCsStorePOSRelation."Store Code") and NpCsStore."Local Store" and not TempNpCsStore.Get(NpCsStore.Code) then begin
                    TempNpCsStore.Init;
                    TempNpCsStore := NpCsStore;
                    TempNpCsStore.Insert;
                end;
            until NpCsStorePOSRelation.Next = 0;

            if TempNpCsStore.FindFirst then;
            if PAGE.RunModal(0, TempNpCsStore) <> ACTION::LookupOK then
                exit;

            StoreCode := TempNpCsStore.Code;
        end;

        JSON.SetContext('from_store_code', StoreCode);
        FrontEnd.SetActionContext(ActionCode(), JSON);
    end;

    local procedure OnActionSelectFromStoreCodeStoreCodeParameter(JSON: Codeunit "POS JSON Management"; FrontEnd: Codeunit "POS Front End Management")
    var
        NpCsStore: Record "NpCs Store";
        StoreCode: Text;
    begin
        StoreCode := UpperCase(JSON.GetStringParameter('Store Code', false));
        NpCsStore.Get(StoreCode);

        JSON.SetContext('from_store_code', NpCsStore.Code);
        FrontEnd.SetActionContext(ActionCode(), JSON);
    end;

    local procedure OnActionSelectFromStoreCodeLocationFilterParameter(JSON: Codeunit "POS JSON Management"; FrontEnd: Codeunit "POS Front End Management")
    var
        NpCsStore: Record "NpCs Store";
        LocationFilter: Text;
        LastRec: Text;
    begin
        LocationFilter := UpperCase(JSON.GetStringParameter('Location Filter', false));
        NpCsStore.SetRange("Local Store", true);
        NpCsStore.SetFilter("Location Code", LocationFilter);
        NpCsStore.FindLast;
        LastRec := Format(NpCsStore);

        NpCsStore.FindFirst;
        if LastRec <> Format(NpCsStore) then begin
            if PAGE.RunModal(0, NpCsStore) <> ACTION::LookupOK then
                exit;
        end;

        JSON.SetContext('from_store_code', NpCsStore.Code);
        FrontEnd.SetActionContext(ActionCode(), JSON);
    end;

    local procedure OnActionSelectToStoreCode(JSON: Codeunit "POS JSON Management"; POSSession: Codeunit "POS Session"; FrontEnd: Codeunit "POS Front End Management")
    var
        FromNpCsStore: Record "NpCs Store";
        NpCsStoreInventoryBuffer: Record "NpCs Store Inventory Buffer" temporary;
        SalePOS: Record "Sale POS";
        TempSaleLinePOS: Record "Sale Line POS" temporary;
        TempNpCsStore: Record "NpCs Store" temporary;
        ToNpCsStore: Record "NpCs Store";
        NpCsStoreMgt: Codeunit "NpCs Store Mgt.";
        POSSale: Codeunit "POS Sale";
        NpCsStoresbyDistance: Page "NpCs Stores by Distance";
        FromStoreCode: Text;
        PrevRec: Text;
    begin
        FromStoreCode := UpperCase(JSON.GetString('from_store_code', false));
        FromNpCsStore.Get(FromStoreCode);

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        FindItemPosLines(SalePOS, TempSaleLinePOS);

        //-NPR5.51 [362443]
        ToNpCsStore.SetFilter(Code,'<>%1',FromNpCsStore.Code);
        //+NPR5.51 [362443]
        ToNpCsStore.FindSet;
        repeat
            TempNpCsStore.Init;
            TempNpCsStore := ToNpCsStore;
            TempNpCsStore."Distance (km)" := NpCsStoreMgt.CalcDistance(FromNpCsStore, ToNpCsStore);
            TempNpCsStore.Insert;

            TempSaleLinePOS.FindSet;
            repeat
                NpCsStoreInventoryBuffer.Init;
                NpCsStoreInventoryBuffer."Store Code" := TempNpCsStore.Code;
                NpCsStoreInventoryBuffer.Sku := TempSaleLinePOS.Reference;
                NpCsStoreInventoryBuffer.Description := CopyStr(TempSaleLinePOS.Description, 1, MaxStrLen(NpCsStoreInventoryBuffer.Description));
                NpCsStoreInventoryBuffer."Description 2" := TempSaleLinePOS."Description 2";
                NpCsStoreInventoryBuffer.Quantity := TempSaleLinePOS.Quantity;
                NpCsStoreInventoryBuffer.Insert;
            until TempSaleLinePOS.Next = 0;
        until ToNpCsStore.Next = 0;

        NpCsStoreMgt.SetBufferInventory(NpCsStoreInventoryBuffer);
        TempNpCsStore.FindSet;
        repeat
            PrevRec := Format(TempNpCsStore);

            Clear(NpCsStoreInventoryBuffer);
            NpCsStoreInventoryBuffer.SetRange("Store Code", TempNpCsStore.Code);
            NpCsStoreInventoryBuffer.SetRange("In Stock", false);
            TempNpCsStore."In Stock" := NpCsStoreInventoryBuffer.IsEmpty;

            if PrevRec <> Format(TempNpCsStore) then
                TempNpCsStore.Modify;
        until TempNpCsStore.Next = 0;

        Clear(NpCsStoresbyDistance);
        Clear(TempNpCsStore);
        Clear(NpCsStoreInventoryBuffer);
        NpCsStoresbyDistance.SetSourceTables(TempNpCsStore, NpCsStoreInventoryBuffer);
        NpCsStoresbyDistance.SetShowInventory(true);
        NpCsStoresbyDistance.LookupMode(true);
        if NpCsStoresbyDistance.RunModal() <> ACTION::LookupOK then
            exit;

        NpCsStoresbyDistance.GetRecord(TempNpCsStore);
        TempNpCsStore.Find;
        if not TempNpCsStore."In Stock" then begin
            if not Confirm(Text001, true, TempNpCsStore."Company Name") then
                exit;
        end;

        JSON.SetContext('to_store_code', TempNpCsStore.Code);
        FrontEnd.SetActionContext(ActionCode(), JSON);
    end;

    local procedure FindItemPosLines(SalePOS: Record "Sale POS"; var TempSaleLinePOS: Record "Sale Line POS" temporary)
    var
        SaleLinePOS: Record "Sale Line POS";
        Sku: Text;
    begin
        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLinePOS.SetRange("Sale Type", SaleLinePOS."Sale Type"::Sale);
        SaleLinePOS.SetRange(Type, SaleLinePOS.Type::Item);
        SaleLinePOS.SetFilter(Quantity, '>%1', 0);
        SaleLinePOS.FindSet;
        repeat
            Sku := SaleLinePOS."No.";
            if SaleLinePOS."Variant Code" <> '' then
                Sku += '_' + SaleLinePOS."Variant Code";

            TempSaleLinePOS.SetRange(Reference, Sku);
            if not TempSaleLinePOS.FindFirst then begin
                TempSaleLinePOS.Init;
                TempSaleLinePOS := SaleLinePOS;
                TempSaleLinePOS.Reference := Sku;
                TempSaleLinePOS.Insert;
            end else begin
                TempSaleLinePOS.Quantity += SaleLinePOS.Quantity;
                TempSaleLinePOS.Modify;
            end;
        until SaleLinePOS.Next = 0;
        Clear(TempSaleLinePOS);
    end;

    local procedure OnActionSelectWorkflowCode(JSON: Codeunit "POS JSON Management"; FrontEnd: Codeunit "POS Front End Management")
    var
        NpCsStore: Record "NpCs Store";
        NpCsStoreWorkflowRelation: Record "NpCs Store Workflow Relation";
        NpCsWorkflow: Record "NpCs Workflow";
        TempNpCsWorkflow: Record "NpCs Workflow" temporary;
        StoreCode: Text;
        LastRec: Text;
        WorkflowCode: Text;
    begin
        StoreCode := UpperCase(JSON.GetString('to_store_code', false));
        NpCsStore.Get(StoreCode);

        NpCsStoreWorkflowRelation.SetRange("Store Code", NpCsStore.Code);
        NpCsStoreWorkflowRelation.FindLast;
        LastRec := Format(NpCsStoreWorkflowRelation);
        WorkflowCode := NpCsStoreWorkflowRelation."Workflow Code";

        NpCsStoreWorkflowRelation.FindFirst;
        if LastRec <> Format(NpCsStoreWorkflowRelation) then begin
            NpCsStoreWorkflowRelation.FindSet;
            repeat
                if NpCsWorkflow.Get(NpCsStoreWorkflowRelation."Workflow Code") and not TempNpCsWorkflow.Get(NpCsWorkflow.Code) then begin
                    TempNpCsWorkflow.Init;
                    TempNpCsWorkflow := NpCsWorkflow;
                    TempNpCsWorkflow.Insert;
                end;
            until NpCsStoreWorkflowRelation.Next = 0;

            if TempNpCsWorkflow.FindFirst then;
            if PAGE.RunModal(0, TempNpCsWorkflow) <> ACTION::LookupOK then
                exit;

            WorkflowCode := TempNpCsWorkflow.Code;
        end;

        JSON.SetContext('workflow_code', WorkflowCode);
        FrontEnd.SetActionContext(ActionCode(), JSON);
    end;

    local procedure OnActionSelectCustomer(POSSession: Codeunit "POS Session"; FrontEnd: Codeunit "POS Front End Management")
    var
        SalePOS: Record "Sale POS";
        JSON: Codeunit "POS JSON Management";
        Customer: Record Customer;
    begin
        if (SalePOS."Customer No." <> '') and (SalePOS."Customer Type" = SalePOS."Customer Type"::Ord) then
            if Customer.Get(SalePOS."Customer No.") then;

        if Customer."No." = '' then begin
            if PAGE.RunModal(0, Customer) <> ACTION::LookupOK then
                exit;
        end;

        JSON.SetContext('customer_no', Customer."No.");
        FrontEnd.SetActionContext(ActionCode(), JSON);
    end;

    local procedure OnActionCreateCollectOrder(JSON: Codeunit "POS JSON Management"; POSSession: Codeunit "POS Session")
    var
        NpCsDocument: Record "NpCs Document";
        FromNpCsStore: Record "NpCs Store";
        ToNpCsStore: Record "NpCs Store";
        NpCsWorkflow: Record "NpCs Workflow";
        SalesHeader: Record "Sales Header";
        SalePOS: Record "Sale POS";
        NpCsCollectMgt: Codeunit "NpCs Collect Mgt.";
        NpCsWorkflowMgt: Codeunit "NpCs Workflow Mgt.";
        RetailSalesDocMgt: Codeunit "Retail Sales Doc. Mgt.";
        POSSale: Codeunit "POS Sale";
        FromStoreCode: Text;
        ToStoreCode: Text;
        WorkflowCode: Text;
        PrepaymentPct: Decimal;
    begin
        FromStoreCode := UpperCase(JSON.GetString('from_store_code', false));
        FromNpCsStore.Get(FromStoreCode);
        ToStoreCode := UpperCase(JSON.GetString('to_store_code', false));
        ToNpCsStore.Get(ToStoreCode);
        WorkflowCode := UpperCase(JSON.GetString('workflow_code', false));
        NpCsWorkflow.Get(WorkflowCode);

        ExportToDocument(JSON, POSSession, RetailSalesDocMgt);
        RetailSalesDocMgt.GetCreatedSalesHeader(SalesHeader);

        NpCsCollectMgt.InitSendToStoreDocument(SalesHeader, ToNpCsStore, NpCsWorkflow, NpCsDocument);
        NpCsDocument."From Store Code" := FromNpCsStore.Code;
        NpCsDocument."To Document Type" := NpCsDocument."To Document Type"::Order;
        NpCsDocument.Modify(true);
        Commit;

        NpCsWorkflowMgt.ScheduleRunWorkflow(NpCsDocument);

        Commit;
        //PrepaymentPct := GetPrepaymentPct(JSON);
        if PrepaymentPct > 0 then begin
            //End sale, auto start new sale, and insert prepayment line.
            POSSession.GetSale(POSSale);
            POSSale.GetCurrentSale(SalePOS);
            POSSession.StartTransaction();
            POSSession.ChangeViewSale();
            HandlePrepayment(POSSession, RetailSalesDocMgt, PrepaymentPct, true, SalePOS);
        end else
            //End sale
            POSSale.SelectViewForEndOfSale(POSSession);
    end;

    local procedure ExportToDocument(JSON: Codeunit "POS JSON Management"; POSSession: Codeunit "POS Session"; RetailSalesDocMgt: Codeunit "Retail Sales Doc. Mgt.")
    var
        SalePOS: Record "Sale POS";
        POSSaleLine: Codeunit "POS Sale Line";
        POSSale: Codeunit "POS Sale";
        CustomerNo: Text;
        PrevRec: Text;
    begin
        POSSession.GetSale(POSSale);
        POSSession.GetSaleLine(POSSaleLine);
        POSSale.GetCurrentSale(SalePOS);

        PrevRec := Format(SalePOS);

        SalePOS.Reference := SalePOS."Sales Ticket No.";
        CustomerNo := JSON.GetString('customer_no', false);
        SalePOS.Validate("Customer Type", SalePOS."Customer Type"::Ord);
        SalePOS.Validate("Customer No.", CustomerNo);
        SalePOS.TestField("Customer No.");

        if PrevRec <> Format(SalePOS) then
            SalePOS.Modify(true);
        Commit;

        if JSON.GetBooleanParameter('Check Customer Credit', false) then
            CheckCustCredit(SalePOS);

        SetParameters(POSSaleLine, RetailSalesDocMgt);
        RetailSalesDocMgt.TestSalePOS(SalePOS);
        RetailSalesDocMgt.ProcessPOSSale(SalePOS);
    end;

    local procedure CheckCustCredit(SalePOS: Record "Sale POS")
    var
        TempSalesHeader: Record "Sales Header" temporary;
        FormCode: Codeunit "Retail Form Code";
        POSCheckCrLimit: Codeunit "POS-Check Cr. Limit";
    begin
        FormCode.CreateSalesHeader(SalePOS, TempSalesHeader);
        if not POSCheckCrLimit.SalesHeaderPOSCheck(TempSalesHeader) then
            Error('');
    end;

    local procedure SetParameters(var POSSaleLine: Codeunit "POS Sale Line"; var RetailSalesDocMgt: Codeunit "Retail Sales Doc. Mgt.")
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
        RetailSalesDocMgt.SetTransferPaymentMethod(true);
        RetailSalesDocMgt.SetTransferTaxSetup(true);
        RetailSalesDocMgt.SetOpenSalesDocAfterExport(false);
        RetailSalesDocMgt.SetWriteInAuditRoll(true);

        POSSaleLine.CalculateBalance(AmountExclVAT, VATAmount, AmountInclVAT);
        RetailSalesDocMgt.SetDocumentTypeOrder();
    end;

    local procedure HandlePrepayment(POSSession: Codeunit "POS Session"; RetailSalesDocMgt: Codeunit "Retail Sales Doc. Mgt."; PrepaymentPct: Decimal; PrintPrepaymentInvoice: Boolean; PreviousSalePOS: Record "Sale POS")
    var
        Success: Boolean;
        SalesHeader: Record "Sales Header";
        POSSale: Codeunit "POS Sale";
        SalePOS: Record "Sale POS";
    begin
        //An error after sale end, before front end sync, is not allowed.
        RetailSalesDocMgt.GetCreatedSalesHeader(SalesHeader);
        if not SalesHeader.Find then
            exit;

        Commit;
        asserterror
        begin
            POSSession.GetSale(POSSale);
            POSSale.GetCurrentSale(SalePOS);
            SalePOS.Validate("Customer Type", PreviousSalePOS."Customer Type");
            SalePOS.Validate("Customer No.", PreviousSalePOS."Customer No.");
            SalePOS.Modify(true);
            POSSale.RefreshCurrent();

          //-NPR5.51
          // RetailSalesDocMgt.CreatePrepaymentLine(POSSession, SalesHeader, PrepaymentPct, PrintPrepaymentInvoice, TRUE);
          RetailSalesDocMgt.CreatePrepaymentLine(POSSession,SalesHeader,PrepaymentPct,PrintPrepaymentInvoice,true,false);
          //+NPR5.51

            POSSession.RequestRefreshData();
            Commit;
            Success := true;
            Error('');
        end;

        if not Success then
            Message(Text002, GetLastErrorText);
    end;

    local procedure "--- Aux"()
    begin
    end;

    local procedure StoreFromCodeOptionString(Index: Integer) OptionStr: Text
    begin
        OptionStr := 'POS Relation,Store Code Parameter,Location Filter Parameter';
        if Index < 0 then
            exit(OptionStr);

        OptionStr := SelectStr(Index + 1, OptionStr);

        exit(OptionStr);
    end;
}

