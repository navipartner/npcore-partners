table 6184482 "NPR EFTType POSUnit BLOBParam."
{
    // NPR5.46/MMV /20181008 CASE 290734 Created object
    // NPR5.48/MMV /20181029 CASE 334105 Fixed invalid variant parameter.

    Caption = 'EFT Type POS Unit BLOB Param.';
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
        field(5; "POS Unit No."; Code[10])
        {
            Caption = 'POS Unit No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Unit"."No.";
        }
    }

    keys
    {
        key(Key1; "Integration Type", "POS Unit No.", Name)
        {
        }
    }

    fieldgroups
    {
    }

    procedure GetParameterValue(IntegrationType: Text; POSUnitNo: Text; NameIn: Text; UserConfigurable: Boolean; var TempBlobOut: Codeunit "Temp Blob")
    begin
        SetAutoCalcFields(Value);
        if not Get(IntegrationType, POSUnitNo, NameIn) then begin
            Init();
            "Integration Type" := IntegrationType;
            "POS Unit No." := POSUnitNo;
            Name := NameIn;
            "User Configurable" := UserConfigurable;
            Insert();
        end;

        TempBlobOut.FromRecord(Rec, FieldNo(Value));
    end;

    procedure LookupValue()
    begin
        OnLookupParameterValue(Rec);
    end;

    procedure ValidateValue()
    begin
        OnValidateParameterValue(Rec);
    end;

    procedure UpdateParameterValue(IntegrationType: Text; POSUnitNo: Text; NameIn: Text; var TempBlob: Codeunit "Temp Blob")
    var
        RecRef: RecordRef;
    begin
        Get(IntegrationType, POSUnitNo, NameIn);
        //-NPR5.48 [334105]
        //VALIDATE(Value, ValueIn);

        RecRef.GetTable(Rec);
        TempBlob.ToRecordRef(RecRef, FieldNo("Value"));
        RecRef.SetTable(Rec);

        //+NPR5.48 [334105]
        Modify();
    end;

    [IntegrationEvent(false, false)]
    procedure OnGetParameterNameCaption(Parameter: Record "NPR EFTType POSUnit BLOBParam."; var Caption: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnGetParameterDescriptionCaption(Parameter: Record "NPR EFTType POSUnit BLOBParam."; var Caption: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnLookupParameterValue(var Parameter: Record "NPR EFTType POSUnit BLOBParam.")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnValidateParameterValue(var Parameter: Record "NPR EFTType POSUnit BLOBParam.")
    begin
    end;
}

