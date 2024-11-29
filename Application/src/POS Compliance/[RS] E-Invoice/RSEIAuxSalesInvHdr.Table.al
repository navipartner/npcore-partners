table 6150834 "NPR RS EI Aux Sales Inv. Hdr."
{
    Access = Internal;
    Caption = 'RS EI Aux Sales Invoice Header';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Sales Invoice SystemId"; Guid)
        {
            Caption = 'Sales Invoice SystemId';
            TableRelation = "Sales Invoice Header".SystemId;
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
        field(4; "NPR RS Invoice Type Code"; Enum "NPR RS EI Invoice Type Code")
        {
            Caption = 'RS Inovice Type Code';
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
        key(PK; "Sales Invoice SystemId")
        {
            Clustered = true;
        }
    }

#if not (BC17 or BC18 or BC19 or BC20 or BC21)
    internal procedure ReadRSEIAuxSalesInvHdrFields(SalesInvHdr: Record "Sales Invoice Header")
    var
        RSEInvoiceMgt: Codeunit "NPR RS E-Invoice Mgt.";
    begin
        if not RSEInvoiceMgt.IsRSEInvoiceEnabled() then
            exit;
        if not Rec.Get(SalesInvHdr.SystemId) then begin
            Rec.Init();
            Rec."Sales Invoice SystemId" := SalesInvHdr.SystemId;
        end;
    end;

    internal procedure SaveRSEIAuxSalesInvHdrFields()
    begin
        if not Insert() then
            Modify();
    end;

    internal procedure SetRSEIAuxSalesInvHdrInvoiceStatus(DocumentNo: Code[20]; RSEInvoiceStatus: Enum "NPR RS E-Invoice Status")
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
    begin
        if not SalesInvoiceHeader.Get(DocumentNo) then
            exit;
        ReadRSEIAuxSalesInvHdrFields(SalesInvoiceHeader);
        "NPR RS EI Invoice Status" := RSEInvoiceStatus;
        SaveRSEIAuxSalesInvHdrFields();
    end;

    internal procedure SetRSEIAuxSalesInvHdrSendToSEF(SendToSEF: Boolean)
    begin
        "NPR RS EI Send To SEF" := SendToSEF;
        SaveRSEIAuxSalesInvHdrFields();
    end;
#endif
}