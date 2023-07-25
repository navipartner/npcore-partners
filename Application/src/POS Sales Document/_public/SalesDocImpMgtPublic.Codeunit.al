codeunit 6059986 "NPR Sales Doc. Imp. Mgt Public"
{
    var
        _SalesDocImpMgt: Codeunit "NPR Sales Doc. Imp. Mgt.";

    procedure SalesDocumentToPOS(var POSSession: Codeunit "NPR POS Session"; var SalesHeader: Record "Sales Header")
    begin
        _SalesDocImpMgt.SalesDocumentToPOS(POSSession, SalesHeader);
    end;

    procedure GetImportInvDiscAmtQst()
    begin
        _SalesDocImpMgt.GetImportInvDiscAmtQst();
    end;

    procedure GetTotalAmountToBeInvoiced(SalesHeader: Record "Sales Header")
    begin
        _SalesDocImpMgt.GetTotalAmountToBeInvoiced(SalesHeader);
    end;
}
