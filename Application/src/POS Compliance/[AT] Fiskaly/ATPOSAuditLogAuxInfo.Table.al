table 6150857 "NPR AT POS Audit Log Aux. Info"
{
    Access = Internal;
    Caption = 'AT POS Audit Log Aux. Info';
    DataClassification = CustomerContent;
    DrillDownPageId = "NPR AT POS Audit Log Aux. Info";
    LookupPageId = "NPR AT POS Audit Log Aux. Info";

    fields
    {
        field(1; "Audit Entry Type"; Enum "NPR AT Audit Entry Type")
        {
            Caption = 'Audit Entry Type';
            DataClassification = CustomerContent;
        }
        field(2; "Audit Entry No."; Integer)
        {
            Caption = 'Audit Entry No.';
            DataClassification = CustomerContent;
            AutoIncrement = true;
        }
        field(10; "POS Entry No."; Integer)
        {
            Caption = 'POS Entry No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Entry";
        }
        field(20; "Entry Date"; Date)
        {
            Caption = 'Entry Date';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Entry"."Entry Date";
        }
        field(30; "POS Store Code"; Code[10])
        {
            Caption = 'POS Store Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Store".Code;
        }
        field(40; "POS Unit No."; Code[10])
        {
            Caption = 'POS Unit No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Unit"."No.";
        }
        field(50; "Source Document No."; Code[20])
        {
            Caption = 'Source Document No.';
            DataClassification = CustomerContent;
        }
        field(60; "Amount Incl. Tax"; Decimal)
        {
            Caption = 'Amount Incl. Tax';
            DataClassification = CustomerContent;
        }
        field(80; "Salesperson Code"; Code[20])
        {
            Caption = 'Salesperson Code';
            DataClassification = CustomerContent;
            TableRelation = "Salesperson/Purchaser";
        }
        field(90; "AT Organization Code"; Code[20])
        {
            Caption = 'AT Organization Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR AT Organization";
        }
        field(100; "AT SCU Code"; Code[20])
        {
            Caption = 'AT Signature Creation Unit Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR AT SCU";
        }
        field(101; "AT SCU Id"; Guid)
        {
            Caption = 'AT Signature Creation Unit Id';
            DataClassification = CustomerContent;
        }
        field(111; "AT Cash Register Id"; Guid)
        {
            Caption = 'AT Cash Register Id';
            DataClassification = CustomerContent;
        }
        field(112; "AT Cash Register Serial Number"; Text[100])
        {
            Caption = 'AT Cash Register Serial Number';
            DataClassification = CustomerContent;
        }
        field(120; "Receipt Type"; Enum "NPR AT Receipt Type")
        {
            Caption = 'Receipt Type';
            DataClassification = CustomerContent;
        }
        field(130; "Receipt Number"; Text[30])
        {
            Caption = 'Receipt Number';
            DataClassification = CustomerContent;
        }
        field(140; Signed; Boolean)
        {
            Caption = 'Signed';
            DataClassification = CustomerContent;
        }
        field(141; "Signed At"; DateTime)
        {
            Caption = 'Signed At';
            DataClassification = CustomerContent;
        }
        field(150; "QR Code"; Media)
        {
            Caption = 'QR Code';
            DataClassification = CustomerContent;
        }
        field(160; Hints; Text[250])
        {
            Caption = 'Hints';
            DataClassification = CustomerContent;
        }
        field(170; "FON Receipt Validation Status"; Enum "NPR AT FON Rcpt. Valid. Status")
        {
            Caption = 'FinanzOnline Receipt Validation Status';
            DataClassification = CustomerContent;
        }
        field(171; "Validated At"; DateTime)
        {
            Caption = 'Validated At';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Audit Entry Type", "Audit Entry No.")
        {
        }
    }

    fieldgroups
    {
        fieldgroup(Brick; "POS Entry No.", "Entry Date", "POS Unit No.", "Salesperson Code", "Source Document No.", "Amount Incl. Tax")
        {

        }
    }

    trigger OnInsert()
    begin
        SystemId := CreateGuid();
    end;

    internal procedure FindAuditLog(POSEntryNo: Integer): Boolean
    begin
        SetRange("Audit Entry Type", "Audit Entry Type"::"POS Entry");
        SetRange("POS Entry No.", POSEntryNo);
        exit(FindFirst());
    end;

    internal procedure GetQRCode() QRCode: Text;
    var
        TempBlob: Codeunit "Temp Blob";
        OutStream: OutStream;
        InStream: InStream;
    begin
        TempBlob.CreateOutStream(OutStream, TextEncoding::UTF8);
        Rec."QR Code".ExportStream(OutStream);
        TempBlob.CreateInStream(InStream, TextEncoding::UTF8);
        InStream.ReadText(QRCode);
    end;

    internal procedure SetQRCode(QRCode: Text)
    var
        TenantMedia: Record "Tenant Media";
        TempBlob: Codeunit "Temp Blob";
        OutStream: OutStream;
        InStream: InStream;
    begin
        if "QR Code".HasValue() then
            if TenantMedia.Get("QR Code".MediaId) then
                TenantMedia.Delete(true);

        TempBlob.CreateOutStream(OutStream, TextEncoding::UTF8);
        OutStream.WriteText(QRCode);
        TempBlob.CreateInStream(InStream, TextEncoding::UTF8);
        Rec."QR Code".ImportStream(InStream, Rec.FieldCaption("QR Code"));
    end;
}