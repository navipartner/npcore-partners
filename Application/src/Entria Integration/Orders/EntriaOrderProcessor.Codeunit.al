#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 6248584 "NPR Entria Order Processor"
{
    Access = Internal;
    TableNo = "NPR Ecom Sales Header";

    trigger OnRun()
    var
        EntriaOrderImpl: Codeunit "NPR Entria Order Impl.";
    begin
        EntriaOrderImpl.ImportOrder(_OrderTkn, _EntriaStore, _DocumentNo, Rec);
    end;

    internal procedure SetParams(OrderTkn: JsonToken; EntriaStore: Record "NPR Entria Store"; DocumentNo: Code[20])
    begin
        _OrderTkn := OrderTkn;
        _EntriaStore := EntriaStore;
        _DocumentNo := DocumentNo;
    end;

    var
        _OrderTkn: JsonToken;
        _EntriaStore: Record "NPR Entria Store";
        _DocumentNo: Code[20];
}
#endif
