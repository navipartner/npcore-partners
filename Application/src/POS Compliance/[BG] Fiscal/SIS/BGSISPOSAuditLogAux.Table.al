table 6150735 "NPR BG SIS POS Audit Log Aux."
{
    Access = Internal;
    Caption = 'BG SIS POS Audit Log Aux. Info';
    DataClassification = CustomerContent;
    DrillDownPageId = "NPR BG SIS POS Audit Log Aux.";
    LookupPageId = "NPR BG SIS POS Audit Log Aux.";

    fields
    {
        field(1; "Audit Entry Type"; Enum "NPR BG Audit Entry Type")
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
        field(8; "Amount Incl. Tax"; Decimal)
        {
            Caption = 'Amount Incl. Tax';
            DataClassification = CustomerContent;
        }
        field(10; "Grand Receipt No."; Text[10])
        {
            Caption = 'Grand Receipt No.';
            DataClassification = CustomerContent;
        }
        field(15; "Receipt Timestamp"; Text[30])
        {
            Caption = 'Receipt Timestamp';
            DataClassification = CustomerContent;
        }
        field(20; "Transaction Type"; Enum "NPR BG SIS Transaction Type")
        {
            Caption = 'Transaction Type';
            DataClassification = CustomerContent;
        }
        field(25; "Extended Receipt"; Boolean)
        {
            Caption = 'Extended Receipt';
            DataClassification = CustomerContent;
        }
        field(30; "Fiscal Printer Device No."; Text[8])
        {
            Caption = 'Fiscal Printer Device No.';
            DataClassification = CustomerContent;
        }
        field(31; "Fiscal Printer Memory No."; Text[8])
        {
            Caption = 'Fiscal Printer Memory No.';
            DataClassification = CustomerContent;
        }
        field(40; "Request Content"; Media)
        {
            Caption = 'Request Content';
            DataClassification = CustomerContent;
        }
        // TO-DO this will be finished in one of the future tasks
        // field(50; "Receipt Content"; Media)
        // {
        //     Caption = 'Receipt Content';
        //     DataClassification = CustomerContent;
        // }
    }

    keys
    {
        key(Key1; "Audit Entry Type", "Audit Entry No.")
        {
        }
    }

    internal procedure FindAuditLog(POSEntryNo: Integer): Boolean
    begin
        SetRange("Audit Entry Type", "Audit Entry Type"::"POS Entry");
        SetRange("POS Entry No.", POSEntryNo);
        exit(FindFirst());
    end;

    internal procedure GetRequestText() RequestText: Text;
    var
        JSONManagement: Codeunit "JSON Management";
        TempBlob: Codeunit "Temp Blob";
        InStream: InStream;
        OutStream: OutStream;
        RequestTextLine: Text;
    begin
        TempBlob.CreateOutStream(OutStream);
        "Request Content".ExportStream(OutStream);
        TempBlob.CreateInStream(InStream);
        while not InStream.EOS do begin
            InStream.ReadText(RequestTextLine);
            RequestText += RequestTextLine;
        end;

        if RequestText <> '' then begin
            JSONManagement.InitializeFromString(RequestText);
            RequestText := JSONManagement.WriteObjectToString();
        end;
    end;

    internal procedure SetRequestText(RequestText: Text)
    var
        TenantMedia: Record "Tenant Media";
        TempBlob: Codeunit "Temp Blob";
        InStream: InStream;
        OutStream: OutStream;
    begin
        if "Request Content".HasValue() then
            if TenantMedia.Get("Request Content".MediaId) then
                TenantMedia.Delete(true);

        TempBlob.CreateOutStream(OutStream);
        OutStream.WriteText(RequestText);
        TempBlob.CreateInStream(InStream);
        "Request Content".ImportStream(InStream, FieldCaption("Request Content"));
    end;

    // TO-DO this will be finished in one of the future tasks
    // internal procedure GetReceiptData() ReceiptData: Text;
    // var
    //     Base64Convert: Codeunit "Base64 Convert";
    //     TempBlob: Codeunit "Temp Blob";
    //     InStream: InStream;
    //     OutStream: OutStream;
    //     ReceiptDataEncoded: Text;
    // begin
    //     TempBlob.CreateOutStream(OutStream);
    //     Rec."Receipt Content".ExportStream(OutStream);
    //     TempBlob.CreateInStream(InStream);
    //     InStream.ReadText(ReceiptDataEncoded);
    //     ReceiptData := Base64Convert.FromBase64(ReceiptDataEncoded, TextEncoding::Windows);
    // end;

    // internal procedure SetReceiptData(ReceiptData: Text)
    // var
    //     TenantMedia: Record "Tenant Media";
    //     TempBlob: Codeunit "Temp Blob";
    //     InStream: InStream;
    //     OutStream: OutStream;
    // begin
    //     if "Receipt Content".HasValue() then
    //         if TenantMedia.Get("Receipt Content".MediaId) then
    //             TenantMedia.Delete(true);

    //     TempBlob.CreateOutStream(OutStream);
    //     OutStream.WriteText(ReceiptData);
    //     TempBlob.CreateInStream(InStream);
    //     "Receipt Content".ImportStream(InStream, FieldCaption("Receipt Content"));
    // end;
}