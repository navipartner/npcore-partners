codeunit 6184522 "NPR EFT Adyen Backgnd. Resp."
{
    Access = Internal;
    // NPR5.49/MMV /20190409 CASE 351678 Created object
    // NPR5.53/MMV /20191211 CASE 377533 Renamed
    // NPR5.54/MMV /20200226 CASE 364340 Split into 2 steps.

    TableNo = "NPR EFT Transaction Request";

    trigger OnRun()
    var
        EFTAdyenCloudProtocol: Codeunit "NPR EFT Adyen Cloud Prot.";
        EFTTrxBackgroundSessionMgt: Codeunit "NPR EFT Trx Bgd. Session Mgt";
        EFTTransactionAsyncResponse: Record "NPR EFT Trx Async Resp.";
    begin
        //-NPR5.54 [364340]
        case RunMode of
            RunMode::FIND_RESPONSE:
                EFTTrxBackgroundSessionMgt.TryGetResponseRecord(Rec."Entry No.", EFTTransactionAsyncResponse);
            RunMode::PROCESS_RESPONSE:
                EFTAdyenCloudProtocol.ProcessAsyncResponse(Rec."Entry No.");
        end;
        //+NPR5.54 [364340]
    end;

    var
        RunMode: Option FIND_RESPONSE,PROCESS_RESPONSE;

    procedure SetRunMode(ModeIn: Option FIND_RESPONSE,PROCESS_RESPONSE)
    begin
        //-NPR5.54 [364340]
        RunMode := ModeIn;
        //+NPR5.54 [364340]
    end;
}

