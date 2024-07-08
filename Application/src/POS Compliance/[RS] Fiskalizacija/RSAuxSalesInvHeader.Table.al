table 6059826 "NPR RS Aux Sales Inv. Header"
{
    Access = Internal;
    Caption = 'RS Aux Sales Invoice Header';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Sales Invoice Header No."; Code[20])
        {
            Caption = 'Sales Invoice Header No.';
            DataClassification = CustomerContent;
            TableRelation = "Sales Invoice Header"."No.";
        }
        field(10; "NPR RS POS Unit"; Code[10])
        {
            Caption = 'RS POS Unit';
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = "NPR POS Unit";
        }
        field(15; "NPR RS Customer Ident."; Text[20])
        {
            Caption = 'RS Customer Identification';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(20; "NPR RS Add. Cust. Ident."; Code[10])
        {
            Caption = 'RS Additional Cust. Identification';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(25; "NPR RS Audit Entry"; Enum "NPR RS Fiscal Status")
        {
            Caption = 'RS Audit Entry';
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
            Editable = false;
        }
        field(45; "NPR RS Add. Cust. Ident. Type"; Enum "NPR RS Optional Cust. Ident.")
        {
            Caption = 'RS Additional Cust. Identification Type';
            DataClassification = CustomerContent;
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Sales Invoice Header No.")
        {
            Clustered = true;
        }
    }

    internal procedure ReadRSAuxSalesInvHeaderFields(SalesInvoiceHeader: Record "Sales Invoice Header")
    var
        RSAuditMgt: Codeunit "NPR RS Audit Mgt.";
    begin
        if not RSAuditMgt.IsRSFiscalActive() then
            exit;
        if not Rec.Get(SalesInvoiceHeader."No.") then begin
            Rec.Init();
            Rec."Sales Invoice Header No." := SalesInvoiceHeader."No.";
        end;
    end;

    internal procedure SaveRSAuxSalesInvHeaderFields()
    begin
        if not Insert() then
            Modify();
    end;
}