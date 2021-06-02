xmlport 6151159 "NPR M2 Delete Shipto Address"
{
    Caption = 'Delete Shipto Address';
    Encoding = UTF8;
    FormatEvaluate = Xml;
    UseDefaultNamespace = true;

    schema
    {
        textelement(DeleteShiptoAddress)
        {
            textelement(Request)
            {
                MaxOccurs = Once;
                tableelement(tmpaccountrequest; Contact)
                {
                    MaxOccurs = Once;
                    XmlName = 'Account';
                    UseTemporary = true;
                    fieldattribute(Id; TmpAccountRequest."No.")
                    {
                    }
                }
                textelement(shiptoaddressrequest)
                {
                    MaxOccurs = Once;
                    XmlName = 'ShiptoAddress';
                    tableelement(tmpshiptoaddressrequest; "Ship-to Address")
                    {
                        XmlName = 'Address';
                        UseTemporary = true;
                        fieldattribute(Id; TmpShipToAddressRequest.Code)
                        {
                        }
                    }
                }
            }
            textelement(Response)
            {
                MaxOccurs = Once;
                MinOccurs = Zero;
                textelement(Status)
                {
                    MaxOccurs = Once;
                    textelement(ResponseCode)
                    {
                        MaxOccurs = Once;
                    }
                    textelement(ResponseMessage)
                    {
                        MaxOccurs = Once;
                    }
                    textelement(ExecutionTime)
                    {
                        MaxOccurs = Once;
                    }
                }
            }
        }
    }

    var
        StartTime: Time;
        ExecutionTimeLbl: Label '%1 (ms)', Locked = true;

    procedure GetRequest(var TmpAccount: Record Contact temporary; var TmpShipToAddress: Record "Ship-to Address" temporary)
    begin

        StartTime := Time;
        SetErrorResponse('No response.');

        TmpAccountRequest.FindFirst();
        TmpAccount.TransferFields(TmpAccountRequest, true);
        TmpAccount.Insert();

        TmpShipToAddressRequest.FindSet();
        repeat
            TmpShipToAddress.TransferFields(TmpShipToAddressRequest, true);
            TmpShipToAddress.Insert();
        until (TmpShipToAddressRequest.Next() = 0);
    end;

    procedure SetResponse()
    begin

        ResponseCode := 'OK';
        ResponseMessage := '';
        ExecutionTime := StrSubstNo(ExecutionTimeLbl, Format(Time - StartTime, 0, 9));
    end;

    procedure SetErrorResponse(ErrorMessage: Text)
    begin

        ResponseCode := 'ERROR';
        ResponseMessage := ErrorMessage;
        ExecutionTime := StrSubstNo(ExecutionTimeLbl, Format(Time - StartTime, 0, 9));
    end;
}