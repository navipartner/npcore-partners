table 6059828 "NPR RS Aux Sales Header"
{
    Access = Internal;
    Caption = 'RS Aux Sales Header';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Sales Header SystemId"; Guid)
        {
            Caption = 'Sales Header SystemId';
            DataClassification = CustomerContent;
            TableRelation = "Sales Header".SystemId;
        }
        field(10; "NPR RS POS Unit"; Code[10])
        {
            Caption = 'RS POS Unit';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Unit";
            trigger OnValidate()
            begin
                TestStatusOpen();
            end;
        }
        field(15; "NPR RS Customer Ident."; Text[20])
        {
            Caption = 'RS Customer Identification';
            DataClassification = CustomerContent;
            trigger OnValidate()
            begin
                TestStatusOpen();
            end;
        }
        field(20; "NPR RS Add. Cust. Ident."; Code[10])
        {
            Caption = 'RS Additional Cust. Identification';
            DataClassification = CustomerContent;
            trigger OnValidate()
            begin
                TestStatusOpen();
            end;
        }
        field(25; "NPR RS Audit Entry"; Enum "NPR RS Fiscal Status")
        {
            Caption = 'RS Audit Entry';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(30; "NPR RS Refund Reference"; Code[20])
        {
            Caption = 'RS Refund Reference';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(35; "NPR RS Audit Entry No."; Integer)
        {
            Caption = 'RS Audit Entry No.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(40; "NPR RS Cust. Ident. Type"; Enum "NPR RS Customer Ident.")
        {
            Caption = 'RS Customer Identification Type';
            DataClassification = CustomerContent;
            trigger OnValidate()
            begin
                TestStatusOpen();
            end;
        }
        field(45; "NPR RS Add. Cust. Ident. Type"; Enum "NPR RS Optional Cust. Ident.")
        {
            Caption = 'RS Additional Cust. Identification Type';
            DataClassification = CustomerContent;
            trigger OnValidate()
            begin
                TestStatusOpen();
            end;
        }
        field(60; "NPR RS Referent No."; Code[100])
        {
            Caption = 'RS Referent No.';
            DataClassification = CustomerContent;
            trigger OnValidate()
            begin
                TestStatusOpen();
            end;
        }
        field(65; "NPR RS Referent Date/Time"; DateTime)
        {
            Caption = 'RS Referent Date/Time';
            DataClassification = CustomerContent;
            trigger OnValidate()
            begin
                TestStatusOpen();
            end;
        }
    }

    keys
    {
        key(PK; "Sales Header SystemId")
        {
            Clustered = true;
        }
    }

    internal procedure ReadRSAuxSalesHeaderFields(SalesHeader: Record "Sales Header")
    var
        RSAuditMgt: Codeunit "NPR RS Audit Mgt.";
    begin
        if not RSAuditMgt.IsRSFiscalActive() then
            exit;
        if not Rec.Get(SalesHeader.SystemId) then begin
            Rec.Init();
            Rec."Sales Header SystemId" := SalesHeader.SystemId;
        end;
    end;

    internal procedure SaveRSAuxSalesHeaderFields()
    begin
        if not Insert() then
            Modify();
    end;

    local procedure TestStatusOpen()
    var
        SalesHeader: Record "Sales Header";
    begin
        SalesHeader.GetBySystemId("Sales Header SystemId");
        SalesHeader.TestStatusOpen();
    end;
}