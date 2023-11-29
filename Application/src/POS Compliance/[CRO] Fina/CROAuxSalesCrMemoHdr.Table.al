table 6150697 "NPR CRO Aux Sales Cr. Memo Hdr"
{
    Access = Internal;
    Caption = 'CRO Aux Sales Cr. Memo Header';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Sales Cr.Memo Header SystemId"; Guid)
        {
            Caption = 'Sales Header SystemId';
            DataClassification = CustomerContent;
            TableRelation = "Sales Cr.Memo Header".SystemId;
        }
        field(2; "NPR CRO POS Unit"; Code[10])
        {
            Caption = 'POS Unit No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Unit";
        }
        field(3; "NPR CRO Document Fiscalized"; Boolean)
        {
            Caption = 'Document Fiscalized';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(4; "NPR CRO Audit Entry No."; Integer)
        {
            Caption = 'CRO Audit Entry No.';
            DataClassification = CustomerContent;
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Sales Cr.Memo Header SystemId")
        {
            Clustered = true;
        }
    }

    internal procedure ReadCROAuxSalesCrMemoHeaderFields(SalesCrMemHeader: Record "Sales Cr.Memo Header")
    var
        CROAuditMgt: Codeunit "NPR CRO Audit Mgt.";
    begin
        if not CROAuditMgt.IsCROFiscalActive() then
            exit;
        if not Rec.Get(SalesCrMemHeader.SystemId) then begin
            Rec.Init();
            Rec."Sales Cr.Memo Header SystemId" := SalesCrMemHeader.SystemId;
        end;
    end;

    internal procedure SaveCROAuxSalesCrMemoHeaderFields()
    begin
        if not Insert() then
            Modify();
    end;
}