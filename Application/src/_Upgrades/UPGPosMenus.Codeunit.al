codeunit 6014539 "NPR UPG Pos Menus"
{
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        UpgradeTagMgt: Codeunit "Upgrade Tag";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR UPG Pos Menus', 'OnUpgradePerCompany');

        ReplaceItemAddonPOSAction();
        if not UpgradeTagMgt.HasUpgradeTag(GetUpgradeTag()) then begin
            AdjustSplitBillPOSActionParameters();
            UpgradeTagMgt.SetUpgradeTag(GetUpgradeTag());
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
                            'InputType':
                                ParamValue.Name := 'SeatingSelectionMethod';
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

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Upgrade Tag", 'OnGetPerCompanyUpgradeTags', '', false, false)]
    local procedure OnGetPerCompanyTags(var PerCompanyUpgradeTags: List of [Code[250]]);
    begin
        PerCompanyUpgradeTags.Add(GetUpgradeTag());
    end;

    procedure GetUpgradeTag(): Text
    begin
        exit(CopyStr(CompanyName() + ' NPRSplitBillActionToWF2 ' + Format(Today(), 0, 9), 1, 250));
    end;
}