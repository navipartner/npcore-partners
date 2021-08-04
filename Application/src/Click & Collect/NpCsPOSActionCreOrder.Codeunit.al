codeunit 6151206 "NPR NpCs POSAction Cre. Order"
{
    var
        ActionDescriptionLbl: Label 'This built-in action create collect order from one to another store.';
        MissingStockInCompanyLbl: Label 'All Items might not be in stock in %1. Do you still wish to continue?', Comment = '%1="NPR NpCs Store"."Company Name';
        PrepaymentFailedLbl: Label 'Sale was exported correctly but prepayment in new sale failed: %1', Comment = '%1=GetLastErrorText()';
        ConfirmMissingStockLbl: Label 'Confirm Missing Stock';
        PrepaymentPercantageLbl: Label 'Enter Prepayment Percentage';
        OptionsFromStoreCodeLbl: Label 'POS Relation,Store Code Parameter,Location Filter Parameter';

    local procedure ActionCode(): Text
    begin
        exit('CREATE_COLLECT_ORD');
    end;

    local procedure ActionVersion(): Text
    begin
        exit('1.1');
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Action", 'OnDiscoverActions', '', true, true)]
    local procedure OnDiscoverActions(var Sender: Record "NPR POS Action")
    begin
        if Sender.DiscoverAction20(ActionCode(), ActionDescriptionLbl, ActionVersion()) then begin
            Sender.RegisterWorkflow20(
                'switch($parameters.fromStoreCode + "") {' +
                '  case "0":' +
                '    await workflow.respond("SelectFromStoreCodeFromPOSRelation");' +
                '    break;' +
                '  case "1":' +
                '    await workflow.respond("SelectFromStoreCodeFromStoreCodeParameter");' +
                '    break;' +
                '  case "2":' +
                '    await workflow.respond("SelectFromStoreCodeFromLocationFilterParameter");' +
                '    break;' +
                '}' +
                'if (!$context.fromStoreCode) {return}' +

                'if (!$context.toStoreCode) {' +
                '    await workflow.respond("SelectToStoreCode");' +
                '    if ($context.ConfirmMissingStock) {' +
                '        if ($context.MissingStockInCompanyLbl.length > 0) {' +
                '            if (!(await popup.confirm({ title: $labels.ConfirmSetStoreForMissingStock, caption: $context.MissingStockInCompanyLbl }))) {' +
                '                return;' +
                '            }' +
                '        }' +
                '    }' +
                '}' +
                'if (!$context.toStoreCode) { return }' +

                'if (!$context.workflowCode) {' +
                '    await workflow.respond("SelectWorkflow")' +
                '}' +
                'if (!$context.workflowCode) { return }' +

                'if (!$context.customerNo) {' +
                '    await workflow.respond("SelectCustomer")' +
                '}' +
                'if (!$context.customerNo) { return }' +

                'if (!$context.prepaymentPercent) {' +
                '   $context.prepaymentPercent = await popup.numpad({caption: $labels.SetPrepaymentPercentage,value: $parameters.prepaymentPercent});' +
                '}' +

                'await workflow.respond("CreateCollectOrder");' +

                'if ($context.HandlePrepaymentFailed) {' +
                '    if ($context.HandlePrepaymentFailReasonMsg.length > 0) {' +
                '        await popup.message($context.HandlePrepaymentFailReasonMsg);' +
                '    }' +
                '}'
                );

            Sender.RegisterOptionParameter('fromStoreCode', 'POS Relation,Store Code Parameter,Location Filter Parameter', 'POS Relation');
            Sender.RegisterTextParameter('storeCode', '');
            Sender.RegisterTextParameter('locationFilter', '');
            Sender.RegisterDecimalParameter('prepaymentPercent', 0);
            Sender.RegisterBooleanParameter('checkCustomerCredit', true);
            Sender.RegisterDataSourceBinding('BUILTIN_SALELINE');
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnGetParameterOptionStringCaption', '', true, false)]
    local procedure OnGetParameterOptionStringCaption(POSParameterValue: Record "NPR POS Parameter Value"; var Caption: Text)
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;

        CASE POSParameterValue.Name OF
            'fromStoreCore':
                Caption := OptionsFromStoreCodeLbl;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS UI Management", 'OnInitializeCaptions', '', true, false)]
    local procedure OnInitializeCaptions(Captions: Codeunit "NPR POS Caption Management")
    begin
        Captions.AddActionCaption(ActionCode(), 'SetPrepaymentPercentage', PrepaymentPercantageLbl);
        Captions.AddActionCaption(ActionCode(), 'ConfirmSetStoreForMissingStock', ConfirmMissingStockLbl);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnLookupValue', '', true, true)]
    local procedure OnLookupStoreCode(var POSParameterValue: Record "NPR POS Parameter Value"; Handled: Boolean)
    var
        NpCsStore: Record "NPR NpCs Store";
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;
        if POSParameterValue.Name <> 'storeCode' then
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

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnValidateValue', '', true, true)]
    local procedure OnValidateStoreCode(var POSParameterValue: Record "NPR POS Parameter Value")
    var
        NpCsStore: Record "NPR NpCs Store";
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;
        if POSParameterValue.Name <> 'storeCode' then
            exit;
        if POSParameterValue."Data Type" <> POSParameterValue."Data Type"::Text then
            exit;
        if POSParameterValue.Value = '' then
            exit;

        POSParameterValue.Value := UpperCase(POSParameterValue.Value);
        if not NpCsStore.Get(POSParameterValue.Value) then begin
            NpCsStore.SetFilter(Code, '%1', POSParameterValue.Value + '*');
            NpCsStore.SetRange("Local Store", true);
            if NpCsStore.FindFirst() then
                POSParameterValue.Value := NpCsStore.Code;
        end;

        NpCsStore.Get(POSParameterValue.Value);
        NpCsStore.TestField("Local Store");
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnLookupValue', '', true, true)]
    local procedure OnLookupLocationFilter(var POSParameterValue: Record "NPR POS Parameter Value"; Handled: Boolean)
    var
        Location: Record Location;
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;
        if POSParameterValue.Name <> 'locationFilter' then
            exit;
        if POSParameterValue."Data Type" <> POSParameterValue."Data Type"::Text then
            exit;

        Handled := true;

        if StrLen(POSParameterValue.Value) > MaxStrLen(Location.Code) then
            if Location.Get(UpperCase(POSParameterValue.Value)) then;

        if PAGE.RunModal(0, Location) = ACTION::LookupOK then
            POSParameterValue.Value := Location.Code;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnValidateValue', '', true, true)]
    local procedure OnValidateLocationFilter(var POSParameterValue: Record "NPR POS Parameter Value")
    var
        Location: Record Location;
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;
        if POSParameterValue.Name <> 'locationFilter' then
            exit;
        if POSParameterValue."Data Type" <> POSParameterValue."Data Type"::Text then
            exit;
        if POSParameterValue.Value = '' then
            exit;

        POSParameterValue.Value := UpperCase(POSParameterValue.Value);
        Location.SetFilter(Code, POSParameterValue.Value);
        if not Location.FindFirst() then begin
            Location.SetFilter(Code, '%1', POSParameterValue.Value + '*');
            if Location.FindFirst() then
                POSParameterValue.Value := Location.Code;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Workflows 2.0", 'OnAction', '', true, true)]
    local procedure OnAction20("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: Codeunit "NPR POS JSON Management"; POSSession: Codeunit "NPR POS Session"; State: Codeunit "NPR POS WF 2.0: State"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    begin
        if not Action.IsThisAction(ActionCode()) then
            exit;
        Handled := true;

        case WorkflowStep of
            'SelectFromStoreCodeFromPOSRelation':
                begin
                    SelectPOSRelation(Context, POSSession);
                end;
            'SelectFromStoreCodeFromStoreCodeParameter':
                begin
                    SelectStoreCodeParameter(Context);
                end;
            'SelectFromStoreCodeFromLocationFilterParameter':
                begin
                    SelectLocationFilterParameter(Context);
                end;
            'SelectToStoreCode':
                begin
                    SelectToStoreCode(Context, POSSession);
                end;
            'SelectWorkflow':
                begin
                    SelectWorkflow(Context);
                end;
            'SelectCustomer':
                begin
                    SelectCustomer(Context);
                end;
            'CreateCollectOrder':
                begin
                    CreateCollectOrder(Context, POSSession);
                    POSSession.RequestRefreshData();
                end;
        end;
    end;

    local procedure SelectPOSRelation(Context: Codeunit "NPR POS JSON Management"; POSSession: Codeunit "NPR POS Session")
    var
        NpCsStore: Record "NPR NpCs Store";
        TempNpCsStore: Record "NPR NpCs Store" temporary;
        NpCsStorePOSRelation: Record "NPR NpCs Store POS Relation";
        POSUnit: Record "NPR POS Unit";
        POSStore: Record "NPR POS Store";
        POSSetup: Codeunit "NPR POS Setup";
        LastRec: Text;
        StoreCode: Code[20];
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
            if PAGE.RunModal(0, TempNpCsStore) <> ACTION::LookupOK then
                exit;

            StoreCode := TempNpCsStore.Code;
        end;

        Context.SetContext('fromStoreCode', StoreCode);
    end;

    local procedure SelectStoreCodeParameter(Context: Codeunit "NPR POS JSON Management")
    var
        NpCsStore: Record "NPR NpCs Store";
        StoreCode: Text;
    begin
        StoreCode := UpperCase(Context.GetStringParameter('storeCode'));
        NpCsStore.Get(StoreCode);

        Context.SetContext('fromStoreCode', NpCsStore.Code);
    end;

    local procedure SelectLocationFilterParameter(Context: Codeunit "NPR POS JSON Management")
    var
        NpCsStore: Record "NPR NpCs Store";
        LocationFilter: Text;
        LastRec: Text;
    begin
        LocationFilter := UpperCase(Context.GetStringParameter('locationFilter'));
        NpCsStore.SetRange("Local Store", true);
        NpCsStore.SetFilter("Location Code", LocationFilter);
        NpCsStore.FindLast();
        LastRec := Format(NpCsStore);

        NpCsStore.FindFirst();
        if LastRec <> Format(NpCsStore) then begin
            if PAGE.RunModal(0, NpCsStore) <> ACTION::LookupOK then
                exit;
        end;

        Context.SetContext('fromStoreCode', NpCsStore.Code);
    end;

    local procedure SelectToStoreCode(Context: Codeunit "NPR POS JSON Management"; POSSession: Codeunit "NPR POS Session")
    var
        FromNpCsStore: Record "NPR NpCs Store";
        TempNpCsStoreInventoryBuffer: Record "NPR NpCs Store Inv. Buffer" temporary;
        SalePOS: Record "NPR POS Sale";
        TempSaleLinePOS: Record "NPR POS Sale Line" temporary;
        TempNpCsStore: Record "NPR NpCs Store" temporary;
        ToNpCsStore: Record "NPR NpCs Store";
        NpCsStoreMgt: Codeunit "NPR NpCs Store Mgt.";
        POSSale: Codeunit "NPR POS Sale";
        NpCsStoresbyDistance: Page "NPR NpCs Stores by Distance";
        FromStoreCode: Text;
        PrevRec: Text;
    begin
        FromStoreCode := UpperCase(Context.GetString('fromStoreCode'));
        FromNpCsStore.Get(FromStoreCode);

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        FindItemPosLines(SalePOS, TempSaleLinePOS);

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
        NpCsStoresbyDistance.SetFromStoreCode(FromStoreCode);
        NpCsStoresbyDistance.LookupMode(true);
        if NpCsStoresbyDistance.RunModal() <> ACTION::LookupOK then
            exit;

        NpCsStoresbyDistance.GetRecord(TempNpCsStore);
        TempNpCsStore.Find();
        if not TempNpCsStore."In Stock" then begin
            Context.SetContext('ConfirmMissingStock', true);
            Context.SetContext('MissingStockInCompanyLbl', Strsubstno(MissingStockInCompanyLbl, TempNpCsStore."Company Name"));
        end;
        Context.SetContext('toStoreCode', TempNpCsStore.Code);
    end;

    local procedure FindItemPosLines(SalePOS: Record "NPR POS Sale"; var TempSaleLinePOS: Record "NPR POS Sale Line" temporary)
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        Sku: Text;
    begin
        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLinePOS.SetRange("Sale Type", SaleLinePOS."Sale Type"::Sale);
        SaleLinePOS.SetRange(Type, SaleLinePOS.Type::Item);
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
                TempSaleLinePOS.Reference := Sku;
                TempSaleLinePOS.Insert();
            end else begin
                TempSaleLinePOS.Quantity += SaleLinePOS.Quantity;
                TempSaleLinePOS.Modify();
            end;
        until SaleLinePOS.Next() = 0;
        Clear(TempSaleLinePOS);
    end;

    local procedure SelectWorkflow(JSON: Codeunit "NPR POS JSON Management")
    var
        NpCsStore: Record "NPR NpCs Store";
        NpCsStoreWorkflowRelation: Record "NPR NpCs Store Workflow Rel.";
        NpCsWorkflow: Record "NPR NpCs Workflow";
        TempNpCsWorkflow: Record "NPR NpCs Workflow" temporary;
        StoreCode: Text;
        LastRec: Text;
        WorkflowCode: Text;
    begin
        StoreCode := UpperCase(JSON.GetString('toStoreCode'));
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
            if PAGE.RunModal(0, TempNpCsWorkflow) <> ACTION::LookupOK then
                exit;

            WorkflowCode := TempNpCsWorkflow.Code;
        end;

        JSON.SetContext('workflowCode', WorkflowCode);
    end;

    local procedure SelectCustomer(Context: Codeunit "NPR POS JSON Management")
    var
        SalePOS: Record "NPR POS Sale";
        Customer: Record Customer;
    begin
        if (SalePOS."Customer No." <> '') and (SalePOS."Customer Type" = SalePOS."Customer Type"::Ord) then
            if Customer.Get(SalePOS."Customer No.") then;

        if Customer."No." = '' then begin
            if PAGE.RunModal(0, Customer) <> ACTION::LookupOK then
                exit;
        end;

        Context.SetContext('customerNo', Customer."No.");
    end;

    local procedure CreateCollectOrder(Context: Codeunit "NPR POS JSON Management"; POSSession: Codeunit "NPR POS Session")
    var
        NpCsDocument: Record "NPR NpCs Document";
        FromNpCsStore: Record "NPR NpCs Store";
        ToNpCsStore: Record "NPR NpCs Store";
        NpCsWorkflow: Record "NPR NpCs Workflow";
        SalesHeader: Record "Sales Header";
        SalePOS: Record "NPR POS Sale";
        NpCsCollectMgt: Codeunit "NPR NpCs Collect Mgt.";
        NpCsWorkflowMgt: Codeunit "NPR NpCs Workflow Mgt.";
        RetailSalesDocMgt: Codeunit "NPR Sales Doc. Exp. Mgt.";
        POSPrepaymentMgt: Codeunit "NPR POS Prepayment Mgt.";
        POSSale: Codeunit "NPR POS Sale";
        FromStoreCode: Text;
        ToStoreCode: Text;
        WorkflowCode: Text;
        PrepaymentPct: Decimal;
    begin
        FromStoreCode := UpperCase(Context.GetString('fromStoreCode'));
        FromNpCsStore.Get(FromStoreCode);
        ToStoreCode := UpperCase(Context.GetString('toStoreCode'));
        ToNpCsStore.Get(ToStoreCode);
        WorkflowCode := UpperCase(Context.GetString('workflowCode'));
        NpCsWorkflow.Get(WorkflowCode);
        PrepaymentPct := Context.GetDecimal('prepaymentPercent');

        ExportToDocument(Context, POSSession, RetailSalesDocMgt);
        RetailSalesDocMgt.GetCreatedSalesHeader(SalesHeader);

        NpCsCollectMgt.InitSendToStoreDocument(SalesHeader, ToNpCsStore, NpCsWorkflow, NpCsDocument);
        NpCsDocument."From Store Code" := FromNpCsStore.Code;
        NpCsDocument."To Document Type" := NpCsDocument."To Document Type"::Order;
        NpCsDocument.Modify(true);

        POSSession.GetSale(POSSale);

        if PrepaymentPct > 0 then begin
            //End sale, auto start new sale, and insert prepayment line.
            POSSale.GetCurrentSale(SalePOS);
            POSSession.StartTransaction();
            POSSession.ChangeViewSale();
            HandlePrepayment(Context, POSSession, RetailSalesDocMgt, PrepaymentPct, true, SalePOS);
            NpCsDocument."Prepaid Amount" := POSPrepaymentMgt.GetPrepaymentAmountToPay(SalesHeader);
            NpCsDocument.Modify();
        end else
            //End sale
            POSSale.SelectViewForEndOfSale(POSSession);

        NpCsWorkflowMgt.ScheduleRunWorkflow(NpCsDocument);
    end;

    local procedure ExportToDocument(Context: Codeunit "NPR POS JSON Management"; POSSession: Codeunit "NPR POS Session"; RetailSalesDocMgt: Codeunit "NPR Sales Doc. Exp. Mgt.")
    var
        SalePOS: Record "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSSale: Codeunit "NPR POS Sale";
        CustomerNo: Text;
        PrevRec: Text;
    begin
        POSSession.GetSale(POSSale);
        POSSession.GetSaleLine(POSSaleLine);
        POSSale.GetCurrentSale(SalePOS);

        PrevRec := Format(SalePOS);

        SalePOS."External Document No." := SalePOS."Sales Ticket No.";
        SalePOS.Reference := SalePOS."Sales Ticket No.";
        CustomerNo := Context.GetString('customerNo');
        SalePOS.Validate("Customer Type", SalePOS."Customer Type"::Ord);
        SalePOS.Validate("Customer No.", CustomerNo);
        SalePOS.TestField("Customer No.");

        if PrevRec <> Format(SalePOS) then
            SalePOS.Modify(true);
        Commit();

        SetParameters(POSSaleLine, RetailSalesDocMgt, Context);
        RetailSalesDocMgt.TestSalePOS(SalePOS);
        RetailSalesDocMgt.ProcessPOSSale(SalePOS);
    end;

    local procedure SetParameters(var POSSaleLine: Codeunit "NPR POS Sale Line"; var RetailSalesDocMgt: Codeunit "NPR Sales Doc. Exp. Mgt."; Context: Codeunit "NPR POS JSON Management")
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
        RetailSalesDocMgt.SetCustomerCreditCheck(Context.GetBooleanParameter('checkCustomerCredit'));

        POSSaleLine.CalculateBalance(AmountExclVAT, VATAmount, AmountInclVAT);
        RetailSalesDocMgt.SetDocumentTypeOrder();
    end;

    local procedure HandlePrepayment(Context: Codeunit "NPR POS JSON Management"; POSSession: Codeunit "NPR POS Session"; RetailSalesDocMgt: Codeunit "NPR Sales Doc. Exp. Mgt."; PrepaymentPct: Decimal; PrintPrepaymentInvoice: Boolean; PreviousSalePOS: Record "NPR POS Sale")
    var
        HandlePrepmtCU: Codeunit "NPR NpCs Cr.Ord: Handle Prepmt";
    begin
        //An error after sale end, before front end sync, is not allowed.
        Commit();
        ClearLastError();
        Clear(HandlePrepmtCU);
        HandlePrepmtCU.SetParameters(POSSession, RetailSalesDocMgt, PrepaymentPct, PrintPrepaymentInvoice, PreviousSalePOS);
        if not HandlePrepmtCU.Run() then begin
            Context.SetContext('HandlePrepaymentFailed', true);
            Context.SetContext('HandlePrepaymentFailReasonMsg', Strsubstno(PrepaymentFailedLbl, GetLastErrorText()));
        end;
    end;
}