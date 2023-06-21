codeunit 6059842 "NPR POS Menu Mgt."
{
    Access = Public;

    var
        POSMenuImpl: Codeunit "NPR POS Menu Impl.";

    procedure GetPOSMenuButtonLocationFilter(POSSession: Codeunit "NPR POS Session"; ActionCode: Code[20]): Text
    begin
        exit(POSMenuImpl.GetPOSMenuButtonLocationFilter(POSSession, ActionCode));
    end;

    procedure GetPOSMenuButtonTableId(): Integer
    begin
        exit(Database::"NPR POS Menu Button");
    end;

}