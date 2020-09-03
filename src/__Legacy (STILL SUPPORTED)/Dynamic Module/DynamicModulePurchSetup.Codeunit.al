codeunit 6014471 "NPR Dynamic Module Purch.Setup"
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
        DynamicModuleHelper.CreateModuleSetting(Sender, 1, 'Show Posted Purchase Invoice No.', DynamicModuleSetting."Data Type"::Boolean, AdditionalPropertyType::" ", '', false);
        DynamicModuleHelper.CreateModuleSetting(Sender, 2, 'Show Posted Purchase Credit Memo No.', DynamicModuleSetting."Data Type"::Boolean, AdditionalPropertyType::" ", '', false);
        DynamicModuleHelper.CreateModuleSetting(Sender, 3, 'Show Posted Purchase Receipt No.', DynamicModuleSetting."Data Type"::Boolean, AdditionalPropertyType::" ", '', false);
        DynamicModuleHelper.CreateModuleSetting(Sender, 4, 'Show Posted Return Shipment No.', DynamicModuleSetting."Data Type"::Boolean, AdditionalPropertyType::" ", '', false);
    end;

    [EventSubscriber(ObjectType::Codeunit, 90, 'OnAfterPostPurchaseDoc', '', true, true)]
    local procedure ShowPostedPurchaseInvoiceNoSetting(var PurchaseHeader: Record "Purchase Header"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; PurchRcpHdrNo: Code[20]; RetShptHdrNo: Code[20]; PurchInvHdrNo: Code[20]; PurchCrMemoHdrNo: Code[20])
    var
        PostedPurchaseInvMsg: Label 'Posted Purchase Invoice No.: %1';
        Value: Variant;
        SetupValue: Boolean;
    begin
        SettingID := 1;
        if not DynamicModuleHelper.ModuleIsEnabledAndReturnSetupValue(GetModuleName(), SettingID, Value) then
            exit;

        SetupValue := Value;
        //-NPR5.52 [366647]
        //IF SetupValue THEN
        if SetupValue and (PurchInvHdrNo <> '') then
            //+NPR5.52 [366647]
            Message(PostedPurchaseInvMsg, PurchInvHdrNo);
    end;

    [EventSubscriber(ObjectType::Codeunit, 90, 'OnAfterPostPurchaseDoc', '', true, true)]
    local procedure ShowPostedPurchaseCrMemoNoSetting(var PurchaseHeader: Record "Purchase Header"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; PurchRcpHdrNo: Code[20]; RetShptHdrNo: Code[20]; PurchInvHdrNo: Code[20]; PurchCrMemoHdrNo: Code[20])
    var
        Value: Variant;
        SetupValue: Boolean;
        PostedPurchaseCrMemoMsg: Label 'Posted Purchase Credit Memo No.: %1';
    begin
        SettingID := 2;
        if not DynamicModuleHelper.ModuleIsEnabledAndReturnSetupValue(GetModuleName(), SettingID, Value) then
            exit;

        SetupValue := Value;
        //-NPR5.52 [366647]
        //IF SetupValue THEN
        if SetupValue and (PurchCrMemoHdrNo <> '') then
            //+NPR5.52 [366647]
            Message(PostedPurchaseCrMemoMsg, PurchCrMemoHdrNo);
    end;

    [EventSubscriber(ObjectType::Codeunit, 90, 'OnAfterPostPurchaseDoc', '', true, true)]
    local procedure ShowPostedPurchaseReceiptNoSetting(var PurchaseHeader: Record "Purchase Header"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; PurchRcpHdrNo: Code[20]; RetShptHdrNo: Code[20]; PurchInvHdrNo: Code[20]; PurchCrMemoHdrNo: Code[20])
    var
        Value: Variant;
        SetupValue: Boolean;
        PostedPurchaseReceiptMsg: Label 'Posted Purchase Receipt No.: %1';
    begin
        SettingID := 3;
        if not DynamicModuleHelper.ModuleIsEnabledAndReturnSetupValue(GetModuleName(), SettingID, Value) then
            exit;

        SetupValue := Value;
        //-NPR5.52 [366647]
        //IF SetupValue THEN
        if SetupValue and (PurchRcpHdrNo <> '') then
            //+NPR5.52 [366647]
            Message(PostedPurchaseReceiptMsg, PurchRcpHdrNo);
    end;

    [EventSubscriber(ObjectType::Codeunit, 90, 'OnAfterPostPurchaseDoc', '', true, true)]
    local procedure ShowPostedReturnShipmentNoSetting(var PurchaseHeader: Record "Purchase Header"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; PurchRcpHdrNo: Code[20]; RetShptHdrNo: Code[20]; PurchInvHdrNo: Code[20]; PurchCrMemoHdrNo: Code[20])
    var
        Value: Variant;
        SetupValue: Boolean;
        PostedReturnShipmentMsg: Label 'Posted Return Shipment No.: %1';
    begin
        SettingID := 4;
        if not DynamicModuleHelper.ModuleIsEnabledAndReturnSetupValue(GetModuleName(), SettingID, Value) then
            exit;

        SetupValue := Value;
        //-NPR5.52 [366647]
        //IF SetupValue THEN
        if SetupValue and (RetShptHdrNo <> '') then
            //+NPR5.52 [366647]
            Message(PostedReturnShipmentMsg, RetShptHdrNo);
    end;

    procedure GetModuleName(): Text
    begin
        exit('Purchase Setup');
    end;
}

