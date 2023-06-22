codeunit 6151035 "NPR Item Mgt."
{
    var
        _ItemMgtImpl: Codeunit "NPR Item Mgt. Impl.";

    procedure CopyMagentoProductRelations(FromItemNo: Code[20]; ToItemNo: Code[20])
    begin
        _ItemMgtImpl.CopyMagentoProductRelations(FromItemNo, ToItemNo);
    end;
}