table 6150863 "NPR RS EI Aux Purch. Inv. Hdr."
{
    Access = Internal;
    Caption = 'RS EI Aux Purchase Inv. Header';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Purch. Inv. Header SystemId"; Guid)
        {
            Caption = 'Purchase Invoice Header SystemId';
            TableRelation = "Purch. Inv. Header".SystemId;
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
        key(PK; "Purch. Inv. Header SystemId")
        {
            Clustered = true;
        }
    }

#if not (BC17 or BC18 or BC19 or BC20 or BC21)
    internal procedure ReadRSEIAuxPurchInvHdrFields(PurchInvHeader: Record "Purch. Inv. Header")
    var
        RSEInvoiceMgt: Codeunit "NPR RS E-Invoice Mgt.";
    begin
        if not RSEInvoiceMgt.IsRSEInvoiceEnabled() then
            exit;
        if not Rec.Get(PurchInvHeader.SystemId) then begin
            Rec.Init();
            Rec."Purch. Inv. Header SystemId" := PurchInvHeader.SystemId;
        end;
    end;

    internal procedure SaveRSEIAuxPurchInvHdrFields()
    begin
        if not Insert() then
            Modify();
    end;

    internal procedure SetRSEIAuxPurchInvHdrInvoiceStatus(DocumentNo: Code[20]; RSEInvoiceStatus: Enum "NPR RS E-Invoice Status")
    var
        PurchInvHdr: Record "Purch. Inv. Header";
    begin
        if not PurchInvHdr.Get(DocumentNo) then
            exit;
        ReadRSEIAuxPurchInvHdrFields(PurchInvHdr);
        "NPR RS EI Invoice Status" := RSEInvoiceStatus;
        SaveRSEIAuxPurchInvHdrFields();
    end;
#endif
}