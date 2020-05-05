codeunit 6184537 "EFT NETSCloud Bg. Resp."
{
    // NPR5.54/JAKUBV/20200408  CASE 364340 Transport NPR5.54 - 8 April 2020

    TableNo = "EFT Transaction Request";

    trigger OnRun()
    var
        EFTNETSCloudProtocol: Codeunit "EFT NETSCloud Protocol";
        EFTTrxBackgroundSessionMgt: Codeunit "EFT Trx Background Session Mgt";
        EFTTransactionAsyncResponse: Record "EFT Transaction Async Response";
    begin
        case RunMode of
          RunMode::FIND_RESPONSE : EFTTrxBackgroundSessionMgt.TryGetResponseRecord(Rec."Entry No.", EFTTransactionAsyncResponse);
          RunMode::PROCESS_RESPONSE : EFTNETSCloudProtocol.ProcessAsyncResponse(Rec."Entry No.");
        end;
    end;

    var
        RunMode: Option FIND_RESPONSE,PROCESS_RESPONSE;

    procedure SetRunMode(ModeIn: Option FIND_RESPONSE,PROCESS_RESPONSE)
    begin
        RunMode := ModeIn;
    end;
}

