table 6184500 "CleanCash Setup"
{
    // NPR4.21/JHL/20160302 CASE 222417 Table created to handle the setup for CleanCash
    // NPR5.29/JHL/20161027 CASE 256695 Add field "CleanCash Register No." the number used to write to the Black box, must be unique.
    // NPR5.30/TJ /20170215 CASE 265504 Changed ENU captions on fields with word Register in their name
    // NPR5.31/JHL/20170223 CASE 256695 Added field "Run Local"
    // NPR5.31/JLK /20170313 CASE 268274 Changed ENU Caption

    Caption = 'CleanCash Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; Register; Code[20])
        {
            Caption = 'Cash Register No.';
            DataClassification = CustomerContent;
            TableRelation = Register;
        }
        field(2; "Connection String"; Text[100])
        {
            Caption = 'Connection String';
            DataClassification = CustomerContent;
        }
        field(3; "Organization ID"; Text[10])
        {
            Caption = 'Organization ID';
            DataClassification = CustomerContent;
        }
        field(4; "Last Z Reort Date"; Date)
        {
            Caption = 'Last Report Date';
            DataClassification = CustomerContent;
        }
        field(5; "Last Z Report Time"; Time)
        {
            Caption = 'Last Report Time';
            DataClassification = CustomerContent;
        }
        field(6; "Multi Organization ID Per POS"; Boolean)
        {
            Caption = 'Multi Organization ID Per POS';
            DataClassification = CustomerContent;
        }
        field(7; Training; Boolean)
        {
            Caption = 'Training';
            DataClassification = CustomerContent;
        }
        field(8; "Show Error Message"; Boolean)
        {
            Caption = 'Show Error Message';
            DataClassification = CustomerContent;
            InitValue = true;
        }
        field(9; "CleanCash Register No."; Text[16])
        {
            Caption = 'CleanCash Cash Register No.';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                UniqueRegisterNo: Code[16];
            begin
            end;
        }
        field(10; "Run Local"; Boolean)
        {
            Caption = 'Run Local';
            DataClassification = CustomerContent;
            Description = 'Used to tell where the CleanCashAPI dll is placed (third part application)';
        }
    }

    keys
    {
        key(Key1; Register)
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        if Rec."CleanCash Register No." = '' then
            Rec."CleanCash Register No." := Register;
    end;
}

