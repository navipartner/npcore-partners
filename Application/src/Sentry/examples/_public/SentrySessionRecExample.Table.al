table 6151217 "NPR Sentry Session Rec Example"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; MyField; Integer)
        {
            DataClassification = SystemMetadata;
        }
        field(2; "Sentry Parent Trace Id"; Text[100])
        {
            DataClassification = SystemMetadata;
        }
        field(3; "Sentry Parent Span Id"; Text[100])
        {
            DataClassification = SystemMetadata;
        }
        field(4; "Sentry Parent Sampled"; Boolean)
        {
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(Key1; MyField)
        {
            Clustered = true;
        }
    }
}
