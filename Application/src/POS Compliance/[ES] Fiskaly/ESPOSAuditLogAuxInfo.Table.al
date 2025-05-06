table 6150894 "NPR ES POS Audit Log Aux. Info"
{
    Access = Internal;
    Caption = 'ES POS Audit Log Aux. Info';
    DataClassification = CustomerContent;
    DrillDownPageId = "NPR ES POS Audit Log Aux. Info";
    LookupPageId = "NPR ES POS Audit Log Aux. Info";

    fields
    {
        field(1; "Audit Entry Type"; Enum "NPR ES Audit Entry Type")
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
        field(90; "ES Organization Code"; Code[20])
        {
            Caption = 'ES Organization Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR ES Organization";
        }
        field(100; "ES Signer Code"; Code[20])
        {
            Caption = 'ES Signer Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR ES Signer";
        }
        field(101; "ES Signer Id"; Guid)
        {
            Caption = 'ES Signer Id';
            DataClassification = CustomerContent;
        }
        field(111; "ES Client Id"; Guid)
        {
            Caption = 'ES Client Id';
            DataClassification = CustomerContent;
        }
        field(120; "Invoice Type"; Enum "NPR ES Invoice Type")
        {
            Caption = 'Invoice Type';
            DataClassification = CustomerContent;
        }
        field(130; "Invoice No."; Code[20])
        {
            Caption = 'Invoice No.';
            DataClassification = CustomerContent;
        }
        field(131; "Invoice No. Series"; Code[20])
        {
            Caption = 'Invoice No. Series';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        field(140; "Invoice State"; Enum "NPR ES Invoice State")
        {
            Caption = 'Invoice State';
            DataClassification = CustomerContent;
        }
        field(141; "Issued At"; DateTime)
        {
            Caption = 'Issued At';
            DataClassification = CustomerContent;
        }
        field(150; "QR Code"; Media)
        {
            Caption = 'QR Code';
            DataClassification = CustomerContent;
        }
        field(160; "Validation URL"; Text[250])
        {
            Caption = 'Validation URL';
            DataClassification = CustomerContent;
        }
        field(170; "Invoice Registration State"; Enum "NPR ES Inv. Registration State")
        {
            Caption = 'Invoice Registration State';
            DataClassification = CustomerContent;
        }
        field(171; "Invoice Cancellation State"; Enum "NPR ES Inv. Cancellation State")
        {
            Caption = 'Invoice Cancellation State';
            DataClassification = CustomerContent;
        }
        field(180; "Invoice Validation Status"; Text[250])
        {
            Caption = 'Invoice Validation Status';
            DataClassification = CustomerContent;
        }
        field(181; "Invoice Validation Description"; Text[1024])
        {
            Caption = 'Invoice Validation Description';
            DataClassification = CustomerContent;
        }
        field(190; "Recipient Type"; Enum "NPR ES Inv. Recipient Type")
        {
            Caption = 'Recipient Type';
            DataClassification = CustomerContent;
        }
        field(191; "Recipient Legal Name"; Text[120])
        {
            Caption = 'Recipient Legal Name';
            DataClassification = CustomerContent;
        }
        field(192; "Recipient Address"; Text[250])
        {
            Caption = 'Recipient Address';
            DataClassification = CustomerContent;
        }
        field(193; "Recipient Post Code"; Code[20])
        {
            Caption = 'Recipient Post Code';
            DataClassification = CustomerContent;
            TableRelation = if ("Recipient Country/Region Code" = const('')) "Post Code" else
            if ("Recipient Country/Region Code" = filter(<> '')) "Post Code" where("Country/Region Code" = field("Recipient Country/Region Code"));
            ValidateTableRelation = false;
        }
        field(194; "Recipient VAT Registration No."; Text[9])
        {
            Caption = 'Recipient VAT Registration No.';
            DataClassification = CustomerContent;
        }
        field(195; "Recipient Identification Type"; Enum "NPR ES Inv. Rcpt. Id Type")
        {
            Caption = 'Recipient Identification Type';
            DataClassification = CustomerContent;
        }
        field(196; "Recipient Identification No."; Text[20])
        {
            Caption = 'Recipient Identification No.';
            DataClassification = CustomerContent;
        }
        field(197; "Recipient Country/Region Code"; Code[20])
        {
            Caption = 'Recipient Country/Region Code';
            DataClassification = CustomerContent;
            TableRelation = "Country/Region";
            ValidateTableRelation = false;
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

    internal procedure FindAuditLog(SourceDocumentNo: Code[20]): Boolean
    begin
        SetRange("Audit Entry Type", "Audit Entry Type"::"Customer Information");
        SetRange("Source Document No.", SourceDocumentNo);
        exit(FindFirst());
    end;

    internal procedure GetQRCode() QRCode: Text
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
        ESAuditMgt: Codeunit "NPR ES Audit Mgt.";
        TempBlob: Codeunit "Temp Blob";
        OutStream: OutStream;
        InStream: InStream;
    begin
        if "QR Code".HasValue() then
            ESAuditMgt.ClearTenantMedia("QR Code".MediaId);

        TempBlob.CreateOutStream(OutStream, TextEncoding::UTF8);
        OutStream.WriteText(QRCode);
        TempBlob.CreateInStream(InStream, TextEncoding::UTF8);
        Rec."QR Code".ImportStream(InStream, Rec.FieldCaption("QR Code"));
    end;
}