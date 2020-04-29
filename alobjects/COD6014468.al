codeunit 6014468 "Dynamic Module Example"
{
    // WARNING: You should not add anything to this codeunit
    //          This codeunit serves as a template which you can save to another ID
    // 
    // How to make your own dynamic setup:
    // 1. In function LoadModule add module name with settings:
    //    a) DynamicModuleHelper.CreateOrFindModule - function will create a new module for your settings or add them to an existing module with ModuleName
    //    b) DynamicModuleHelper.CreateModuleSetting - creates a setting in set Module with hardcoded setting ID, name, data type, potentially a property, property value and default value
    // 2. Create a function subscriber that subscribes to process on which you wish to process single setting:
    //    a) Needs to have SettingID := xx where xx is the same value you have provided in function LoadModule with DynamicModuleHelper.CreateModuleSetting
    //    b) Check if the module is enabled (through its name) and retrieve its value
    //    c) Process the setup
    // Function IsEnabled and variable ExampleEnabled are not needed and they are only here so this codeunit is not loaded into the tool by accident
    // You CAN change the value of variable ExampleEnabled to TRUE so you can try the tool
    // Whenever you create a new codeunit with this structure or add a setting in already existing codeunit, you need to load it through Load Modules action
    //   from page Dynamic Modules - this action will recreate entire dynamic setup as it ensures all changes are applied
    // DO NOT forget to set OnMissingLicense and OnMissingPermission on subscriber functions properties to Skip
    // NPR5.38/NPKNAV/20180126  CASE 294992 Transport NPR5.38 - 26 January 2018


    trigger OnRun()
    begin
    end;

    var
        DynamicModuleHelper: Codeunit "Dynamic Module Helper";
        SettingID: Integer;
        AdditionalPropertyType: Option " ",Length,OptionString,DecimalPrecision;
        ExampleEnabled: Boolean;
        DynamicModuleSetting: Record "Dynamic Module Setting";
        TypeHelper: Codeunit "Type Helper";

    local procedure IsEnabled()
    begin
        ExampleEnabled := false;
    end;

    [EventSubscriber(ObjectType::Table, 6014479, 'OnDiscoverModule', '', true, true)]
    local procedure LoadModule(var Sender: Record "Dynamic Module")
    begin
        IsEnabled();
        if not ExampleEnabled then
          exit;

        DynamicModuleHelper.CreateOrFindModule(GetModuleName(),Sender);
        DynamicModuleHelper.CreateModuleSetting(Sender,1,'Show Posted Sales Invoice No.',DynamicModuleSetting."Data Type"::Boolean,AdditionalPropertyType::" ",'',false);
        DynamicModuleHelper.CreateModuleSetting(Sender,2,'Show Posted Sales Credit Memo No.',DynamicModuleSetting."Data Type"::Boolean,AdditionalPropertyType::" ",'',false);
        DynamicModuleHelper.CreateModuleSetting(Sender,3,'Default External Document No. on Sales Order',DynamicModuleSetting."Data Type"::Code,AdditionalPropertyType::Length,'35','TEST');
        DynamicModuleHelper.CreateModuleSetting(Sender,4,'Default Purch. Order Posting Date',DynamicModuleSetting."Data Type"::Date,AdditionalPropertyType::" ",'',Today);
        DynamicModuleHelper.CreateModuleSetting(Sender,5,'Confirm Purch. Order Deletion',DynamicModuleSetting."Data Type"::Boolean,AdditionalPropertyType::" ",'',false);
    end;

    [EventSubscriber(ObjectType::Table, 6014479, 'OnDiscoverModule', '', true, true)]
    local procedure LoadDummyExample(var Sender: Record "Dynamic Module")
    var
        DateFormulaValue: DateFormula;
        DecimalValue: Decimal;
        DurationValue: Duration;
    begin
        IsEnabled();
        if not ExampleEnabled then
          exit;

        DynamicModuleHelper.CreateOrFindModule(GetDummyModuleName(),Sender);
        DynamicModuleHelper.CreateModuleSetting(Sender,1,'Boolean Example',DynamicModuleSetting."Data Type"::Boolean,AdditionalPropertyType::" ",'',false);
        DynamicModuleHelper.CreateModuleSetting(Sender,2,'Code Example with Length 20',DynamicModuleSetting."Data Type"::Code,AdditionalPropertyType::Length,'20','Default Code');
        DynamicModuleHelper.CreateModuleSetting(Sender,3,'Text Example with Length 30',DynamicModuleSetting."Data Type"::Text,AdditionalPropertyType::Length,'30','');
        DynamicModuleHelper.CreateModuleSetting(Sender,4,'Date Example',DynamicModuleSetting."Data Type"::Date,AdditionalPropertyType::" ",'',Today);
        DynamicModuleHelper.CreateModuleSetting(Sender,5,'DateFormula Example',DynamicModuleSetting."Data Type"::DateFormula,AdditionalPropertyType::" ",'',DateFormulaValue);
        DynamicModuleHelper.CreateModuleSetting(Sender,6,'DateTime Example',DynamicModuleSetting."Data Type"::DateTime,AdditionalPropertyType::" ",'',CreateDateTime(DMY2Date(1,1,2018),0T));
        DecimalValue := 22;
        DynamicModuleHelper.CreateModuleSetting(Sender,7,'Decimal Example with precision 0,001',DynamicModuleSetting."Data Type"::Decimal,AdditionalPropertyType::DecimalPrecision,Format(1 / 1000),DecimalValue);
        DurationValue := CreateDateTime(CalcDate('<CM>',Today),0T) - CreateDateTime(Today,0T);
        DynamicModuleHelper.CreateModuleSetting(Sender,8,'Duration Example',DynamicModuleSetting."Data Type"::Duration,AdditionalPropertyType::" ",'',DurationValue);
        DynamicModuleHelper.CreateModuleSetting(Sender,9,'Integer Example',DynamicModuleSetting."Data Type"::Integer,AdditionalPropertyType::" ",'',0);
        DynamicModuleHelper.CreateModuleSetting(Sender,10,'Option Example',DynamicModuleSetting."Data Type"::Option,AdditionalPropertyType::OptionString,'MON,TUE,WED,THI,FRI,SAT,SUN',2);
        DynamicModuleHelper.CreateModuleSetting(Sender,11,'Time Example',DynamicModuleSetting."Data Type"::Time,AdditionalPropertyType::" ",'',130000T);
    end;

    [EventSubscriber(ObjectType::Codeunit, 80, 'OnAfterPostSalesDoc', '', true, true)]
    local procedure ShowPostedSalesInvoiceNoSetting(var SalesHeader: Record "Sales Header";var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";SalesShptHdrNo: Code[20];RetRcpHdrNo: Code[20];SalesInvHdrNo: Code[20];SalesCrMemoHdrNo: Code[20])
    var
        PostedSalesInvMsg: Label 'Posted Sales Invoice No.: %1';
        Value: Variant;
        SetupValue: Boolean;
    begin
        //identify myself
        //-----
        SettingID := 1;
        //+++++

        //check if setup is enabled and retrieve set value if it is
        //-----
        if not DynamicModuleHelper.ModuleIsEnabledAndReturnSetupValue(GetModuleName(),SettingID,Value) then
          exit;
        SetupValue := Value;
        //+++++

        //process the setup
        //-----
        if SetupValue then
          Message(PostedSalesInvMsg,SalesInvHdrNo);
        //+++++
    end;

    [EventSubscriber(ObjectType::Codeunit, 80, 'OnAfterPostSalesDoc', '', true, true)]
    local procedure ShowPostedSalesCrMemoNoSetting(var SalesHeader: Record "Sales Header";var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";SalesShptHdrNo: Code[20];RetRcpHdrNo: Code[20];SalesInvHdrNo: Code[20];SalesCrMemoHdrNo: Code[20])
    var
        Value: Variant;
        SetupValue: Boolean;
        PostedSalesCrMemoMsg: Label 'Posted Sales Credit Memo No.: %1';
    begin
        SettingID := 2;
        if not DynamicModuleHelper.ModuleIsEnabledAndReturnSetupValue(GetModuleName(),SettingID,Value) then
          exit;

        SetupValue := Value;
        if SetupValue then
          Message(PostedSalesCrMemoMsg,SalesCrMemoHdrNo);
    end;

    [EventSubscriber(ObjectType::Table, 36, 'OnAfterInsertEvent', '', true, true)]
    local procedure AddExternalDocNoOnSalesOrder(var Rec: Record "Sales Header";RunTrigger: Boolean)
    var
        Value: Variant;
        SetupValue: Text;
    begin
        if not RunTrigger then
          exit;

        SettingID := 3;
        if not DynamicModuleHelper.ModuleIsEnabledAndReturnSetupValue(GetModuleName(),SettingID,Value) then
          exit;

        SetupValue := Value;
        if SetupValue <> '' then begin
          Rec.Validate("External Document No.",SetupValue);
          Rec.Modify;
        end;
    end;

    [EventSubscriber(ObjectType::Table, 38, 'OnAfterInsertEvent', '', true, true)]
    local procedure DefaultPurchOrderPostDate(var Rec: Record "Purchase Header";RunTrigger: Boolean)
    var
        Value: Variant;
        SetupValue: Date;
    begin
        if not RunTrigger then
          exit;

        SettingID := 4;
        if not DynamicModuleHelper.ModuleIsEnabledAndReturnSetupValue(GetModuleName(),SettingID,Value) then
          exit;

        SetupValue := Value;
        if SetupValue <> 0D then begin
          Rec.Validate("Posting Date",SetupValue);
          Rec.Modify;
        end;
    end;

    [EventSubscriber(ObjectType::Table, 38, 'OnBeforeDeleteEvent', '', true, true)]
    local procedure ConfirmPurchOrderDeletion(var Rec: Record "Purchase Header";RunTrigger: Boolean)
    var
        Value: Variant;
        SetupValue: Boolean;
        ConfirmDelete: Label 'Are you sure you want to delete this order?';
    begin
        if not RunTrigger then
          exit;

        SettingID := 5;
        if not DynamicModuleHelper.ModuleIsEnabledAndReturnSetupValue(GetModuleName(),SettingID,Value) then
          exit;

        SetupValue := Value;
        if SetupValue then
          if not Confirm(ConfirmDelete) then
            Error('');
    end;

    procedure GetModuleName(): Text
    begin
        exit('Proper examples to test setup and process');
    end;

    procedure GetDummyModuleName(): Text
    begin
        exit('Examples to show each data type usage');
    end;
}

