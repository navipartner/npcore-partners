table 6014479 "Dynamic Module"
{
    // NPR5.38/NPKNAV/20180126  CASE 294992 Transport NPR5.38 - 26 January 2018
    // NPR5.43/THRO  /20180525  CASE 316419 Dynamic Module added to DeleteSetting and RestoreData to keep Enabled setting on modules after discover

    Caption = 'Dynamic Module';

    fields
    {
        field(1;"Module Guid";Guid)
        {
            Caption = 'Module Guid';
        }
        field(10;"Module Name";Text[50])
        {
            Caption = 'Module Name';
        }
        field(20;Enabled;Boolean)
        {
            Caption = 'Enabled';

            trigger OnValidate()
            begin
                DynamicModuleSetting.SetRange("Module Guid","Module Guid");
                DynamicModuleSetting.ModifyAll(Enabled,Enabled);
            end;
        }
    }

    keys
    {
        key(Key1;"Module Guid")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        DynamicModuleSetting.SetRange("Module Guid","Module Guid");
        DynamicModuleSetting.DeleteAll;
    end;

    var
        DynamicModuleSetting: Record "Dynamic Module Setting";
        DynamicModuleHelper: Codeunit "Dynamic Module Helper";

    [IntegrationEvent(TRUE, false)]
    local procedure OnDiscoverModule()
    begin
    end;

    procedure DiscoverModules()
    var
        DynamicModuleTemp: Record "Dynamic Module" temporary;
        DynamicModuleSettingTemp: Record "Dynamic Module Setting" temporary;
    begin
        //-NPR5.43 [316419]
        DynamicModuleHelper.DeleteSettings(DynamicModuleTemp,DynamicModuleSettingTemp);
        OnDiscoverModule;
        DynamicModuleHelper.RestoreData(DynamicModuleTemp,DynamicModuleSettingTemp);
        //+NPR5.43 [316419]
    end;
}

