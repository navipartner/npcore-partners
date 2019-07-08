codeunit 6184522 "EFT Adyen Cloud Backgnd. Resp."
{
    // NPR5.49/MMV /20190409 CASE 351678 Created object

    TableNo = "EFT Transaction Request";

    trigger OnRun()
    var
        EFTAdyenCloudProtocol: Codeunit "EFT Adyen Cloud Protocol";
    begin
        EFTAdyenCloudProtocol.ProcessAsyncResponse(Rec."Entry No.");
    end;
}

