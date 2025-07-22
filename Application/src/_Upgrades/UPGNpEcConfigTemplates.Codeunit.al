#if not BC17
codeunit 6248442 "NPR UPG NpEc Config. Templates"
{
    Access = Internal;
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        UpgTagDef: Codeunit "NPR Upgrade Tag Definitions";
        UpgradeTagMgt: Codeunit "Upgrade Tag";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR UPG NpEc Config. Templates', 'OnUpgradePerCompany');

        if UpgradeTagMgt.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG NpEc Config. Templates")) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;

        Upgrade();

        UpgradeTagMgt.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG NpEc Config. Templates"));
        LogMessageStopwatch.LogFinish();
    end;

    local procedure Upgrade()
    var
        ECommerceTemplates: Dictionary of [Code[20], Boolean];
    begin
        GetEcommerceTemplates(ECommerceTemplates);
        TransferEcConfigTemplatesToCustTemplates(ECommerceTemplates);
    end;

    local procedure GetEcommerceTemplates(var ECommerceTemplates: Dictionary of [Code[20], Boolean])
    var
        NpEcStore: Record "NPR NpEc Store";
        NpEcCustomerMapping: Record "NPR NpEc Customer Mapping";
    begin
        NpEcStore.SetFilter("Customer Config. Template Code", '<>%1', '');
        if NpEcStore.FindSet() then
            repeat
                if not ECommerceTemplates.ContainsKey(NpEcStore."Customer Config. Template Code") then
                    ECommerceTemplates.Add(NpEcStore."Customer Config. Template Code", true);
            until NpEcStore.Next() = 0;

        NpEcCustomerMapping.SetFilter("Config. Template Code", '<>%1', '');
        if NpEcCustomerMapping.FindSet() then
            repeat
                if not ECommerceTemplates.ContainsKey(NpEcCustomerMapping."Config. Template Code") then
                    ECommerceTemplates.Add(NpEcCustomerMapping."Config. Template Code", true);
            until NpEcCustomerMapping.Next() = 0;
    end;

    local procedure TransferEcConfigTemplatesToCustTemplates(ECommerceTemplates: Dictionary of [Code[20], Boolean])
    var
        Template: Code[20];
        CustomerTempl: Record "Customer Templ.";
    begin
        foreach Template in ECommerceTemplates.Keys()
        do
            if not CustomerTempl.Get(Template) then
                CreateCustTemplateFromConfigTemplate(Template);
    end;

    local procedure CreateCustTemplateFromConfigTemplate(Template: Code[20])
    var
        ConfigTemplateHeader: Record "Config. Template Header";
        CustomerTempl: Record "Customer Templ.";
    begin
        ConfigTemplateHeader.Get(Template);
        CustomerTempl.Init();
        CustomerTempl.Code := ConfigTemplateHeader.Code;
        CustomerTempl.Description := ConfigTemplateHeader.Description;
        TransferConfigLinesAndInsert(CustomerTempl);
    end;

    local procedure TransferConfigLinesAndInsert(var CustomerTempl: Record "Customer Templ.")
    var
        ConfigTemplateLine: Record "Config. Template Line";
        ConfigValidateMgt: Codeunit "Config. Validate Management";
        CustTemplateFieldRef: FieldRef;
        CustTemplateRecordRef: RecordRef;
        ValidationError: Text;
    begin
        CustTemplateRecordRef.GetTable(CustomerTempl);

        ConfigTemplateLine.SetRange("Data Template Code", CustomerTempl.Code);
        SetAvaliableCustConfigTemplateFieldFilter(ConfigTemplateLine);
        if ConfigTemplateLine.FindSet() then begin
            repeat
                CustTemplateFieldRef := CustTemplateRecordRef.Field(ConfigTemplateLine."Field ID");
                ValidationError := ConfigValidateMgt.EvaluateValue(CustTemplateFieldRef, ConfigTemplateLine."Default Value", false);
            until ConfigTemplateLine.Next() = 0;
        end;

        CustTemplateRecordRef.Insert();
    end;

    local procedure SetAvaliableCustConfigTemplateFieldFilter(var ConfigTemplateLine: Record "Config. Template Line")
    var
        FieldFilter: Text;
    begin
        // Customer field existing on the Customer Template table
        FieldFilter := '5 .. 7 | 9 .. 11 | 14 .. 37 | 39 | 42 | 45 | 47 .. 48 | 80 | 82 .. 93 | 95 ';
        FieldFilter += '| 102 .. 104 | 107 .. 110 | 115 .. 116 | 119 | 124 | 132 .. 133 | 150 | 160';
        FieldFilter += '| 840 | 5050 | 5061 | 5700 | 5750 | 5790 | 5792 | 7600 .. 7602';

        ConfigTemplateLine.SetFilter("Field ID", FieldFilter);
    end;
}
#endif