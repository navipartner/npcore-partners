table 6150692 "NPR SI POS Store Mapping"
{
    Access = Internal;
    Caption = 'SI POS Store Mapping';
    DataClassification = CustomerContent;
    LookupPageId = "NPR SI POS Store Mapping";
    DrillDownPageId = "NPR SI POS Store Mapping";

    fields
    {
        field(1; "POS Store Code"; Code[10])
        {
            Caption = 'POS Store Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Store";
        }
        field(2; Registered; Boolean)
        {
            Caption = 'Registered';
            DataClassification = CustomerContent;
        }
        field(3; "Cadastral Number"; Integer)
        {
            Caption = 'Cadastral Number';
            DataClassification = CustomerContent;
            trigger OnValidate()
            begin
                ValidateIntegerFieldLength(Rec.FieldCaption("Cadastral Number"), "Cadastral Number", 4);
            end;
        }
        field(4; "Building Number"; Integer)
        {
            Caption = 'Building Number';
            DataClassification = CustomerContent;
            trigger OnValidate()
            begin
                ValidateIntegerFieldLength(Rec.FieldCaption("Building Number"), "Building Number", 5);
            end;
        }
        field(5; "Building Section Number"; Integer)
        {
            Caption = 'Building Section Number';
            DataClassification = CustomerContent;
            trigger OnValidate()
            begin
                ValidateIntegerFieldLength(Rec.FieldCaption("Building Section Number"), "Building Section Number", 4);
            end;
        }
        field(6; "Validity Date"; Date)
        {
            Caption = 'Validity Date';
            DataClassification = CustomerContent;
            trigger OnValidate()
            begin
                ValidateValidityDate();
            end;
        }
        field(10; "Receipt No. Series"; Code[20])
        {
            Caption = 'Receipt No. Series';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
    }

    keys
    {
        key(Key1; "POS Store Code")
        {
            Clustered = true;
        }
    }

    local procedure ValidateIntegerFieldLength(FieldCaption: Text; Value: Integer; MaxLength: Integer)
    var
        MaxLengthErr: Label 'Length of %1 can be a maximum of %2 numbers.', Comment = '%1 = Field Caption, %2 = Max Length';
    begin
        if StrLen(Format(Value)) <= MaxLength then
            exit;

        Error(MaxLengthErr, FieldCaption, MaxLength);
    end;

    local procedure ValidateValidityDate()
    var
        DateEnteredErr: Label 'The Validity Date cannot be earlier than today''s date.';
    begin
        if "Validity Date" < Today() then
            Error(DateEnteredErr);
    end;
}