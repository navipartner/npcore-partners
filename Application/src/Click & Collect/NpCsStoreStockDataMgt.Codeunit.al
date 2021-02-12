codeunit 6151222 "NPR NpCs Store Stock Data Mgt."
{
    TableNo = "NPR Data Log Record";

    trigger OnRun()
    var
        TempStockkeepingUnit: Record "Stockkeeping Unit" temporary;
    begin
        if not StoreStockEnabled() then
            exit;
        if not FindSKUs(Rec, TempStockkeepingUnit) then
            exit;

        if TempStockkeepingUnit.FindSet then
            repeat
                RegisterStoreStocks(TempStockkeepingUnit);
            until TempStockkeepingUnit.Next = 0;
    end;

    [EventSubscriber(ObjectType::Table, 6151222, 'OnAfterModifyEvent', '', true, true)]
    local procedure OnAfterModifyStoreStockSetup(var Rec: Record "NPR NpCs Store Stock Setup"; var xRec: Record "NPR NpCs Store Stock Setup"; RunTrigger: Boolean)
    begin
        if not RunTrigger then
            exit;

        if Rec.IsTemporary then
            exit;

        if xRec."Store Stock Enabled" then
            exit;
        if not Rec."Store Stock Enabled" then
            exit;

        InitODataServices();
        InitDataLogSetup();
    end;

    local procedure InitODataServices()
    var
        Company: Record Company;
        NpCsStore: Record "NPR NpCs Store";
        WebService: Record "Web Service";
        Url: Text;
        PrevRec: Text;
    begin
        if (GetStoreStockItemUrl(CompanyName) = '') and not WebService.Get(WebService."Object Type"::Page, 'collect_store_stock_items') then begin
            WebService.Init;
            WebService."Object Type" := WebService."Object Type"::Page;
            WebService."Object ID" := PAGE::"NPR NpCs Store Stock Items";
            WebService."Service Name" := 'collect_store_stock_items';
            WebService.Published := true;
            WebService.Insert(true);
        end;

        if (GetStoreStockStatusUrl(CompanyName) = '') and not WebService.Get(WebService."Object Type"::Query, 'collect_store_stock_status') then begin
            WebService.Init;
            WebService."Object Type" := WebService."Object Type"::Query;
            WebService."Object ID" := QUERY::"NPR NpCs Store Stock Status";
            WebService."Service Name" := 'collect_store_stock_status';
            WebService.Published := true;
            WebService.Insert(true);
        end;

        if NpCsStore.FindSet then
            repeat
                if Company.Get(NpCsStore."Company Name") then begin
                    PrevRec := Format(NpCsStore);

                    NpCsStore."Store Stock Item Url" := GetStoreStockItemUrl(Company.Name);
                    NpCsStore."Store Stock Status Url" := GetStoreStockStatusUrl(Company.Name);

                    if PrevRec <> Format(NpCsStore) then
                        NpCsStore.Modify(true);
                end;
            until NpCsStore.Next = 0;
    end;

    local procedure InitDataLogSetup()
    begin
        InitDataLogSetupTable(DATABASE::"Item Ledger Entry", true, false, false);
        InitDataLogSetupTable(DATABASE::"Sales Line", true, true, true);
    end;

    local procedure InitDataLogSetupTable(TableId: Integer; InsertTrigger: Boolean; ModifyTrigger: Boolean; DeleteTrigger: Boolean)
    var
        DataLogSetup: Record "NPR Data Log Setup (Table)";
        DataLogSubscriber: Record "NPR Data Log Subscriber";
        TableMetadata: Record "Table Metadata";
        PrevRec: Text;
        SubscriberCode: Code[30];
    begin
        if not TableMetadata.Get(TableId) then
            exit;

        if not DataLogSetup.Get(TableMetadata.ID) then begin
            DataLogSetup.Init;
            DataLogSetup."Table ID" := TableMetadata.ID;
            if InsertTrigger then
                DataLogSetup."Log Insertion" := DataLogSetup."Log Insertion"::Simple;
            if ModifyTrigger then
                DataLogSetup."Log Modification" := DataLogSetup."Log Modification"::Simple;
            if DeleteTrigger then
                DataLogSetup."Log Deletion" := DataLogSetup."Log Deletion"::Detailed;
            DataLogSetup."Keep Log for" := CurrentDateTime - CreateDateTime(CalcDate('<-30D>', Today), Time);
            DataLogSetup.Insert(true);
        end;

        PrevRec := Format(DataLogSetup);

        if InsertTrigger and (DataLogSetup."Log Insertion" < DataLogSetup."Log Insertion"::Simple) then
            DataLogSetup."Log Insertion" := DataLogSetup."Log Insertion"::Simple;
        if ModifyTrigger and (DataLogSetup."Log Modification" < DataLogSetup."Log Modification"::Simple) then
            DataLogSetup."Log Modification" := DataLogSetup."Log Modification"::Simple;
        if DeleteTrigger and (DataLogSetup."Log Deletion" < DataLogSetup."Log Deletion"::Detailed) then
            DataLogSetup."Log Deletion" := DataLogSetup."Log Deletion"::Detailed;

        if PrevRec <> Format(DataLogSetup) then
            DataLogSetup.Modify(true);

        SubscriberCode := 'STORE_STOCK';
        if not DataLogSubscriber.Get(SubscriberCode, TableMetadata.ID, '') then begin
            DataLogSubscriber.Init;
            DataLogSubscriber.Code := SubscriberCode;
            DataLogSubscriber."Table ID" := TableMetadata.ID;
            DataLogSubscriber."Company Name" := '';
            DataLogSubscriber."Data Processing Codeunit ID" := CurrCodeunitId();
            DataLogSubscriber."Direct Data Processing" := false;
            DataLogSubscriber."Delayed Data Processing (sec)" := 10;
            DataLogSubscriber."Failure Codeunit ID" := 0;
            DataLogSubscriber.Insert(true);
        end;

        PrevRec := Format(DataLogSubscriber);

        DataLogSubscriber."Data Processing Codeunit ID" := CurrCodeunitId();
        DataLogSubscriber."Direct Data Processing" := false;
        DataLogSubscriber."Delayed Data Processing (sec)" := 10;
        DataLogSubscriber."Failure Codeunit ID" := 0;

        if PrevRec <> Format(DataLogSubscriber) then
            DataLogSubscriber.Modify(true);
    end;

    local procedure FindSKUs(DataLogRecord: Record "NPR Data Log Record"; var TempStockkeepingUnit: Record "Stockkeeping Unit" temporary): Boolean
    var
        ItemLedgEntry: Record "Item Ledger Entry";
        SalesLine: Record "Sales Line";
        DataLogSubscriberMgt: Codeunit "NPR Data Log Sub. Mgt.";
        RecRef: RecordRef;
    begin
        if not TempStockkeepingUnit.IsTemporary then
            exit(false);
        Clear(TempStockkeepingUnit);
        TempStockkeepingUnit.DeleteAll;

        if not DataLogSubscriberMgt.RestoreRecordToRecRef(DataLogRecord."Entry No.", false, RecRef) then
            exit(false);

        case RecRef.Number of
            DATABASE::"Item Ledger Entry":
                begin
                    RecRef.SetTable(ItemLedgEntry);
                    TempStockkeepingUnit.Init;
                    TempStockkeepingUnit."Item No." := ItemLedgEntry."Item No.";
                    TempStockkeepingUnit."Variant Code" := ItemLedgEntry."Variant Code";
                    TempStockkeepingUnit."Location Code" := ItemLedgEntry."Location Code";
                    TempStockkeepingUnit.Insert;
                    exit(true);
                end;
            DATABASE::"Sales Line":
                begin
                    RecRef.SetTable(SalesLine);
                    if SalesLine."Document Type" <> SalesLine."Document Type"::Order then
                        exit(false);
                    if SalesLine.Type <> SalesLine.Type::Item then
                        exit(false);
                    if SalesLine."No." = '' then
                        exit(false);

                    TempStockkeepingUnit.Init;
                    TempStockkeepingUnit."Item No." := SalesLine."No.";
                    TempStockkeepingUnit."Variant Code" := SalesLine."Variant Code";
                    TempStockkeepingUnit."Location Code" := SalesLine."Location Code";
                    TempStockkeepingUnit.Insert;

                    DataLogSubscriberMgt.RestoreRecordToRecRef(DataLogRecord."Entry No.", true, RecRef);
                    RecRef.SetTable(SalesLine);
                    if (SalesLine.Type = SalesLine.Type::Item) and (SalesLine."No." <> '') and
                      not TempStockkeepingUnit.Get(SalesLine."Location Code", SalesLine."No.", SalesLine."Variant Code")
                    then begin
                        TempStockkeepingUnit.Init;
                        TempStockkeepingUnit."Item No." := SalesLine."No.";
                        TempStockkeepingUnit."Variant Code" := SalesLine."Variant Code";
                        TempStockkeepingUnit."Location Code" := SalesLine."Location Code";
                        TempStockkeepingUnit.Insert;
                    end;
                    exit(true);
                end;
        end;

        exit(false);
    end;

    local procedure RegisterStoreStocks(TempStockkeepingUnit: Record "Stockkeeping Unit" temporary)
    var
        ItemVariant: Record "Item Variant";
        NpCsStore: Record "NPR NpCs Store";
    begin
        if TempStockkeepingUnit."Variant Code" = '' then begin
            ItemVariant.SetRange("Item No.", TempStockkeepingUnit."Item No.");
            ItemVariant.SetRange("NPR Blocked", false);
            if ItemVariant.FindFirst then
                exit;
        end;

        NpCsStore.SetRange("Local Store", true);
        NpCsStore.SetRange("Location Code", TempStockkeepingUnit."Location Code");
        if NpCsStore.IsEmpty then
            exit;

        NpCsStore.FindSet;
        repeat
            RegisterStoreStock(NpCsStore, TempStockkeepingUnit);
        until NpCsStore.Next = 0;
    end;

    local procedure RegisterStoreStock(NpCsStore: Record "NPR NpCs Store"; TempStockkeepingUnit: Record "Stockkeeping Unit" temporary)
    var
        Item: Record Item;
        NpCsStoreStockItem: Record "NPR NpCs Store Stock Item";
        StockQty: Decimal;
    begin
        if NpCsStore."Location Code" <> TempStockkeepingUnit."Location Code" then
            exit;
        if not Item.Get(TempStockkeepingUnit."Item No.") then
            exit;
        Item.SetRange("Variant Filter", TempStockkeepingUnit."Variant Code");
        Item.SetRange("Location Filter", TempStockkeepingUnit."Location Code");
        Item.CalcFields(Inventory, "Qty. on Sales Order");
        StockQty := Item.Inventory - Item."Qty. on Sales Order";

        NpCsStoreStockItem.LockTable;
        if not NpCsStoreStockItem.Get(NpCsStore.Code, TempStockkeepingUnit."Item No.", TempStockkeepingUnit."Variant Code") then begin
            NpCsStoreStockItem.Init;
            NpCsStoreStockItem."Store Code" := NpCsStore.Code;
            NpCsStoreStockItem."Item No." := TempStockkeepingUnit."Item No.";
            NpCsStoreStockItem."Variant Code" := TempStockkeepingUnit."Variant Code";
            NpCsStoreStockItem."Stock Qty." := StockQty;
            NpCsStoreStockItem.Insert(true);
        end else
            if NpCsStoreStockItem."Stock Qty." <> StockQty then begin
                NpCsStoreStockItem."Stock Qty." := StockQty;
                NpCsStoreStockItem.Modify(true);
            end;
        Commit;
    end;

    procedure InitStoreStockItems()
    var
        Item: Record Item;
        NpCsStore: Record "NPR NpCs Store";
        TempNpCsStore: Record "NPR NpCs Store" temporary;
    begin
        if not StoreStockEnabled() then
            exit;

        NpCsStore.SetRange("Local Store", true);
        if not NpCsStore.FindSet then
            exit;
        repeat
            TempNpCsStore.Init;
            TempNpCsStore := NpCsStore;
            TempNpCsStore.Insert;
        until NpCsStore.Next = 0;

        if not Item.FindSet then
            exit;

        repeat
            InitStoreStockItem(TempNpCsStore, Item);
        until Item.Next = 0;
    end;

    local procedure InitStoreStockItem(var TempNpCsStore: Record "NPR NpCs Store" temporary; Item: Record Item)
    var
        ItemVariant: Record "Item Variant";
        TempStockkeepingUnit: Record "Stockkeeping Unit" temporary;
        NpCsStoreStockDataMgt: Codeunit "NPR NpCs Store Stock Data Mgt.";
    begin
        ItemVariant.SetRange("Item No.", Item."No.");
        ItemVariant.SetRange("NPR Blocked", false);
        if ItemVariant.IsEmpty then begin
            TempNpCsStore.FindSet;
            repeat
                TempStockkeepingUnit.Init;
                TempStockkeepingUnit."Item No." := Item."No.";
                TempStockkeepingUnit."Variant Code" := '';
                TempStockkeepingUnit."Location Code" := TempNpCsStore."Location Code";
                RegisterStoreStock(TempNpCsStore, TempStockkeepingUnit);
            until TempNpCsStore.Next = 0;

            exit;
        end;

        ItemVariant.FindSet;
        repeat
            TempNpCsStore.FindSet;
            repeat
                TempStockkeepingUnit.Init;
                TempStockkeepingUnit."Item No." := Item."No.";
                TempStockkeepingUnit."Variant Code" := ItemVariant.Code;
                TempStockkeepingUnit."Location Code" := TempNpCsStore."Location Code";
                RegisterStoreStock(TempNpCsStore, TempStockkeepingUnit);
            until TempNpCsStore.Next = 0;
        until ItemVariant.Next = 0;
    end;

    local procedure StoreStockEnabled(): Boolean
    var
        NpCsStoreStockSetup: Record "NPR NpCs Store Stock Setup";
    begin
        if not NpCsStoreStockSetup.Get then
            exit;

        exit(NpCsStoreStockSetup."Store Stock Enabled");
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(CODEUNIT::"NPR NpCs Store Stock Data Mgt.");
    end;

    procedure GetStoreStockItemUrl(ServiceCompany: Text): Text
    begin
        exit(GetUrl(CLIENTTYPE::ODataV4, ServiceCompany, OBJECTTYPE::Page, PAGE::"NPR NpCs Store Stock Items"));
    end;

    procedure GetStoreStockStatusUrl(ServiceCompany: Text): Text
    begin
        exit(GetUrl(CLIENTTYPE::ODataV4, ServiceCompany, OBJECTTYPE::Query, QUERY::"NPR NpCs Store Stock Status"));
    end;
}