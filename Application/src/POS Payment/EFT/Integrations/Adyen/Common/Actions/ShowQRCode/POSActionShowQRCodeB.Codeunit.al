codeunit 6151114 "NPR POS Action Show QRCode B"
{
    Access = Internal;

    internal procedure RequestShowQRCode(SalePOS: Record "NPR POS Sale"; var EFTTransactionRequest: Record "NPR EFT Transaction Request"; var QRCodeSetupCode: Code[20]; var TimeoutIntervalSec: Integer): Boolean
    var
        QRCodeSetupHeader: Record "NPR QR Code Setup Header";
        QRCodeSetupLine: Record "NPR QR Code Setup Line";
    begin
        if not GetQRCodeSetup(SalePOS."Register No.", QRCodeSetupHeader, QRCodeSetupLine, TimeoutIntervalSec) then
            exit;

        QRCodeSetupCode := QRCodeSetupHeader.Code;
        CreateAuxRequest(EFTTransactionRequest, Enum::"NPR EFT Adyen Aux Operation"::SHOW_QRCODE.AsInteger(), QRCodeSetupLine."POS Unit No.", SalePOS."Sales Ticket No.", '', QRCodeSetupHeader, QRCodeSetupLine);
        EFTTransactionRequest.Insert();
        EFTTransactionRequest."Reference Number Input" := Format(EFTTransactionRequest."Entry No.");
        EFTTransactionRequest.Modify();
        Commit();

        exit(true);
    end;

    local procedure CreateAuxRequest(var EFTTransactionRequest: Record "NPR EFT Transaction Request"; AuxFunction: Integer; POSUnitNo: Code[10]; SalesReceiptNo: Code[20]; POSPaymentMethod: Text; QRCodeSetupHeader: Record "NPR QR Code Setup Header"; QRCodeSetupLine: Record "NPR QR Code Setup Line")
    var
        EFTInterface: Codeunit "NPR EFT Interface";
        TempEFTAuxOperation: Record "NPR EFT Aux Operation" temporary;
    begin
        InitGenericRequest(EFTTransactionRequest, POSUnitNo, SalesReceiptNo, POSPaymentMethod, QRCodeSetupHeader, QRCodeSetupLine);

        EFTInterface.OnDiscoverAuxiliaryOperations(TempEFTAuxOperation);
        TempEFTAuxOperation.SetRange("Auxiliary ID", AuxFunction);
        TempEFTAuxOperation.FindFirst();

        EFTTransactionRequest."Processing Type" := EFTTransactionRequest."Processing Type"::AUXILIARY;
        EFTTransactionRequest."Auxiliary Operation ID" := AuxFunction;
        EFTTransactionRequest."Auxiliary Operation Desc." := TempEFTAuxOperation.Description;
    end;

    local procedure InitGenericRequest(var EFTTransactionRequest: Record "NPR EFT Transaction Request"; POSUnitNo: Code[10]; SalesReceiptNo: Code[20]; POSPaymentMethodCode: Text; QRCodeSetupHeader: Record "NPR QR Code Setup Header"; QRCodeSetupLine: Record "NPR QR Code Setup Line")
    var
        SalePOS: Record "NPR POS Sale";
        POSUnit: Record "NPR POS Unit";
    begin
        EFTTransactionRequest.Init();
        EFTTransactionRequest."Integration Version Code" := '3.0'; //Adyen Terminal API Protocol v3.0
        EFTTransactionRequest."POS Payment Type Code" := CopyStr(POSPaymentMethodCode, 1, MaxStrLen(EFTTransactionRequest."POS Payment Type Code"));
        EFTTransactionRequest."Original POS Payment Type Code" := CopyStr(POSPaymentMethodCode, 1, MaxStrLen(EFTTransactionRequest."Original POS Payment Type Code"));
        EFTTransactionRequest."Register No." := POSUnitNo;
        EFTTransactionRequest."Sales Ticket No." := SalesReceiptNo;
        EFTTransactionRequest."User ID" := CopyStr(UserId, 1, MaxStrLen(EFTTransactionRequest."User ID"));
        EFTTransactionRequest.Started := CurrentDateTime;
        EFTTransactionRequest.Token := CreateGuid();
        if POSUnitNo <> '' then begin
            POSUnit.SetLoadFields("POS Type");
            POSUnit.Get(POSUnitNo);
            EFTTransactionRequest."Self Service" := POSUnit."POS Type" = POSUnit."POS Type"::UNATTENDED;
        end;

        if (POSUnitNo <> '') and (SalesReceiptNo <> '') then begin
            SalePOS.Get(POSUnitNo, SalesReceiptNo);
            EFTTransactionRequest."Sales ID" := SalePOS.SystemId;
        end;

        EFTTransactionRequest."Hardware ID" := QRCodeSetupLine."Terminal ID";
        case QRCodeSetupHeader.Environment of
            QRCodeSetupHeader.Environment::Live:
                EFTTransactionRequest.Mode := EFTTransactionRequest.Mode::Production;
            QRCodeSetupHeader.Environment::Test:
                EFTTransactionRequest.Mode := EFTTransactionRequest.Mode::"TEST Remote";
        end;
    end;

    local procedure GetQRCodeSetup(POSUnitNo: Code[10]; var QRCodeSetupHeader: Record "NPR QR Code Setup Header"; var QRCodeSetupLine: Record "NPR QR Code Setup Line"; var TimeoutIntervalSec: Integer): Boolean
    var
        POSUnit: Record "NPR POS Unit";
        POSReceiptProfile: Record "NPR POS Receipt Profile";
    begin
        POSUnit.SetLoadFields("POS Receipt Profile");
        if not POSUnit.Get(POSUnitNo) then
            exit(false);
        POSReceiptProfile.SetLoadFields("QR Code Setup Code", "QRCode Time Interval Enabled", "QRCode Timeout Interval(sec.)");
        if not POSReceiptProfile.Get(POSUnit."POS Receipt Profile") then
            exit(false);
        if not QRCodeSetupHeader.Get(POSReceiptProfile."QR Code Setup Code") then
            exit(false);

        if POSReceiptProfile."QRCode Time Interval Enabled" and (POSReceiptProfile."QRCode Timeout Interval(sec.)" > 0) then
            TimeoutIntervalSec := POSReceiptProfile."QRCode Timeout Interval(sec.)";

        QRCodeSetupLine.SetRange("QR Code Setup Header Code", QRCodeSetupHeader.Code);
        QRCodeSetupLine.SetRange("POS Unit No.", POSUnitNo);
        exit(QRCodeSetupLine.FindFirst());
    end;
}
