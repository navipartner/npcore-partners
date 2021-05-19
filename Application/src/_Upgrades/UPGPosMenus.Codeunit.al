codeunit 6014539 "NPR UPG Pos Menus"
{
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    begin
        ReplaceItemAddonPOSAction();
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
}