table 6150695 "NPR CRO Aux Sales Header"
{
    Access = Internal;
    Caption = 'CRO Aux Sales Header';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Sales Header SystemId"; Guid)
        {
            Caption = 'Sales Header SystemId';
            DataClassification = CustomerContent;
            TableRelation = "Sales Header".SystemId;
        }
        field(2; "NPR CRO POS Unit"; Code[10])
        {
            Caption = 'CRO POS Unit';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Unit";
        }
    }

    keys
    {
        key(PK; "Sales Header SystemId")
        {
            Clustered = true;
        }
    }

    internal procedure ReadCROAuxSalesHeaderFields(SalesHeader: Record "Sales Header")
    var
        CROAuditMgt: Codeunit "NPR CRO Audit Mgt.";
    begin
        if not CROAuditMgt.IsCROFiscalActive() then
            exit;
        if not Rec.Get(SalesHeader.SystemId) then begin
            Rec.Init();
            Rec."Sales Header SystemId" := SalesHeader.SystemId;
        end;
    end;

    internal procedure SaveCROAuxSalesHeaderFields()
    begin
        if not Insert() then
            Modify();
    end;
}