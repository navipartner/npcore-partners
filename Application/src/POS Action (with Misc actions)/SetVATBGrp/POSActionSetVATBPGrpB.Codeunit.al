codeunit 6060104 "NPR POSAction: Set VAT BPGrp B"
{
    Access = Internal;
    procedure SetVATBusPostingGroup(POSSale: Codeunit "NPR POS Sale")
    var
        SalePOS: Record "NPR POS Sale";
        VATBusPostingGroupValue: Code[20];
    begin
        VATBusPostingGroupValue := GetVATPostingGroup();

        POSSale.GetCurrentSale(SalePOS);
        SalePOS.Validate("VAT Bus. Posting Group", VATBusPostingGroupValue);
        SalePOS.Modify(true);
    end;

    local procedure GetVATPostingGroup(): Code[20]
    var
        VATBusinessPostingGroups: Page "VAT Business Posting Groups";
        VATBusinessPostingGroup: Record "VAT Business Posting Group";
    begin
        VATBusinessPostingGroups.LookupMode(true);
        if VATBusinessPostingGroups.RunModal() = ACTION::LookupOK then begin
            VATBusinessPostingGroups.GetRecord(VATBusinessPostingGroup);
            exit(VATBusinessPostingGroup.Code);
        end;
    end;
}