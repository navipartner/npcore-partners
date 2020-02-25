codeunit 6184522 "EFT Adyen Backgnd. Response"
{
    // NPR5.49/MMV /20190409 CASE 351678 Created object
    // NPR5.53/MMV /20191211 CASE 377533 Renamed

    TableNo = "EFT Transaction Request";

    trigger OnRun()
    var
        EFTAdyenCloudProtocol: Codeunit "EFT Adyen Cloud Protocol";
    begin
        EFTAdyenCloudProtocol.ProcessAsyncResponse(Rec."Entry No.");
    end;
}

