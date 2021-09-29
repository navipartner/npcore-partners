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
            DataClassification = EndUserIdentifiableInformation;
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
            DataClassification = EndUserPseudonymousIdentifiers;
            Description = 'NPR5.55';
        }
        field(100; "Earliest Import Datetime"; DateTime)
        {
            Caption = 'Earliest Import Datetime';
            DataClassification = CustomerContent;
            Description = 'NPR5.55';
        }

        field(110; "Batch Id"; GUID)
        {
            Caption = 'Batch Id';
            DataClassification = CustomerContent;
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
        key(Key4; "Import Type", "Batch Id", Imported)
        {
        }
    }

    var
        DeleteAllRecordsFromBatchConfirm: Label 'This operation will delete all entries with Batch Id %1. Are you sure you want to continue?';


    trigger OnInsert()
    begin
        if Date = 0DT then
            Date := CurrentDateTime;
    end;

    trigger OnDelete()
    var
        ImportEntry: Record "NPR Nc Import Entry";
        DeleteConfirmed: Boolean;
    begin
        IF NOT ISNULLGUID(Rec."Batch Id") then begin
            DeleteConfirmed := true;
            IF GuiAllowed then
                IF NOT Confirm(StrSubstNo(DeleteAllRecordsFromBatchConfirm, Rec."Batch Id")) then
                    DeleteConfirmed := false;

            IF DeleteConfirmed then begin
                ImportEntry.SetRange("Import Type", Rec."Import Type");
                ImportEntry.SetRange("Batch Id", Rec."Batch Id");
                If NOT ImportEntry.IsEmpty then
                    ImportEntry.DeleteAll();
            end else
                Error('');
        end;
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

