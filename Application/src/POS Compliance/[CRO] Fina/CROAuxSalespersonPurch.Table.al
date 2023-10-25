table 6060038 "NPR CRO Aux Salesperson/Purch."
{
    Access = Internal;
    Caption = 'CRO Aux Salesperson/Purchaser';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Salesperson/Purchaser SystemId"; Guid)
        {
            Caption = 'Salesperson/Purchaser SystemId';
            DataClassification = CustomerContent;
            TableRelation = "Salesperson/Purchaser".SystemId;
        }
        field(2; "NPR CRO Salesperson OIB"; BigInteger)
        {
            Caption = 'Salesperson OIB';
            DataClassification = CustomerContent;
            trigger OnValidate()
            begin
                CheckOIBValidity();
            end;
        }
    }

    keys
    {
        key(PK; "Salesperson/Purchaser SystemId")
        {
            Clustered = true;
        }
    }

    internal procedure ReadCROAuxSalespersonFields(SalespersonPurchaser: Record "Salesperson/Purchaser")
    var
        CROAuditMgt: Codeunit "NPR CRO Audit Mgt.";
    begin
        if not CROAuditMgt.IsCROFiscalActive() then
            exit;
        if not Rec.Get(SalespersonPurchaser.SystemId) then begin
            Rec.Init();
            Rec."Salesperson/Purchaser SystemId" := SalespersonPurchaser.SystemId;
        end;
    end;

    internal procedure SaveCROAuxSalespersonFields()
    begin
        if not Insert() then
            Modify();
    end;

    local procedure CheckOIBValidity()
    var
        SalespersonOIBLengthErr: Label 'Salesperson OIB must consist of 11 digits!';
    begin
        if (StrLen(Format("NPR CRO Salesperson OIB")) <> 11) and not ("NPR CRO Salesperson OIB" = 0) then
            Error(SalespersonOIBLengthErr);
    end;
}