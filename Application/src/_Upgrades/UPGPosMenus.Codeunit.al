codeunit 6014539 "NPR UPG Pos Menus"
{
    Access = Internal;
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        UpgradeTagMgt: Codeunit "Upgrade Tag";
        UpgTagDef: Codeunit "NPR Upgrade Tag Definitions";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR UPG Pos Menus', 'OnUpgradePerCompany');

        ReplaceItemAddonPOSAction();
        if not UpgradeTagMgt.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG Pos Menus", 'AdjustSplitBillPOSActionParameters')) then begin
            AdjustSplitBillPOSActionParameters();
            UpgradeTagMgt.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG Pos Menus", 'AdjustSplitBillPOSActionParameters'));
        end;
        if not UpgradeTagMgt.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG Pos Menus", 'AdjustDeletePOSLinePOSActionParameters')) then begin
            AdjustDeletePOSLinePOSActionParameters();
            UpgradeTagMgt.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG Pos Menus", 'AdjustDeletePOSLinePOSActionParameters'));
        end;
        if not UpgradeTagMgt.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG Pos Menus", 'PosMenuPaymentButtonsAutoEnabled')) then begin
            SetPosMenuPaymentButtonsAutoEnabled();
            UpgradeTagMgt.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG Pos Menus", 'PosMenuPaymentButtonsAutoEnabled'));
        end;
        if not UpgradeTagMgt.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG Pos Menus", 'POSDataSourceExtFieldSetup')) then begin
            GeneratePOSDataSourceExtFieldSetup();
            UpgradeTagMgt.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG Pos Menus", 'POSDataSourceExtFieldSetup'));
        end;

        LogMessageStopwatch.LogFinish();
    end;

    local procedure ReplaceItemAddonPOSAction()
    var
        ParamValue: Record "NPR POS Parameter Value";
        ParamValue2: Record "NPR POS Parameter Value";
        POSAction: Record "NPR POS Action";
        POSMenuButton: Record "NPR POS Menu Button";
        POSMenuButton2: Record "NPR POS Menu Button";
        ParamMgt: Codeunit "NPR POS Action Param. Mgt.";
    begin
        if not POSAction.Get('RUN_ITEM_ADDONS') then
            exit;
        POSMenuButton.SetRange("Action Type", POSMenuButton."Action Type"::Action);
        POSMenuButton.SetRange("Action Code", 'INSERT_ITEM_ADDONS');
        if POSMenuButton.FindSet() then
            repeat
                if not ParamValue.get(Database::"NPR POS Menu Button", POSMenuButton."Menu Code", POSMenuButton.ID, POSMenuButton.RecordId, 'ItemAddOnNo') then
                    ParamValue.init();

                POSMenuButton2 := POSMenuButton;
                POSMenuButton2."Action Code" := POSAction.Code;
                if POSAction."Bound to DataSource" then
                    POSMenuButton2.Enabled := POSMenuButton2.Enabled::Auto;
                POSMenuButton2."Data Source Name" := POSAction."Data Source Name";
                POSMenuButton2."Blocking UI" := POSAction."Blocking UI";
                if (POSAction.Tooltip <> '') and (POSMenuButton2.Tooltip = '') then
                    POSMenuButton2.Tooltip := POSAction.Tooltip;
                if (POSAction."Secure Method Code" <> '') and (POSMenuButton2."Secure Method Code" = '') then
                    POSMenuButton2."Secure Method Code" := POSAction."Secure Method Code";
                POSMenuButton2.Modify();

                ParamMgt.ClearParametersForRecord(POSMenuButton2.RecordId, 0);
                ParamMgt.CopyFromActionToMenuButton(POSMenuButton2."Action Code", POSMenuButton2);

                if ParamValue.Value <> '' then
                    if ParamValue2.get(Database::"NPR POS Menu Button", POSMenuButton2."Menu Code", POSMenuButton2.ID, POSMenuButton2.RecordId, 'ItemAddOnNo') then begin
                        ParamValue2.Value := ParamValue.Value;
                        ParamValue2.Modify();
                    end;
            until POSMenuButton.Next() = 0;
    end;

    local procedure AdjustSplitBillPOSActionParameters()
    var
        POSAction: Record "NPR POS Action";
        POSMenuButton: Record "NPR POS Menu Button";
        ParamValue: Record "NPR POS Parameter Value";
        TempParamValue: Record "NPR POS Parameter Value" temporary;
        ParamMgt: Codeunit "NPR POS Action Param. Mgt.";
    begin
        if not TempParamValue.IsTemporary then
            exit;
        if not POSAction.Get('SPLIT_BILL') then
            exit;
        POSMenuButton.SetRange("Action Type", POSMenuButton."Action Type"::Action);
        POSMenuButton.SetRange("Action Code", POSAction.Code);
        if POSMenuButton.FindSet() then
            repeat
                TempParamValue.DeleteAll();
                ParamValue.SetRange("Table No.", Database::"NPR POS Menu Button");
                ParamValue.SetRange(Code, POSMenuButton."Menu Code");
                ParamValue.SetRange("Record ID", POSMenuButton.RecordId);
                ParamValue.SetRange(ID, POSMenuButton.ID);
                if ParamValue.FindSet() then
                    repeat
                        TempParamValue := ParamValue;
                        TempParamValue.Insert();
                    until ParamValue.Next() = 0;

                ParamMgt.ClearParametersForRecord(POSMenuButton.RecordId, 0);
                ParamMgt.CopyFromActionToMenuButton(POSMenuButton."Action Code", POSMenuButton);

                if TempParamValue.FindSet() then
                    repeat
                        ParamValue := TempParamValue;
                        case TempParamValue.Name of
                            'SeatingSelectionMethod':
                                ParamValue.Name := 'InputType';
                            'FixedSeatingCode':
                                ParamValue.Name := 'SeatingCode';
                        end;
                        if ParamValue.Find() then begin
                            ParamValue.Value := TempParamValue.Value;
                            ParamValue.Modify();
                        end;
                    until TempParamValue.Next() = 0;
            until POSMenuButton.Next() = 0;
    end;

    local procedure AdjustDeletePOSLinePOSActionParameters()
    var
        POSAction: Record "NPR POS Action";
        POSMenuButton: Record "NPR POS Menu Button";
        ParamValue: Record "NPR POS Parameter Value";
        TempParamValue: Record "NPR POS Parameter Value" temporary;
        ParamMgt: Codeunit "NPR POS Action Param. Mgt.";
    begin
        if not TempParamValue.IsTemporary then
            exit;
        if not POSAction.Get('DELETE_POS_LINE') then
            exit;
        POSMenuButton.SetRange("Action Type", POSMenuButton."Action Type"::Action);
        POSMenuButton.SetRange("Action Code", POSAction.Code);
        if POSMenuButton.FindSet() then
            repeat
                TempParamValue.DeleteAll();
                ParamValue.SetRange("Table No.", Database::"NPR POS Menu Button");
                ParamValue.SetRange(Code, POSMenuButton."Menu Code");
                ParamValue.SetRange("Record ID", POSMenuButton.RecordId);
                ParamValue.SetRange(ID, POSMenuButton.ID);
                if ParamValue.FindSet() then
                    repeat
                        TempParamValue := ParamValue;
                        TempParamValue.Insert();
                    until ParamValue.Next() = 0;

                ParamMgt.ClearParametersForRecord(POSMenuButton.RecordId, 0);
                ParamMgt.CopyFromActionToMenuButton(POSMenuButton."Action Code", POSMenuButton);

                if TempParamValue.FindSet() then
                    repeat
                        ParamValue := TempParamValue;
                        if ParamValue.Find() then begin
                            if ParamValue.Name = 'ConfirmDialog' then begin
                                if UpperCase(TempParamValue.Value) = 'YES' then
                                    ParamValue.Value := 'true';
                            end else
                                ParamValue.Value := TempParamValue.Value;
                            ParamValue.Modify();
                        end;
                    until TempParamValue.Next() = 0;
            until POSMenuButton.Next() = 0;
    end;

    local procedure SetPosMenuPaymentButtonsAutoEnabled()
    var
        PosMenuButton: Record "NPR POS Menu Button";
        POSDataMgt: Codeunit "NPR POS Data Management";
    begin
        PosMenuButton.SetRange("Action Type", PosMenuButton."Action Type"::PaymentType);
        PosMenuButton.SetFilter("Action Code", '<>%1', '');
        PosMenuButton.ModifyAll(Enabled, PosMenuButton.Enabled::Auto);
        PosMenuButton.SetRange("Data Source Name", '');
        PosMenuButton.ModifyAll("Data Source Name", POSDataMgt.POSDataSource_BuiltInSaleLine());
    end;

    local procedure GeneratePOSDataSourceExtFieldSetup()
    var
        POSMenuButton: Record "NPR POS Menu Button";
    begin
        POSMenuButton.SetFilter(Caption, '*CollectInStore.*|*SalesDoc.*');
        if POSMenuButton.FindSet() then
            repeat
                POSMenuButton.Caption := DelChr(POSMenuButton.Caption, '=', ' ');
                if POSMenuButton.Caption.Contains('.OpenOrdersQty}') then
                    AddDataSourceExtFieldSetup(POSMenuButton, Enum::"NPR POS DS Extension Module"::DocImport, 'SalesDoc', 'OpenOrdersQty');
                if POSMenuButton.Caption.Contains('.UnprocessedOrdersExist}') then
                    AddDataSourceExtFieldSetup(POSMenuButton, Enum::"NPR POS DS Extension Module"::ClickCollect, 'CollectInStore', 'UnprocessedOrdersExist');
                if POSMenuButton.Caption.Contains('.UnprocessedOrdersQty}') then
                    AddDataSourceExtFieldSetup(POSMenuButton, Enum::"NPR POS DS Extension Module"::ClickCollect, 'CollectInStore', 'UnprocessedOrdersQty');
                if POSMenuButton.Caption.Contains('.ProcessedOrdersExist}') then
                    AddDataSourceExtFieldSetup(POSMenuButton, Enum::"NPR POS DS Extension Module"::ClickCollect, 'CollectInStore', 'ProcessedOrdersExist');
                if POSMenuButton.Caption.Contains('.ProcessedOrdersQty}') then
                    AddDataSourceExtFieldSetup(POSMenuButton, Enum::"NPR POS DS Extension Module"::ClickCollect, 'CollectInStore', 'ProcessedOrdersQty');
            until POSMenuButton.Next() = 0;
    end;

    local procedure AddDataSourceExtFieldSetup(POSMenuButton: Record "NPR POS Menu Button"; Module: Enum "NPR POS DS Extension Module"; ExtentionName: Text[50]; ExtentionField: Text[50])
    var
        DataSourceExtFieldSetup: Record "NPR POS DS Exten. Field Setup";
        POSParameterValue: Record "NPR POS Parameter Value";
        DSExtFieldSetupPublic: Codeunit "NPR DS Ext.Field Setup Public";
        POSDataMgt: Codeunit "NPR POS Data Management";
        LocationFrom: Enum "NPR Location Filter From";
        LocationFilter: Text;
        ButtonParameterFound: Boolean;
    begin
        DSExtFieldSetupPublic.FilterDataSourceExtFieldSetup(DataSourceExtFieldSetup, Module, POSDataMgt.POSDataSource_BuiltInSale(), ExtentionName, ExtentionField);
        DataSourceExtFieldSetup.SetRange("Exten.Field Instance Name", ExtentionField);
        if not DataSourceExtFieldSetup.IsEmpty() then
            exit;
        DataSourceExtFieldSetup.Init();
        DataSourceExtFieldSetup."Extension Module" := Module;
        DataSourceExtFieldSetup."Data Source Name" := POSDataMgt.POSDataSource_BuiltInSale();
        DataSourceExtFieldSetup."Extension Name" := ExtentionName;
        DataSourceExtFieldSetup.Validate("Extension Field", ExtentionField);
        DataSourceExtFieldSetup."Entry No." := 0;
        DataSourceExtFieldSetup.Insert();

        LocationFrom := LocationFrom::PosStore;
        ButtonParameterFound := POSParameterValue.Get(Database::"NPR POS Menu Button", POSMenuButton."Menu Code", POSMenuButton.ID, POSMenuButton.RecordId(), 'Location From');
        if not ButtonParameterFound then
            ButtonParameterFound := POSParameterValue.Get(Database::"NPR POS Menu Button", POSMenuButton."Menu Code", POSMenuButton.ID, POSMenuButton.RecordId(), 'LocationFrom');
        if ButtonParameterFound and (POSParameterValue.Value = 'Location Filter Parameter') then begin
            LocationFrom := LocationFrom::LocationFilter;
            ButtonParameterFound := POSParameterValue.Get(DATABASE::"NPR POS Menu Button", POSMenuButton."Menu Code", POSMenuButton.ID, POSMenuButton.RecordId, 'Location Filter');
            if not ButtonParameterFound then
                ButtonParameterFound := POSParameterValue.Get(DATABASE::"NPR POS Menu Button", POSMenuButton."Menu Code", POSMenuButton.ID, POSMenuButton.RecordId, 'LocationFilter');
            if ButtonParameterFound then
                LocationFilter := POSParameterValue.Value;
        end;
        DSExtFieldSetupPublic.SetLocationFilterParams(DataSourceExtFieldSetup, LocationFrom, LocationFilter);
    end;
}
