xmlport 6014415 "NPR MM CancelReservePoints"
{
    Caption = 'Cancel Reserve Points';
    FormatEvaluate = Xml;
    UseDefaultNamespace = true;
    Encoding = UTF8;
    schema
    {
        textelement(CancelReservePoints)
        {
            MaxOccurs = Once;
            textelement(Request)
            {
                MaxOccurs = Once;
                tableelement(TmpAuthorizationRequest; "NPR MM Loy. LedgerEntry (Srvr)")
                {
                    MaxOccurs = Once;
                    XmlName = 'Authorization';
                    UseTemporary = true;
                    fieldelement(PosCompanyName; TmpAuthorizationRequest."Company Name")
                    {
                    }
                    fieldelement(PosStoreCode; TmpAuthorizationRequest."POS Store Code")
                    {
                    }
                    fieldelement(PosUnitCode; TmpAuthorizationRequest."POS Unit Code")
                    {
                    }
                    fieldelement(Token; TmpAuthorizationRequest."Authorization Code")
                    {
                    }
                    fieldelement(ClientCardNumber; TmpAuthorizationRequest."Card Number")
                    {
                    }
                    fieldelement(ReceiptNumber; TmpAuthorizationRequest."Reference Number")
                    {
                    }
                    fieldelement(TransactionId; TmpAuthorizationRequest."Foreign Transaction Id")
                    {
                    }
                    fieldelement(Date; TmpAuthorizationRequest."Transaction Date")
                    {
                    }
                    fieldelement(Time; TmpAuthorizationRequest."Transaction Time")
                    {
                    }
                    fieldelement(RetailId; TmpAuthorizationRequest."Retail Id")
                    {
                    }
                }
                textelement(CancelReservation)
                {
                    MaxOccurs = Once;
                    tableelement(TmpRegisterCancelRequest; "NPR MM Reg. Sales Buffer")
                    {
                        MaxOccurs = Once;
                        XmlName = 'Line';
                        UseTemporary = true;
                        fieldattribute(Type; TmpRegisterCancelRequest.Type)
                        {
                        }
                        fieldattribute(AuthorizationCode; TmpRegisterCancelRequest."Authorization Code")
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
                        textattribute(MessageCode)
                        {
                            Occurrence = Optional;
                        }
                    }
                    textelement(ExecutionTime)
                    {
                        MaxOccurs = Once;
                    }
                }
                tableelement(TmpPointsResponse; "NPR MM Loy. LedgerEntry (Srvr)")
                {
                    MaxOccurs = Once;
                    XmlName = 'Points';
                    UseTemporary = true;
                    fieldattribute(ReferenceNumber; TmpPointsResponse."Entry No.")
                    {
                    }
                    fieldattribute(AuthorizationNumber; TmpPointsResponse."Authorization Code")
                    {
                    }
                    fieldattribute(NewPointBalance; TmpPointsResponse.Balance)
                    {
                    }
                }
            }
        }
    }

    trigger OnInitXmlPort()
    begin
        StartTime := Time;
    end;

    var
        StartTime: Time;
        DocumentId: Text;
        ExecutionTimeLbl: Label '%1 (ms)', Locked = true;

    internal procedure SetDocumentId(DocumentIdIn: Text)
    begin
        // For test framework
        DocumentId := DocumentIdIn;
    end;

    internal procedure GetRequest(var TmpAuthorization: Record "NPR MM Loy. LedgerEntry (Srvr)" temporary; var TmpCancelLine: Record "NPR MM Reg. Sales Buffer" temporary)
    begin

        SetErrorResponse('No response.', '-1099');

        // Extract the request data
        TmpAuthorizationRequest.FindFirst();
        TmpAuthorization.TransferFields(TmpAuthorizationRequest, true);
        TmpAuthorization.Insert();

        if (TmpRegisterCancelRequest.FindSet()) then begin
            repeat
                TmpCancelLine.TransferFields(TmpRegisterCancelRequest, true);
                TmpCancelLine.Insert();
            until (TmpRegisterCancelRequest.Next() = 0);
        end;
    end;

    internal procedure GetResponse(var ResponseCodeOut: Code[10]; var ResponseMessageOut: Text; var DocumentIdOut: Text; var TmpPoints: Record "NPR MM Loy. LedgerEntry (Srvr)" temporary)
    begin

        // For test framework
        ResponseCodeOut := ResponseCode;
        ResponseMessageOut := ResponseMessage;
        DocumentIdOut := DocumentId;

        TmpPoints.TransferFields(TmpPointsResponse);
        TmpPoints."Entry No." := 1;
        TmpPoints.Insert();
    end;

    internal procedure SetResponse(var TmpPoints: Record "NPR MM Loy. LedgerEntry (Srvr)" temporary)
    begin

        if (not TmpPoints.FindFirst()) then begin
            SetErrorResponse('Cancel Reservation Failed.', '-1098');
            exit;
        end;

        TmpPointsResponse.TransferFields(TmpPoints);
        TmpPointsResponse.Insert();

        ResponseCode := 'OK';
        ResponseMessage := '';
        MessageCode := '';

        if (StartTime <> 0T) then
            ExecutionTime := StrSubstNo(ExecutionTimeLbl, Format(Time - StartTime, 0, 9));
    end;

    internal procedure SetErrorResponse(ResponseMessageIn: Text; MessageId: Text)
    begin

        ResponseCode := 'ERROR';
        ResponseMessage := ResponseMessageIn;
        MessageCode := MessageId;
    end;
}

