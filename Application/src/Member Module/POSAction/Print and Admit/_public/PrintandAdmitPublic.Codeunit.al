codeunit 6150689 "NPR Print and Admit Public"
{
    procedure ResolveTicket(ReferenceNo: Text; var PrintandAdmitBuffer: Record "NPR Print and Admit Buffer" temporary)
    var
        POSActionPrintandAdmit: Codeunit "NPR POS Action Print and Admit";
    begin
        POSActionPrintandAdmit.ResolveTicket(ReferenceNo, PrintandAdmitBuffer);
    end;

    procedure ResolveMemberCard(ReferenceNo: Text; var PrintandAdmitBuffer: Record "NPR Print and Admit Buffer" temporary)
    var
        POSActionPrintandAdmit: Codeunit "NPR POS Action Print and Admit";
    begin
        POSActionPrintandAdmit.ResolveMemberCard(ReferenceNo, PrintandAdmitBuffer);
    end;

    procedure ResolveWallet(ReferenceNo: Text; var PrintandAdmitBuffer: Record "NPR Print and Admit Buffer" temporary)
    var
        POSActionPrintandAdmit: Codeunit "NPR POS Action Print and Admit";
    begin
        POSActionPrintandAdmit.ResolveWallet(ReferenceNo, PrintandAdmitBuffer);
    end;

    procedure ResolveTicketRequest(ReferenceNo: Text; var PrintandAdmitBuffer: Record "NPR Print and Admit Buffer" temporary)
    var
        POSActionPrintandAdmit: Codeunit "NPR POS Action Print and Admit";
    begin
        POSActionPrintandAdmit.ResolveTicketRequest(ReferenceNo, PrintandAdmitBuffer);
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnGetDataForReference(ReferenceNo: Text; var PrintandAdmitBuffer: Record "NPR Print and Admit Buffer" temporary)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeHandleBuffer(var PrintandAdmitBuffer: Record "NPR Print and Admit Buffer" temporary)
    begin
    end;
}
