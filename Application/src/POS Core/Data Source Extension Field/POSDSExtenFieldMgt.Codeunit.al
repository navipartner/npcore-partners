codeunit 6184501 "NPR POS DS Exten. Field Mgt."
{
    Access = Internal;

    internal procedure FilterDataSourceExtFieldSetup(var DataSourceExtFieldSetup: Record "NPR POS DS Exten. Field Setup"; Module: Enum "NPR POS DS Extension Module"; DataSourceName: Text[50]; ExtensionName: Text[50]; ExtensionField: Text[50])
    begin
        Clear(DataSourceExtFieldSetup);
        DataSourceExtFieldSetup.SetCurrentKey("Extension Module", "Data Source Name", "Extension Name", "Extension Field", "Exclude from Data Source", "Exten.Field Instance Name");
        DataSourceExtFieldSetup.SetRange("Extension Module", Module);
        DataSourceExtFieldSetup.SetRange("Data Source Name", DataSourceName);
        DataSourceExtFieldSetup.SetRange("Extension Name", ExtensionName);
        if ExtensionField <> '' then
            DataSourceExtFieldSetup.SetRange("Extension Field", ExtensionField);
    end;

    internal procedure LookupDataSource(Module: Enum "NPR POS DS Extension Module"; var Text: Text): Boolean
    var
        DataSourceExtFieldSetupInt: Interface "NPR POS DS Exten. Field Setup";
        DataSources: Page "NPR POS Data Sources";
    begin
        DataSourceExtFieldSetupInt := Module;
        DataSources.SetSupportedDataSourceFilter(DataSourceExtFieldSetupInt.GetSupportedDataSourceNameFilter());
        DataSources.SetCurrent(CopyStr(Text, 1, 50));
        DataSources.LookupMode := true;
        if DataSources.RunModal() = Action::LookupOK then begin
            Text := DataSources.GetCurrent();
            exit(true);
        end;
        exit(false);
    end;

    internal procedure LookupExtensionName(Module: Enum "NPR POS DS Extension Module"; DataSourceName: Text[50]; var Text: Text): Boolean
    var
        TempExtensionNameList: Record "NPR Retail List" temporary;
        DataSourceExtFieldSetupInt: Interface "NPR POS DS Exten. Field Setup";
    begin
        DataSourceExtFieldSetupInt := Module;
        DataSourceExtFieldSetupInt.GetSupportedDataSourceExtensionNameList(DataSourceName, TempExtensionNameList);
        exit(LookupRetailValue(TempExtensionNameList, Text));
    end;

    internal procedure LookupExtensionField(Module: Enum "NPR POS DS Extension Module"; DataSourceName: Text[50]; ExtensionName: Text[50]; var Text: Text): Boolean
    var
        TempExtensionNameList: Record "NPR Retail List" temporary;
        DataSourceExtFieldSetupInt: Interface "NPR POS DS Exten. Field Setup";
    begin
        DataSourceExtFieldSetupInt := Module;
        DataSourceExtFieldSetupInt.GetSupportedExtensionFieldList(DataSourceName, ExtensionName, TempExtensionNameList);
        exit(LookupRetailValue(TempExtensionNameList, Text));
    end;

    local procedure LookupRetailValue(var TempRetailList: Record "NPR Retail List"; var Text: Text): Boolean
    var
        RetailList: Page "NPR Retail List";
    begin
        Clear(RetailList);
        RetailList.SetShowValue(true);
        RetailList.SetRec(TempRetailList);
        RetailList.LookupMode(true);
        if RetailList.RunModal() = Action::LookupOK then begin
            RetailList.GetRec(TempRetailList);
            Text := TempRetailList.Choice;
            exit(true);
        end;
        exit(false);
    end;

    internal procedure EnsureDataSourceIsValid(var DataSourceExtFieldSetup: Record "NPR POS DS Exten. Field Setup")
    var
        TempDataSource: Record "NPR POS Data Source Discovery" temporary;
        DataSourceExtFieldSetupInt: Interface "NPR POS DS Exten. Field Setup";
        SupportedDataSourceNameFilter: Text;
    begin
        if DataSourceExtFieldSetup."Data Source Name" = '' then
            exit;
        TempDataSource.DiscoverDataSources();
        DataSourceExtFieldSetupInt := DataSourceExtFieldSetup."Extension Module";
        SupportedDataSourceNameFilter := DataSourceExtFieldSetupInt.GetSupportedDataSourceNameFilter();
        if SupportedDataSourceNameFilter <> '' then begin
            TempDataSource.FilterGroup(2);
            TempDataSource.SetFilter(Name, SupportedDataSourceNameFilter);
            TempDataSource.FilterGroup(0);
        end;
        TempDataSource.Name := DataSourceExtFieldSetup."Data Source Name";
        if not TempDataSource.Find() then begin
            TempDataSource.SetFilter(Name, '@%1*', DataSourceExtFieldSetup."Data Source Name");
            TempDataSource.FindFirst();
        end;
        DataSourceExtFieldSetup."Data Source Name" := TempDataSource.Name;
    end;

    internal procedure EnsureExtensionNameIsValid(var DataSourceExtFieldSetup: Record "NPR POS DS Exten. Field Setup")
    var
        TempExtensionNameList: Record "NPR Retail List" temporary;
        DataSourceExtFieldSetupInt: Interface "NPR POS DS Exten. Field Setup";
        NotValidErr: Label '%1 ''%2'' is not valid for %3 = %4, and %5 = %6.', Comment = '%1, %3, %5 - field captions; %2, %4, %6 - field values. Fields: "Extension Name", "Extension Module", "Data Source Name"';
    begin
        if DataSourceExtFieldSetup."Extension Name" = '' then
            exit;
        DataSourceExtFieldSetup.TestField("Data Source Name");
        DataSourceExtFieldSetupInt := DataSourceExtFieldSetup."Extension Module";
        DataSourceExtFieldSetupInt.GetSupportedDataSourceExtensionNameList(DataSourceExtFieldSetup."Data Source Name", TempExtensionNameList);
        if not CheckRetailValueExists(TempExtensionNameList, DataSourceExtFieldSetup."Extension Name") then
            Error(NotValidErr,
                DataSourceExtFieldSetup.FieldCaption("Extension Name"), DataSourceExtFieldSetup."Extension Name",
                DataSourceExtFieldSetup.FieldCaption("Extension Module"), DataSourceExtFieldSetup."Extension Module",
                DataSourceExtFieldSetup.FieldCaption("Data Source Name"), DataSourceExtFieldSetup."Data Source Name");
    end;

    internal procedure EnsureExtensionFieldIsValid(var DataSourceExtFieldSetup: Record "NPR POS DS Exten. Field Setup")
    var
        TempExtensionNameList: Record "NPR Retail List" temporary;
        DataSourceExtFieldSetupInt: Interface "NPR POS DS Exten. Field Setup";
        NotValidErr: Label '%1 ''%2'' is not valid for %3 = %4, %5 = %6, and %7 = %8.', Comment = '%1, %3, %5, %7 - field captions; %2, %4, %6, %8 - field values. Fields: "Extension Field", "Extension Module", "Data Source Name", "Extension Name"';
    begin
        if DataSourceExtFieldSetup."Extension Field" = '' then
            exit;
        DataSourceExtFieldSetup.TestField("Data Source Name");
        DataSourceExtFieldSetup.TestField("Extension Name");
        DataSourceExtFieldSetupInt := DataSourceExtFieldSetup."Extension Module";
        DataSourceExtFieldSetupInt.GetSupportedExtensionFieldList(DataSourceExtFieldSetup."Data Source Name", DataSourceExtFieldSetup."Extension Name", TempExtensionNameList);
        if not CheckRetailValueExists(TempExtensionNameList, DataSourceExtFieldSetup."Extension Field") then
            Error(NotValidErr,
                DataSourceExtFieldSetup.FieldCaption("Extension Field"), DataSourceExtFieldSetup."Extension Field",
                DataSourceExtFieldSetup.FieldCaption("Extension Module"), DataSourceExtFieldSetup."Extension Module",
                DataSourceExtFieldSetup.FieldCaption("Data Source Name"), DataSourceExtFieldSetup."Data Source Name",
                DataSourceExtFieldSetup.FieldCaption("Extension Name"), DataSourceExtFieldSetup."Extension Name");
    end;

    local procedure CheckRetailValueExists(var TempRetailList: Record "NPR Retail List"; var Value: Text[50]): Boolean
    begin
        TempRetailList.SetRange(Choice, Value);
        if not TempRetailList.FindFirst() then begin
            TempRetailList.SetFilter(Choice, '@%1*', Value);
            if not TempRetailList.FindFirst() then
                exit(false);
        end;
        Value := CopyStr(TempRetailList.Choice, 1, MaxStrLen(Value));
        exit(true);
    end;

    procedure OpenAdditionalParameterPage(var DataSourceExtFieldSetup: Record "NPR POS DS Exten. Field Setup"; EditMode: boolean)
    var
        DataSourceExtFieldSetupInt: Interface "NPR POS DS Exten. Field Setup";
    begin
        DataSourceExtFieldSetupInt := DataSourceExtFieldSetup."Extension Module";
        DataSourceExtFieldSetupInt.OpenAdditionalParameterPage(DataSourceExtFieldSetup, EditMode);
    end;
}