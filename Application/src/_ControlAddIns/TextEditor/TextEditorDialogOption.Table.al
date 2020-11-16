table 6151450 "NPR Text Editor Dialog Option"
{
    DataClassification = SystemMetadata;
    // TODO: Switch to temporary table in BC runtime 6.0+.
    // TableType = Temporary;

    fields
    {
        field(1; "Option Key"; Text[250])
        {
            DataClassification = SystemMetadata;
        }
        field(2; "Option Value"; Blob)
        {
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(PK; "Option Key")
        {
            Clustered = true;
        }
    }

    procedure SetOptionValue(OptionValue: Variant)
    var
        OutStrm: OutStream;
    begin
        Rec."Option Value".CreateOutStream(OutStrm);
        OutStrm.Write(OptionValue);
    end;

    procedure GetOptionValue(): Text
    var
        InStrm: InStream;
        OptionValue: Text;
    begin
        Rec.CalcFields("Option Value");
        Rec."Option Value".CreateInStream(InStrm);
        InStrm.Read(OptionValue);

        exit(OptionValue);
    end;
}