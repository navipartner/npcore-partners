table 6184481 "EFT Type Payment BLOB Param."
{
    // NPR5.46/MMV /20181008 CASE 290734 Created object
    // NPR5.48/MMV /20181029 CASE 334105 Fixed invalid variant parameter.

    Caption = 'EFT Type Payment BLOB Param.';

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
        field(5;"Payment Type POS";Code[10])
        {
            Caption = 'Payment Type POS';
            TableRelation = "Payment Type POS"."No.";
        }
    }

    keys
    {
        key(Key1;"Integration Type","Payment Type POS",Name)
        {
        }
    }

    fieldgroups
    {
    }

    procedure GetParameterValue(IntegrationType: Code[20];PaymentTypePOS: Code[10];NameIn: Text;UserConfigurable: Boolean;var TempBlobOut: Record TempBlob temporary)
    var
        InvokeParameter: Record "POS Payment Bin Eject Param.";
    begin
        SetAutoCalcFields(Value);
        if not Get(IntegrationType, PaymentTypePOS, NameIn) then begin
          Init;
          "Integration Type" := IntegrationType;
          "Payment Type POS" := PaymentTypePOS;
          Name := NameIn;
          "User Configurable" := UserConfigurable;
          Insert;
        end;

        TempBlobOut.Blob := Value;
    end;

    procedure LookupValue()
    var
        tmpRetailList: Record "Retail List" temporary;
        Parts: DotNet npNetArray;
        "Part": DotNet npNetString;
        OptionStringCaption: Text;
        Handled: Boolean;
    begin
        OnLookupParameterValue(Rec);
    end;

    procedure ValidateValue()
    begin
        OnValidateParameterValue(Rec);
    end;

    procedure UpdateParameterValue(SetupID: Guid;PaymentTypePOS: Code[10];NameIn: Text;var TempBlob: Record TempBlob)
    begin
        Get (SetupID, PaymentTypePOS, NameIn);
        //-NPR5.48 [334105]
        //VALIDATE(Value, ValueIn);
        Value := TempBlob.Blob;
        //+NPR5.48 [334105]
        Modify;
    end;

    [IntegrationEvent(false, false)]
    procedure OnGetParameterNameCaption(Parameter: Record "EFT Type Payment BLOB Param.";var Caption: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnGetParameterDescriptionCaption(Parameter: Record "EFT Type Payment BLOB Param.";var Caption: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnLookupParameterValue(var Parameter: Record "EFT Type Payment BLOB Param.")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnValidateParameterValue(var Parameter: Record "EFT Type Payment BLOB Param.")
    begin
    end;
}

