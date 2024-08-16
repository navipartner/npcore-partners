table 6059860 "NPR RS POS Audit Log Aux. Copy"
{
    Access = Internal;
    Caption = 'RS POS Audit Log Aux. Copy';
    DataClassification = CustomerContent;
    DrillDownPageId = "NPR RS POS Audit Log Aux. Copy";
    LookupPageId = "NPR RS POS Audit Log Aux. Copy";

    fields
    {
        field(1; "Audit Entry No."; Integer)
        {
            Caption = 'POS Entry No.';
            DataClassification = CustomerContent;
        }
        field(2; "Audit Entry Type"; Enum "NPR RS Audit Entry Type")
        {
            Caption = 'Audit Entry Type';
            DataClassification = CustomerContent;
        }
        field(3; "Copy No."; Integer)
        {
            Caption = 'Copy No.';
            DataClassification = CustomerContent;
        }
        field(4; "POS Store Code"; Code[10])
        {
            Caption = 'POS Store Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Store";
        }
        field(5; "POS Unit No."; Code[10])
        {
            Caption = 'POS Unit No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Unit";
        }
        field(6; "RS Invoice Type"; Enum "NPR RS Invoice Type")
        {
            Caption = 'Invoice Type';
            DataClassification = CustomerContent;
        }
        field(7; "RS Transaction Type"; Enum "NPR RS Transaction Type")
        {
            Caption = 'Transaction Type';
            DataClassification = CustomerContent;
        }
        field(8; "POS Entry No."; Integer)
        {
            Caption = 'POS Entry No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Entry";
        }
        field(9; "Source Document No."; Code[20])
        {
            Caption = 'Source Document No.';
            DataClassification = CustomerContent;
        }
        field(10; "Requested By"; Text[10])
        {
            Caption = 'Requested By';
            DataClassification = CustomerContent;
        }
        field(11; "SDC DateTime"; Text[33])
        {
            Caption = 'SDC Date and Time';
            DataClassification = CustomerContent;
        }
        field(12; "Invoice Counter"; Text[20])
        {
            Caption = 'Invoice Counter';
            DataClassification = CustomerContent;
        }
        field(13; "Invoice Counter Extension"; Text[10])
        {
            Caption = 'Invoice Counter Extension';
            DataClassification = CustomerContent;
        }
        field(14; "Invoice Number"; Text[30])
        {
            Caption = 'Invoice Number';
            DataClassification = CustomerContent;
        }
        field(15; "Verification URL"; Text[1024])
        {
            Caption = 'Verification URL';
            DataClassification = CustomerContent;
        }
        field(16; Journal; Text[2048])
        {
            Caption = 'Journal';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'Changing field to be Media type. New field: Receipt Content';
        }
        field(17; "Receipt Content"; Media)
        {
            Caption = 'Receipt Content';
            DataClassification = CustomerContent;
        }
        field(18; "Ecrypted Internal Data"; Text[512])
        {
            Caption = 'Ecrypted Internal Data';
            DataClassification = CustomerContent;
        }
        field(19; Signature; Text[512])
        {
            Caption = 'Signature';
            DataClassification = CustomerContent;
        }
        field(20; "Total Counter"; Integer)
        {
            Caption = 'Total Counter';
            DataClassification = CustomerContent;
        }
        field(21; "Transaction Type Counter"; Integer)
        {
            Caption = 'Transaction Type Counter';
            DataClassification = CustomerContent;
        }
        field(22; "Total Amount"; Decimal)
        {
            Caption = 'Total Amount';
            DataClassification = CustomerContent;
        }
        field(23; "Tax Group Revision"; Integer)
        {
            Caption = 'Tax Group Revision';
            DataClassification = CustomerContent;
        }
        field(24; "Business Name"; Text[500])
        {
            Caption = 'Business Name';
            DataClassification = CustomerContent;
        }
        field(25; Tin; Text[20])
        {
            Caption = 'Tin';
            DataClassification = CustomerContent;
        }
        field(26; "Location Name"; Text[100])
        {
            Caption = 'Location Name';
            DataClassification = CustomerContent;
        }
        field(27; Address; Text[300])
        {
            Caption = 'Address';
            DataClassification = CustomerContent;
        }
        field(28; District; Text[100])
        {
            Caption = 'District';
            DataClassification = CustomerContent;
        }
        field(29; Mrc; Text[40])
        {
            Caption = 'Mrc';
            DataClassification = CustomerContent;
        }
        field(30; "Signed By"; Text[20])
        {
            Caption = 'Signed By';
            DataClassification = CustomerContent;
        }
        field(50; "Customer Identification"; Code[30])
        {
            Caption = 'Customer Identification';
            DataClassification = CustomerContent;
        }
        field(51; "Additional Customer Field"; Code[30])
        {
            Caption = 'Additional Customer Field';
            DataClassification = CustomerContent;
        }
        field(54; "Payment Method Code"; Code[10])
        {
            Caption = 'Payment Method Code';
            DataClassification = CustomerContent;
            TableRelation = "Payment Method";
        }
        field(56; "Discount Amount"; Decimal)
        {
            Caption = 'Discount Amount';
            DataClassification = CustomerContent;
        }
        field(57; "Entry Date"; Date)
        {
            Caption = 'Entry Date';
            DataClassification = CustomerContent;
        }
        field(65; "Source Document Type"; Enum "Sales Document Type")
        {
            Caption = 'Source Document Type';
            DataClassification = CustomerContent;
        }
        field(70; "Email-To"; Text[250])
        {
            Caption = 'Email-To';
            DataClassification = CustomerContent;
        }
        field(120; "Return Reference No."; Code[100])
        {
            Caption = 'Return Reference No.';
            DataClassification = CustomerContent;
        }
        field(121; "Return Reference Date/Time"; Text[33])
        {
            Caption = 'Return Reference Date/Time';
            DataClassification = CustomerContent;
        }
        field(200; "Fiscal Processing Time"; Duration)
        {
            Caption = 'Fiscal Processing Time';
            DataClassification = CustomerContent;
            Editable = false;
        }
    }

    keys
    {
        key(Key1; "Audit Entry Type", "Audit Entry No.", "Copy No.")
        {
        }
    }

    procedure GetTextFromJournal() JournalText: Text;
    var
        TempBlob: Codeunit "Temp Blob";
        OutStream: OutStream;
        InStream: InStream;
    begin
        TempBlob.CreateOutStream(OutStream, TextEncoding::UTF8);
        Rec."Receipt Content".ExportStream(OutStream);
        TempBlob.CreateInStream(InStream, TextEncoding::UTF8);
        InStream.ReadText(JournalText);
    end;

    procedure SetTextToJournal(JournalText: Text)
    var
        TempBlob: Codeunit "Temp Blob";
        OutStream: OutStream;
        InStream: InStream;
    begin
        TempBlob.CreateOutStream(OutStream, TextEncoding::UTF8);
        OutStream.WriteText(JournalText);
        TempBlob.CreateInStream(InStream, TextEncoding::UTF8);
        Rec."Receipt Content".ImportStream(InStream, Rec.FieldCaption("Receipt Content"));
    end;
}
