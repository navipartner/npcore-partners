table 6150952 "NPR SI Aux Sales Header"
{
    Access = Internal;
    DataClassification = CustomerContent;
    Caption = 'SI Aux Sales Header';

    fields
    {
        field(1; "Sales Header SystemId"; Guid)
        {
            Caption = 'Sales Header SystemId';
            DataClassification = CustomerContent;
            TableRelation = "Sales Header".SystemId;
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
        field(5; "NPR SI Return Receipt No."; Code[20])
        {
            Caption = 'SI Return Receipt No.';
            DataClassification = CustomerContent;
        }
        field(6; "NPR SI Return Bus. Premise ID"; Code[20])
        {
            Caption = 'SI Return Business Premise ID';
            DataClassification = CustomerContent;
        }
        field(7; "NPR SI Return Cash Register ID"; Code[20])
        {
            Caption = 'SI Return Cash Register ID';
            DataClassification = CustomerContent;
        }
        field(8; "NPR SI Return Receipt DateTime"; DateTime)
        {
            Caption = 'SI Return Receipt Date/Time';
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

    internal procedure ReadSIAuxSalesHeaderFields(SalesHeader: Record "Sales Header")
    var
        SIAuditMgt: Codeunit "NPR SI Audit Mgt.";
    begin
        if not SIAuditMgt.IsSIFiscalActive() then
            exit;
        if not Rec.Get(SalesHeader.SystemId) then begin
            Rec.Init();
            Rec."Sales Header SystemId" := SalesHeader.SystemId;
        end;
    end;

    internal procedure SaveSIAuxSalesHeaderFields()
    begin
        if not Insert() then
            Modify();
    end;
}