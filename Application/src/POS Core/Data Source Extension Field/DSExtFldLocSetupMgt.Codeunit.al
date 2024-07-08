codeunit 6184554 "NPR DS Ext.Fld. Loc.Setup Mgt."
{
    Access = Internal;

    var
        _LocationFromTok: Label 'LocationFrom', Locked = true;
        _LocationFilterTok: label 'LocationFilter', Locked = true;

    internal procedure OpenLocationFilterSetupPage(var DataSourceExtFieldSetup: Record "NPR POS DS Exten. Field Setup"; EditMode: boolean)
    var
        DSExtFieldSetupParams: Page "NPR DS Ext.Fld. Location Setup";
        LocationFrom: Enum "NPR Location Filter From";
        LocationFilter: Text;
    begin
        GetLocationFilterParams(DataSourceExtFieldSetup, LocationFrom, LocationFilter);
        Clear(DSExtFieldSetupParams);
        DSExtFieldSetupParams.SetLocationFilterParamValues(LocationFrom, LocationFilter);
        DSExtFieldSetupParams.Editable(EditMode);
        if not EditMode then
            DSExtFieldSetupParams.Run()
        else
            if DSExtFieldSetupParams.RunModal() = Action::Yes then begin
                DSExtFieldSetupParams.GetLocationFilterParamValues(LocationFrom, LocationFilter);
                SetLocationFilterParams(DataSourceExtFieldSetup, LocationFrom, LocationFilter);
            end;
    end;

    internal procedure GetLocationFilterParams(DataSourceExtFieldSetup: Record "NPR POS DS Exten. Field Setup"; var LocationFrom: Enum "NPR Location Filter From"; var LocationFilter: Text)
    var
        JsonHelper: Codeunit "NPR Json Helper";
        ParameterSet: JsonToken;
    begin
        if not ParameterSet.ReadFrom(DataSourceExtFieldSetup.GetAdditionalParameterSet()) then
            exit;
        LocationFrom := Enum::"NPR Location Filter From".FromInteger(JsonHelper.GetJInteger(ParameterSet, _LocationFromTok, false, 0));
        LocationFilter := JsonHelper.GetJText(ParameterSet, _LocationFilterTok, false);
    end;

    internal procedure SetLocationFilterParams(var DataSourceExtFieldSetup: Record "NPR POS DS Exten. Field Setup"; LocationFrom: Enum "NPR Location Filter From"; LocationFilter: Text)
    var
        ParameterSet: JsonToken;
    begin
        ParameterSet.ReadFrom('{}');
        ParameterSet.AsObject().Add(_LocationFromTok, LocationFrom.AsInteger());
        ParameterSet.AsObject().Add(_LocationFilterTok, LocationFilter);
        DataSourceExtFieldSetup.SetAdditionalParameterSet(ParameterSet);
        DataSourceExtFieldSetup.Modify();
    end;

    internal procedure GetDSExtFldLocationFilter(SalePOS: Record "NPR POS Sale"; LocationFrom: Enum "NPR Location Filter From"; PreDefinedLocationFilter: Text): Text
    var
        POSStore: Record "NPR POS Store";
        DSExtFieldSetupPublic: Codeunit "NPR DS Ext.Field Setup Public";
        POSSession: Codeunit "NPR POS Session";
        POSSetup: Codeunit "NPR POS Setup";
        LocationFilter: Text;
        Handled: Boolean;
    begin
        LocationFilter := PreDefinedLocationFilter;
        DSExtFieldSetupPublic.OnGetDSExtFldLocationFilter(SalePOS, LocationFrom, LocationFilter, Handled);
        if Handled then
            exit(LocationFilter);

        case LocationFrom of
            LocationFrom::NotUsed:
                exit('');
            LocationFrom::PosSaleHdr:
                exit(SalePOS."Location Code");
            LocationFrom::PosStore:
                begin
                    if not POSStore.Get(SalePOS."POS Store Code") then begin
                        if not POSSession.IsInitialized() then
                            exit(SalePOS."Location Code");
                        POSSession.GetSetup(POSSetup);
                        POSSetup.GetPOSStore(POSStore);
                    end;
                    exit(POSStore."Location Code");
                end;
            LocationFrom::LocationFilter:
                exit(PreDefinedLocationFilter);
        end;
    end;
}