table 6014532 "NPR DE POS Unit Aux. Info"
{
    Access = Internal;
    Caption = 'DE Fiskaly POS Unit Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "POS Unit No."; Code[10])
        {
            Caption = 'POS Unit No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Unit"."No.";
        }
        field(2; "Cash Register Brand"; Text[50])
        {
            Caption = 'Cash Register Brand';
            Description = 'Cash Register Brand for DE Fiskaly DSFINKV';
            DataClassification = CustomerContent;
        }
        field(3; "Cash Register Model"; Text[50])
        {
            Caption = 'Cash Register Model';
            Description = 'Cash Register Model for DE Fiskaly DSFINKV';
            DataClassification = CustomerContent;
        }
        field(10; "Client ID"; Guid)
        {
            Caption = 'Client ID';
            Editable = false;
            Description = 'Client ID for DE Fiskaly';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Use field SystemId instead';
        }
        field(20; "TSS ID"; Guid)
        {
            Caption = 'TSS ID';
            Editable = false;
            Description = 'TSS ID for DE Fiskaly';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Replaced by field "TSS Code" and related table 6014685 "NPR DE TSS"';
        }
        field(21; "TSS Code"; Code[10])
        {
            Caption = 'TSS Code';
            TableRelation = "NPR DE TSS";
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "TSS Code" <> xRec."TSS Code" then
                    TestField("Fiskaly Client Created at", 0DT);
            end;
        }
        field(30; "Serial Number"; Text[250])
        {
            Caption = 'Serial Number';
            Description = 'Serial Number for DE Fiskaly';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Serial Number" <> xRec."Serial Number" then
                    TestField("Fiskaly Client Created at", 0DT);
                if "Serial Number" = '' then
                    exit;
                "Serial Number" := DelChr("Serial Number", '=', '/_');
            end;
        }
        field(40; "Cash Register Created"; Boolean)
        {
            Caption = 'Cash Register Created';
            Description = 'Is Cash Register Created for DE Fiskaly DSFINVK';
            DataClassification = CustomerContent;
        }
        field(50; "Fiskaly Client Created at"; DateTime)
        {
            Caption = 'Fiskaly Client Created at';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(60; "Fiskaly Client State"; Enum "NPR DE TSS Client State")
        {
            Caption = 'Last Known Fiskaly Client State';
            DataClassification = CustomerContent;
            Editable = false;
        }
    }

    keys
    {
        key(PK; "POS Unit No.")
        {
            Clustered = true;
        }
    }
}
