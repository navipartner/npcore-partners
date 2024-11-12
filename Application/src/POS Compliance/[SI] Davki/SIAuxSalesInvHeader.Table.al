table 6150953 "NPR SI Aux Sales Inv. Header"
{
    Access = Internal;
    DataClassification = CustomerContent;
    Caption = 'SI Aux Sales Invoice Header';

    fields
    {
        field(1; "Sales Invoice Header SystemId"; Guid)
        {
            Caption = 'Sales Invoice Header SystemId';
            DataClassification = CustomerContent;
            TableRelation = "Sales Invoice Header"."SystemId";
        }
        field(2; "NPR SI POS Unit"; Code[10])
        {
            Caption = 'SI POS Unit';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Unit";
        }
        field(3; "NPR SI Document Fiscalized"; Boolean)
        {
            Caption = 'SI Document Fiscalized';
            DataClassification = CustomerContent;
        }
        field(4; "NPR SI Audit Entry No."; Integer)
        {
            Caption = 'SI Audit Entry No.';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Sales Invoice Header SystemId")
        {
            Clustered = true;
        }
    }

    internal procedure ReadSIAuxSalesInvHeaderFields(SalesInvoiceHeader: Record "Sales Invoice Header")
    var
        SIAuditMgt: Codeunit "NPR SI Audit Mgt.";
    begin
        if not SIAuditMgt.IsSIFiscalActive() then
            exit;
        if not Rec.Get(SalesInvoiceHeader.SystemId) then begin
            Rec.Init();
            Rec."Sales Invoice Header SystemId" := SalesInvoiceHeader.SystemId;
        end;
    end;

    internal procedure SaveSIAuxSalesInvHeaderFields()
    begin
        if not Insert() then
            Modify();
    end;
}