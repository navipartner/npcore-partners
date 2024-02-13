page 6151348 "NPR CRO Salesperson Step"
{
    Extensible = False;
    Caption = 'CRO Salesperson Setup';
    PageType = ListPart;
    SourceTable = "Salesperson/Purchaser";
    SourceTableTemporary = true;
    UsageCategory = None;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Code"; Rec.Code)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the code of the record.';
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the name of the Salesperson.';
                }
                field("NPR CRO OIB Code"; CROAuxSalespersonPurchaser."NPR CRO Salesperson OIB")
                {
                    ApplicationArea = NPRCROFiscal;
                    ToolTip = 'Specifies OIB of the Salesperson.';
                    Caption = 'Salesperson OIB';
                    trigger OnValidate()
                    begin
                        CROAuxSalespersonPurchaser.Validate("NPR CRO Salesperson OIB");
                        CROAuxSalespersonPurchaser.SaveCROAuxSalespersonFields();
                    end;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        if SalespersonPurchaser.Get(Rec.Code) then
            CROAuxSalespersonPurchaser.ReadCROAuxSalespersonFields(SalespersonPurchaser);
    end;

    internal procedure CopyRealToTemp()
    begin
        if not SalespersonPurchaser.FindSet() then
            exit;
        repeat
            Rec.TransferFields(SalespersonPurchaser);
            if not Rec.Insert() then
                Rec.Modify();
            CROAuxSalespersonPurchaser.ReadCROAuxSalespersonFields(SalespersonPurchaser);
        until SalespersonPurchaser.Next() = 0;
    end;

    internal procedure CROSalespersonPurchDataToCreate(): Boolean
    begin
        exit(CheckIsDataSet());
    end;

    internal procedure CreateSalespersonPurchData()
    begin
        if not Rec.FindSet() then
            exit;
        repeat
            if not SalespersonPurchaser.Get(Rec.Code) then
                SalespersonPurchaser.Init();
            SalespersonPurchaser.TransferFields(Rec);
            if not SalespersonPurchaser.Insert() then
                SalespersonPurchaser.Modify();
        until Rec.Next() = 0;
    end;

    local procedure CheckIsDataSet(): Boolean
    begin
        if not Rec.FindSet() then
            exit;
        repeat
            if SalespersonPurchaser.Get(Rec.Code) then begin
                CROAuxSalespersonPurchaser.ReadCROAuxSalespersonFields(SalespersonPurchaser);
                if CROAuxSalespersonPurchaser."NPR CRO Salesperson OIB" <> 0 then
                    exit(true);
            end;
        until Rec.Next() = 0;
        exit(true);
    end;

    var
        CROAuxSalespersonPurchaser: Record "NPR CRO Aux Salesperson/Purch.";
        SalespersonPurchaser: Record "Salesperson/Purchaser";
}