table 6150738 "NPR IT POS Audit Log Aux Info"
{
    Access = Internal;
    Caption = 'IT POS Audit Log Aux. Info';
    DataClassification = CustomerContent;
    DrillDownPageId = "NPR IT POS Audit Log Aux Info";
    LookupPageId = "NPR IT POS Audit Log Aux Info";

    fields
    {
        field(1; "Audit Entry Type"; Enum "NPR IT Audit Entry Type")
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
        field(3; "POS Entry No."; Integer)
        {
            Caption = 'POS Entry No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Entry"."Entry No.";
        }
        field(4; "Entry Date"; Date)
        {
            Caption = 'Entry Date';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Entry"."Entry Date";
        }
        field(5; "POS Store Code"; Code[10])
        {
            Caption = 'POS Store Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Store".Code;
        }
        field(6; "POS Unit No."; Code[10])
        {
            Caption = 'POS Unit No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Unit"."No.";
        }
        field(7; "Source Document No."; Code[20])
        {
            Caption = 'Source Document No.';
            DataClassification = CustomerContent;
        }
        field(8; "Payment Method"; Enum "NPR IT Payment Method")
        {
            Caption = 'Payment Method';
            DataClassification = CustomerContent;
        }
        field(9; "Transaction Type"; Enum "NPR IT Transaction Type")
        {
            Caption = 'Transaction Type';
            DataClassification = CustomerContent;
        }
        field(10; "Z Report No."; Code[20])
        {
            Caption = 'Z Report No.';
            DataClassification = CustomerContent;
        }
        field(11; "Receipt No."; Code[20])
        {
            Caption = 'Receipt No.';
            DataClassification = CustomerContent;
        }
        field(12; Amount; Decimal)
        {
            Caption = 'Amount';
            DataClassification = CustomerContent;
        }
        field(13; "Refund Source Document No."; Code[20])
        {
            Caption = 'Return Source Document No.';
            DataClassification = CustomerContent;
        }
        field(14; "Receipt Fiscalized"; Boolean)
        {
            Caption = 'Receipt Fiscalized';
            DataClassification = CustomerContent;
        }
        field(15; "Fiscal Printer Serial No."; Text[11])
        {
            Caption = 'Fiscal Printer Serial No.';
            DataClassification = CustomerContent;
        }
        field(16; "Customer Lottery Code"; Text[15])
        {
            Caption = 'Customer Lottery Code';
            DataClassification = CustomerContent;
        }
        field(17; "Request Content"; Media)
        {
            Caption = 'Request Content';
            DataClassification = CustomerContent;
        }
        field(18; "Response Content"; Media)
        {
            Caption = 'Response Content';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Audit Entry Type", "Audit Entry No.")
        {
        }
    }

    internal procedure GetAuditFromPOSEntry(POSEntryNo: Integer): Boolean
    begin
        Rec.Reset();
        Rec.SetRange("Audit Entry Type", Rec."Audit Entry Type"::"POS Entry");
        Rec.SetRange("POS Entry No.", POSEntryNo);
        exit(Rec.FindFirst());
    end;

    internal procedure SetRequestContent(RequestText: Text)
    var
        TenantMedia: Record "Tenant Media";
        TempBlob: Codeunit "Temp Blob";
        InStream: InStream;
        OutStream: OutStream;
    begin
        if "Request Content".HasValue() then
            if TenantMedia.Get("Request Content".MediaId) then
                TenantMedia.Delete(true);

        TempBlob.CreateOutStream(OutStream, TextEncoding::UTF8);
        OutStream.WriteText(RequestText);
        TempBlob.CreateInStream(InStream, TextEncoding::UTF8);
        "Request Content".ImportStream(InStream, FieldCaption("Request Content"));
    end;

    internal procedure SetResponseContent(ResponseText: Text)
    var
        TenantMedia: Record "Tenant Media";
        TempBlob: Codeunit "Temp Blob";
        InStream: InStream;
        OutStream: OutStream;
    begin
        if "Response Content".HasValue() then
            if TenantMedia.Get("Response Content".MediaId) then
                TenantMedia.Delete(true);

        TempBlob.CreateOutStream(OutStream, TextEncoding::UTF8);
        OutStream.WriteText(ResponseText);
        TempBlob.CreateInStream(InStream, TextEncoding::UTF8);
        "Response Content".ImportStream(InStream, FieldCaption("Response Content"));
    end;

}