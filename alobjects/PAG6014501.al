page 6014501 "Dynamic Module Setting Dialog"
{
    // NPR5.38/NPKNAV/20180126  CASE 294992 Transport NPR5.38 - 26 January 2018

    Caption = 'Dynamic Module Setting';
    PageType = StandardDialog;

    layout
    {
        area(content)
        {
            field(BooleanValue; BooleanValue)
            {
                ApplicationArea = All;
                CaptionClass = '3,' + SettingName;
                Visible = BooleanVisible;

                trigger OnValidate()
                begin
                    DynamicModuleHelper.CheckSetupValue(DynamicModuleSettingGlobal, BooleanValue);
                    DynamicModuleHelper.SetSetupValue(DynamicModuleSettingGlobal, BooleanValue);
                end;
            }
            field(TextValue; TextValue)
            {
                ApplicationArea = All;
                CaptionClass = '3,' + SettingName;
                Visible = TextVisible;

                trigger OnValidate()
                begin
                    DynamicModuleHelper.CheckSetupValue(DynamicModuleSettingGlobal, TextValue);
                    DynamicModuleHelper.SetSetupValue(DynamicModuleSettingGlobal, TextValue);
                end;
            }
            field(CodeValue; CodeValue)
            {
                ApplicationArea = All;
                CaptionClass = '3,' + SettingName;
                Visible = CodeVisible;

                trigger OnValidate()
                begin
                    DynamicModuleHelper.CheckSetupValue(DynamicModuleSettingGlobal, CodeValue);
                    DynamicModuleHelper.SetSetupValue(DynamicModuleSettingGlobal, UpperCase(CodeValue));
                end;
            }
            field(DateValue; DateValue)
            {
                ApplicationArea = All;
                CaptionClass = '3,' + SettingName;
                Visible = DateVisible;

                trigger OnValidate()
                begin
                    DynamicModuleHelper.CheckSetupValue(DynamicModuleSettingGlobal, DateValue);
                    DynamicModuleHelper.SetSetupValue(DynamicModuleSettingGlobal, DateValue);
                end;
            }
            field(DateFormulaValue; DateFormulaValue)
            {
                ApplicationArea = All;
                CaptionClass = '3,' + SettingName;
                Visible = DateFormulaVisible;

                trigger OnValidate()
                begin
                    DynamicModuleHelper.CheckSetupValue(DynamicModuleSettingGlobal, DateFormulaValue);
                    DynamicModuleHelper.SetSetupValue(DynamicModuleSettingGlobal, DateFormulaValue);
                end;
            }
            field(DateTimeValue; DateTimeValue)
            {
                ApplicationArea = All;
                CaptionClass = '3,' + SettingName;
                Visible = DateTimeVisible;

                trigger OnValidate()
                begin
                    DynamicModuleHelper.CheckSetupValue(DynamicModuleSettingGlobal, DateTimeValue);
                    DynamicModuleHelper.SetSetupValue(DynamicModuleSettingGlobal, DateTimeValue);
                end;
            }
            field(DecimalValue; DecimalValue)
            {
                ApplicationArea = All;
                CaptionClass = '3,' + SettingName;
                DecimalPlaces = 2 : 5;
                Visible = DecimalVisible;

                trigger OnValidate()
                begin
                    DynamicModuleHelper.CheckSetupValue(DynamicModuleSettingGlobal, DecimalValue);
                    DynamicModuleHelper.SetSetupValue(DynamicModuleSettingGlobal, DecimalValue);
                end;
            }
            field(DurationValue; DurationValue)
            {
                ApplicationArea = All;
                CaptionClass = '3,' + SettingName;
                Visible = DurationVisible;

                trigger OnValidate()
                begin
                    DynamicModuleHelper.CheckSetupValue(DynamicModuleSettingGlobal, DurationValue);
                    DynamicModuleHelper.SetSetupValue(DynamicModuleSettingGlobal, DurationValue);
                end;
            }
            field(IntegerValue; IntegerValue)
            {
                ApplicationArea = All;
                CaptionClass = '3,' + SettingName;
                Visible = IntegerVisible;

                trigger OnValidate()
                begin
                    DynamicModuleHelper.CheckSetupValue(DynamicModuleSettingGlobal, IntegerValue);
                    DynamicModuleHelper.SetSetupValue(DynamicModuleSettingGlobal, IntegerValue);
                end;
            }
            field(TimeValue; TimeValue)
            {
                ApplicationArea = All;
                CaptionClass = '3,' + SettingName;
                Visible = TimeVisible;

                trigger OnValidate()
                begin
                    DynamicModuleHelper.CheckSetupValue(DynamicModuleSettingGlobal, TimeValue);
                    DynamicModuleHelper.SetSetupValue(DynamicModuleSettingGlobal, TimeValue);
                end;
            }
        }
    }

    actions
    {
    }

    var
        DynamicModuleSettingGlobal: Record "Dynamic Module Setting";
        VariantValue: Variant;
        SettingName: Text;
        DynamicModuleHelper: Codeunit "Dynamic Module Helper";
        BooleanValue: Boolean;
        BooleanVisible: Boolean;
        TextValue: Text;
        TextVisible: Boolean;
        CodeValue: Text;
        CodeVisible: Boolean;
        DateValue: Date;
        DateVisible: Boolean;
        DateFormulaValue: DateFormula;
        DateFormulaVisible: Boolean;
        DateTimeValue: DateTime;
        DateTimeVisible: Boolean;
        DecimalValue: Decimal;
        DecimalVisible: Boolean;
        DurationValue: Duration;
        DurationVisible: Boolean;
        IntegerValue: Integer;
        IntegerVisible: Boolean;
        TimeValue: Time;
        TimeVisible: Boolean;

    procedure SetModuleScopeSetting(DynamicModuleSetting: Record "Dynamic Module Setting")
    begin
        DynamicModuleSettingGlobal := DynamicModuleSetting;
        SettingName := DynamicModuleSettingGlobal.Name;
        DynamicModuleHelper.GetSetupValue(DynamicModuleSetting, VariantValue);
        with DynamicModuleSetting do
            case "Data Type" of
                "Data Type"::Boolean:
                    begin
                        BooleanVisible := true;
                        BooleanValue := VariantValue;
                    end;
                "Data Type"::Text:
                    begin
                        TextVisible := true;
                        TextValue := VariantValue;
                    end;
                "Data Type"::Code:
                    begin
                        CodeVisible := true;
                        CodeValue := VariantValue;
                    end;
                "Data Type"::Date:
                    begin
                        DateVisible := true;
                        DateValue := VariantValue;
                    end;
                "Data Type"::DateFormula:
                    begin
                        DateFormulaVisible := true;
                        DateFormulaValue := VariantValue;
                    end;
                "Data Type"::DateTime:
                    begin
                        DateTimeVisible := true;
                        DateTimeValue := VariantValue;
                    end;
                "Data Type"::Decimal:
                    begin
                        DecimalVisible := true;
                        DecimalValue := VariantValue;
                    end;
                "Data Type"::Duration:
                    begin
                        DurationVisible := true;
                        DurationValue := VariantValue;
                    end;
                "Data Type"::Integer:
                    begin
                        IntegerVisible := true;
                        IntegerValue := VariantValue;
                    end;
                "Data Type"::Time:
                    begin
                        TimeVisible := true;
                        TimeValue := VariantValue;
                    end;
            end;
    end;

    procedure GetModuleScopeSetting(var DynamicModuleSetting: Record "Dynamic Module Setting")
    begin
        DynamicModuleSetting := DynamicModuleSettingGlobal;
    end;
}

