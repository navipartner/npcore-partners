codeunit 6060072 "NPR POS Action: Run Object-B"
{
    Access = Internal;

    procedure RunObject(MenuFilterCode: Code[20]; POSSession: Codeunit "NPR POS Session")
    var
        POSMenuFilter: Record "NPR POS Menu Filter";
    begin
        POSMenuFilter.SetFilter("Filter Code", '=%1', MenuFilterCode);
        POSMenuFilter.FindFirst();
        POSMenuFilter.RunObjectWithFilter(POSMenuFilter, POSSession);
    end;
}
