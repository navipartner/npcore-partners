codeunit 6014469 "Dynamic Module Helper"
{
    // NPR5.38/NPKNAV/20180126  CASE 294992 Transport NPR5.38 - 26 January 2018
    // NPR5.43/THRO  /20180525  CASE 316419 Backup and Restore Enabled setting on modules
    // NPR5.48/TJ    /20190123  CASE 304372 New function ReturnSetupValueWithError
    // NPR5.48/TJ    /20181102  CASE 333210 Property FunctionVisibility changed to External for functions CreateOrFindModule, CreateModuleSetting and ModuleIsEnabledAndReturnSetupValue


    trigger OnRun()
    begin
    end;

    var
        ErrorType: Option WrongDataType,LengthExceeded,WrongOption;
        SetupSettingErr: Label 'Module %1 or setting %2 doesn''t exist or module isn''t enabled.';

        procedure CreateOrFindModule(ModuleName: Text[50];var DynamicModule: Record "Dynamic Module")
    begin
        if not GetDynamicModuleFromName(ModuleName,DynamicModule) then begin
          DynamicModule."Module Name" := ModuleName;
          InsertModule(DynamicModule);
        end;
    end;

        procedure CreateModuleSetting(DynamicModule: Record "Dynamic Module";SettingID: Integer;Name: Text;DataType: Integer;AdditionalPropertyType: Option;AdditionalPropertyValue: Text;SetupValue: Variant)
    var
        DynamicModuleSetting: Record "Dynamic Module Setting";
        SettingAlreadyExistsErr: Label 'Setting with name %1 already exists in module %2.';
    begin
        if DynamicModuleSetting.Get(DynamicModule."Module Guid",SettingID) then
          Error(SettingAlreadyExistsErr,Name,DynamicModule."Module Name");
        DynamicModuleSetting."Module Guid" := DynamicModule."Module Guid";
        DynamicModuleSetting."Setting ID" := SettingID;
        DynamicModuleSetting.Name := Name;
        DynamicModuleSetting."Data Type" := DataType;
        DynamicModuleSetting."Module Name" := DynamicModule."Module Name";
        AssignAdditionalProperty(DynamicModuleSetting,AdditionalPropertyType,AdditionalPropertyValue);
        ValidateModuleSetting(DynamicModuleSetting,SetupValue);
        PresetValuesAction(DynamicModuleSetting,1);
        DynamicModuleSetting.Insert;
    end;

    local procedure InsertModule(var DynamicModule: Record "Dynamic Module")
    begin
        DynamicModule."Module Guid" := CreateGuid;
        DynamicModule.Enabled := false;
        DynamicModule.Insert;
    end;

    local procedure ValidateModuleSetting(var DynamicModuleSetting: Record "Dynamic Module Setting";DefaultValue: Variant)
    begin
        CheckSetupValue(DynamicModuleSetting,DefaultValue);
        SetSetupValue(DynamicModuleSetting,DefaultValue);
    end;

    local procedure PresetValuesAction(var DynamicModuleSetting: Record "Dynamic Module Setting";ActionToTake: Option Get,Set)
    begin
        with DynamicModuleSetting do
          case ActionToTake of
            ActionToTake::Get:
              begin
                "Formatted Value" := "Preset Formatted Value";
                "XML Formatted Value" := "Preset XML Formatted Value";
                "Boolean Value" := "Preset Boolean Value";
                "Date Value" := "Preset Date Value";
                "DateFormula Value" := "Preset DateFormula Value";
                "DateTime Value" := "Preset DateTime Value";
                "Decimal Value" := "Preset Decimal Value";
                "Duration Value" := "Preset Duration Value";
                "Integer Value" := "Preset Integer Value";
                "Time Value" := "Preset Time Value";
              end;
            ActionToTake::Set:
              begin
                "Preset Formatted Value" := "Formatted Value";
                "Preset XML Formatted Value" := "XML Formatted Value";
                "Preset Boolean Value" := "Boolean Value";
                "Preset Date Value" := "Date Value";
                "Preset DateFormula Value" := "DateFormula Value";
                "Preset DateTime Value" := "DateTime Value";
                "Preset Decimal Value" := "Decimal Value";
                "Preset Duration Value" := "Duration Value";
                "Preset Integer Value" := "Integer Value";
                "Preset Time Value" := "Time Value";
              end;
          end;
    end;

    procedure CheckSetupValue(DynamicModuleSetting: Record "Dynamic Module Setting";VariantValue: Variant)
    begin
        DataTypeAction(DynamicModuleSetting,VariantValue,0);
    end;

    procedure GetSetupValue(DynamicModuleSetting: Record "Dynamic Module Setting";var VariantValue: Variant)
    begin
        DataTypeAction(DynamicModuleSetting,VariantValue,1);
    end;

    procedure SetSetupValue(var DynamicModuleSetting: Record "Dynamic Module Setting";VariantValue: Variant)
    begin
        DataTypeAction(DynamicModuleSetting,VariantValue,2);
    end;

    local procedure DataTypeAction(var DynamicModuleSetting: Record "Dynamic Module Setting";var VariantValue: Variant;ActionToTake: Option Check,Get,Set)
    var
        GLSetup: Record "General Ledger Setup";
        TextValue: Text;
        IntegerValue: Integer;
        TypeHelper: Codeunit "Type Helper";
        DecimalPrecision: Decimal;
    begin
        with DynamicModuleSetting do begin
          case "Data Type" of
            "Data Type"::Boolean:
              case ActionToTake of
                ActionToTake::Check:
                  ShowError(not VariantValue.IsBoolean,DynamicModuleSetting,ErrorType::WrongDataType);
                ActionToTake::Get:
                    VariantValue := "Boolean Value";
                ActionToTake::Set:
                  "Boolean Value" := VariantValue;
              end;
            "Data Type"::Code,"Data Type"::Text:
              case ActionToTake of
                ActionToTake::Check:
                  begin
                    ShowError(not VariantValue.IsCode and not VariantValue.IsText,DynamicModuleSetting,ErrorType::WrongDataType);
                    TestField("Data Length");
                    if "Data Length" > MaxStrLen("Formatted Value") then begin
                      "Data Length" := MaxStrLen("Formatted Value");
                      ShowError(true,DynamicModuleSetting,ErrorType::LengthExceeded);
                    end;
                    TextValue := VariantValue;
                    ShowError(StrLen(TextValue) > "Data Length",DynamicModuleSetting,ErrorType::LengthExceeded);
                  end;
                ActionToTake::Get:
                  VariantValue := "Formatted Value";
              end;
            "Data Type"::Date:
              case ActionToTake of
                ActionToTake::Check:
                  ShowError(not VariantValue.IsDate,DynamicModuleSetting,ErrorType::WrongDataType);
                ActionToTake::Get:
                  VariantValue := "Date Value";
                ActionToTake::Set:
                  "Date Value" := VariantValue;
              end;
            "Data Type"::DateFormula:
              case ActionToTake of
                ActionToTake::Check:
                  ShowError(not VariantValue.IsDateFormula,DynamicModuleSetting,ErrorType::WrongDataType);
                ActionToTake::Get:
                  VariantValue := "DateFormula Value";
                ActionToTake::Set:
                  "DateFormula Value" := VariantValue;
              end;
            "Data Type"::DateTime:
              case ActionToTake of
                ActionToTake::Check:
                  ShowError(not VariantValue.IsDateTime,DynamicModuleSetting,ErrorType::WrongDataType);
                ActionToTake::Get:
                  VariantValue := "DateTime Value";
                ActionToTake::Set:
                  "DateTime Value" := VariantValue;
              end;
            "Data Type"::Decimal:
              case ActionToTake of
                ActionToTake::Check:
                  ShowError(not VariantValue.IsDecimal,DynamicModuleSetting,ErrorType::WrongDataType);
                ActionToTake::Get:
                  VariantValue := "Decimal Value";
                ActionToTake::Set:
                  begin
                    GLSetup.Get;
                    "Decimal Value" := VariantValue;
                    DecimalPrecision := GLSetup."Amount Rounding Precision";
                    if "Decimal Precision" <> 0 then
                      DecimalPrecision := "Decimal Precision";
                    "Decimal Value" := Round("Decimal Value",DecimalPrecision);
                    VariantValue := "Decimal Value";
                  end;
              end;
            "Data Type"::Duration:
              case ActionToTake of
                ActionToTake::Check:
                  ShowError(not VariantValue.IsDuration,DynamicModuleSetting,ErrorType::WrongDataType);
                ActionToTake::Get:
                  VariantValue := "Duration Value";
                ActionToTake::Set:
                  "Duration Value" := VariantValue;
              end;
            "Data Type"::Integer:
              case ActionToTake of
                ActionToTake::Check:
                  ShowError(not VariantValue.IsInteger,DynamicModuleSetting,ErrorType::WrongDataType);
                ActionToTake::Get:
                  VariantValue := "Integer Value";
                ActionToTake::Set:
                  "Integer Value" := VariantValue;
              end;
            "Data Type"::Option:
              case ActionToTake of
                ActionToTake::Check:
                  begin
                    ShowError(not VariantValue.IsOption and not VariantValue.IsInteger,DynamicModuleSetting,ErrorType::WrongDataType);
                    TestField("Option String");
                    IntegerValue := VariantValue;
                    ShowError((IntegerValue > TypeHelper.GetNumberOfOptions("Option String")) or (IntegerValue < 0),DynamicModuleSetting,ErrorType::WrongOption);
                  end;
                ActionToTake::Get:
                  VariantValue := "Integer Value";
                ActionToTake::Set:
                  begin
                    "Integer Value" := VariantValue;
                    TextValue := SelectStr("Integer Value" + 1,"Option String");
                    VariantValue := TextValue;
                  end;
              end;
            "Data Type"::Time:
              case ActionToTake of
                ActionToTake::Check:
                  ShowError(not VariantValue.IsTime,DynamicModuleSetting,ErrorType::WrongDataType);
                ActionToTake::Get:
                  VariantValue := "Time Value";
                ActionToTake::Set:
                  "Time Value" := VariantValue;
              end;
          end;
        end;
        if ActionToTake = ActionToTake::Set then
          FormatValue(DynamicModuleSetting,VariantValue);
    end;

    local procedure FormatValue(var DynamicModuleSetting: Record "Dynamic Module Setting";VariantValue: Variant)
    begin
        if DynamicModuleSetting."Data Type" = DynamicModuleSetting."Data Type"::Decimal then
          DynamicModuleSetting."Formatted Value" := Format(VariantValue,0,'<Precision,2:5><Standard Format,0>')
        else
          DynamicModuleSetting."Formatted Value" := Format(VariantValue);
        DynamicModuleSetting."XML Formatted Value" := Format(VariantValue,0,9);
    end;

    local procedure ShowError(IsError: Boolean;DynamicModuleSetting: Record "Dynamic Module Setting";ErrorType2: Option)
    var
        LengthExceededErr: Label 'Length can''t be greater than %1.';
        ValueDataTypeErr: Label 'Value needs to be of type %1.';
        OptionTypeErr: Label 'That option doesn''t exist. Available options are: %1.';
        RecordDoesntExistErr: Label 'Record with this primary key doesn''t exist.';
    begin
        if IsError then
          case ErrorType2 of
            ErrorType::WrongDataType:
              Error(ValueDataTypeErr,Format(DynamicModuleSetting."Data Type"));
            ErrorType::LengthExceeded:
              Error(LengthExceededErr,DynamicModuleSetting."Data Length");
            ErrorType::WrongOption:
              Error(OptionTypeErr,DynamicModuleSetting."Option String");
          end;
    end;

    procedure ShowModuleSettings(DynamicModule: Record "Dynamic Module")
    var
        DynamicModuleSetting: Record "Dynamic Module Setting";
    begin
        DynamicModuleSetting.SetRange("Module Guid",DynamicModule."Module Guid");
        PrepareScopeSettings(DynamicModuleSetting,false);
    end;

    procedure ShowAllSettings()
    var
        DynamicModuleSetting: Record "Dynamic Module Setting";
    begin
        PrepareScopeSettings(DynamicModuleSetting,true);
    end;

    local procedure PrepareScopeSettings(var DynamicModuleSetting: Record "Dynamic Module Setting";ShowAll: Boolean)
    var
        DynamicModuleSettingTemp: Record "Dynamic Module Setting" temporary;
        NewGuid: Guid;
        DynamicModule: Record "Dynamic Module";
        DynamicModuleSettings: Page "Dynamic Module Settings";
    begin
        if DynamicModuleSetting.FindSet then
          repeat
            if ShowAll and (NewGuid <> DynamicModuleSetting."Module Guid") then begin
              NewGuid := DynamicModuleSetting."Module Guid";
              DynamicModuleSettingTemp.Init;
              DynamicModuleSettingTemp."Module Guid" := NewGuid;
              DynamicModuleSettingTemp."Setting ID" := 0;
              DynamicModule.Get(NewGuid);
              DynamicModuleSettingTemp.Name := DynamicModule."Module Name";
              DynamicModuleSettingTemp.Insert;
            end;
            DynamicModuleSettingTemp := DynamicModuleSetting;
            DynamicModuleSettingTemp.Insert;
          until DynamicModuleSetting.Next = 0;
        DynamicModuleSettings.SetModuleSettings(DynamicModuleSettingTemp);
        DynamicModuleSettings.Run;
    end;

    local procedure GetDynamicModuleFromName(ModuleName: Text[50];var DynamicModule: Record "Dynamic Module"): Boolean
    var
        DynamicModule2: Record "Dynamic Module";
    begin
        DynamicModule2.SetRange("Module Name",ModuleName);
        if DynamicModule2.FindFirst then begin
          DynamicModule.Get(DynamicModule2."Module Guid");
          exit(true);
        end;
        exit(false);
    end;

        procedure ModuleIsEnabledAndReturnSetupValue(ModuleName: Text;SettingID: Integer;var SetupValue: Variant): Boolean
    var
        DynamicModule: Record "Dynamic Module";
        DynamicModuleSetting: Record "Dynamic Module Setting";
    begin
        if not GetDynamicModuleFromName(ModuleName,DynamicModule) then
          exit(false);
        if not DynamicModule.Enabled then
          exit(false);
        //-NPR5.48 [304372]
        //DynamicModuleSetting.GET(DynamicModule."Module Guid",SettingID);
        if not DynamicModuleSetting.Get(DynamicModule."Module Guid",SettingID) then
          exit(false);
        //+NPR5.48 [304372]
        GetSetupValue(DynamicModuleSetting,SetupValue);
        exit(true);
    end;

        procedure ReturnSetupValueWithError(ModuleName: Text;SettingID: Integer;var SetupValue: Variant)
    begin
        //-NPR5.48 [304372]
        if not ModuleIsEnabledAndReturnSetupValue(ModuleName,SettingID,SetupValue) then
          Error(SetupSettingErr,ModuleName,SettingID);
        //+NPR5.48 [304372]
    end;

    procedure UpdateAdditionalProperty(DynamicModule: Record "Dynamic Module";SettingID: Integer;AdditionalPropertyType: Option;AdditionalPropertyValue: Text)
    var
        DynamicModuleSetting: Record "Dynamic Module Setting";
    begin
        DynamicModuleSetting.Get(DynamicModule."Module Guid",SettingID);
        if AssignAdditionalProperty(DynamicModuleSetting,AdditionalPropertyType,AdditionalPropertyValue) then
          DynamicModuleSetting.Modify;
    end;

    local procedure AssignAdditionalProperty(var DynamicModuleSetting: Record "Dynamic Module Setting";AdditionalPropertyType: Option " ",Length,OptionString,DecimalPrecision;AdditionalPropertyValue: Text): Boolean
    var
        AdditionalPropertyTypeErr: Label 'You need to provide property type for which this value is set.';
        IntegerValue: Integer;
        DecimalValue: Decimal;
    begin
        if (AdditionalPropertyType = AdditionalPropertyType::" ") and (AdditionalPropertyValue <> '') then
          Error(AdditionalPropertyTypeErr);
        case AdditionalPropertyType of
          AdditionalPropertyType::Length:
            begin
              Evaluate(IntegerValue,AdditionalPropertyValue);
              DynamicModuleSetting."Data Length" := IntegerValue;
            end;
          AdditionalPropertyType::OptionString:
            DynamicModuleSetting."Option String" := AdditionalPropertyValue;
          AdditionalPropertyType::DecimalPrecision:
            begin
              Evaluate(DecimalValue,AdditionalPropertyValue);
              DynamicModuleSetting."Decimal Precision" := DecimalValue;
            end;
        end;
        exit(true);
    end;

    procedure DeleteSettings(var DynamicModule: Record "Dynamic Module";var DynamicModuleSetting: Record "Dynamic Module Setting")
    var
        DynamicModule2: Record "Dynamic Module";
    begin
        //-NPR5.43 [316419]
        BackupData(DynamicModule,DynamicModuleSetting);
        //+NPR5.43 [316419]
        DynamicModule2.DeleteAll(true);
    end;

    local procedure BackupData(var DynamicModule: Record "Dynamic Module";var DynamicModuleSetting: Record "Dynamic Module Setting")
    var
        DynamicModule2: Record "Dynamic Module";
        DynamicModuleSetting2: Record "Dynamic Module Setting";
    begin
        //-NPR5.43 [316419]
        if DynamicModule2.FindSet then
          repeat
            DynamicModule := DynamicModule2;
            DynamicModule.Insert;
          until DynamicModule2.Next = 0;
        //+NPR5.43 [316419]
        if DynamicModuleSetting2.FindSet then
          repeat
            DynamicModuleSetting := DynamicModuleSetting2;
            DynamicModuleSetting.Insert;
          until DynamicModuleSetting2.Next = 0;
    end;

    procedure RestoreData(var SavedDynamicModule: Record "Dynamic Module";var SavedDynamicModuleSetting: Record "Dynamic Module Setting")
    var
        DynamicModule: Record "Dynamic Module";
        DynamicModuleSetting2: Record "Dynamic Module Setting";
    begin
        //-NPR5.43 [316419]
        if SavedDynamicModule.FindSet then
          repeat
            if SavedDynamicModule.Enabled then begin
              DynamicModule.SetRange("Module Name",SavedDynamicModule."Module Name");
              if DynamicModule.FindFirst then begin
                DynamicModule.Enabled := true;
                DynamicModule.Modify;
              end;
            end;
          until SavedDynamicModule.Next = 0;
        //+NPR5.43 [316419]
        if SavedDynamicModuleSetting.FindSet then
          repeat
            DynamicModuleSetting2.SetRange("Module Name",SavedDynamicModuleSetting."Module Name");
            DynamicModuleSetting2.SetRange("Setting ID",SavedDynamicModuleSetting."Setting ID");
            if DynamicModuleSetting2.FindFirst then begin
              if (DynamicModuleSetting2."Data Type" = SavedDynamicModuleSetting."Data Type") and
                 (DynamicModuleSetting2."Data Length" = SavedDynamicModuleSetting."Data Length") and
                 (DynamicModuleSetting2."Option String" = SavedDynamicModuleSetting."Option String") and
                 (DynamicModuleSetting2."Decimal Precision" = SavedDynamicModuleSetting."Decimal Precision") and
                 (SavedDynamicModuleSetting."Preset XML Formatted Value" <> SavedDynamicModuleSetting."XML Formatted Value") then begin
                DynamicModuleSetting2."Formatted Value" := SavedDynamicModuleSetting."Formatted Value";
                DynamicModuleSetting2."XML Formatted Value" := SavedDynamicModuleSetting."XML Formatted Value";
                DynamicModuleSetting2."Boolean Value" := SavedDynamicModuleSetting."Boolean Value";
                DynamicModuleSetting2."Date Value" := SavedDynamicModuleSetting."Date Value";
                DynamicModuleSetting2."DateFormula Value" := SavedDynamicModuleSetting."DateFormula Value";
                DynamicModuleSetting2."DateTime Value" := SavedDynamicModuleSetting."DateTime Value";
                DynamicModuleSetting2."Decimal Value" := SavedDynamicModuleSetting."Decimal Value";
                DynamicModuleSetting2."Duration Value" := SavedDynamicModuleSetting."Duration Value";
                DynamicModuleSetting2."Integer Value" := SavedDynamicModuleSetting."Integer Value";
                DynamicModuleSetting2."Time Value" := SavedDynamicModuleSetting."Time Value";
                DynamicModuleSetting2.Modify;
              end;
            end;
          until SavedDynamicModuleSetting.Next = 0;
    end;

    procedure RestoreSetting(var DynamicModuleSetting: Record "Dynamic Module Setting")
    begin
        PresetValuesAction(DynamicModuleSetting,0);
    end;
}

