table 6060059 "NPR CRO POS Aud. Log Aux. Info"
{
    Access = Internal;
    Caption = 'CRO POS Audit Log Aux. Info';
    DataClassification = CustomerContent;
    DrillDownPageId = "NPR CRO POS Aud. Log Aux. Info";
    LookupPageId = "NPR CRO POS Aud. Log Aux. Info";

    fields
    {
        field(1; "Audit Entry Type"; Enum "NPR CRO Audit Entry Type")
        {
            Caption = 'Audit Entry Type';
            DataClassification = CustomerContent;
        }
        field(2; "Audit Entry No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Audit Entry No.';
            DataClassification = CustomerContent;
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
        field(8; "JIR Code"; Text[36])
        {
            Caption = 'JIR';
            DataClassification = CustomerContent;
        }
        field(9; "ZKI Code"; Text[32])
        {
            Caption = 'ZKI';
            DataClassification = CustomerContent;
        }
        field(10; "Bill No."; Code[20])
        {
            Caption = 'Bill No.';
            DataClassification = CustomerContent;
            trigger OnValidate()
            begin
                if "Bill No." <> xRec."Bill No." then begin
                    CROFiscalSetup.Get();
                    NoSeriesMgt.TestManual(CROFiscalSetup."Bill No. Series");
                    "No. Series" := '';
                end;
            end;
        }
        field(11; "Log Timestamp"; Time)
        {
            Caption = 'Log Timestamp';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(12; "Cashier ID"; BigInteger)
        {
            Caption = 'Cashier ID';
            DataClassification = CustomerContent;
            TableRelation = "NPR CRO Aux Salesperson/Purch."."NPR CRO Salesperson OIB";
        }
        field(13; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            DataClassification = CustomerContent;
        }
        field(14; "Payment Method Code"; Code[10])
        {
            Caption = 'Payment Method Code';
            DataClassification = CustomerContent;
            trigger OnValidate()
            begin
                if Rec."Audit Entry Type" in [Rec."Audit Entry Type"::"POS Entry"] then
                    FindPOSPaymentMethodMapping()
                else
                    FindPaymentMethodMapping();
            end;
        }
        field(15; "CRO Payment Method"; Enum "NPR CRO POS Payment Method")
        {
            Caption = 'Payment Method';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteTag = 'NPR28.0';
            ObsoleteReason = 'Replaced by Payment Method field.';
        }
        field(16; "Receipt Content"; Media)
        {
            Caption = 'Receipt Content';
            DataClassification = CustomerContent;
        }
        field(17; "Verification URL"; Text[1024])
        {
            Caption = 'Verification URL';
            DataClassification = CustomerContent;
        }
        field(18; "Total Amount"; Decimal)
        {
            Caption = 'Total Amount';
            DataClassification = CustomerContent;
        }
        field(19; "Receipt Fiscalized"; Boolean)
        {
            Caption = 'Receipt Fiscalized';
            DataClassification = CustomerContent;
            InitValue = false;
        }
        field(20; "Receipt Printed"; Boolean)
        {
            Caption = 'Receipt Printed';
            DataClassification = CustomerContent;
        }
        field(21; "Paragon Number"; Text[40])
        {
            Caption = 'Paragon Number';
            DataClassification = CustomerContent;
        }
        field(22; "Payment Method"; Enum "NPR CRO Payment Method")
        {
            Caption = 'Payment Method';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Audit Entry Type", "Audit Entry No.")
        {
        }
    }

    trigger OnInsert()
    var
    begin
        if "Bill No." = '' then begin
            CROFiscalSetup.Get();
            CROFiscalSetup.TestField("Bill No. Series");
            NoSeriesMgt.InitSeries(CROFiscalSetup."Bill No. Series", xRec."No. Series", 0D, "Bill No.", "No. Series");
        end;
    end;

    procedure GetAuditFromPOSEntry(POSEntryNo: Integer): Boolean
    begin
        Rec.Reset();
        Rec.SetRange("Audit Entry Type", Rec."Audit Entry Type"::"POS Entry");
        Rec.SetRange("POS Entry No.", POSEntryNo);
        exit(Rec.FindFirst());
    end;

    procedure GetAuditFromSalesInvoice(SalesInvoiceNo: Code[20]): Boolean
    begin
        Rec.Reset();
        Rec.SetRange("Audit Entry Type", Rec."Audit Entry Type"::"Sales Invoice");
        Rec.SetRange("Source Document No.", SalesInvoiceNo);
        exit(Rec.FindFirst());
    end;

    procedure GetAuditFromSalesCrMemo(SalesCrMemoNo: Code[20]): Boolean
    begin
        Rec.Reset();
        Rec.SetRange("Audit Entry Type", Rec."Audit Entry Type"::"Sales Credit Memo");
        Rec.SetRange("Source Document No.", SalesCrMemoNo);
        exit(Rec.FindFirst());
    end;

    local procedure FindPaymentMethodMapping()
    var
        CROPaymentMethodMapping: Record "NPR CRO Payment Method Mapping";
    begin
        if CROPaymentMethodMapping.Get("Payment Method Code") then
            "Payment Method" := CROPaymentMethodMapping."CRO Payment Method"
        else
            "Payment Method" := "NPR CRO Payment Method"::Other;
    end;

    local procedure FindPOSPaymentMethodMapping()
    var
        CROPOSPaymentMethodMapping: Record "NPR CRO POS Paym. Method Mapp.";
    begin
        if CROPOSPaymentMethodMapping.Get("Payment Method Code") then
            "Payment Method" := CROPOSPaymentMethodMapping."Payment Method"
        else
            "Payment Method" := "NPR CRO Payment Method"::Other;
    end;

    var
        CROFiscalSetup: Record "NPR CRO Fiscalization Setup";
        NoSeriesMgt: Codeunit NoSeriesManagement;
}