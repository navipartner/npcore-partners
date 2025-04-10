codeunit 6248393 "NPR Consignor Ext. Mgt."
{
    Access = Public;

    procedure InsertFromSalesHeader(InCode: Code[20]; DocumentType: Enum "Sales Document Type")
    var
        ConsignorEntry: Record "NPR Consignor Entry";
    begin
        ConsignorEntry.InsertFromSalesHeader(InCode, DocumentType);
    end;
}