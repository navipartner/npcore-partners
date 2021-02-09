codeunit 6014472 "NPR DynamicModule Cr.RefSetup"
{
    var
        TextItemRefBlock2: Label 'Unique Item Reference No. by Customer';
        TextItemRefBlock3: Label 'Unique Item Reference No. by Vendor';
        TextItemRefBlock4: Label 'Unique Item Reference No. by Barcode';
        TextError01: Label '%1 %2 already exist for %3 %4 %5 %6';

    [EventSubscriber(ObjectType::Table, 6014479, 'OnDiscoverModule', '', true, true)]
    local procedure LoadBlockSetting(var Sender: Record "NPR Dynamic Module")
    var
        DynamicModuleSetting: Record "NPR Dynamic Module Setting";
        DateFormulaValue: DateFormula;
        DecimalValue: Decimal;
        DurationValue: Duration;
        DynamicModuleHelper: Codeunit "NPR Dynamic Module Helper";
        AdditionalPropertyType: Option " ",Length,OptionString,DecimalPrecision;
    begin

        DynamicModuleHelper.CreateOrFindModule(GetModuleName(), Sender);

        DynamicModuleHelper.CreateModuleSetting(Sender, 2, TextItemRefBlock2, DynamicModuleSetting."Data Type"::Boolean, AdditionalPropertyType::" ", '', false);
        DynamicModuleHelper.CreateModuleSetting(Sender, 3, TextItemRefBlock3, DynamicModuleSetting."Data Type"::Boolean, AdditionalPropertyType::" ", '', false);
        DynamicModuleHelper.CreateModuleSetting(Sender, 4, TextItemRefBlock4, DynamicModuleSetting."Data Type"::Boolean, AdditionalPropertyType::" ", '', false);
    end;

    procedure GetModuleName(): Text
    begin
        exit('UniqueItemReferenceNo');
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Reference", 'OnAfterValidateEvent', 'Reference No.', true, true)]
    local procedure OnValidateItemReferenceNoItem(var Rec: Record "Item Reference"; var xRec: Record "Item Reference"; CurrFieldNo: Integer)
    var
        DynamicModuleHelper: Codeunit "NPR Dynamic Module Helper";
        Value: Variant;
        SetupValue: Boolean;
        SettingID: Integer;
    begin
        SettingID := 0;
        case Rec."Reference Type" of
            Rec."Reference Type"::Customer:
                SettingID := 2;
            Rec."Reference Type"::Vendor:
                SettingID := 3;
            Rec."Reference Type"::"Bar Code":
                SettingID := 4;
        end;
        if SettingID = 0 then
            exit;

        if DynamicModuleHelper.ModuleIsEnabledAndReturnSetupValue(GetModuleName(), SettingID, Value) then
            SetupValue := Value;
        if SetupValue then
            TestUniqueItemRefNo(Rec."Reference No.", SettingID);
    end;

    local procedure TestUniqueItemRefNo(ItemRefNo: Code[50]; SettingID: Integer)
    var
        ItemRef: Record "Item Reference";
    begin
        ItemRef.Reset;
        ItemRef.SetRange("Reference No.", ItemRefNo);
        case SettingID of
            2:
                ItemRef.SetRange("Reference Type", ItemRef."Reference Type"::Customer);
            3:
                ItemRef.SetRange("Reference Type", ItemRef."Reference Type"::Vendor);
            4:
                ItemRef.SetRange("Reference Type", ItemRef."Reference Type"::"Bar Code");
        end;
        if ItemRef.FindFirst then
            Error(TextError01, ItemRef.FieldCaption("Reference No."), ItemRef."Reference No.",
                              ItemRef.FieldCaption("Item No."), ItemRef."Item No.",
                              ItemRef.FieldCaption("Reference Type"), ItemRef."Reference Type");
    end;
}

