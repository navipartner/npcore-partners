table 6150687 "NPR SI Aux Salesperson/Purch."
{
    Access = Internal;
    Caption = 'SI Aux Salesperson/Purchaser';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Salesperson/Purchaser SystemId"; Guid)
        {
            Caption = 'Salesperson/Purchaser SystemId';
            DataClassification = CustomerContent;
            TableRelation = "Salesperson/Purchaser".SystemId;
        }
        field(2; "NPR SI Salesperson Tax Number"; Integer)
        {
            Caption = 'Salesperson Tax Number';
            DataClassification = CustomerContent;
            trigger OnValidate()
            begin
                CheckTaxNumberValidity();
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

    internal procedure ReadSIAuxSalespersonFields(SalespersonPurchaser: Record "Salesperson/Purchaser")
    var
        SIAuditMgt: Codeunit "NPR SI Audit Mgt.";
    begin
        if not SIAuditMgt.IsSIFiscalActive() then
            exit;
        if not Rec.Get(SalespersonPurchaser.SystemId) then begin
            Rec.Init();
            Rec."Salesperson/Purchaser SystemId" := SalespersonPurchaser.SystemId;
        end;
    end;

    internal procedure SaveSIAuxSalespersonFields()
    begin
        if not Insert() then
            Modify();
    end;

    local procedure CheckTaxNumberValidity()
    var
        SalespersonTaxNumberLengthErr: Label 'Salesperson Tax Number must consist of 8 digits!';
    begin
        if (StrLen(Format("NPR SI Salesperson Tax Number")) <> 8) and not ("NPR SI Salesperson Tax Number" = 0) then
            Error(SalespersonTaxNumberLengthErr);
    end;
}