codeunit 6184873 "NPR DocLxCityCardWebServices"
{
    Access = Public;

    procedure ValidateCityCard(var DocLxCityCardXmlPort: XmlPort "NPR DocLxCityCardValidate")
    var
        TempCityCardRequest: Record "NPR DocLXCityCardHistory" temporary;
        TempCityCardResponse: Record "NPR DocLXCityCardHistory" temporary;
        CityCardLog: Record "NPR DocLXCityCardHistory";
        CityCard: Codeunit "NPR DocLXCityCard";
        LogEntryNo: Integer;
        Result: JsonObject;
        State: JsonToken;
    begin
        DocLxCityCardXmlPort.Import();

        DocLxCityCardXmlPort.GetCityCardRequest(TempCityCardRequest);
        TempCityCardRequest.Reset();
        if (TempCityCardRequest.FindSet()) then begin
            repeat
                if (TempCityCardRequest.CityCode = '') then
                    TempCityCardRequest.CityCode := CityCard.GetDefaultCityCode(TempCityCardRequest.LocationCode);

                Result := CityCard.ValidateCityCard(TempCityCardRequest.CardNumber, TempCityCardRequest.CityCode, TempCityCardRequest.LocationCode, TempCityCardRequest.POSUnitNo, LogEntryNo);
                if (CityCardLog.Get(LogEntryNo)) then begin
                    TempCityCardResponse.TransferFields(CityCardLog, true);

                end else begin
                    // Most likely it failed input validation
                    TempCityCardResponse.TransferFields(TempCityCardRequest, false);
                    TempCityCardResponse.EntryNo := Power(2, 31) - TempCityCardRequest.EntryNo;
                    TempCityCardResponse.RedemptionResultCode := '500';
                    TempCityCardResponse.RedemptionResultMessage := 'Internal Server Error';
                    if (Result.Get('state', State)) then begin
                        TempCityCardResponse.RedemptionResultCode := CopyStr(CityCard.Get(State.AsObject(), 'code').AsCode(), 1, MaxStrLen(TempCityCardResponse.RedemptionResultCode));
                        TempCityCardResponse.RedemptionResultMessage := CopyStr(CityCard.Get(State.AsObject(), 'message').AsText(), 1, MaxStrLen(TempCityCardResponse.RedemptionResultMessage));
                    end;
                end;

                TempCityCardResponse.Insert();

            until (TempCityCardRequest.Next() = 0);
        end;
        DocLxCityCardXmlPort.SetCityCardResponse(TempCityCardResponse);
        // Export is implicit since the XmlPort is passed by reference
    end;

    procedure RedeemCityCard(var DocLxCityCardXmlPort: XmlPort "NPR DocLxCityCardRedeem")
    var
        TempCityCardRequest: Record "NPR DocLXCityCardHistory" temporary;
        TempCityCardResponse: Record "NPR DocLXCityCardHistory" temporary;
        CityCardLog: Record "NPR DocLXCityCardHistory";
        CityCard: Codeunit "NPR DocLXCityCard";
        LogEntryNo: Integer;
        Result: JsonObject;
        State: JsonToken;
    begin
        DocLxCityCardXmlPort.Import();

        DocLxCityCardXmlPort.GetCityCardRequest(TempCityCardRequest);
        TempCityCardRequest.Reset();
        if (TempCityCardRequest.FindSet()) then begin
            repeat
                if (TempCityCardRequest.CityCode = '') then
                    TempCityCardRequest.CityCode := CityCard.GetDefaultCityCode(TempCityCardRequest.LocationCode);

                Result := CityCard.ValidateCityCard(TempCityCardRequest.CardNumber, TempCityCardRequest.CityCode, TempCityCardRequest.LocationCode, TempCityCardRequest.POSUnitNo, LogEntryNo);
                if (CityCardLog.Get(LogEntryNo)) then begin

                    case (CityCardLog.ValidationResultCode) of
                        '200':
                            begin
                                CityCard.RedeemCityCard(TempCityCardRequest.CardNumber, TempCityCardRequest.CityCode, TempCityCardRequest.LocationCode, LogEntryNo);
                                CityCard.AcquireCoupon(TempCityCardRequest.CardNumber, TempCityCardRequest.CityCode, TempCityCardRequest.LocationCode, TempCityCardRequest.SalesDocumentNo, LogEntryNo);
                                CityCardLog.Get(LogEntryNo);
                                TempCityCardResponse.TransferFields(CityCardLog, true);
                            end;
                        else begin
                            TempCityCardResponse.TransferFields(CityCardLog, true);
                            TempCityCardResponse.RedemptionResultCode := CityCardLog.ValidationResultCode;
                            TempCityCardResponse.RedemptionResultMessage := CityCardLog.ValidationResultMessage;
                        end;
                    end;

                end else begin
                    // Most likely it failed input validation
                    TempCityCardResponse.TransferFields(TempCityCardRequest, false);
                    TempCityCardResponse.EntryNo := Power(2, 31) - TempCityCardRequest.EntryNo;
                    TempCityCardResponse.RedemptionResultCode := '500';
                    TempCityCardResponse.RedemptionResultMessage := 'Internal Server Error';
                    if (Result.Get('state', State)) then begin
                        TempCityCardResponse.RedemptionResultCode := CopyStr(CityCard.Get(State.AsObject(), 'code').AsCode(), 1, MaxStrLen(TempCityCardResponse.RedemptionResultCode));
                        TempCityCardResponse.RedemptionResultMessage := CopyStr(CityCard.Get(State.AsObject(), 'message').AsText(), 1, MaxStrLen(TempCityCardResponse.RedemptionResultMessage));
                    end;
                end;

                TempCityCardResponse.Insert();

            until (TempCityCardRequest.Next() = 0);
        end;
        DocLxCityCardXmlPort.SetCityCardResponse(TempCityCardResponse);
        // Export is implicit since the XmlPort is passed by reference
    end;

}
