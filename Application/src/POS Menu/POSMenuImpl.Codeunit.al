codeunit 6059848 "NPR POS Menu Impl."
{
    Access = Internal;
    ObsoleteState = Pending;
    ObsoleteTag = 'NPR27.0';
    ObsoleteReason = 'Replaced with data source extension field setup functionality.';

    [Obsolete('The function was a major hack abusing button parameters. It didn’t work in some cases, and it won’t work with the new POS layouts replacing legacy POS menus. Use data source extension field setup functionality. instead.', 'NPR27.0')]
    internal procedure GetPOSMenuButtonLocationFilter(POSSession: Codeunit "NPR POS Session"; ActionCode: Code[20]): Text
    var
        POSStore: Record "NPR POS Store";
        POSMenuButton: Record "NPR POS Menu Button";
        POSParameterValue: Record "NPR POS Parameter Value";
        SalePOS: Record "NPR POS Sale";
        POSSale: Codeunit "NPR POS Sale";
        POSSetup: Codeunit "NPR POS Setup";
    begin
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        POSMenuButton.SetRange("Action Code", ActionCode);
        POSMenuButton.SetRange("Register No.", SalePOS."Register No.");
        if not POSMenuButton.FindFirst() then
            POSMenuButton.SetRange("Register No.");
        if not POSMenuButton.FindFirst() then
            exit('');

        if not POSParameterValue.Get(DATABASE::"NPR POS Menu Button", POSMenuButton."Menu Code", POSMenuButton.ID, POSMenuButton.RecordId, 'Location From') then
            if not POSParameterValue.Get(DATABASE::"NPR POS Menu Button", POSMenuButton."Menu Code", POSMenuButton.ID, POSMenuButton.RecordId, 'LocationFrom') then
                exit('');
        case POSParameterValue.Value of
            'POS Store':
                begin
                    if not POSStore.Get(SalePOS."POS Store Code") then begin
                        POSSession.GetSetup(POSSetup);
                        POSSetup.GetPOSStore(POSStore);
                    end;
                    exit(POSStore."Location Code");
                end;
            'Location Filter Parameter':
                begin
                    Clear(POSParameterValue);
                    if not POSParameterValue.Get(DATABASE::"NPR POS Menu Button", POSMenuButton."Menu Code", POSMenuButton.ID, POSMenuButton.RecordId, 'Location Filter') then
                        if not POSParameterValue.Get(DATABASE::"NPR POS Menu Button", POSMenuButton."Menu Code", POSMenuButton.ID, POSMenuButton.RecordId, 'LocationFilter') then;
                    exit(POSParameterValue.Value);
                end;
        end;

        exit('');
    end;
}