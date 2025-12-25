#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22 or BC23 or BC24 or BC25)
table 6151288 "NPR Retention Policy Log Entry"
{
    Caption = 'NPR Retention Policy Log Entry';
    Extensible = false;
    Access = Internal;

    fields
    {
        field(1; "Entry No."; BigInteger)
        {
            DataClassification = SystemMetadata;
            AutoIncrement = true;
            Caption = 'Entry No.';
        }
        field(2; "User Id"; Code[50])
        {
            FieldClass = FlowField;
            CalcFormula = lookup(User."User Name" where("User Security Id" = field(SystemCreatedBy)));
            Editable = false;
            Caption = 'User Id';
        }
        field(3; "Message Type"; Enum "Retention Policy Log Message Type")
        {
            DataClassification = SystemMetadata;
            Caption = 'Message Type';
        }
        field(4; "Message"; Text[2048])
        {
            DataClassification = SystemMetadata;
            Caption = 'Message';
        }
        field(5; "Error Call Stack"; BLOB)
        {
            Caption = 'Error Call Stack';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(Retention; SystemCreatedAt) { }
    }

    internal procedure SetErrorCallStack(NewCallStack: Text)
    var
        OutStream: OutStream;
    begin
        Rec."Error Call Stack".CreateOutStream(OutStream, TextEncoding::Windows);
        OutStream.Write(NewCallStack);
    end;

    internal procedure GetErrorCallStack(): Text
    var
        TypeHelper: Codeunit "Type Helper";
        TempBlob: Codeunit "Temp Blob";
        InStream: InStream;
    begin
        TempBlob.FromRecord(Rec, FieldNo("Error Call Stack"));
        TempBlob.CreateInStream(InStream, TextEncoding::Windows);
        exit(TypeHelper.ReadAsTextWithSeparator(InStream, TypeHelper.LFSeparator()));
    end;
}
#endif