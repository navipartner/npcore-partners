table 6150995 "NPR HU L POS Audit Log Aux."
{
    Access = Internal;
    Caption = 'HU Laurel POS Audit Log Aux. Info';
    DataClassification = CustomerContent;
    DrillDownPageId = "NPR HU L POS Audit Log Aux.";
    LookupPageId = "NPR HU L POS Audit Log Aux.";

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
            TableRelation = "NPR POS Entry";
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
        field(9; "Salesperson Code"; Code[20])
        {
            Caption = 'Salesperson Code';
            DataClassification = CustomerContent;
            TableRelation = "Salesperson/Purchaser";
        }
        field(10; "Change Amount"; Decimal)
        {
            Caption = 'Change Amount';
            DataClassification = CustomerContent;
        }
        field(11; "Rounding Amount"; Decimal)
        {
            Caption = 'Rounding Amount';
            DataClassification = CustomerContent;
        }
        field(20; "Transaction Type"; Enum "NPR HU L Transaction Type")
        {
            Caption = 'Transaction Type';
            DataClassification = CustomerContent;
        }
        field(25; "FCU BBOX ID"; Code[9])
        {
            Caption = 'FCU BBOX ID';
            DataClassification = CustomerContent;
        }
        field(26; "FCU Document No."; Integer)
        {
            Caption = 'FCU Document No.';
            DataClassification = CustomerContent;
        }
        field(27; "FCU Full Document No."; Text[50])
        {
            Caption = 'FCU Full Document No.';
            DataClassification = CustomerContent;
        }
        field(28; "FCU Timestamp"; Text[20])
        {
            Caption = 'FCU Timestamp';
            DataClassification = CustomerContent;
        }
        field(29; "FCU Closure No."; Integer)
        {
            Caption = 'FCU Closure No.';
            DataClassification = CustomerContent;
        }
        field(30; "Request Content"; Media)
        {
            Caption = 'Request Content';
            DataClassification = CustomerContent;
        }
        field(31; "Response Content"; Media)
        {
            Caption = 'Response Content';
            DataClassification = CustomerContent;
        }
        field(60; "Customer Name"; Text[100])
        {
            Caption = 'Customer Name';
            DataClassification = CustomerContent;
        }
        field(61; "Customer Post Code"; Text[20])
        {
            Caption = 'Customer Post Code';
            DataClassification = CustomerContent;
        }
        field(62; "Customer City"; Text[30])
        {
            Caption = 'Customer City';
            DataClassification = CustomerContent;
        }
        field(63; "Customer Address"; Text[100])
        {
            Caption = 'Customer Address';
            DataClassification = CustomerContent;
        }
        field(64; "Customer VAT Number"; Text[20])
        {
            Caption = 'Customer VAT Number';
            DataClassification = CustomerContent;
        }
        field(70; "Original Date"; Date)
        {
            Caption = 'Original Date';
            DataClassification = CustomerContent;
        }
        field(71; "Original Type"; Text[2])
        {
            Caption = 'Original Type';
            DataClassification = CustomerContent;
        }
        field(72; "Original BBOX ID"; Text[9])
        {
            Caption = 'Original BBOX ID';
            DataClassification = CustomerContent;
        }
        field(73; "Original Document No."; Integer)
        {
            Caption = 'Original Document No.';
            DataClassification = CustomerContent;
        }
        field(74; "Original Closure No."; Integer)
        {
            Caption = 'Original Closure No.';
            DataClassification = CustomerContent;
        }
        field(75; "Return Reason"; Enum "NPR HU L Return Reason Code")
        {
            Caption = 'Return Reason';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Audit Entry Type", "Audit Entry No.")
        {
        }
    }

    fieldgroups
    {
        fieldgroup(Brick; "POS Entry No.", "Entry Date", "POS Unit No.", "Salesperson Code", "Source Document No.", "Amount Incl. Tax", "FCU Document No.")
        {

        }
    }

    internal procedure FindAuditLog(POSEntryNo: Integer): Boolean
    begin
        SetRange("Audit Entry Type", "Audit Entry Type"::"POS Entry");
        SetRange("POS Entry No.", POSEntryNo);
        exit(FindFirst());
    end;

    internal procedure FindAuditLogBySalesTicket(SalesTicketNo: Code[20]): Boolean
    begin
        SetRange("Audit Entry Type", "Audit Entry Type"::"POS Entry");
        SetRange("Source Document No.", SalesTicketNo);
        exit(FindLast());
    end;

    internal procedure GetRequestText() RequestText: Text;
    var
        JSONManagement: Codeunit "JSON Management";
        TempBlob: Codeunit "Temp Blob";
        InStream: InStream;
        OutStream: OutStream;
        RequestTextLine: Text;
    begin
        TempBlob.CreateOutStream(OutStream, TextEncoding::UTF8);
        "Request Content".ExportStream(OutStream);
        TempBlob.CreateInStream(InStream, TextEncoding::UTF8);
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
        TempBlob: Codeunit "Temp Blob";
        InStream: InStream;
        OutStream: OutStream;
    begin
        if "Request Content".HasValue() then
            HULAuditMgt.ClearTenantMedia("Request Content".MediaId);

        TempBlob.CreateOutStream(OutStream, TextEncoding::UTF8);
        OutStream.WriteText(RequestText);
        TempBlob.CreateInStream(InStream, TextEncoding::UTF8);
        "Request Content".ImportStream(InStream, FieldCaption("Request Content"));
    end;

    internal procedure SetResponseText(ResponseText: Text)
    var
        TempBlob: Codeunit "Temp Blob";
        InStream: InStream;
        OutStream: OutStream;
    begin
        if "Response Content".HasValue() then
            HULAuditMgt.ClearTenantMedia("Response Content".MediaId);

        TempBlob.CreateOutStream(OutStream, TextEncoding::UTF8);
        OutStream.WriteText(ResponseText);
        TempBlob.CreateInStream(InStream, TextEncoding::UTF8);
        "Response Content".ImportStream(InStream, FieldCaption("Response Content"));
    end;

    internal procedure GetReceiptDateAsText(): Text
    var
        DateTimePart: List of [Text];
    begin
        DateTimePart := "FCU Timestamp".Split(' ');
        exit(DateTimePart.Get(1));
    end;

    var
        HULAuditMgt: Codeunit "NPR HU L Audit Mgt.";
}