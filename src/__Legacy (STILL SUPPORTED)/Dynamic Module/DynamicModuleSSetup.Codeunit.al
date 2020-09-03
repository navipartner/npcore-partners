codeunit 6014470 "NPR Dynamic Module S.Setup"
{
    // NPR5.41/TJ  /20180413 CASE 311170 New object
    // NPR5.52/TJ  /20190905 CASE 366647 Showing message only if data is sent


    trigger OnRun()
    begin
    end;

    var
        DynamicModuleHelper: Codeunit "NPR Dynamic Module Helper";
        SettingID: Integer;
        AdditionalPropertyType: Option " ",Length,OptionString,DecimalPrecision;
        ExampleEnabled: Boolean;
        DynamicModuleSetting: Record "NPR Dynamic Module Setting";
        TypeHelper: Codeunit "Type Helper";

    [EventSubscriber(ObjectType::Table, 6014479, 'OnDiscoverModule', '', true, true)]
    local procedure LoadModule(var Sender: Record "NPR Dynamic Module")
    begin
        DynamicModuleHelper.CreateOrFindModule(GetModuleName(), Sender);
        DynamicModuleHelper.CreateModuleSetting(Sender, 1, 'Show Posted Sales Invoice No.', DynamicModuleSetting."Data Type"::Boolean, AdditionalPropertyType::" ", '', false);
        DynamicModuleHelper.CreateModuleSetting(Sender, 2, 'Show Posted Sales Credit Memo No.', DynamicModuleSetting."Data Type"::Boolean, AdditionalPropertyType::" ", '', false);
        DynamicModuleHelper.CreateModuleSetting(Sender, 3, 'Show Posted Sales Shipment No.', DynamicModuleSetting."Data Type"::Boolean, AdditionalPropertyType::" ", '', false);
        DynamicModuleHelper.CreateModuleSetting(Sender, 4, 'Show Posted Return Receipt No.', DynamicModuleSetting."Data Type"::Boolean, AdditionalPropertyType::" ", '', false);
    end;

    [EventSubscriber(ObjectType::Codeunit, 80, 'OnAfterPostSalesDoc', '', true, true)]
    local procedure ShowPostedSalesInvoiceNoSetting(var SalesHeader: Record "Sales Header"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; SalesShptHdrNo: Code[20]; RetRcpHdrNo: Code[20]; SalesInvHdrNo: Code[20]; SalesCrMemoHdrNo: Code[20])
    var
        PostedSalesInvMsg: Label 'Posted Sales Invoice No.: %1';
        Value: Variant;
        SetupValue: Boolean;
    begin
        SettingID := 1;
        if not DynamicModuleHelper.ModuleIsEnabledAndReturnSetupValue(GetModuleName(), SettingID, Value) then
            exit;

        SetupValue := Value;
        //-NPR5.52 [366647]
        //IF SetupValue THEN
        if SetupValue and (SalesInvHdrNo <> '') then
            //+NPR5.52 [366647]
            Message(PostedSalesInvMsg, SalesInvHdrNo);
    end;

    [EventSubscriber(ObjectType::Codeunit, 80, 'OnAfterPostSalesDoc', '', true, true)]
    local procedure ShowPostedSalesCrMemoNoSetting(var SalesHeader: Record "Sales Header"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; SalesShptHdrNo: Code[20]; RetRcpHdrNo: Code[20]; SalesInvHdrNo: Code[20]; SalesCrMemoHdrNo: Code[20])
    var
        Value: Variant;
        SetupValue: Boolean;
        PostedSalesCrMemoMsg: Label 'Posted Sales Credit Memo No.: %1';
    begin
        SettingID := 2;
        if not DynamicModuleHelper.ModuleIsEnabledAndReturnSetupValue(GetModuleName(), SettingID, Value) then
            exit;

        SetupValue := Value;
        //-NPR5.52 [366647]
        //IF SetupValue THEN
        if SetupValue and (SalesCrMemoHdrNo <> '') then
            //+NPR5.52 [366647]
            Message(PostedSalesCrMemoMsg, SalesCrMemoHdrNo);
    end;

    [EventSubscriber(ObjectType::Codeunit, 80, 'OnAfterPostSalesDoc', '', true, true)]
    local procedure ShowPostedSalesShipmentNoSetting(var SalesHeader: Record "Sales Header"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; SalesShptHdrNo: Code[20]; RetRcpHdrNo: Code[20]; SalesInvHdrNo: Code[20]; SalesCrMemoHdrNo: Code[20])
    var
        Value: Variant;
        SetupValue: Boolean;
        PostedSalesShipmentMsg: Label 'Posted Sales Shipment No.: %1';
    begin
        SettingID := 3;
        if not DynamicModuleHelper.ModuleIsEnabledAndReturnSetupValue(GetModuleName(), SettingID, Value) then
            exit;

        SetupValue := Value;
        //-NPR5.52 [366647]
        //IF SetupValue THEN
        if SetupValue and (SalesShptHdrNo <> '') then
            //+NPR5.52 [366647]
            Message(PostedSalesShipmentMsg, SalesShptHdrNo);
    end;

    [EventSubscriber(ObjectType::Codeunit, 80, 'OnAfterPostSalesDoc', '', true, true)]
    local procedure ShowPostedReturnReceiptNoSetting(var SalesHeader: Record "Sales Header"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; SalesShptHdrNo: Code[20]; RetRcpHdrNo: Code[20]; SalesInvHdrNo: Code[20]; SalesCrMemoHdrNo: Code[20])
    var
        Value: Variant;
        SetupValue: Boolean;
        PostedReturnReceiptMsg: Label 'Posted Return Receipt No.: %1';
    begin
        SettingID := 4;
        if not DynamicModuleHelper.ModuleIsEnabledAndReturnSetupValue(GetModuleName(), SettingID, Value) then
            exit;

        SetupValue := Value;
        //-NPR5.52 [366647]
        //IF SetupValue THEN
        if SetupValue and (RetRcpHdrNo <> '') then
            //+NPR5.52 [366647]
            Message(PostedReturnReceiptMsg, RetRcpHdrNo);
    end;

    procedure GetModuleName(): Text
    begin
        exit('Sales Setup');
    end;
}

