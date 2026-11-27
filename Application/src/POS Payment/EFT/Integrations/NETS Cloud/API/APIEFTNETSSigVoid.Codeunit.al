#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
codeunit 6248753 "NPR API EFT NETS Sig. Void"
{
    Access = Internal;
    TableNo = "NPR EFT Transaction Request";

    trigger OnRun()
    var
        EFTSetup: Record "NPR EFT Setup";
        POSSale: Record "NPR POS Sale";
        VoidEFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTTransactionMgt: Codeunit "NPR EFT Transaction Mgt.";
        EFTFrameworkMgt: Codeunit "NPR EFT Framework Mgt.";
        IntegrationRequest: JsonObject;
        Mechanism: Enum "NPR EFT Request Mechanism";
        Workflow: Text;
    begin
        EFTSetup.FindSetup(Rec."Register No.", Rec."Original POS Payment Type Code");
        POSSale.Get(Rec."Register No.", Rec."Sales Ticket No.");

        Sleep(5 * 1000);

        VoidEFTTransactionRequest.Get(EFTTransactionMgt.PrepareVoid(EFTSetup, POSSale, Rec."Entry No.", false, IntegrationRequest, Mechanism, Workflow));
        EFTFrameworkMgt.SendSynchronousRequest(VoidEFTTransactionRequest);
    end;
}
#endif
