table 6184482 "EFT Type POS Unit BLOB Param."
{
    // NPR5.46/MMV /20181008 CASE 290734 Created object
    // NPR5.48/MMV /20181029 CASE 334105 Fixed invalid variant parameter.

    Caption = 'EFT Type POS Unit BLOB Param.';

    fields
    {
        field(1;"Integration Type";Code[20])
        {
            Caption = 'Integration Type';
        }
        field(2;Name;Text[30])
        {
            Caption = 'Name';
        }
        field(3;Value;BLOB)
        {
            Caption = 'Value';

            trigger OnLookup()
            begin
                LookupValue();
            end;

            trigger OnValidate()
            begin
                ValidateValue();
            end;
        }
        field(4;"User Configurable";Boolean)
        {
            Caption = 'User Configurable';
        }
        field(5;"POS Unit No.";Code[10])
        {
            Caption = 'POS Unit No.';
            TableRelation = "POS Unit"."No.";
        }
    }

    keys
    {
        key(Key1;"Integration Type","POS Unit No.",Name)
        {
        }
    }

    fieldgroups
    {
    }

    procedure GetParameterValue(IntegrationType: Text;POSUnitNo: Text;NameIn: Text;UserConfigurable: Boolean;var TempBlobOut: Record TempBlob temporary)
    var
        InvokeParameter: Record "POS Payment Bin Eject Param.";
    begin
        SetAutoCalcFields(Value);
        if not Get(IntegrationType, POSUnitNo, NameIn) then begin
          Init;
          "Integration Type" := IntegrationType;
          "POS Unit No." := POSUnitNo;
          Name := NameIn;
          "User Configurable" := UserConfigurable;
          Insert;
        end;

        TempBlobOut.Blob := Value;
    end;

    procedure LookupValue()
    var
        tmpRetailList: Record "Retail List" temporary;
        Parts: DotNet Array;
        "Part": DotNet String;
        OptionStringCaption: Text;
        Handled: Boolean;
    begin
        OnLookupParameterValue(Rec);
    end;

    procedure ValidateValue()
    begin
        OnValidateParameterValue(Rec);
    end;

    procedure UpdateParameterValue(IntegrationType: Text;POSUnitNo: Text;NameIn: Text;var TempBlob: Record TempBlob)
    begin
        Get(IntegrationType, POSUnitNo, NameIn);
        //-NPR5.48 [334105]
        //VALIDATE(Value, ValueIn);
        Value := TempBlob.Blob;
        //+NPR5.48 [334105]
        Modify;
    end;

    [IntegrationEvent(false, false)]
    procedure OnGetParameterNameCaption(Parameter: Record "EFT Type POS Unit BLOB Param.";var Caption: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnGetParameterDescriptionCaption(Parameter: Record "EFT Type POS Unit BLOB Param.";var Caption: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnLookupParameterValue(var Parameter: Record "EFT Type POS Unit BLOB Param.")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnValidateParameterValue(var Parameter: Record "EFT Type POS Unit BLOB Param.")
    begin
    end;
}

