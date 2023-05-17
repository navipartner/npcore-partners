page 6014689 "NPR Salesperson/Purchaser Step"
{
    Extensible = False;
    Caption = 'Salespersons';
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
                field("Code"; Rec.Code)
                {

                    ToolTip = 'Specifies the code of the record.';
                    ApplicationArea = NPRRetail;
                }
                field("NPR Register Password"; Rec."NPR Register Password")
                {
                    ExtendedDatatype = Masked;
                    ToolTip = 'Enable defining a password for accessing a POS unit.';
                    ApplicationArea = NPRRetail;
                }
                field(Name; Rec.Name)
                {
                    ToolTip = 'Specifies the name of the record.';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    internal procedure CheckIfNoAvailableInSalespersonPurchaser(var SalespersonPurchaser: Record "NPR Salesperson Buffer"; var WantedStartingNo: Code[10]) CalculatedNo: Code[10]
    var
        HelperFunctions: Codeunit "NPR Wizard Helper Functions";
    begin
        if WantedStartingNo = '' then
            WantedStartingNo := '1';

        CalculatedNo := WantedStartingNo;

        if SalespersonPurchaser.Get(WantedStartingNo) then begin
            HelperFunctions.FormatCode(WantedStartingNo, true);
            CalculatedNo := CheckIfNoAvailableInSalespersonPurchaser(SalespersonPurchaser, WantedStartingNo);
        end;
    end;

    internal procedure SalespersonsToCreate(): Boolean
    begin
        exit(Rec.FindSet());
    end;

    internal procedure CopyRealToTemp()
    var
        Salesperson: Record "Salesperson/Purchaser";
    begin
        if Salesperson.FindSet() then
            repeat
                Rec.TransferFields(Salesperson);
                if not Rec.Insert() then
                    Rec.Modify();
            until Salesperson.Next() = 0;
    end;

    internal procedure CreateSalespersonData()
    var
        Salesperson: Record "Salesperson/Purchaser";
    begin
        if Rec.FindSet() then
            repeat
                Salesperson.TransferFields(Rec);
                if not Salesperson.Insert() then
                    Salesperson.Modify();
            until Rec.Next() = 0;
    end;
}
