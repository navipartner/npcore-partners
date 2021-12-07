codeunit 6014686 "NPR UPG Item Blob 2 Media"
{
    Subtype = Upgrade;

    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";

    trigger OnUpgradePerCompany()
    var
        UpgradeTagMgt: Codeunit "Upgrade Tag";
        UpgTagDef: Codeunit "NPR Upgrade Tag Definitions";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR UPG Item Blob 2 Media', 'OnUpgradePerCompany');

        // Check whether the tag has been used before, and if so, don't run upgrade code
        if UpgradeTagMgt.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG Item Blob 2 Media")) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;

        // Run upgrade code
        Upgrade();

        // Insert the upgrade tag in table 9999 "Upgrade Tags" for future reference
        UpgradeTagMgt.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG Item Blob 2 Media"));

        LogMessageStopwatch.LogFinish();
    end;

    local procedure Upgrade()
    begin
        //Blob to Media on Item table
        UpgradeItemNPRMagentoDescription();

        //Updating References in XML Template
        //XML Element
        UpgradeFieldReferencesToXMLElement();

        //XML Filter
        UpgradeFieldReferencesToXMLFilter();

        //XML Attribute
        UpgradeFieldReferencesToXMLAttribute();
    end;

    local procedure UpgradeItemNPRMagentoDescription()
    var
        MigrationRec2: Record Item;
        MigrationRec: Record Item;
        DataLogMgt: Codeunit "NPR Data Log Management";
        InStr: InStream;
        NPRMagentoDescHasValue: Boolean;
        NPRMagentoShortDescHasValue: Boolean;
        WithError: Boolean;
        ProblemErr: Label 'Problem upgrading media for: %1', Locked = true;
    begin
        if MigrationRec.IsEmpty() then
            exit;

        MigrationRec.SetLoadFields(SystemId, "NPR Magento Description", "NPR Magento Short Description");
        if MigrationRec.FindSet() then
            repeat
                MigrationRec2.GetBySystemId(MigrationRec.SystemId);
                NPRMagentoDescHasValue := MigrationRec2."NPR Magento Description".HasValue();
                if NPRMagentoDescHasValue then begin
                    MigrationRec2.CalcFields("NPR Magento Description");
                    MigrationRec2."NPR Magento Description".CreateInStream(InStr);
                    WithError := IsNullGuid(MigrationRec2."NPR Magento Desc.".ImportStream(InStr, MigrationRec2.FieldName("NPR Magento Desc.")));
                    Clear(InStr);
                end;
                NPRMagentoShortDescHasValue := MigrationRec2."NPR Magento Short Description".HasValue();
                if NPRMagentoShortDescHasValue then begin
                    MigrationRec2.CalcFields("NPR Magento Short Description");
                    MigrationRec2."NPR Magento Short Description".CreateInStream(InStr);
                    WithError := IsNullGuid(MigrationRec2."NPR Magento Short Desc.".ImportStream(InStr, MigrationRec2.FieldName("NPR Magento Short Desc.")));
                    Clear(InStr);
                end;
                if NPRMagentoDescHasValue or NPRMagentoShortDescHasValue then begin
                    if not WithError then begin
                        DataLogMgt.DisableDataLog(true);
                        MigrationRec2.Modify();
                        DataLogMgt.DisableDataLog(false);
                    end else
                        LogMessageStopwatch.SetError(StrSubstNo(ProblemErr, MigrationRec2.RecordId()));
                end;
            until MigrationRec.Next() = 0;
    end;

    local procedure UpgradeFieldReferencesToXMLElement()
    var
        Item: Record Item;
        MigrationRec: Record "NPR NpXml Element";
    begin
        if MigrationRec.IsEmpty() then
            exit;

        MigrationRec.SetLoadFields("Field No.");
        MigrationRec.SetRange("Table No.", Database::Item);
        MigrationRec.SetRange("Field No.", Item.FieldNo("NPR Magento Description"));
        if not MigrationRec.IsEmpty() then
            MigrationRec.ModifyAll("Field No.", Item.FieldNo("NPR Magento Desc."));

        MigrationRec.Reset();
        MigrationRec.SetRange("Table No.", Database::Item);
        MigrationRec.SetRange("Field No.", Item.FieldNo("NPR Magento Short Description"));
        if not MigrationRec.IsEmpty() then
            MigrationRec.ModifyAll("Field No.", Item.FieldNo("NPR Magento Short Desc."));
    end;

    local procedure UpgradeFieldReferencesToXMLFilter()
    var
        Item: Record Item;
        MigrationRec: Record "NPR NpXml Filter";
    begin
        if MigrationRec.IsEmpty() then
            exit;

        MigrationRec.SetLoadFields("Field No.");
        MigrationRec.SetRange("Table No.", Database::Item);
        MigrationRec.SetRange("Field No.", Item.FieldNo("NPR Magento Description"));
        if not MigrationRec.IsEmpty() then
            MigrationRec.ModifyAll("Field No.", Item.FieldNo("NPR Magento Desc."));

        MigrationRec.Reset();
        MigrationRec.SetRange("Table No.", Database::Item);
        MigrationRec.SetRange("Field No.", Item.FieldNo("NPR Magento Short Description"));
        if not MigrationRec.IsEmpty() then
            MigrationRec.ModifyAll("Field No.", Item.FieldNo("NPR Magento Short Desc."));
    end;

    local procedure UpgradeFieldReferencesToXMLAttribute()
    var
        Item: Record Item;
        MigrationRec: Record "NPR NpXml Attribute";
    begin
        if MigrationRec.IsEmpty() then
            exit;

        MigrationRec.SetLoadFields("Attribute Field No.");
        MigrationRec.SetRange("Table No.", Database::Item);
        MigrationRec.SetRange("Attribute Field No.", Item.FieldNo("NPR Magento Description"));
        if not MigrationRec.IsEmpty() then
            MigrationRec.ModifyAll("Attribute Field No.", Item.FieldNo("NPR Magento Desc."));

        MigrationRec.Reset();
        MigrationRec.SetRange("Table No.", Database::Item);
        MigrationRec.SetRange("Attribute Field No.", Item.FieldNo("NPR Magento Short Description"));
        if not MigrationRec.IsEmpty() then
            MigrationRec.ModifyAll("Attribute Field No.", Item.FieldNo("NPR Magento Short Desc."));
    end;
}