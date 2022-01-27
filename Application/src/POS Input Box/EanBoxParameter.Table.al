table 6060108 "NPR Ean Box Parameter"
{
    Access = Internal;

    Caption = 'Ean Box Parameter';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR POS Input Box Parameters";
    LookupPageID = "NPR POS Input Box Parameters";

    fields
    {
        field(1; "Setup Code"; Code[20])
        {
            Caption = 'Setup Code';
            DataClassification = CustomerContent;
        }
        field(2; "Event Code"; Code[20])
        {
            Caption = 'Event Code';
            DataClassification = CustomerContent;
        }
        field(6; "Action Code"; Code[20])
        {
            Caption = 'Action Code';
            DataClassification = CustomerContent;
        }
        field(7; Name; Text[30])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(8; "Data Type"; Option)
        {
            Caption = 'Data Type';
            DataClassification = CustomerContent;
            Editable = false;
            OptionCaption = 'Text,Integer,Decimal,Date,Boolean,Option';
            OptionMembers = Text,"Integer",Decimal,Date,Boolean,Option;
        }
        field(9; "Default Value"; Text[250])
        {
            Caption = 'Default Value';
            DataClassification = CustomerContent;
        }
        field(10; Options; Text[250])
        {
            Caption = 'Options';
            DataClassification = CustomerContent;
        }
        field(11; Value; Text[250])
        {
            Caption = 'Value';
            DataClassification = CustomerContent;

            trigger OnLookup()
            begin
                LookupValue();
            end;

            trigger OnValidate()
            begin
                ValidateValue();
            end;
        }
        field(16; OptionValueInteger; Integer)
        {
            Caption = 'OptionValueInteger';
            DataClassification = CustomerContent;
        }
        field(20; "Ean Box Value"; Boolean)
        {
            Caption = 'Ean Box Value';
            DataClassification = CustomerContent;
        }
        field(25; "Non Editable"; Boolean)
        {
            Caption = 'Non Editable';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Setup Code", "Event Code", "Action Code", Name)
        {
        }
    }

    fieldgroups
    {
    }

    local procedure LookupValue()
    var
        TempPOSParameterValue: Record "NPR POS Parameter Value" temporary;
    begin
        // CASE "Data Type" OF
        //  "Data Type"::Option :
        //    BEGIN
        //      POSActionParamMgt.SplitString(Options,Parts);
        //      FOREACH Part IN Parts DO BEGIN
        //        TempRetailList.Number += 1;
        //        TempRetailList.Choice := Part;
        //        TempRetailList.Insert();
        //      END;
        //    END;
        //  ELSE
        //    EXIT;
        // END;
        //
        // IF TempRetailList.ISEMPTY THEN
        //  EXIT;
        //
        // IF PAGE.RUNMODAL(PAGE::"Retail List", TempRetailList) = ACTION::LookupOK THEN BEGIN
        //  OptionTextValue := TempRetailList.Choice;
        //  VALIDATE(Value,OptionTextValue);
        // END;
        InitPOSParameterValue(TempPOSParameterValue);
        TempPOSParameterValue.LookupValue();
        Value := TempPOSParameterValue.Value;
    end;

    local procedure ValidateValue()
    var
        TempPOSParameterValue: Record "NPR POS Parameter Value" temporary;
        TypeHelper: Codeunit "Type Helper";
    begin
        // TempPOSActionParameter."Data Type" := "Data Type";
        // TempPOSActionParameter.Options := Options;
        // TempPOSActionParameter.VALIDATE("Default Value",Value);
        // Value := TempPOSActionParameter."Default Value";
        InitPOSParameterValue(TempPOSParameterValue);
        TempPOSParameterValue.Validate(Value);
        Value := TempPOSParameterValue.Value;
        if "Data Type" = "Data Type"::Option then
            Validate(OptionValueInteger, TypeHelper.GetOptionNo(Value, Options));
    end;

    local procedure InitPOSParameterValue(var TempPOSParameterValue: Record "NPR POS Parameter Value" temporary)
    begin
        TempPOSParameterValue.Init();
        TempPOSParameterValue."Action Code" := "Action Code";
        TempPOSParameterValue.Name := Name;
        TempPOSParameterValue."Data Type" := "Data Type";
        TempPOSParameterValue.Value := Value;
    end;
}

