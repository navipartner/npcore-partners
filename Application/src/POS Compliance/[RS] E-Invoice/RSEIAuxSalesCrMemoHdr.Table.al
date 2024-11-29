table 6150865 "NPR RSEI Aux Sales Cr.Memo Hdr"
{
    Access = Internal;
    Caption = 'RS EI Aux Sales Cr. Memo Header';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Sales Cr.Memo Header SystemId"; Guid)
        {
            Caption = 'Sales Cr.Memo Header SystemId';
            TableRelation = "Sales Cr.Memo Header".SystemId;
            DataClassification = CustomerContent;
        }
        field(2; "NPR RS EI Send To SEF"; Boolean)
        {
            Caption = 'RS EI Send to SEF';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(3; "NPR RS EI Send To CIR"; Boolean)
        {
            Caption = 'RS EI Send to CIR';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(4; "NPR RS E-Invoice Type Code"; Enum "NPR RS EI Invoice Type Code")
        {
            Caption = 'RS E-Inovice Type Code';
            DataClassification = CustomerContent;
        }
        field(5; "NPR RS EI Tax Liability Method"; Enum "NPR RS EI Tax Liability Method")
        {
            Caption = 'RS EI Tax Liability Code';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(6; "NPR RS EI Sales Invoice ID"; Integer)
        {
            Caption = 'RS EI Sales Invoice ID';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(7; "NPR RS EI Purchase Invoice ID"; Integer)
        {
            Caption = 'RS EI Purchase Invoice ID';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(8; "NPR RS EI Invoice Status"; Enum "NPR RS E-Invoice Status")
        {
            Caption = 'RS E-Invoice Status';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(9; "NPR RS EI Request ID"; Guid)
        {
            Caption = 'RS EI Request ID';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(10; "NPR RS EI Model"; Text[3])
        {
            Caption = 'RS EI Model';
            Editable = false;
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
        key(PK; "Sales Cr.Memo Header SystemId")
        {
            Clustered = true;
        }
    }

#if not (BC17 or BC18 or BC19 or BC20 or BC21)
    internal procedure ReadRSEIAuxSalesCrMemoHdrFields(SalesCrMemoHeader: Record "Sales Cr.Memo Header")
    var
        RSEInvoiceMgt: Codeunit "NPR RS E-Invoice Mgt.";
    begin
        if not RSEInvoiceMgt.IsRSEInvoiceEnabled() then
            exit;
        if not Rec.Get(SalesCrMemoHeader.SystemId) then begin
            Rec.Init();
            Rec."Sales Cr.Memo Header SystemId" := SalesCrMemoHeader.SystemId;
        end;
    end;

    internal procedure SaveRSEIAuxSalesCrMemoHdrFields()
    begin
        if not Insert() then
            Modify();
    end;

    internal procedure SetRSEIAuxSalesCrMemoHdrInvoiceStatus(DocumentNo: Code[20]; RSEInvoiceStatus: Enum "NPR RS E-Invoice Status")
    var
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
    begin
        if not SalesCrMemoHeader.Get(DocumentNo) then
            exit;
        ReadRSEIAuxSalesCrMemoHdrFields(SalesCrMemoHeader);
        "NPR RS EI Invoice Status" := RSEInvoiceStatus;
        SaveRSEIAuxSalesCrMemoHdrFields();
    end;

    internal procedure SetRSEIAuxSalesCrMemoHdrSendToSEF(SendToSEF: Boolean)
    begin
        "NPR RS EI Send To SEF" := SendToSEF;
        SaveRSEIAuxSalesCrMemoHdrFields();
    end;
#endif
}