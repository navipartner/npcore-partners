page 6014501 "NPR Dynamic Module Sett. Dlg."
{
    // NPR5.38/NPKNAV/20180126  CASE 294992 Transport NPR5.38 - 26 January 2018

    Caption = 'Dynamic Module Setting';
    PageType = StandardDialog;
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            field(BooleanValue; BooleanValue)
            {
                ApplicationArea = All;
                CaptionClass = '3,' + SettingName;
                Visible = BooleanVisible;
                ToolTip = 'Specifies the value of the BooleanValue field';

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
                ToolTip = 'Specifies the value of the TextValue field';

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
                ToolTip = 'Specifies the value of the CodeValue field';

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
                ToolTip = 'Specifies the value of the DateValue field';

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
                ToolTip = 'Specifies the value of the DateFormulaValue field';

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
                ToolTip = 'Specifies the value of the DateTimeValue field';

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
                ToolTip = 'Specifies the value of the DecimalValue field';

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
                ToolTip = 'Specifies the value of the DurationValue field';

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
                ToolTip = 'Specifies the value of the IntegerValue field';

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
                ToolTip = 'Specifies the value of the TimeValue field';

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
        DynamicModuleSettingGlobal: Record "NPR Dynamic Module Setting";
        VariantValue: Variant;
        SettingName: Text;
        DynamicModuleHelper: Codeunit "NPR Dynamic Module Helper";
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

    procedure SetModuleScopeSetting(DynamicModuleSetting: Record "NPR Dynamic Module Setting")
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

    procedure GetModuleScopeSetting(var DynamicModuleSetting: Record "NPR Dynamic Module Setting")
    begin
        DynamicModuleSetting := DynamicModuleSettingGlobal;
    end;
}

