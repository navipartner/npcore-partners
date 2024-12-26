table 6150833 "NPR RS EI Aux Sales Header"
{
    Access = Internal;
    Caption = 'RS EI Aux Sales Header';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Sales Header SystemId"; Guid)
        {
            Caption = 'Sales Header SystemId';
            TableRelation = "Sales Header".SystemId;
            DataClassification = CustomerContent;
        }
        field(2; "NPR RS EI Send To SEF"; Boolean)
        {
            Caption = 'RS EI Send to SEF';
            DataClassification = CustomerContent;
        }
        field(3; "NPR RS EI Send To CIR"; Boolean)
        {
            Caption = 'RS EI Send to CIR';
            DataClassification = CustomerContent;
        }
        field(4; "NPR RS E-Invoice Type Code"; Enum "NPR RS EI Invoice Type Code")
        {
            Caption = 'RS Inovice Type Code';
            DataClassification = CustomerContent;
        }
        field(5; "NPR RS EI Tax Liability Method"; Enum "NPR RS EI Tax Liability Method")
        {
            Caption = 'RS EI Tax Liability Code';
            DataClassification = CustomerContent;
        }
        field(6; "NPR RS EI Sales Invoice ID"; Integer)
        {
            Caption = 'RS EI Sales Invoice ID';
            DataClassification = CustomerContent;
        }
        field(7; "NPR RS EI Purchase Invoice ID"; Integer)
        {
            Caption = 'RS EI Purchase Invoice ID';
            DataClassification = CustomerContent;
        }
        field(8; "NPR RS EI Invoice Status"; Enum "NPR RS E-Invoice Status")
        {
            Caption = 'RS E-Invoice Status';
            DataClassification = CustomerContent;
        }
        field(9; "NPR RS EI Request ID"; Guid)
        {
            Caption = 'RS EI Request ID';
            DataClassification = CustomerContent;
        }
        field(10; "NPR RS EI Model"; Text[3])
        {
            Caption = 'RS EI Model';
            DataClassification = CustomerContent;
        }
        field(11; "NPR RS EI Reference Number"; Text[23])
        {
            Caption = 'RS EI Reference Number';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(12; "NPR RS EI Creation Date"; Date)
        {
            Caption = 'RS EI Creation Date';
            DataClassification = CustomerContent;
        }
        field(13; "NPR RS EI Sending Date"; Date)
        {
            Caption = 'RS EI Sending Date';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Sales Header SystemId")
        {
            Clustered = true;
        }
    }

#if not (BC17 or BC18 or BC19 or BC20 or BC21)
    internal procedure ReadRSEIAuxSalesHeaderFields(SalesHeader: Record "Sales Header")
    var
        RSEInvoiceMgt: Codeunit "NPR RS E-Invoice Mgt.";
    begin
        if not RSEInvoiceMgt.IsRSEInvoiceEnabled() then
            exit;
        if not Rec.Get(SalesHeader.SystemId) then begin
            Rec.Init();
            Rec."Sales Header SystemId" := SalesHeader.SystemId;
        end;
    end;

    internal procedure SaveRSEIAuxSalesHeaderFields()
    begin
        if not Insert() then
            Modify();
    end;

    internal procedure SetDefaultTaxLiabilityForSalesCrMemo(SalesHeader: Record "Sales Header")
    var
        RSEInvoiceMgt: Codeunit "NPR RS E-Invoice Mgt.";
    begin
        if not RSEInvoiceMgt.IsRSEInvoiceEnabled() then
            exit;
        if not (SalesHeader."Document Type" in [SalesHeader."Document Type"::"Credit Memo"]) then
            exit;
        Rec."NPR RS EI Tax Liability Method" := Rec."NPR RS EI Tax Liability Method"::" ";
        if not Insert() then
            Modify();
    end;

    internal procedure SetRSEIAuxSalesHeaderInvoiceStatus(DocumentType: Enum "NPR RS EI Document Type"; DocumentNo: Code[20]; RSEInvoiceStatus: Enum "NPR RS E-Invoice Status")
    var
        SalesHeader: Record "Sales Header";
    begin
        case DocumentType of
            DocumentType::"Sales Invoice":
                if not SalesHeader.Get(SalesHeader."Document Type"::Invoice, DocumentNo) then
                    exit;
            DocumentType::"Sales Cr. Memo":
                if not SalesHeader.Get(SalesHeader."Document Type"::"Credit Memo", DocumentNo) then
                    exit;
        end;
        ReadRSEIAuxSalesHeaderFields(SalesHeader);
        "NPR RS EI Invoice Status" := RSEInvoiceStatus;
        SaveRSEIAuxSalesHeaderFields();
    end;

#if BC24
    internal procedure SetReferenceNumberFromSalesHeader(SalesHeader: Record "Sales Header")
    var
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
        NoSeries: Codeunit "No. Series";
        RSEInvoiceMgt: Codeunit "NPR RS E-Invoice Mgt.";
    begin
        if not RSEInvoiceMgt.IsRSEInvoiceEnabled() then
            exit;

        ReadRSEIAuxSalesHeaderFields(SalesHeader);

        if not "NPR RS EI Send To SEF" then begin
            "NPR RS EI Reference Number" := '';
            SaveRSEIAuxSalesHeaderFields();
            exit;
        end;

        SalesReceivablesSetup.Get();

        case SalesHeader."Document Type" of
            SalesHeader."Document Type"::Order, SalesHeader."Document Type"::Invoice:
                "NPR RS EI Reference Number" := NoSeries.PeekNextNo(SalesReceivablesSetup."Posted Invoice Nos.");
            SalesHeader."Document Type"::"Credit Memo":
                "NPR RS EI Reference Number" := NoSeries.PeekNextNo(SalesReceivablesSetup."Posted Credit Memo Nos.");
        end;

        SaveRSEIAuxSalesHeaderFields();
    end;
#else
    internal procedure SetReferenceNumberFromSalesHeader(SalesHeader: Record "Sales Header")
    var
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        RSEInvoiceMgt: Codeunit "NPR RS E-Invoice Mgt.";
    begin
        if not RSEInvoiceMgt.IsRSEInvoiceEnabled() then
            exit;

        ReadRSEIAuxSalesHeaderFields(SalesHeader);

        if not "NPR RS EI Send To SEF" then begin
            "NPR RS EI Reference Number" := '';
            SaveRSEIAuxSalesHeaderFields();
            exit;
        end;

        SalesReceivablesSetup.Get();

        case SalesHeader."Document Type" of
            SalesHeader."Document Type"::Order, SalesHeader."Document Type"::Invoice:
                "NPR RS EI Reference Number" := NoSeriesMgt.GetNextNo(SalesReceivablesSetup."Posted Invoice Nos.", Today(), false);
            SalesHeader."Document Type"::"Credit Memo":
                "NPR RS EI Reference Number" := NoSeriesMgt.GetNextNo(SalesReceivablesSetup."Posted Credit Memo Nos.", Today(), false)
        end;

        SaveRSEIAuxSalesHeaderFields();
    end;
#endif
#endif
}