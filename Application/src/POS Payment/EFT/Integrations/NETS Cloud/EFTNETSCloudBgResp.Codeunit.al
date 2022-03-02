#if not CLOUD
codeunit 6184537 "NPR EFT NETSCloud Bg. Resp."
{
    Access = Internal;
    // NPR5.54/JAKUBV/20200408  CASE 364340 Transport NPR5.54 - 8 April 2020

    TableNo = "NPR EFT Transaction Request";

    trigger OnRun()
    var
        EFTNETSCloudProtocol: Codeunit "NPR EFT NETSCloud Protocol";
        EFTTrxBackgroundSessionMgt: Codeunit "NPR EFT Trx Bgd. Session Mgt";
        EFTTransactionAsyncResponse: Record "NPR EFT Trx Async Resp.";
    begin
        case RunMode of
            RunMode::FIND_RESPONSE:
                EFTTrxBackgroundSessionMgt.TryGetResponseRecord(Rec."Entry No.", EFTTransactionAsyncResponse);
            RunMode::PROCESS_RESPONSE:
                EFTNETSCloudProtocol.ProcessAsyncResponse(Rec."Entry No.");
        end;
    end;

    var
        RunMode: Option FIND_RESPONSE,PROCESS_RESPONSE;

    procedure SetRunMode(ModeIn: Option FIND_RESPONSE,PROCESS_RESPONSE)
    begin
        RunMode := ModeIn;
    end;
}
#endif
