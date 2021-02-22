table 6184481 "NPR EFTType Paym. BLOB Param."
{
    // NPR5.46/MMV /20181008 CASE 290734 Created object
    // NPR5.48/MMV /20181029 CASE 334105 Fixed invalid variant parameter.

    Caption = 'EFT Type Payment BLOB Param.';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Integration Type"; Code[20])
        {
            Caption = 'Integration Type';
            DataClassification = CustomerContent;
        }
        field(2; Name; Text[30])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;
        }
        field(3; Value; BLOB)
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
        field(4; "User Configurable"; Boolean)
        {
            Caption = 'User Configurable';
            DataClassification = CustomerContent;
        }
        field(5; "Payment Type POS"; Code[10])
        {
            Caption = 'Payment Type POS';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Payment Method".Code;
        }
    }

    keys
    {
        key(Key1; "Integration Type", "Payment Type POS", Name)
        {
        }
    }

    fieldgroups
    {
    }

    procedure GetParameterValue(IntegrationType: Code[20]; PaymentTypePOS: Code[10]; NameIn: Text; UserConfigurable: Boolean; var TempBlobOut: Codeunit "Temp Blob")
    var
        InvokeParameter: Record "NPR POS Paym. Bin Eject Param.";
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

        TempBlobOut.FromRecord(Rec, FieldNo(Value));
    end;

    procedure LookupValue()
    var
        tmpRetailList: Record "NPR Retail List" temporary;
        Parts: DotNet NPRNetArray;
        "Part": DotNet NPRNetString;
        OptionStringCaption: Text;
        Handled: Boolean;
    begin
        OnLookupParameterValue(Rec);
    end;

    procedure ValidateValue()
    begin
        OnValidateParameterValue(Rec);
    end;

    procedure UpdateParameterValue(SetupID: Guid; PaymentTypePOS: Code[10]; NameIn: Text; var TempBlob: Codeunit "Temp Blob")
    var
        RecRef: RecordRef;
    begin
        Get(SetupID, PaymentTypePOS, NameIn);
        //-NPR5.48 [334105]
        //VALIDATE(Value, ValueIn);

        RecRef.GetTable(Rec);
        TempBlob.ToRecordRef(RecRef, FieldNo("Value"));
        RecRef.SetTable(Rec);

        //+NPR5.48 [334105]
        Modify;
    end;

    [IntegrationEvent(false, false)]
    procedure OnGetParameterNameCaption(Parameter: Record "NPR EFTType Paym. BLOB Param."; var Caption: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnGetParameterDescriptionCaption(Parameter: Record "NPR EFTType Paym. BLOB Param."; var Caption: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnLookupParameterValue(var Parameter: Record "NPR EFTType Paym. BLOB Param.")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnValidateParameterValue(var Parameter: Record "NPR EFTType Paym. BLOB Param.")
    begin
    end;
}

