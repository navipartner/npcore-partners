codeunit 6014471 "NPR UPG Master Line Map"
{
    Subtype = Upgrade;

    var
        MasterLineMapMgt: Codeunit "NPR Master Line Map Mgt.";

    trigger OnUpgradePerCompany()
    begin
        Upgrade();
    end;

    local procedure Upgrade()
    var
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgradeTagLbl: Label 'NPRPUGMasterLineMap_Upgrade-20210312', Locked = true;
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagLbl) then
            exit;

        UpgradeItemJournalLineMasterLineData();
        UpgradePurchaseLineMasterLineData();
        UpgradePurchasePriceMasterLineData();
        UpgradeSalesLineMasterLineData();
        UpgradeSalesPriceMasterLineData();
        UpgradeTransferLineMasterLineData();
        UpgradeItemReplByStoreMasterLineData();
        UpgradeRetailJournalLineMasterLineData();

        UpgradeTag.SetUpgradeTag(UpgradeTagLbl);
    end;

    local procedure UpgradeItemJournalLineMasterLineData()
    var
        MasterItemJournalLine: Record "Item Journal Line";
        ItemJournalLine: Record "Item Journal Line";
    begin
        MasterItemJournalLine.SetRange("NPR Is Master", true);
        if MasterItemJournalLine.FindSet() then
            repeat
                MasterLineMapMgt.CreateMap(Database::"Item Journal Line", MasterItemJournalLine.SystemId, MasterItemJournalLine.SystemId);

                ItemJournalLine.SetRange("Journal Template Name", MasterItemJournalLine."Journal Template Name");
                ItemJournalLine.SetRange("Journal Batch Name", MasterItemJournalLine."Journal Batch Name");
                ItemJournalLine.SetRange("NPR Master Line No.", MasterItemJournalLine."Line No.");
                ItemJournalLine.SetRange("NPR Is Master", false);
                if ItemJournalLine.FindSet() then
                    repeat
                        MasterLineMapMgt.CreateMap(Database::"Item Journal Line", ItemJournalLine.SystemId, MasterItemJournalLine.SystemId);
                    until ItemJournalLine.Next() = 0;
            until MasterItemJournalLine.Next() = 0;
    end;

    local procedure UpgradePurchaseLineMasterLineData()
    var
        MasterPurchaseLine: Record "Purchase Line";
        PurchaseLine: Record "Purchase Line";
    begin
        MasterPurchaseLine.SetRange("NPR Is Master", true);
        if MasterPurchaseLine.FindSet() then
            repeat
                MasterLineMapMgt.CreateMap(Database::"Purchase Line", MasterPurchaseLine.SystemId, MasterPurchaseLine.SystemId);

                PurchaseLine.SetRange("Document Type", MasterPurchaseLine."Document Type");
                PurchaseLine.SetRange("Document No.", MasterPurchaseLine."Document No.");
                PurchaseLine.SetRange("NPR Master Line No.", MasterPurchaseLine."Line No.");
                PurchaseLine.SetRange("NPR Is Master", false);
                if PurchaseLine.FindSet() then
                    repeat
                        MasterLineMapMgt.CreateMap(Database::"Purchase Line", PurchaseLine.SystemId, MasterPurchaseLine.SystemId);
                    until PurchaseLine.Next() = 0;
            until MasterPurchaseLine.Next() = 0;
    end;

    local procedure UpgradePurchasePriceMasterLineData()
    var
        MasterPurchasePrice: Record "Purchase Price";
        PurchasePrice: Record "Purchase Price";
    begin
        MasterPurchasePrice.SetRange("NPR Is Master", true);
        if MasterPurchasePrice.FindSet() then
            repeat
                MasterLineMapMgt.CreateMap(Database::"Purchase Price", MasterPurchasePrice.SystemId, MasterPurchasePrice.SystemId);

                PurchasePrice.SetRange("NPR Master Record Reference", MasterPurchasePrice.GetPosition(false));
                PurchasePrice.SetRange("NPR Is Master", false);
                if PurchasePrice.FindSet() then
                    repeat
                        MasterLineMapMgt.CreateMap(Database::"Purchase Price", PurchasePrice.SystemId, MasterPurchasePrice.SystemId);
                    until PurchasePrice.Next() = 0;
            until MasterPurchasePrice.Next() = 0;
    end;

    local procedure UpgradeSalesLineMasterLineData()
    var
        MasterSalesLine: Record "Sales Line";
        SalesLine: Record "Sales Line";
    begin
        MasterSalesLine.SetRange("NPR Is Master", true);
        if MasterSalesLine.FindSet() then
            repeat
                MasterLineMapMgt.CreateMap(Database::"Sales Line", MasterSalesLine.SystemId, MasterSalesLine.SystemId);

                SalesLine.SetRange("Document Type", MasterSalesLine."Document Type");
                SalesLine.SetRange("Document No.", MasterSalesLine."Document No.");
                SalesLine.SetRange("NPR Master Line No.", MasterSalesLine."Line No.");
                SalesLine.SetRange("NPR Is Master", false);
                if SalesLine.FindSet() then
                    repeat
                        MasterLineMapMgt.CreateMap(Database::"Sales Line", SalesLine.SystemId, MasterSalesLine.SystemId);
                    until SalesLine.Next() = 0;
            until MasterSalesLine.Next() = 0;
    end;

    local procedure UpgradeSalesPriceMasterLineData()
    var
        MasterSalesPrice: Record "Sales Price";
        SalesPrice: Record "Sales Price";
    begin
        MasterSalesPrice.SetRange("NPR Is Master", true);
        if MasterSalesPrice.FindSet() then
            repeat
                MasterLineMapMgt.CreateMap(Database::"Sales Price", MasterSalesPrice.SystemId, MasterSalesPrice.SystemId);

                SalesPrice.SetRange("NPR Master Record Reference", MasterSalesPrice.GetPosition(false));
                SalesPrice.SetRange("NPR Is Master", false);
                if SalesPrice.FindSet() then
                    repeat
                        MasterLineMapMgt.CreateMap(Database::"Sales Price", SalesPrice.SystemId, MasterSalesPrice.SystemId);
                    until SalesPrice.Next() = 0;
            until MasterSalesPrice.Next() = 0;
    end;

    local procedure UpgradeTransferLineMasterLineData()
    var
        MasterTransferLine: Record "Transfer Line";
        TransferLine: Record "Transfer Line";
    begin
        MasterTransferLine.SetRange("NPR Is Master", true);
        if MasterTransferLine.FindSet() then
            repeat
                MasterLineMapMgt.CreateMap(Database::"Transfer Line", MasterTransferLine.SystemId, MasterTransferLine.SystemId);

                TransferLine.SetRange("Document No.", MasterTransferLine."Document No.");
                TransferLine.SetRange("NPR Master Line No.", MasterTransferLine."Line No.");
                TransferLine.SetRange("NPR Is Master", false);
                if TransferLine.FindSet() then
                    repeat
                        MasterLineMapMgt.CreateMap(Database::"Transfer Line", TransferLine.SystemId, MasterTransferLine.SystemId);
                    until TransferLine.Next() = 0;
            until MasterTransferLine.Next() = 0;
    end;

    local procedure UpgradeItemReplByStoreMasterLineData()
    var
        MasterItemReplByStore: Record "NPR Item Repl. by Store";
        ItemReplByStore: Record "NPR Item Repl. by Store";
    begin
        MasterItemReplByStore.SetRange("Is Master", true);
        if MasterItemReplByStore.FindSet() then
            repeat
                MasterLineMapMgt.CreateMap(Database::"NPR Item Repl. by Store", MasterItemReplByStore.SystemId, MasterItemReplByStore.SystemId);

                ItemReplByStore.SetRange("Master Record Reference", MasterItemReplByStore.GetPosition(false));
                ItemReplByStore.SetRange("Is Master", false);
                if ItemReplByStore.FindSet() then
                    repeat
                        MasterLineMapMgt.CreateMap(Database::"NPR Item Repl. by Store", ItemReplByStore.SystemId, MasterItemReplByStore.SystemId);
                    until ItemReplByStore.Next() = 0;
            until MasterItemReplByStore.Next() = 0;
    end;

    local procedure UpgradeRetailJournalLineMasterLineData()
    var
        MasterRetailJournalLine: Record "NPR Retail Journal Line";
        RetailJournalLine: Record "NPR Retail Journal Line";
    begin
        MasterRetailJournalLine.SetRange("Is Master", true);
        if MasterRetailJournalLine.FindSet() then
            repeat
                MasterLineMapMgt.CreateMap(Database::"NPR Retail Journal Line", MasterRetailJournalLine.SystemId, MasterRetailJournalLine.SystemId);

                RetailJournalLine.SetRange("No.", MasterRetailJournalLine."No.");
                RetailJournalLine.SetRange("Master Line No.", MasterRetailJournalLine."Line No.");
                RetailJournalLine.SetRange("Is Master", false);
                if RetailJournalLine.FindSet() then
                    repeat
                        MasterLineMapMgt.CreateMap(Database::"NPR Retail Journal Line", RetailJournalLine.SystemId, MasterRetailJournalLine.SystemId);
                    until RetailJournalLine.Next() = 0;
            until MasterRetailJournalLine.Next() = 0;
    end;
}
