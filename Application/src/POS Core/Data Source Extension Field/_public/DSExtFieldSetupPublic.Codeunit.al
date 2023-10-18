codeunit 6184553 "NPR DS Ext.Field Setup Public"
{
    Access = Public;

    procedure FilterDataSourceExtFieldSetup(var DataSourceExtFieldSetup: Record "NPR POS DS Exten. Field Setup"; Module: Enum "NPR POS DS Extension Module"; DataSourceName: Text[50]; ExtensionName: Text[50]; ExtensionField: Text[50])
    var
        DataSourceExtFieldMgt: Codeunit "NPR POS DS Exten. Field Mgt.";
    begin
        DataSourceExtFieldMgt.FilterDataSourceExtFieldSetup(DataSourceExtFieldSetup, Module, DataSourceName, ExtensionName, ExtensionField);
    end;

    procedure OpenLocationFilterSetupPage(var DataSourceExtFieldSetup: Record "NPR POS DS Exten. Field Setup"; EditMode: boolean)
    var
        DSExtFldLocSetupMgt: Codeunit "NPR DS Ext.Fld. Loc.Setup Mgt.";
    begin
        DSExtFldLocSetupMgt.OpenLocationFilterSetupPage(DataSourceExtFieldSetup, EditMode);
    end;

    procedure GetLocationFilterParams(DataSourceExtFieldSetup: Record "NPR POS DS Exten. Field Setup"; var LocationFrom: Enum "NPR Location Filter From"; var LocationFilter: Text)
    var
        DSExtFldLocSetupMgt: Codeunit "NPR DS Ext.Fld. Loc.Setup Mgt.";
    begin
        DSExtFldLocSetupMgt.GetLocationFilterParams(DataSourceExtFieldSetup, LocationFrom, LocationFilter);
    end;

    procedure SetLocationFilterParams(var DataSourceExtFieldSetup: Record "NPR POS DS Exten. Field Setup"; LocationFrom: Enum "NPR Location Filter From"; LocationFilter: Text)
    var
        DSExtFldLocSetupMgt: Codeunit "NPR DS Ext.Fld. Loc.Setup Mgt.";
    begin
        DSExtFldLocSetupMgt.SetLocationFilterParams(DataSourceExtFieldSetup, LocationFrom, LocationFilter);
    end;

    procedure GetDSExtFldLocationFilter(SalePOS: Record "NPR POS Sale"; LocationFrom: Enum "NPR Location Filter From"; PreDefinedLocationFilter: Text): Text
    var
        DSExtFldLocSetupMgt: Codeunit "NPR DS Ext.Fld. Loc.Setup Mgt.";
    begin
        exit(DSExtFldLocSetupMgt.GetDSExtFldLocationFilter(SalePOS, LocationFrom, PreDefinedLocationFilter));
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnGetDSExtFldLocationFilter(SalePOS: Record "NPR POS Sale"; LocationFrom: Enum "NPR Location Filter From"; var LocationFilter: Text; var Handled: Boolean)
    begin
    end;
}