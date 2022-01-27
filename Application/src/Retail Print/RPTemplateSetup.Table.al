table 6014565 "NPR RP Template Setup"
{
    Access = Internal;
    Caption = 'Template Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = CustomerContent;
        }
        field(2; "Version Major Number"; Integer)
        {
            Caption = 'Version Major Number';
            InitValue = 1;
            MinValue = 1;
            DataClassification = CustomerContent;
        }
        field(3; "Version Prefix"; Code[3])
        {
            Caption = 'Version Prefix';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                NpRegEx: Codeunit "NPR RegEx";
            begin
                if not NpRegEx.IsMatch("Version Prefix", '^[a-zA-Z]+$') then
                    Error(Err_InvalidPrefix);
            end;
        }
    }

    keys
    {
        key(Key1; "Primary Key")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        if "Version Prefix" = '' then
            "Version Prefix" := 'NPK';

        if "Version Major Number" = 0 then
            "Version Major Number" := 1;
    end;

    var
        Err_InvalidPrefix: Label 'Prefix must only contains letters a-z';
}

