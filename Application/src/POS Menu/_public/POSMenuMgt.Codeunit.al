codeunit 6059842 "NPR POS Menu Mgt."
{
    Access = Public;
    ObsoleteState = Pending;
    ObsoleteTag = '2023-10-28';
    ObsoleteReason = 'Replaced with data source extension field setup functionality.';

    var
        POSMenuImpl: Codeunit "NPR POS Menu Impl.";

    [Obsolete('The function was a major hack abusing button parameters. It didn’t work in some cases, and it won’t work with the new POS layouts replacing legacy POS menus. Use GetPosSaleLocationFilter() instead, and subscribe to OnGetPosSaleLocationFilter() event, should you need an alternative processing.', '2023-09-28')]
    procedure GetPOSMenuButtonLocationFilter(POSSession: Codeunit "NPR POS Session"; ActionCode: Code[20]): Text
    begin
        exit(POSMenuImpl.GetPOSMenuButtonLocationFilter(POSSession, ActionCode));
    end;

    procedure GetPOSMenuButtonTableId(): Integer
    begin
        exit(Database::"NPR POS Menu Button");
    end;
}