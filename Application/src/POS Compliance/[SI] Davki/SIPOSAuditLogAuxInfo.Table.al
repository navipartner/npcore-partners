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
            var
                SIPOSStoreMapping: Record "NPR SI POS Store Mapping";
            begin
                if "Receipt No." <> xRec."Receipt No." then begin
                    SIPOSStoreMapping.Get(Rec."POS Store Code");
                    NoSeriesMgt.TestManual(SIPOSStoreMapping."Receipt No. Series");
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
        field(31; "Salesperson Code"; Code[20])
        {
            Caption = 'Salesperson Code';
            DataClassification = CustomerContent;
        }
        field(32; "Email-To"; Text[250])
        {
            Caption = 'Email-To';
            DataClassification = CustomerContent;
        }
        field(33; "Fiscal Bill E-Mails"; Boolean)
        {
            CalcFormula = exist("NPR SI Fiscal E-Mail Log" where("Audit Entry Type" = field("Audit Entry Type"), "Audit Entry No." = field("Audit Entry No."), Successful = const(true)));
            Caption = 'Fiscal Bill E-Mails';
            Editable = false;
            FieldClass = FlowField;
        }
        field(35; "Return Additional Info"; Text[250])
        {
            Caption = 'Return Additional Info';
            DataClassification = CustomerContent;
        }
        field(40; "Salesbook Entry No."; Integer)
        {
            Caption = 'Salesbook Entry No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR SI Salesbook Receipt";
        }
        field(50; "Collect in Store"; Boolean)
        {
            Caption = 'Collect in Store';
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
        SIPOSStoreMapping: Record "NPR SI POS Store Mapping";
    begin
        if "Receipt No." = '' then begin
            SIPOSStoreMapping.Get(Rec."POS Store Code");
            SIPOSStoreMapping.TestField("Receipt No. Series");
#IF NOT (BC17 OR BC18 OR BC19 OR BC20 OR BC21 OR BC22 OR BC23)
            "No. Series" := SIPOSStoreMapping."Receipt No. Series";
            if NoSeriesMgt.AreRelated(SIPOSStoreMapping."Receipt No. Series", xRec."No. Series") then
                "No. Series" := xRec."No. Series";
            "Receipt No." := NoSeriesMgt.GetNextNo("No. Series");
#ELSE
            NoSeriesMgt.InitSeries(SIPOSStoreMapping."Receipt No. Series", xRec."No. Series", 0D, "Receipt No.", "No. Series");
#ENDIF
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

    procedure GetAuditFromSourceDocument(SourceDocumentNo: Code[20]): Boolean
    begin
        Rec.Reset();
        Rec.SetLoadFields("Receipt No.", "POS Store Code", "POS Unit No.", "Entry Date", "Log Timestamp");
        Rec.SetRange("Source Document No.", SourceDocumentNo);
        exit(Rec.FindFirst());
    end;

    var
#IF NOT (BC17 OR BC18 OR BC19 OR BC20 OR BC21 OR BC22 OR BC23)
        NoSeriesMgt: Codeunit "No. Series";
#ELSE
        NoSeriesMgt: Codeunit NoSeriesManagement;
#ENDIF
}