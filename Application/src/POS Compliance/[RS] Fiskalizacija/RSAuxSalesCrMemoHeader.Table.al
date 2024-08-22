table 6059827 "NPR RS Aux Sales CrMemo Header"
{
    Access = Internal;
    Caption = 'RS Aux Sales Credit Memo Header';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Sales Cr.Memo Header No."; Code[20])
        {
            Caption = 'Sales Cr. Memo Header SystemId';
            DataClassification = CustomerContent;
            TableRelation = "Sales Cr.Memo Header".SystemId;
        }
        field(10; "NPR RS POS Unit"; Code[10])
        {
            Caption = 'RS POS Unit';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Unit";
        }
        field(15; "NPR RS Customer Ident."; Text[20])
        {
            Caption = 'RS Customer Identification';
            DataClassification = CustomerContent;
        }
        field(20; "NPR RS Add. Cust. Ident."; Code[10])
        {
            Caption = 'RS Additional Cust. Identification';
            DataClassification = CustomerContent;
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
        }
        field(45; "NPR RS Add. Cust. Ident. Type"; Enum "NPR RS Optional Cust. Ident.")
        {
            Caption = 'RS Additional Cust. Identification Type';
            DataClassification = CustomerContent;
        }
        field(60; "NPR RS Referent No."; Code[100])
        {
            Caption = 'RS Referent No.';
            DataClassification = CustomerContent;
        }
        field(65; "NPR RS Referent Date/Time"; DateTime)
        {
            Caption = 'RS Referent Date/Time';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Sales Cr.Memo Header No.")
        {
            Clustered = true;
        }
    }

    internal procedure ReadRSAuxSalesCrMemoHeaderFields(SalesCrMemoHeader: Record "Sales Cr.Memo Header")
    var
        RSAuditMgt: Codeunit "NPR RS Audit Mgt.";
    begin
        if not RSAuditMgt.IsRSFiscalActive() then
            exit;
        if not Rec.Get(SalesCrMemoHeader."No.") then begin
            Rec.Init();
            Rec."Sales Cr.Memo Header No." := SalesCrMemoHeader."No.";
        end;
    end;

    internal procedure SaveRSAuxSalesCrMemoHeaderFields()
    begin
        if not Insert() then
            Modify();
    end;
}