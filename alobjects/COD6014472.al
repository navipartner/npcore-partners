codeunit 6014472 "Dynamic Module Cross Ref Setup"
{
    // NPR5.52/SARA/20191016 CASE 372997 Object created - Manage unique Cross Reference No by Type


    trigger OnRun()
    begin
    end;

    var
        TextCrossRefBlock2: Label 'Unique Cross Reference No. by Customer';
        TextCrossRefBlock3: Label 'Unique Cross Reference No. by Vendor';
        TextCrossRefBlock4: Label 'Unique Cross Reference No. by Barcode';
        TextError01: Label '%1 %2 already exist for %3 %4 %5 %6';

    local procedure "--- Setup"()
    begin
    end;

    [EventSubscriber(ObjectType::Table, 6014479, 'OnDiscoverModule', '', true, true)]
    local procedure LoadBlockSetting(var Sender: Record "Dynamic Module")
    var
        DynamicModuleSetting: Record "Dynamic Module Setting";
        DateFormulaValue: DateFormula;
        DecimalValue: Decimal;
        DurationValue: Duration;
        DynamicModuleHelper: Codeunit "Dynamic Module Helper";
        AdditionalPropertyType: Option " ",Length,OptionString,DecimalPrecision;
    begin

        DynamicModuleHelper.CreateOrFindModule(GetModuleName(),Sender);

        DynamicModuleHelper.CreateModuleSetting(Sender,2,TextCrossRefBlock2,DynamicModuleSetting."Data Type"::Boolean,AdditionalPropertyType::" ",'',false);
        DynamicModuleHelper.CreateModuleSetting(Sender,3,TextCrossRefBlock3,DynamicModuleSetting."Data Type"::Boolean,AdditionalPropertyType::" ",'',false);
        DynamicModuleHelper.CreateModuleSetting(Sender,4,TextCrossRefBlock4,DynamicModuleSetting."Data Type"::Boolean,AdditionalPropertyType::" ",'',false);
        //DynamicModuleHelper.CreateModuleSetting(Sender,5,TextCrossRefBlock4,DynamicModuleSetting."Data Type"::Boolean,AdditionalPropertyType::" ",'',FALSE);
    end;

    procedure GetModuleName(): Text
    begin
        exit('UniqueCrossReferenceNo');
    end;

    local procedure "---Event"()
    begin
    end;

    [EventSubscriber(ObjectType::Table, 5717, 'OnAfterValidateEvent', 'Cross-Reference No.', true, true)]
    local procedure OnValidateCrossReferenceNoItem(var Rec: Record "Item Cross Reference";var xRec: Record "Item Cross Reference";CurrFieldNo: Integer)
    var
        DynamicModuleHelper: Codeunit "Dynamic Module Helper";
        Value: Variant;
        SetupValue: Boolean;
        SettingID: Integer;
    begin

        SettingID := 2; //Customer
        if DynamicModuleHelper.ModuleIsEnabledAndReturnSetupValue(GetModuleName(),SettingID,Value) then
          SetupValue := Value;
        if SetupValue then
          TestUniqueCrossRefNo(Rec."Cross-Reference No.",SettingID);

        SettingID := 3; //Vendor
        if DynamicModuleHelper.ModuleIsEnabledAndReturnSetupValue(GetModuleName(),SettingID,Value) then
          SetupValue := Value;
        if SetupValue then
          TestUniqueCrossRefNo(Rec."Cross-Reference No.",SettingID);

        SettingID := 4; //Bar Code
        if DynamicModuleHelper.ModuleIsEnabledAndReturnSetupValue(GetModuleName(),SettingID,Value) then
          SetupValue := Value;
        if SetupValue then
          TestUniqueCrossRefNo(Rec."Cross-Reference No.",SettingID);
    end;

    local procedure "---Test"()
    begin
    end;

    local procedure TestUniqueCrossRefNo(CrossRefNo: Code[20];SettingID: Integer)
    var
        ItemCrossRef: Record "Item Cross Reference";
    begin
        ItemCrossRef.Reset;
        ItemCrossRef.SetRange("Cross-Reference No.",CrossRefNo);
        case SettingID of
          2:ItemCrossRef.SetRange("Cross-Reference Type",ItemCrossRef."Cross-Reference Type"::Customer);
          3:ItemCrossRef.SetRange("Cross-Reference Type",ItemCrossRef."Cross-Reference Type"::Vendor);
          4:ItemCrossRef.SetRange("Cross-Reference Type",ItemCrossRef."Cross-Reference Type"::"Bar Code");
        end;
        with ItemCrossRef do begin
        if FindFirst then
          Error(TextError01,FieldCaption("Cross-Reference No."),"Cross-Reference No.",
                            FieldCaption("Item No."),"Item No.",
                            FieldCaption("Cross-Reference Type"),"Cross-Reference Type");
        end;
    end;
}

