codeunit 6248393 "NPR Consignor Ext. Mgt."
{
    Access = Public;

    procedure InsertFromSalesHeader(InCode: Code[20]; DocumentType: Enum "Sales Document Type")
    var
        ConsignorEntry: Record "NPR Consignor Entry";
    begin
        ConsignorEntry.InsertFromSalesHeader(InCode, DocumentType);
    end;

    [IntegrationEvent(false, false)]
    procedure OnBeforeInsertConsignorEntry(var SalesHeader: Record "Sales Header"; SalesShptHdrNo: Code[20]; RetRcpHdrNo: Code[20]; SalesInvHdrNo: Code[20]; SalesCrMemoHdrNo: Code[20]; var SkipInsertion: Boolean)
    begin
    end;
}