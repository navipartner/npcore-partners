codeunit 6150918 "NPR UPG Vend Item No Expansion"
{
    Access = Internal;
    Subtype = Upgrade;

    var
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgTagDef: Codeunit "NPR Upgrade Tag Definitions";

    trigger OnUpgradePerCompany()
    begin
        UpgradeDataInItemWorksheetLine();
        UpgradeDataInRegistItemWorkshLine();
        UpgradeDataInRetailCampaignItems();
        UpgradeDataInMixedDiscountLine();
        UpgradeDataInPeriodDiscountLine();
        UpgradeDataInRetailReplDemandLine();
        UpgradeDataInItemWorksheetExcelColumn();
        UpgradeDataInItemWorksheetFieldSetup();
    end;

    local procedure UpgradeDataInItemWorksheetLine()
    var
        NPRItemWorksheetLine: Record "NPR Item Worksheet Line";
#if not (BC17 or BC18 or BC19 or BC20)
        TableDataTransfer: DataTransfer;
#endif
    begin
        if UpgradeTag.HasUpgradeTag(UpgTagDef.GetUpgradeTag(CurrCodeunitId(), 'ItemWorksheetLine')) then
            exit;
#if (BC17 or BC18 or BC19 or BC20)
        NPRItemWorksheetLine.SetLoadFields("Vendor Item No.", "Vend Item No.");
        NPRItemWorksheetLine.SetFilter("Vendor Item No.", '<>%1', '');
        if NPRItemWorksheetLine.FindSet() then
            repeat
                NPRItemWorksheetLine."Vend Item No." := NPRItemWorksheetLine."Vendor Item No.";
                NPRItemWorksheetLine.Modify();
            until NPRItemWorksheetLine.Next() = 0;
#else
        TableDataTransfer.SetTables(Database::"NPR Item Worksheet Line", Database::"NPR Item Worksheet Line");
        TableDataTransfer.AddSourceFilter(NPRItemWorksheetLine.FieldNo("Vendor Item No."), '<>%1', '');
        TableDataTransfer.AddFieldValue(NPRItemWorksheetLine.FieldNo("Vendor Item No."), NPRItemWorksheetLine.FieldNo("Vend Item No."));
        TableDataTransfer.CopyFields();
#endif
        UpgradeTag.SetUpgradeTag(UpgTagDef.GetUpgradeTag(CurrCodeunitId(), 'ItemWorksheetLine'));
    end;

    local procedure UpgradeDataInRegistItemWorkshLine()
    var
        NPRRegistItemWorkshLine: Record "NPR Regist. Item Worksh Line";
#if not (BC17 or BC18 or BC19 or BC20)
        TableDataTransfer: DataTransfer;
#endif
    begin
        if UpgradeTag.HasUpgradeTag(UpgTagDef.GetUpgradeTag(CurrCodeunitId(), 'RegistItemWorkshLine')) then
            exit;

#if (BC17 or BC18 or BC19 or BC20)
        NPRRegistItemWorkshLine.SetLoadFields("Vendor Item No.", "Vend Item No.");
        NPRRegistItemWorkshLine.SetFilter("Vendor Item No.", '<>%1', '');
        if NPRRegistItemWorkshLine.FindSet() then
            repeat
                NPRRegistItemWorkshLine."Vend Item No." := NPRRegistItemWorkshLine."Vendor Item No.";
                NPRRegistItemWorkshLine.Modify();
            until NPRRegistItemWorkshLine.Next() = 0;
#else
        TableDataTransfer.SetTables(Database::"NPR Regist. Item Worksh Line", Database::"NPR Regist. Item Worksh Line");
        TableDataTransfer.AddSourceFilter(NPRRegistItemWorkshLine.FieldNo("Vendor Item No."), '<>%1', '');
        TableDataTransfer.AddFieldValue(NPRRegistItemWorkshLine.FieldNo("Vendor Item No."), NPRRegistItemWorkshLine.FieldNo("Vend Item No."));
        TableDataTransfer.CopyFields();
#endif
        UpgradeTag.SetUpgradeTag(UpgTagDef.GetUpgradeTag(CurrCodeunitId(), 'RegistItemWorkshLine'));
    end;

    local procedure UpgradeDataInRetailCampaignItems()
    var
        NPRRetailCampaignItems: Record "NPR Retail Campaign Items";
#if not (BC17 or BC18 or BC19 or BC20)
        TableDataTransfer: DataTransfer;
#endif
    begin
        if UpgradeTag.HasUpgradeTag(UpgTagDef.GetUpgradeTag(CurrCodeunitId(), 'RetailCampaignItems')) then
            exit;
#if (BC17 or BC18 or BC19 or BC20)
        NPRRetailCampaignItems.SetLoadFields("Vendor Item No.", "Vend Item No.");
        NPRRetailCampaignItems.SetFilter("Vendor Item No.", '<>%1', '');
        if NPRRetailCampaignItems.FindSet() then
            repeat
                NPRRetailCampaignItems."Vend Item No." := NPRRetailCampaignItems."Vendor Item No.";
                NPRRetailCampaignItems.Modify();
            until NPRRetailCampaignItems.Next() = 0;
#else
        TableDataTransfer.SetTables(Database::"NPR Retail Campaign Items", Database::"NPR Retail Campaign Items");
        TableDataTransfer.AddSourceFilter(NPRRetailCampaignItems.FieldNo("Vendor Item No."), '<>%1', '');
        TableDataTransfer.AddFieldValue(NPRRetailCampaignItems.FieldNo("Vendor Item No."), NPRRetailCampaignItems.FieldNo("Vend Item No."));
        TableDataTransfer.CopyFields();
#endif
        UpgradeTag.SetUpgradeTag(UpgTagDef.GetUpgradeTag(CurrCodeunitId(), 'RetailCampaignItems'));
    end;

    local procedure UpgradeDataInMixedDiscountLine()
    var
        NPRMixedDiscountLine: Record "NPR Mixed Discount Line";
#if not (BC17 or BC18 or BC19 or BC20)
        TableDataTransfer: DataTransfer;
#endif
    begin
        if UpgradeTag.HasUpgradeTag(UpgTagDef.GetUpgradeTag(CurrCodeunitId(), 'MixedDiscountLine')) then
            exit;
#if (BC17 or BC18 or BC19 or BC20)
        NPRMixedDiscountLine.SetLoadFields("Disc. Grouping Type", "Variant Code", "Vendor Item No.", "Vend Item No.");
        NPRMixedDiscountLine.SetFilter("Vendor Item No.", '<>%1', '');
        if NPRMixedDiscountLine.FindSet() then
            repeat
                NPRMixedDiscountLine."Vend Item No." := NPRMixedDiscountLine."Vendor Item No.";
                NPRMixedDiscountLine.Modify();
            until NPRMixedDiscountLine.Next() = 0;
#else
        TableDataTransfer.SetTables(Database::"NPR Mixed Discount Line", Database::"NPR Mixed Discount Line");
        TableDataTransfer.AddSourceFilter(NPRMixedDiscountLine.FieldNo("Vendor Item No."), '<>%1', '');
        TableDataTransfer.AddFieldValue(NPRMixedDiscountLine.FieldNo("Vendor Item No."), NPRMixedDiscountLine.FieldNo("Vend Item No."));
        TableDataTransfer.CopyFields();
#endif
        UpgradeTag.SetUpgradeTag(UpgTagDef.GetUpgradeTag(CurrCodeunitId(), 'MixedDiscountLine'));
    end;

    local procedure UpgradeDataInPeriodDiscountLine()
    var
        NPRPeriodDiscountLine: Record "NPR Period Discount Line";
#if not (BC17 or BC18 or BC19 or BC20)
        TableDataTransfer: DataTransfer;
#endif
    begin
        if UpgradeTag.HasUpgradeTag(UpgTagDef.GetUpgradeTag(CurrCodeunitId(), 'PeriodDiscountLine')) then
            exit;
#if (BC17 or BC18 or BC19 or BC20)
        NPRPeriodDiscountLine.SetLoadFields("Variant Code", "Vendor Item No.", "Vend Item No.");
        NPRPeriodDiscountLine.SetFilter("Vendor Item No.", '<>%1', '');
        if NPRPeriodDiscountLine.FindSet() then
            repeat
                NPRPeriodDiscountLine."Vend Item No." := NPRPeriodDiscountLine."Vendor Item No.";
                NPRPeriodDiscountLine.Modify();
            until NPRPeriodDiscountLine.Next() = 0;
#else
        TableDataTransfer.SetTables(Database::"NPR Period Discount Line", Database::"NPR Period Discount Line");
        TableDataTransfer.AddSourceFilter(NPRPeriodDiscountLine.FieldNo("Vendor Item No."), '<>%1', '');
        TableDataTransfer.AddFieldValue(NPRPeriodDiscountLine.FieldNo("Vendor Item No."), NPRPeriodDiscountLine.FieldNo("Vend Item No."));
        TableDataTransfer.CopyFields();
#endif
        UpgradeTag.SetUpgradeTag(UpgTagDef.GetUpgradeTag(CurrCodeunitId(), 'PeriodDiscountLine'));
    end;

    local procedure UpgradeDataInRetailReplDemandLine()
    var
        NPRRetailReplDemandLine: Record "NPR Retail Repl. Demand Line";
#if not (BC17 or BC18 or BC19 or BC20)
        TableDataTransfer: DataTransfer;
#endif
    begin
        if UpgradeTag.HasUpgradeTag(UpgTagDef.GetUpgradeTag(CurrCodeunitId(), 'RetailReplDemandLine')) then
            exit;
#if (BC17 or BC18 or BC19 or BC20)
        NPRRetailReplDemandLine.SetLoadFields("Vendor Item No.", "Vend Item No.");
        NPRRetailReplDemandLine.SetFilter("Vendor Item No.", '<>%1', '');
        if NPRRetailReplDemandLine.FindSet() then
            repeat
                NPRRetailReplDemandLine."Vend Item No." := NPRRetailReplDemandLine."Vendor Item No.";
                NPRRetailReplDemandLine.Modify();
            until NPRRetailReplDemandLine.Next() = 0;
#else
        TableDataTransfer.SetTables(Database::"NPR Retail Repl. Demand Line", Database::"NPR Retail Repl. Demand Line");
        TableDataTransfer.AddSourceFilter(NPRRetailReplDemandLine.FieldNo("Vendor Item No."), '<>%1', '');
        TableDataTransfer.AddFieldValue(NPRRetailReplDemandLine.FieldNo("Vendor Item No."), NPRRetailReplDemandLine.FieldNo("Vend Item No."));
        TableDataTransfer.CopyFields();
#endif
        UpgradeTag.SetUpgradeTag(UpgTagDef.GetUpgradeTag(CurrCodeunitId(), 'RetailReplDemandLine'));
    end;

    local procedure UpgradeDataInItemWorksheetExcelColumn()
    var
        NPRItemWorkshExcelColumn: Record "NPR Item Worksh. Excel Column";
        NPRItemWorksheetLine: Record "NPR Item Worksheet Line";
    begin
        if UpgradeTag.HasUpgradeTag(UpgTagDef.GetUpgradeTag(CurrCodeunitId(), 'ItemWorksheetExcelColumn')) then
            exit;

        NPRItemWorkshExcelColumn.SetLoadFields("Worksheet Template Name", "Worksheet Name", "Excel Column No.", "Map to Table No.", "Map to Field Number", "Map to Field Name", "Map to Caption");
        NPRItemWorkshExcelColumn.SetRange("Map to Table No.", Database::"NPR Item Worksheet Line");
        NPRItemWorkshExcelColumn.SetRange("Map to Field Number", NPRItemWorksheetLine.FieldNo("Vendor Item No."));
        if NPRItemWorkshExcelColumn.FindSet() then
            repeat
                NPRItemWorkshExcelColumn."Map to Field Number" := NPRItemWorksheetLine.FieldNo("Vend Item No.");
                NPRItemWorkshExcelColumn."Map to Field Name" := CopyStr(NPRItemWorksheetLine.FieldName("Vend Item No."), 1, MaxStrLen(NPRItemWorkshExcelColumn."Map to Field Name"));
                NPRItemWorkshExcelColumn."Map to Caption" := CopyStr(NPRItemWorksheetLine.FieldCaption("Vend Item No."), 1, MaxStrLen(NPRItemWorkshExcelColumn."Map to Caption"));
                NPRItemWorkshExcelColumn.Modify();
            until NPRItemWorkshExcelColumn.Next() = 0;

        UpgradeTag.SetUpgradeTag(UpgTagDef.GetUpgradeTag(CurrCodeunitId(), 'ItemWorksheetExcelColumn'));
    end;

    local procedure UpgradeDataInItemWorksheetFieldSetup()
    var
        NPRItemWorkshFieldSetup: Record "NPR Item Worksh. Field Setup";
        NPRItemWorkshFieldSetup2: Record "NPR Item Worksh. Field Setup";
        NPRItemWorksheetLine: Record "NPR Item Worksheet Line";
    begin
        if UpgradeTag.HasUpgradeTag(UpgTagDef.GetUpgradeTag(CurrCodeunitId(), 'ItemWorksheetFieldSetup')) then
            exit;

        NPRItemWorkshFieldSetup.SetLoadFields("Worksheet Template Name", "Worksheet Name", "Table No.", "Field Number", "Field Name", "Field Caption");
        NPRItemWorkshFieldSetup.SetRange("Table No.", Database::"NPR Item Worksheet Line");
        NPRItemWorkshFieldSetup.SetRange("Field Number", NPRItemWorksheetLine.FieldNo("Vendor Item No."));
        if NPRItemWorkshFieldSetup.FindSet() then
            repeat
                if not NPRItemWorkshFieldSetup2.Get(NPRItemWorkshFieldSetup."Worksheet Template Name", NPRItemWorkshFieldSetup."Worksheet Name",
                                                    NPRItemWorkshFieldSetup."Table No.", NPRItemWorksheetLine.FieldNo("Vend Item No.")) then
                    NPRItemWorkshFieldSetup.Rename(NPRItemWorkshFieldSetup."Worksheet Template Name", NPRItemWorkshFieldSetup."Worksheet Name",
                                                   NPRItemWorkshFieldSetup."Table No.", NPRItemWorksheetLine.FieldNo("Vend Item No."));
            until NPRItemWorkshFieldSetup.Next() = 0;

        UpgradeTag.SetUpgradeTag(UpgTagDef.GetUpgradeTag(CurrCodeunitId(), 'ItemWorksheetFieldSetup'));
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(Codeunit::"NPR UPG Vend Item No Expansion");
    end;
}