table 6150862 "NPR RS EI Aux Purch. Header"
{
    Access = Internal;
    Caption = 'RS EI Aux Purchase Header';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Purchase Header SystemId"; Guid)
        {
            Caption = 'Purchase Header SystemId';
            TableRelation = "Purchase Header".SystemId;
            DataClassification = CustomerContent;
        }
        field(2; "NPR RS E-Invoice"; Boolean)
        {
            Caption = 'RS E-Invoice';
            DataClassification = CustomerContent;
        }
        field(3; "NPR RS E-Invoice Type Code"; Enum "NPR RS EI Invoice Type Code")
        {
            Caption = 'RS E-Inovice Type Code';
            DataClassification = CustomerContent;
        }
        field(4; "NPR RS EI Tax Liability Method"; Enum "NPR RS EI Tax Liability Method")
        {
            Caption = 'RS EI Tax Liability Method';
            DataClassification = CustomerContent;
        }
        field(5; "NPR RS EI Sales Invoice ID"; Integer)
        {
            Caption = 'RS EI Sales Invoice ID';
            TableRelation = "NPR RS E-Invoice Document"."Sales Invoice ID";
            DataClassification = CustomerContent;
        }
        field(6; "NPR RS EI Purchase Invoice ID"; Integer)
        {
            Caption = 'RS EI Purchase Invoice ID';
            TableRelation = "NPR RS E-Invoice Document"."Purchase Invoice ID";
            DataClassification = CustomerContent;
        }
        field(7; "NPR RS EI Invoice Status"; Enum "NPR RS E-Invoice Status")
        {
            Caption = 'RS E-Invoice Status';
            DataClassification = CustomerContent;
        }
        field(8; "NPR RS EI Model"; Text[3])
        {
            Caption = 'RS EI Model';
            DataClassification = CustomerContent;
        }
        field(9; "NPR RS EI Reference Number"; Text[23])
        {
            Caption = 'RS EI Reference Number';
            DataClassification = CustomerContent;
        }
        field(10; "NPR RS EI Total Amount"; Decimal)
        {
            Caption = 'RS EI Total Amount';
            DataClassification = CustomerContent;
        }
        field(11; "NPR RS EI Creation Date"; Date)
        {
            Caption = 'RS EI Creation Date';
            DataClassification = CustomerContent;
        }
        field(12; "NPR RS EI Sending Date"; Date)
        {
            Caption = 'RS EI Sending Date';
            DataClassification = CustomerContent;
        }
        field(13; "NPR RS EI Prepayment"; Boolean)
        {
            Caption = 'RS EI Prepayment';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Purchase Header SystemId")
        {
            Clustered = true;
        }
    }

#if not (BC17 or BC18 or BC19 or BC20 or BC21)
    internal procedure ReadRSEIAuxPurchHeaderFields(PurchaseHeader: Record "Purchase Header")
    var
        RSEInvoiceMgt: Codeunit "NPR RS E-Invoice Mgt.";
    begin
        if not RSEInvoiceMgt.IsRSEInvoiceEnabled() then
            exit;
        if not Rec.Get(PurchaseHeader.SystemId) then begin
            Rec.Init();
            Rec."Purchase Header SystemId" := PurchaseHeader.SystemId;
        end;
    end;

    internal procedure SaveRSEIAuxPurchaseHeaderFields()
    begin
        if not Insert() then
            Modify();
    end;

    internal procedure SetRSEIAuxPurchHeaderInvoiceStatus(DocumentType: Enum "NPR RS EI Document Type"; DocumentNo: Code[20]; RSEInvoiceStatus: Enum "NPR RS E-Invoice Status")
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        case DocumentType of
            DocumentType::"Purchase Order":
                if not PurchaseHeader.Get(PurchaseHeader."Document Type"::Order, DocumentNo) then
                    exit;
            DocumentType::"Purchase Invoice":
                if not PurchaseHeader.Get(PurchaseHeader."Document Type"::Invoice, DocumentNo) then
                    exit;
            DocumentType::"Purchase Cr. Memo":
                if not PurchaseHeader.Get(PurchaseHeader."Document Type"::"Credit Memo", DocumentNo) then
                    exit;
        end;
        ReadRSEIAuxPurchHeaderFields(PurchaseHeader);
        "NPR RS EI Invoice Status" := RSEInvoiceStatus;
        SaveRSEIAuxPurchaseHeaderFields();
    end;
#endif
}
