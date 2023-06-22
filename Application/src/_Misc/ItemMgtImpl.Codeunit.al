codeunit 6151036 "NPR Item Mgt. Impl."
{
    Access = Internal;

    #region Item Copy Managment

    procedure CopyMagentoProductRelations(FromItemNo: Code[20]; ToItemNo: Code[20])
    var
        MagentoProductRelation: Record "NPR Magento Product Relation";
        CopyItem: Codeunit "Copy Item";
    begin
        MagentoProductRelation.SetRange("From Item No.", FromItemNo);

        if MagentoProductRelation.IsEmpty() then
            exit;

        CopyItem.CopyItemRelatedTable(Database::"NPR Magento Product Relation", MagentoProductRelation.FieldNo("From Item No."), FromItemNo, ToItemNo);
    end;

    #endregion
}