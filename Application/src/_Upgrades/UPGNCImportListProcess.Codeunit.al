codeunit 6184569 "NPR UPG NC Import List Process"
{
    Access = Internal;
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        UpgradeTagMgt: Codeunit "Upgrade Tag";
        UpgTagDef: Codeunit "NPR Upgrade Tag Definitions";
    begin
        if not UpgradeTagMgt.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Upg NC Import List Process", 'UpdateImportTypeFields')) then begin
            LogMessageStopwatch.LogStart(CompanyName(), 'NPR Upg NC Import List Process', 'OnUpgradePerCompany');
            UpdateImportTypeFields();
            UpgradeTagMgt.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Upg NC Import List Process", 'UpdateImportTypeFields'));
            LogMessageStopwatch.LogFinish();
        end;

    end;

    local procedure UpdateImportTypeFields()
    begin
        //Magento Sales Order
        ModifyImportType(Codeunit::"NPR Magento Sales Order Mgt.", Enum::"NPR Nc IL Process Handler"::"Magento Sales Order", Enum::"NPR Nc IL Lookup Handler"::"Magento Lookup Sales Order");

        //Magento Return Order
        ModifyImportType(Codeunit::"NPR Magento Imp. Ret. Order", Enum::"NPR Nc IL Process Handler"::"Magento Return Order", Enum::"NPR Nc IL Lookup Handler"::"Magento Lookup Return Order");

        //BTwentyFour
        ModifyImportType(Codeunit::"NPR BTF Nc Import Entry", Enum::"NPR Nc IL Process Handler"::Btwentyfour, Enum::"NPR Nc IL Lookup Handler"::Default);

        //Collect Sales Document
        ModifyImportType(Codeunit::"NPR NpCs Imp. Sales Doc.", Enum::"NPR Nc IL Process Handler"::"Collect Sales Document", Enum::"NPR Nc IL Lookup Handler"::"NpCs Lookup Sales Document");

        // NPR TM Ticket WebService Mgr
        ModifyImportType(Codeunit::"NPR TM Ticket WebService Mgr", Enum::"NPR Nc IL Process Handler"::"TM Ticket WebService Mgr", Enum::"NPR Nc IL Lookup Handler"::"TM View Ticket Requests");

        // NPR MM Member WebService Mgr
        ModifyImportType(Codeunit::"NPR MM Member WebService Mgr", Enum::"NPR Nc IL Process Handler"::"MM Member WebService Mgr", Enum::"NPR Nc IL Lookup Handler"::Default);

        // NPR MM Loyalty WebService Mgr
        ModifyImportType(Codeunit::"NPR MM Loyalty WebService Mgr", Enum::"NPR Nc IL Process Handler"::"MM Loyalty WebService Mgr", Enum::"NPR Nc IL Lookup Handler"::Default);

        // NPR HC POS Entry Management
        ModifyImportType(Codeunit::"NPR HC POS Entry Management", Enum::"NPR Nc IL Process Handler"::"HC POS Entry Management", Enum::"NPR Nc IL Lookup Handler"::Default);

        // NPR Endpoint Query WS Mgr
        ModifyImportType(Codeunit::"NPR Endpoint Query WS Mgr", Enum::"NPR Nc IL Process Handler"::"Endpoint Query WS Mgr", Enum::"NPR Nc IL Lookup Handler"::Default);

        // NPR Replication
        ModifyImportType(Codeunit::"NPR Replication Import Entry", Enum::"NPR Nc IL Process Handler"::Replication, Enum::"NPR Nc IL Lookup Handler"::Default);

        // NPR Item Wksht. WebService Mgr
        ModifyImportType(Codeunit::"NPR Item Wksht. WebService Mgr", Enum::"NPR Nc IL Process Handler"::"Item Wksht. WebService Mgr", Enum::"NPR Nc IL Lookup Handler"::Default);

        // External POS Sale
        ModifyImportType(Codeunit::"NPR Ext. POS Sale Processor", Enum::"NPR Nc IL Process Handler"::"External POS Sale", Enum::"NPR Nc IL Lookup Handler"::"External POS Sale Lookup");

        // NpEc S.Order Import Create
        ModifyImportType(Codeunit::"NPR NpEc S.Order Import Create", Enum::"NPR Nc IL Process Handler"::"NpEc S.Order Import Create", Enum::"NPR Nc IL Lookup Handler"::"NpEc S.Order Lookup");

        // NpEc S.Order Import (Post)
        ModifyImportType(Codeunit::"NPR NpEc S.Order Import (Post)", Enum::"NPR Nc IL Process Handler"::"NpEc S.Order Import (Post)", Enum::"NPR Nc IL Lookup Handler"::"NpEc S.Order Lookup");

        // NpEc S.Order Imp. Delete
        ModifyImportType(Codeunit::"NPR NpEc S.Order Imp. Delete", Enum::"NPR Nc IL Process Handler"::"NpEc S.Order Imp. Delete", Enum::"NPR Nc IL Lookup Handler"::"NpEc S.Order Lookup");

        //NpEc P.Invoice Imp. Create
        ModifyImportType(Codeunit::"NPR NpEc P.Invoice Imp. Create", Enum::"NPR Nc IL Process Handler"::"NpEc P.Invoice Imp. Create", Enum::"NPR Nc IL Lookup Handler"::"NpEc P.Invoice Look");

    end;

    local procedure ModifyImportType(ImportCodeunitID: Integer; IProcessor: Enum "NPR Nc IL Process Handler"; ILLookup: Enum "NPR Nc IL Lookup Handler")
    var
        ImportType: Record "NPR Nc Import Type";
        ImportType2: Record "NPR Nc Import Type";
    begin
        ImportType.SetRange("Import Codeunit ID", ImportCodeunitID);
        if ImportType.FindSet() then
            repeat
                ImportType2 := ImportType;

                ImportType2."Import List Process Handler" := IProcessor;
                if IProcessor <> IProcessor::Default then
                    ImportType2."Import Codeunit ID" := 0;

                ImportType2."Import List Lookup Handler" := ILLookup;
                if ILLookup <> ILLookup::Default then
                    ImportType2."Lookup Codeunit ID" := 0;

                ImportType2.Modify();
            until ImportType.Next() = 0;
    end;

}
