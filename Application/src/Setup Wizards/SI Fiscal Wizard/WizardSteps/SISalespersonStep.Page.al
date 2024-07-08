page 6151612 "NPR SI Salesperson Step"
{
    Extensible = False;
    Caption = 'SI Salesperson Setup';
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
                    ApplicationArea = NPRSIFiscal;
                    ToolTip = 'Specifies the code of the record.';
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = NPRSIFiscal;
                    ToolTip = 'Specifies the name of the Salesperson.';
                }
                field("NPR SI Salesperson Tax Number"; SIAuxSalespersonPurchaser."NPR SI Salesperson Tax Number")
                {
                    ApplicationArea = NPRSIFiscal;
                    ToolTip = 'Specifies Tax Number of the Salesperson.';
                    Caption = 'Salesperson Tax Number';
                    trigger OnValidate()
                    begin
                        SIAuxSalespersonPurchaser.Validate("NPR SI Salesperson Tax Number");
                        SIAuxSalespersonPurchaser.SaveSIAuxSalespersonFields();
                    end;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        if SalespersonPurchaser.Get(Rec.Code) then
            SIAuxSalespersonPurchaser.ReadSIAuxSalespersonFields(SalespersonPurchaser);
    end;

    internal procedure CopyRealToTemp()
    begin
        if not SalespersonPurchaser.FindSet() then
            exit;
        repeat
            Rec.TransferFields(SalespersonPurchaser);
            if not Rec.Insert() then
                Rec.Modify();
            SIAuxSalespersonPurchaser.ReadSIAuxSalespersonFields(SalespersonPurchaser);
        until SalespersonPurchaser.Next() = 0;
    end;

    internal procedure SISalespersonPurchDataToCreate(): Boolean
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
                SIAuxSalespersonPurchaser.ReadSIAuxSalespersonFields(SalespersonPurchaser);
                if SIAuxSalespersonPurchaser."NPR SI Salesperson Tax Number" <> 0 then
                    exit(true);
            end;
        until Rec.Next() = 0;
        exit(true);
    end;

    var
        SIAuxSalespersonPurchaser: Record "NPR SI Aux Salesperson/Purch.";
        SalespersonPurchaser: Record "Salesperson/Purchaser";
}