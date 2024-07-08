table 6014433 "NPR Posted Doc. Buffer"
{
    Access = Internal;
    // NPR5.53/ALPO/20191010 CASE 360297 Prepayment/layaway functionality additions

    Caption = 'Posted Document Buffer';
    DrillDownPageID = "NPR Posted Documents";
    LookupPageID = "NPR Posted Documents";
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Document Type"; Option)
        {
            Caption = 'Document Type';
            OptionCaption = 'Prepayment Invoice,Prepayment Credit Memo';
            OptionMembers = "Prepayment Invoice","Prepayment Credit Memo";
            DataClassification = CustomerContent;
        }
        field(2; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            DataClassification = CustomerContent;
        }
        field(3; "Source Record ID"; RecordID)
        {
            Caption = 'Source Record ID';
            DataClassification = CustomerContent;
        }
        field(10; "External Document No."; Code[35])
        {
            Caption = 'External Document No.';
            DataClassification = CustomerContent;
        }
        field(20; "Sell-to/Buy-from No."; Code[20])
        {
            Caption = 'Sell-to/Buy-from No.';
            TableRelation = Customer;
            DataClassification = CustomerContent;
        }
        field(30; "Bill-to/Pay-to No."; Code[20])
        {
            Caption = 'Bill-to/Pay-to No.';
            TableRelation = Customer;
            DataClassification = CustomerContent;
        }
        field(40; "Sell-to/Buy-from Name"; Text[100])
        {
            Caption = 'Sell-to/Buy-from Name';
            DataClassification = CustomerContent;
        }
        field(50; "Sell-to/Buy-from Name 2"; Text[50])
        {
            Caption = 'Sell-to/Buy-from Name 2';
            DataClassification = CustomerContent;
        }
        field(60; "Bill-to/Pay-to Name"; Text[100])
        {
            Caption = 'Bill-to/Pay-to Name';
            DataClassification = CustomerContent;
        }
        field(70; "Bill-to/Pay-to Name 2"; Text[50])
        {
            Caption = 'Bill-to/Pay-to Name 2';
            DataClassification = CustomerContent;
        }
        field(80; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
            DataClassification = CustomerContent;
        }
        field(90; "Document Date"; Date)
        {
            Caption = 'Document Date';
            DataClassification = CustomerContent;
        }
        field(100; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            TableRelation = Currency;
            DataClassification = CustomerContent;
        }
        field(110; Amount; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'Amount';
            DataClassification = CustomerContent;
        }
        field(120; "Amount Including VAT"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'Amount Including VAT';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Source Record ID", "Document Type", "Document No.")
        {
        }
        key(Key2; "Source Record ID", "Posting Date")
        {
        }
    }

    fieldgroups
    {
    }

    var
        MustBeTemporaryErr: Label 'Incorrect function call. Table 6014433 must be set up as temporary.\Please contact system vendor.';

    procedure Generate(SourceDocRec: Variant; PrepaymentOnly: Boolean)
    var
        SalesHeader: Record "Sales Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        DataTypeManagement: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if not IsTemporary then
            Error(MustBeTemporaryErr);

        if not DataTypeManagement.GetRecordRef(SourceDocRec, RecRef) then
            exit;
        case RecRef.Number of
            DATABASE::"Sales Header":
                begin
                    RecRef.SetTable(SalesHeader);

                    Reset();
                    SetRange("Source Record ID", RecRef.RecordId);
                    DeleteAll();

                    if PrepaymentOnly and (SalesHeader."Document Type" <> SalesHeader."Document Type"::Order) then
                        exit;
                    if SalesHeader."Document Type" = SalesHeader."Document Type"::Order then begin
                        SalesInvoiceHeader.SetCurrentKey("Prepayment Order No.");
                        SalesInvoiceHeader.SetRange("Prepayment Order No.", SalesHeader."No.");
                        SalesInvoiceHeader.SetRange("Prepayment Invoice", true);
                        SalesInvoiceHeader.SetAutoCalcFields(Amount, "Amount Including VAT");
                        if SalesInvoiceHeader.FindSet() then
                            repeat
                                Init();
                                "Source Record ID" := RecRef.RecordId;
                                "Document Type" := "Document Type"::"Prepayment Invoice";
                                "Document No." := SalesInvoiceHeader."No.";
                                "External Document No." := SalesInvoiceHeader."External Document No.";
                                "Sell-to/Buy-from No." := SalesInvoiceHeader."Sell-to Customer No.";
                                "Bill-to/Pay-to No." := SalesInvoiceHeader."Bill-to Customer No.";
                                "Sell-to/Buy-from Name" := SalesInvoiceHeader."Sell-to Customer Name";
                                "Sell-to/Buy-from Name 2" := SalesInvoiceHeader."Sell-to Customer Name 2";
                                "Bill-to/Pay-to Name" := SalesInvoiceHeader."Bill-to Name";
                                "Bill-to/Pay-to Name 2" := SalesInvoiceHeader."Bill-to Name 2";
                                "Posting Date" := SalesInvoiceHeader."Posting Date";
                                "Document Date" := SalesInvoiceHeader."Document Date";
                                "Currency Code" := SalesInvoiceHeader."Currency Code";
                                Amount := SalesInvoiceHeader.Amount;
                                "Amount Including VAT" := SalesInvoiceHeader."Amount Including VAT";
                                Insert();
                            until SalesInvoiceHeader.Next() = 0;

                        SalesCrMemoHeader.SetCurrentKey("Prepayment Order No.");
                        SalesCrMemoHeader.SetRange("Prepayment Order No.", SalesHeader."No.");
                        SalesCrMemoHeader.SetRange("Prepayment Credit Memo", true);
                        SalesCrMemoHeader.SetAutoCalcFields(Amount, "Amount Including VAT");
                        if SalesCrMemoHeader.FindSet() then
                            repeat
                                Init();
                                "Source Record ID" := RecRef.RecordId;
                                "Document Type" := "Document Type"::"Prepayment Credit Memo";
                                "Document No." := SalesCrMemoHeader."No.";
                                "External Document No." := SalesCrMemoHeader."External Document No.";
                                "Sell-to/Buy-from No." := SalesCrMemoHeader."Sell-to Customer No.";
                                "Bill-to/Pay-to No." := SalesCrMemoHeader."Bill-to Customer No.";
                                "Sell-to/Buy-from Name" := SalesCrMemoHeader."Sell-to Customer Name";
                                "Sell-to/Buy-from Name 2" := SalesCrMemoHeader."Sell-to Customer Name 2";
                                "Bill-to/Pay-to Name" := SalesCrMemoHeader."Bill-to Name";
                                "Bill-to/Pay-to Name 2" := SalesCrMemoHeader."Bill-to Name 2";
                                "Posting Date" := SalesCrMemoHeader."Posting Date";
                                "Document Date" := SalesCrMemoHeader."Document Date";
                                "Currency Code" := SalesCrMemoHeader."Currency Code";
                                Amount := -SalesCrMemoHeader.Amount;
                                "Amount Including VAT" := -SalesCrMemoHeader."Amount Including VAT";
                                Insert();
                            until SalesCrMemoHeader.Next() = 0;
                    end;
                    if PrepaymentOnly then
                        exit;
                    /*-=Add other posted document handling here=*/
                end;

            else
                exit;
        end;

    end;

    procedure Navigate()
    var
        NavigatePage: Page Navigate;
    begin
        NavigatePage.SetDoc("Posting Date", "Document No.");
        NavigatePage.Run();
    end;

    procedure ShowPostedDocumentList(SourceRecID: RecordID)
    begin
        SetRange("Source Record ID", SourceRecID);
        PAGE.Run(PAGE::"NPR Posted Documents", Rec);
    end;

    procedure TotalAmt(SourceRecID: RecordID): Decimal
    begin
        SetRange("Source Record ID", SourceRecID);
        CalcSums(Amount);
        exit(Amount);
    end;

    procedure TotalAmtInclVAT(SourceRecID: RecordID): Decimal
    begin
        SetRange("Source Record ID", SourceRecID);
        CalcSums("Amount Including VAT");
        exit("Amount Including VAT");
    end;

    procedure ShowDocumentCard()
    var
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        RecID: RecordID;
    begin
        TestField("Document No.");
        RecID := "Source Record ID";
        case RecID.TableNo of
            DATABASE::"Sales Header":
                case "Document Type" of
                    "Document Type"::"Prepayment Invoice":
                        begin
                            SalesInvoiceHeader.Get("Document No.");
                            PAGE.Run(PAGE::"Posted Sales Invoice", SalesInvoiceHeader);
                        end;
                    "Document Type"::"Prepayment Credit Memo":
                        begin
                            SalesCrMemoHeader.Get("Document No.");
                            PAGE.Run(PAGE::"Posted Sales Credit Memo", SalesCrMemoHeader);
                        end;
                end;
        end;
    end;
}

