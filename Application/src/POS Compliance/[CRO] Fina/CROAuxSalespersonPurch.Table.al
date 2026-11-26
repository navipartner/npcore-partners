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
        CROAuditMgt: Codeunit "NPR CRO Audit Mgt.";
        InvalidOIBErr: Label '%1 %2 is not a valid OIB. An OIB has 11 digits, and the last one must be its check digit.', Comment = '%1 = Salesperson OIB field caption, %2 = Salesperson OIB';
    begin
        if "NPR CRO Salesperson OIB" = 0 then
            exit;
        if not CROAuditMgt.IsValidOIB("NPR CRO Salesperson OIB") then
            Error(InvalidOIBErr, FieldCaption("NPR CRO Salesperson OIB"), CROAuditMgt.FormatOIB("NPR CRO Salesperson OIB"));
    end;
}