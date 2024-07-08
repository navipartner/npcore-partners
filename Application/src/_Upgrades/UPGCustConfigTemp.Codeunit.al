codeunit 6059957 "NPR UPG Cust. Config. Temp."
{
    Access = Internal;
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        UpgTagDef: Codeunit "NPR Upgrade Tag Definitions";
        UpgradeTagMgt: Codeunit "Upgrade Tag";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR UPG Cust. Config. Temp.', 'OnUpgradePerCompany');

        // Check whether the tag has been used before, and if so, don't run upgrade code
        if UpgradeTagMgt.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG Cust. Config. Temp.")) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;

        // Run upgrade code
        DoUpgrade();

        // Insert the upgrade tag in table 9999 "Upgrade Tags" for future reference
        UpgradeTagMgt.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG Cust. Config. Temp."));

        LogMessageStopwatch.LogFinish();
    end;

    local procedure DoUpgrade()
    var
        MagentoSetup: Record "NPR Magento Setup";
        ConfigTemplateHeaderToCheck: Record "Config. Template Header";
        ConfTemplateCode: Code[10];
    begin
        if not MagentoSetup.Get() then
            exit;

        if (MagentoSetup."Customer Posting Group" = '') and (MagentoSetup."Payment Terms Code" = '') then
            exit;

        if MagentoSetup."Customer Config. Template Code" <> '' then
            if ConfigTemplateHeaderToCheck.Get(MagentoSetup."Customer Config. Template Code") then begin
                SetFieldsOnConfTemplate(MagentoSetup);
                exit;
            end;

        CreateNewTemplate(ConfTemplateCode, MagentoSetup."Customer Posting Group", MagentoSetup."Payment Terms Code");
        if ConfTemplateCode = '' then
            exit;

        MagentoSetup."Customer Config. Template Code" := ConfTemplateCode;
        MagentoSetup.Modify(true);
    end;

    local procedure CreateNewTemplate(var ConfTemplateCode: Code[10]; CustPostingGroup: Code[20]; PaymentTermsCode: Code[20])
    var
        CustTemplateLbl: Label 'CUSMAGENTO', Locked = true;
        CustTemplateDescLbl: Label 'Created from Magento setup';
        ConfigTemplateHeader: Record "Config. Template Header";
        Cust: Record Customer;
    begin
        if ConfigTemplateHeader.Get(CustTemplateLbl) then
            exit;

        ConfigTemplateHeader.Code := CustTemplateLbl;
        ConfigTemplateHeader.Description := CustTemplateDescLbl;
        ConfigTemplateHeader."Table ID" := Database::Customer;
        ConfigTemplateHeader.Enabled := true;
        ConfigTemplateHeader.Insert(true);

        ConfTemplateCode := ConfigTemplateHeader.Code;

        InsertConfTempLine(ConfigTemplateHeader.Code, Cust.FieldNo("Customer Posting Group"), CustPostingGroup);
        InsertConfTempLine(ConfigTemplateHeader.Code, Cust.FieldNo("Payment Terms Code"), PaymentTermsCode);
    end;

    local procedure InsertConfTempLine(ConfigTemplateCode: Code[10]; FieldID: Integer; FieldValue: Code[20])
    var
        ConfigTemplateLine: Record "Config. Template Line";
    begin
        ConfigTemplateLine.Validate("Data Template Code", ConfigTemplateCode);
        ConfigTemplateLine."Line No." := GetNextLineNo(ConfigTemplateCode);
        ConfigTemplateLine.Validate("Table ID", Database::Customer);
        ConfigTemplateLine.Validate("Field ID", FieldID);
        ConfigTemplateLine."Default Value" := FieldValue;
        ConfigTemplateLine.Insert();
    end;

    local procedure GetNextLineNo(ConfigTemplateCode: Code[10]): Integer
    var
        ConfigTemplateLine: Record "Config. Template Line";
    begin
        ConfigTemplateLine.SetRange("Data Template Code", ConfigTemplateCode);
        if ConfigTemplateLine.FindLast() then
            exit(ConfigTemplateLine."Line No." + 1000)
        else
            exit(1000);
    end;

    local procedure SetFieldsOnConfTemplate(MagentoSetup: Record "NPR Magento Setup")
    var
        Cust: Record Customer;
    begin
        if MagentoSetup."Customer Posting Group" <> '' then
            if not FieldExistsOnTemplate(MagentoSetup, Cust.FieldNo("Customer Posting Group")) then
                InsertConfTempLine(
                    MagentoSetup."Customer Config. Template Code",
                    Cust.FieldNo("Customer Posting Group"),
                    MagentoSetup."Customer Posting Group");

        if MagentoSetup."Payment Terms Code" <> '' then
            if not FieldExistsOnTemplate(MagentoSetup, Cust.FieldNo("Payment Terms Code")) then
                InsertConfTempLine(
                    MagentoSetup."Customer Config. Template Code",
                    Cust.FieldNo("Payment Terms Code"),
                    MagentoSetup."Payment Terms Code");
    end;

    local procedure FieldExistsOnTemplate(MagentoSetup: Record "NPR Magento Setup"; FieldID: Integer): Boolean
    var
        ConfigTemplateLine: Record "Config. Template Line";
    begin
        ConfigTemplateLine.SetRange("Data Template Code", MagentoSetup."Customer Config. Template Code");
        ConfigTemplateLine.SetRange("Field ID", FieldID);
        ConfigTemplateLine.SetFilter("Default Value", '<>%1', '');
        exit(not ConfigTemplateLine.IsEmpty());
    end;
}
