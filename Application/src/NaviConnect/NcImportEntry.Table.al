table 6151504 "NPR Nc Import Entry"
{
    Caption = 'Nc Import Entry';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; BigInteger)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(3; "Import Type"; Code[20])
        {
            Caption = 'Import Type';
            DataClassification = CustomerContent;
            Description = 'NC1.21,NC2.12';
            TableRelation = "NPR Nc Import Type";
        }
        field(5; "Date"; DateTime)
        {
            Caption = 'Date';
            DataClassification = CustomerContent;
        }
        field(7; "Document Name"; Text[100])
        {
            Caption = 'Document Name';
            DataClassification = CustomerContent;
            Description = 'NC1.22';
        }
        field(8; "Document Source"; BLOB)
        {
            Caption = 'Document Source';
            DataClassification = CustomerContent;

            trigger OnLookup()
            begin
                CalcFields("Document Source");
                "Document Source".Export(TemporaryPath + "Document Name");
                HyperLink(TemporaryPath + "Document Name");
            end;
        }
        field(9; Imported; Boolean)
        {
            Caption = 'Imported';
            DataClassification = CustomerContent;
        }
        field(10; "Runtime Error"; Boolean)
        {
            Caption = 'Runtime Error';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                Clear("Last Error Message");
            end;
        }
        field(11; "Last Error Message"; BLOB)
        {
            Caption = 'Last Error Message';
            DataClassification = CustomerContent;
        }
        field(12; "Error Message"; Text[250])
        {
            Caption = 'Error Message';
            DataClassification = CustomerContent;
        }
        field(15; "Last Error E-mail Sent at"; DateTime)
        {
            Caption = 'Last Error E-mail Sent at';
            DataClassification = CustomerContent;
            Description = 'NC2.02';
        }
        field(17; "Last Error E-mail Sent to"; Text[250])
        {
            Caption = 'Last Error E-mail Sent to';
            DataClassification = CustomerContent;
            Description = 'NC2.02';
        }
        field(30; "Document ID"; Text[100])
        {
            Caption = 'Document ID';
            DataClassification = CustomerContent;
            Description = 'NC1.22,NC2.12';
        }
        field(35; "Sequence No."; Integer)
        {
            Caption = 'Sequence No.';
            DataClassification = CustomerContent;
            Description = 'NC1.22,NC2.12';
        }
        field(40; "Import Started at"; DateTime)
        {
            Caption = 'Import Started at';
            DataClassification = CustomerContent;
            Description = 'NC2.16';
            Editable = false;
        }
        field(45; "Import Completed at"; DateTime)
        {
            Caption = 'Import Completed at';
            DataClassification = CustomerContent;
            Description = 'NC2.16';
            Editable = false;
        }
        field(50; "Import Duration"; Decimal)
        {
            Caption = 'Import Duration (sec.)';
            DataClassification = CustomerContent;
            Description = 'NC2.16';
            Editable = false;
        }
        field(60; "Import Count"; Integer)
        {
            BlankZero = true;
            Caption = 'Import Count';
            DataClassification = CustomerContent;
            Description = 'NPR5.55';
            MinValue = 0;
        }
        field(70; "Import Started by"; Code[50])
        {
            Caption = 'Import Started by';
            DataClassification = CustomerContent;
            Description = 'NPR5.55';
        }
        field(80; "Server Instance Id"; Integer)
        {
            Caption = 'Server Instance Id';
            DataClassification = CustomerContent;
            Description = 'NPR5.55';
        }
        field(90; "Session Id"; Integer)
        {
            Caption = 'Session Id';
            DataClassification = CustomerContent;
            Description = 'NPR5.55';
        }
        field(100; "Earliest Import Datetime"; DateTime)
        {
            Caption = 'Earliest Import Datetime';
            DataClassification = CustomerContent;
            Description = 'NPR5.55';
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
        }
        key(Key2; "Document ID", "Sequence No.")
        {
        }
        key(Key3; "Import Type", Date, Imported)
        {
        }
    }

    trigger OnInsert()
    begin
        if Date = 0DT then
            Date := CurrentDateTime;
    end;

    var
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";

    [Obsolete('Use native Business Central objects instead of DotNet classes', '')]
    procedure LoadXmlDoc(var XmlDoc: DotNet "NPRNetXmlDocument"): Boolean
    var
        InStr: InStream;
    begin
        CalcFields("Document Source");
        if not "Document Source".HasValue() then
            exit(false);

        "Document Source".CreateInStream(InStr);
        if not IsNull(XmlDoc) then
            Clear(XmlDoc);
        XmlDoc := XmlDoc.XmlDocument();
        XmlDoc.Load(InStr);
        NpXmlDomMgt.RemoveNameSpaces(XmlDoc);
        Clear(InStr);
        exit(true);
    end;

    procedure LoadXmlDoc(var Document: XmlDocument): Boolean
    var
        XmlDomManagement: Codeunit "XML DOM Management";
        InStr: InStream;
        BufferText: Text;
        XML: Text;
    begin
        CalcFields("Document Source");
        if not "Document Source".HasValue() then
            exit(false);

        "Document Source".CreateInStream(InStr, TextEncoding::UTF8);
        XML := '';
        while not InStr.EOS() do begin
            InStr.ReadText(BufferText);
            XML += BufferText;
        end;
        XML := XmlDomManagement.RemoveNamespaces(XML);

        Clear(InStr);
        Clear(Document);

        XmlDocument.ReadFrom(XML, Document);
        exit(true);
    end;

    procedure HasActiveImport(): Boolean
    var
        ActiveSession: Record "Active Session";
    begin
        if "Import Completed at" > "Import Started at" then
            exit(false);

        if not GetActiveSession(ActiveSession) then
            exit(false);

        if ActiveSession."User ID" <> "Import Started by" then
            exit(false);

        exit(ActiveSession."Login Datetime" <= "Import Started at");
    end;

    local procedure GetActiveSession(var ActiveSession: Record "Active Session"): Boolean
    begin
        Clear(ActiveSession);

        if "Server Instance Id" <= 0 then
            exit(false);
        if "Session Id" <= 0 then
            exit(false);

        exit(ActiveSession.Get("Server Instance Id", "Session Id"));
    end;
}

