codeunit 6184521 "EFT Adyen Cloud Backgnd. Req."
{
    // NPR5.48/MMV /20190124 CASE 341237 Created object
    // NPR5.49/MMV /20190219 CASE 345188 Added AcquireCard support
    // NPR5.49/MMV /20190409 CASE 351678 Renamed object
    // NPR5.50/MMV /20190515 CASE 355433 Added modify

    TableNo = "EFT Transaction Request";

    trigger OnRun()
    var
        EFTSetup: Record "EFT Setup";
        EFTTransactionAsyncResponse: Record "EFT Transaction Async Response";
        Success: Boolean;
        OutStream: OutStream;
        EFTAdyenCloudProtocol: Codeunit "EFT Adyen Cloud Protocol";
        Response: Text;
    begin
        ClearLastError;

        EFTSetup.FindSetup("Register No.", "Original POS Payment Type Code");

        case "Processing Type" of
          "Processing Type"::PAYMENT : Success := EFTAdyenCloudProtocol.InvokePayment(Rec, EFTSetup, Response);
          "Processing Type"::REFUND : Success := EFTAdyenCloudProtocol.InvokeRefund(Rec, EFTSetup, Response);
        //-NPR5.49 [345188]
          "Processing Type"::AUXILIARY :
            case "Auxiliary Operation ID" of
              2 : Success := EFTAdyenCloudProtocol.InvokeAcquireCard(Rec, EFTSetup, Response);
            end;
        //+NPR5.49 [345188]
        end;

        //-NPR5.50 [355433]
        if Rec.Modify then; //Incase invoke functions wrote logging blobs
        //+NPR5.50 [355433]

        EFTTransactionAsyncResponse.Init;
        EFTTransactionAsyncResponse."Request Entry No" := Rec."Entry No.";
        EFTTransactionAsyncResponse.Error := not Success;

        if Success then begin
          EFTTransactionAsyncResponse.Response.CreateOutStream(OutStream, TEXTENCODING::UTF8);
          OutStream.WriteText(Response);
        end else begin
          EFTTransactionAsyncResponse."Error Text" := CopyStr(GetLastErrorText, 1, MaxStrLen(EFTTransactionAsyncResponse."Error Text"));
        end;

        EFTTransactionAsyncResponse.Insert;
    end;
}

