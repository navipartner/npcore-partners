#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
table 6059882 "NPR Billing Queue Entry"
{
    Access = Internal;
    DataClassification = SystemMetadata;
    Caption = 'Billing Queue Entry';

    fields
    {
        field(1; "Entry No."; BigInteger)
        {
            Caption = 'Entry No.';
            DataClassification = SystemMetadata;
            AutoIncrement = true;
            ToolTip = 'Specifies the unique identifier for the billing queue entry.';
        }
        field(17; "User Security ID"; Guid)
        {
            Caption = 'User Security ID';
            DataClassification = SystemMetadata;
            ToolTip = 'Specifies the security ID of the user who created the billing queue entry.';
        }
        field(21; Status; Enum "NPR Billing Queue Status")
        {
            Caption = 'Status';
            DataClassification = SystemMetadata;
            ToolTip = 'Specifies the current status of the billing queue entry.';
            Editable = false;
        }
        field(23; "Synced At (DateTime)"; DateTime)
        {
            Caption = 'Synced At (DateTime)';
            DataClassification = SystemMetadata;
            ToolTip = 'Specifies the date and time of the successful sync of the billing queue entry.';
            Editable = false;
        }
        field(31; "Event ID"; Guid)
        {
            Caption = 'Event ID';
            DataClassification = SystemMetadata;
            ToolTip = 'Specifies the unique identifier for the event that triggered the billing.';
        }
        field(33; "Event Timestamp"; Text[50])
        {
            Caption = 'Event Timestamp';
            DataClassification = SystemMetadata;
            ToolTip = 'Specifies the timestamp of the event that triggered the billing.';
        }
        field(39; "Is SaaS"; Integer)
        {
            Caption = 'Is SaaS';
            DataClassification = SystemMetadata;
            ToolTip = 'Specifies whether the environment is a Software as a Service (SaaS) environment.';
        }
        field(41; "Tenant ID"; Text[50])
        {
            Caption = 'Tenant ID';
            DataClassification = SystemMetadata;
            ToolTip = 'Specifies the ID of the tenant where the billing occurred.';
        }
        field(43; "Environment Type"; Integer)
        {
            Caption = 'Environment Type';
            DataClassification = SystemMetadata;
            ToolTip = 'Specifies the type of environment where the billing occurred.';
        }
        field(45; "Environment Name"; Text[100])
        {
            Caption = 'Environment Name';
            DataClassification = SystemMetadata;
            ToolTip = 'Specifies the name of the environment where the billing occurred.';
        }
        field(51; "Server Name"; Text[100])
        {
            Caption = 'Server Name';
            DataClassification = SystemMetadata;
            ToolTip = 'Specifies the name of the server where the billing originated.';
        }
        field(57; "Company Name"; Text[30])
        {
            Caption = 'Company Name';
            DataClassification = SystemMetadata;
            ToolTip = 'Specifies the name of the company where the billing occurred.';
        }
        field(71; "Feature ID"; Integer)
        {
            Caption = 'Feature ID';
            DataClassification = SystemMetadata;
            ToolTip = 'Specifies the ID of the feature being billed.';
        }
        field(73; "Feature Name"; Text[100])
        {
            Caption = 'Feature Name';
            DataClassification = SystemMetadata;
            ToolTip = 'Specifies the name of the feature being billed.';
        }
        field(91; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DataClassification = SystemMetadata;
            ToolTip = 'Specifies the quantity to bill for the feature usage.';
        }
        field(101; Metadata; Blob)
        {
            Caption = 'Metadata';
            DataClassification = SystemMetadata;
            ToolTip = 'Specifies additional metadata related to the billing queue entry in JSON format.';
        }
        field(111; "Is Production Environment"; Boolean)
        {
            Caption = 'Is Production Environment';
            DataClassification = SystemMetadata;
            ToolTip = 'Specifies whether the environment is a production environment.';
        }
        field(113; "Billing API URL"; Text[250])
        {
            Caption = 'Billing API URL';
            DataClassification = SystemMetadata;
            ExtendedDatatype = URL;
            ToolTip = 'Specifies the URL of the billing API to use for this entry.';
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(Key2; "Status", "Is Production Environment", SystemCreatedAt)
        {
        }
        key(Key3; "Event ID", "Is Production Environment")
        {
        }
    }

    procedure SetMetadata(MetadataJsonText: Text)
    var
        OutStream: OutStream;
    begin
        Clear(Metadata);
        Rec.Metadata.CreateOutStream(OutStream, TextEncoding::UTF8);
        OutStream.WriteText(MetadataJsonText);
    end;

    procedure GetMetadata() Result: Text
    var
        InStream: InStream;
        TypeHelper: Codeunit "Type Helper";
    begin
        Rec.CalcFields(Metadata);
        if (not Rec.Metadata.HasValue) then
            exit('');

        Rec.Metadata.CreateInStream(InStream, TextEncoding::UTF8);
        exit(TypeHelper.ReadAsTextWithSeparator(InStream, TypeHelper.LFSeparator()));
    end;
}
#endif