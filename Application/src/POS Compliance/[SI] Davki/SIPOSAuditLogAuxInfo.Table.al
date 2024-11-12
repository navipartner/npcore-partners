table 6059838 "NPR SI POS Audit Log Aux. Info"
{
    Access = Internal;
    Caption = 'SI POS Audit Log Aux. Info';
    DataClassification = CustomerContent;
    DrillDownPageId = "NPR SI POS Audit Log Aux. Info";
    LookupPageId = "NPR SI POS Audit Log Aux. Info";

    fields
    {
        field(1; "Audit Entry Type"; Enum "NPR SI Audit Entry Type")
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
        field(8; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            DataClassification = CustomerContent;
        }
        field(9; "Receipt No."; Code[20])
        {
            Caption = 'Receipt No.';
            DataClassification = CustomerContent;
            trigger OnValidate()
            begin
                if "Receipt No." <> xRec."Receipt No." then begin
                    SIFiscalSetup.Get();
                    NoSeriesMgt.TestManual(SIFiscalSetup."Receipt No. Series");
                    "No. Series" := '';
                end;
            end;
        }
        field(10; "Log Timestamp"; Time)
        {
            Caption = 'Log Timestamp';
            DataClassification = CustomerContent;
        }
        field(11; "ZOI Code"; Text[32])
        {
            Caption = 'ZOI Code';
            DataClassification = CustomerContent;
        }
        field(12; "EOR Code"; Text[36])
        {
            Caption = 'EOR Code';
            DataClassification = CustomerContent;
        }
        field(13; "Cashier ID"; Integer)
        {
            Caption = 'Cashier ID';
            DataClassification = CustomerContent;
            TableRelation = "Salesperson/Purchaser".Code;
        }
        field(14; "Validation Code"; Text[60])
        {
            Caption = 'Validation Code';
            DataClassification = CustomerContent;
        }
        field(15; "Total Amount"; Decimal)
        {
            Caption = 'Total Amount';
            DataClassification = CustomerContent;
        }
        field(16; "Payment Amount"; Decimal)
        {
            Caption = 'Payment Amount';
            DataClassification = CustomerContent;
        }
        field(17; "Receipt Content"; Media)
        {
            Caption = 'Receipt Content';
            DataClassification = CustomerContent;
        }
        field(18; "Response Content"; Media)
        {
            Caption = 'Response Content';
            DataClassification = CustomerContent;
        }
        field(19; "Receipt Printed"; Boolean)
        {
            Caption = 'Receipt Printed';
            DataClassification = CustomerContent;
        }
        field(20; "Copies Printed"; Integer)
        {
            Caption = 'Copies Printed';
            DataClassification = CustomerContent;
            InitValue = 0;
        }
        field(21; "Return Receipt No."; Code[20])
        {
            Caption = 'Return Receipt No.';
            DataClassification = CustomerContent;
        }
        field(22; "Transaction Type"; Enum "NPR SI Transaction Type")
        {
            Caption = 'Transaction Type';
            DataClassification = CustomerContent;
        }
        field(23; "Subsequent Submit"; Boolean)
        {
            Caption = 'Subseqeunt Submit';
            DataClassification = CustomerContent;
        }
        field(24; "Receipt Fiscalized"; Boolean)
        {
            Caption = 'Receipt Fiscalized';
            DataClassification = CustomerContent;
        }
        field(25; "Sales Book Invoice No."; Code[20])
        {
            Caption = 'Sales Book Invoice No.';
            DataClassification = CustomerContent;
        }
        field(26; "Sales Book Serial No."; Text[40])
        {
            Caption = 'Sales Book Serial No.';
            DataClassification = CustomerContent;
        }
        field(27; "Returns Amount"; Decimal)
        {
            Caption = 'Refund Amount';
            DataClassification = CustomerContent;
        }
        field(30; "Customer VAT Number"; Text[20])
        {
            Caption = 'Customer VAT Number';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Audit Entry Type", "Audit Entry No.")
        {
        }
        key(Key2; "POS Entry No.")
        {
        }
    }

    trigger OnInsert()
    var
    begin
        if "Receipt No." = '' then begin
            SIFiscalSetup.Get();
            SIFiscalSetup.TestField("Receipt No. Series");
            NoSeriesMgt.InitSeries(SIFiscalSetup."Receipt No. Series", xRec."No. Series", 0D, "Receipt No.", "No. Series");
        end;
    end;

    procedure GetAuditFromPOSEntry(POSEntryNo: Integer): Boolean
    begin
        Rec.Reset();
        Rec.SetRange("Audit Entry Type", Rec."Audit Entry Type"::"POS Entry");
        Rec.SetRange("POS Entry No.", POSEntryNo);
        exit(Rec.FindFirst());
    end;

    procedure GetAuditFromSalesInvHeader(SalesInvHeaderNo: Code[20]): Boolean
    begin
        Rec.Reset();
        Rec.SetRange("Audit Entry Type", Rec."Audit Entry Type"::"Sales Invoice Header");
        Rec.SetRange("Source Document No.", SalesInvHeaderNo);
        exit(Rec.FindFirst());
    end;

    procedure GetAuditFromSalesCrMemoHeader(SalesCrMemoHeaderNo: Code[20]): Boolean
    begin
        Rec.Reset();
        Rec.SetRange("Audit Entry Type", Rec."Audit Entry Type"::"Sales Cr. Memo Header");
        Rec.SetRange("Source Document No.", SalesCrMemoHeaderNo);
        exit(Rec.FindFirst());
    end;

    var
        SIFiscalSetup: Record "NPR SI Fiscalization Setup";
        NoSeriesMgt: Codeunit NoSeriesManagement;
}