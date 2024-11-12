table 6150696 "NPR CRO Aux Sales Inv. Header"
{
    Access = Internal;
    Caption = 'CRO Aux Sales Invoice Header';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Sales Inv. Header SystemId"; Guid)
        {
            Caption = 'Sales Header SystemId';
            DataClassification = CustomerContent;
            TableRelation = "Sales Invoice Header".SystemId;
        }
        field(2; "NPR CRO POS Unit"; Code[10])
        {
            Caption = 'CRO POS Unit';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Unit";
        }
        field(3; "NPR CRO Document Fiscalized"; Boolean)
        {
            Caption = 'CRO Document Fiscalized';
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
        key(PK; "Sales Inv. Header SystemId")
        {
            Clustered = true;
        }
    }

    internal procedure ReadCROAuxSalesInvHeaderFields(SalesInvHeader: Record "Sales Invoice Header")
    var
        CROAuditMgt: Codeunit "NPR CRO Audit Mgt.";
    begin
        if not CROAuditMgt.IsCROFiscalActive() then
            exit;
        if not Rec.Get(SalesInvHeader.SystemId) then begin
            Rec.Init();
            Rec."Sales Inv. Header SystemId" := SalesInvHeader.SystemId;
        end;
    end;

    internal procedure SaveCROAuxSalesInvHeaderFields()
    begin
        if not Insert() then
            Modify();
    end;
}