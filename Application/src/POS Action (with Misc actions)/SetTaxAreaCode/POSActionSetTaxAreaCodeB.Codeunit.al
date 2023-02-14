codeunit 6150645 "NPR POSAction: SetTaxAreaCodeB"
{
    Access = Internal;

    procedure SetTaxAreaCode(var SalePOS: Record "NPR POS Sale")
    var
        TaxAreaValue: Code[20];
    begin
        TaxAreaValue := LookupTaxArea(true, true);

        SalePOS.Validate("Tax Area Code", TaxAreaValue);
        SalePOS.Modify(true);
    end;

    local procedure LookupTaxArea(Lookup: Boolean; ShowEmpty: Boolean): Code[20]
    var
        TaxAreaList: Page "Tax Area List";
        TaxArea: Record "Tax Area";
    begin
        if not ShowEmpty then begin
            TaxArea.SetFilter(Description, '<>%1', '');
            TaxAreaList.SetTableView(TaxArea);
        end;

        if Lookup then begin
            TaxAreaList.LookupMode(true);
            if TaxAreaList.RunModal() = ACTION::LookupOK then begin
                TaxAreaList.GetRecord(TaxArea);
                exit(TaxArea.Code);
            end;
        end else
            TaxAreaList.RunModal();
    end;
}

