xmlport 6151162 "NPR MM Register Sale"
{

    Caption = 'Register Sale';
    FormatEvaluate = Xml;
    UseDefaultNamespace = true;
    Encoding = UTF8;
    schema
    {
        textelement(RegisterSale)
        {
            MaxOccurs = Once;
            textelement(Request)
            {
                MaxOccurs = Once;
                MinOccurs = Once;
                tableelement(tmpauthorizationrequest; "NPR MM Loy. LedgerEntry (Srvr)")
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
                }
                textelement(Sales)
                {
                    MaxOccurs = Once;
                    tableelement(tmpregistersalesrequest; "NPR MM Reg. Sales Buffer")
                    {
                        XmlName = 'Line';
                        UseTemporary = true;
                        fieldattribute(Type; TmpRegisterSalesRequest.Type)
                        {
                        }
                        fieldattribute(ItemNumber; TmpRegisterSalesRequest."Item No.")
                        {
                        }
                        fieldattribute(VariantCode; TmpRegisterSalesRequest."Variant Code")
                        {
                        }
                        fieldattribute(Quantity; TmpRegisterSalesRequest.Quantity)
                        {
                        }
                        fieldattribute(Description; TmpRegisterSalesRequest.Description)
                        {
                        }
                        fieldattribute(CurrencyCode; TmpRegisterSalesRequest."Currency Code")
                        {
                        }
                        fieldattribute(Amount; TmpRegisterSalesRequest."Total Amount")
                        {
                        }
                        fieldattribute(Points; TmpRegisterSalesRequest."Total Points")
                        {
                        }

                        trigger OnBeforeInsertRecord()
                        begin

                            TmpRegisterSalesRequest."Entry No." := TmpRegisterSalesRequest.Count() + 1;
                        end;
                    }
                }
                textelement(Payments)
                {
                    MaxOccurs = Once;
                    tableelement(tmpregisterpaymentrequest; "NPR MM Reg. Sales Buffer")
                    {
                        MinOccurs = Zero;
                        XmlName = 'Line';
                        UseTemporary = true;
                        fieldattribute(Type; TmpRegisterPaymentRequest.Type)
                        {
                        }
                        fieldattribute(Description; TmpRegisterPaymentRequest.Description)
                        {
                        }
                        fieldattribute(CurrencyCode; TmpRegisterPaymentRequest."Currency Code")
                        {
                        }
                        fieldattribute(Amount; TmpRegisterPaymentRequest."Total Amount")
                        {
                        }
                        fieldattribute(Points; TmpRegisterPaymentRequest."Total Points")
                        {
                        }
                        fieldattribute(AuthorizationCode; TmpRegisterPaymentRequest."Authorization Code")
                        {
                        }

                        trigger OnBeforeInsertRecord()
                        begin

                            TmpRegisterPaymentRequest."Entry No." := TmpRegisterPaymentRequest.Count() + 1;
                        end;
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
                tableelement(tmppointsresponse; "NPR MM Loy. LedgerEntry (Srvr)")
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
                    fieldattribute(PointsEarned; TmpPointsResponse."Earned Points")
                    {
                    }
                    fieldattribute(PointsSpent; TmpPointsResponse."Burned Points")
                    {
                    }
                    fieldattribute(NewPointBalance; TmpPointsResponse.Balance)
                    {
                    }
                }
            }
        }
    }

    requestpage
    {

        layout
        {
        }

        actions
        {
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

    procedure SetDocumentId(var DocumentIdIn: Text)
    begin
        // For test framework
        DocumentId := DocumentIdIn;
    end;

    procedure GetRequest(var TmpAuthorization: Record "NPR MM Loy. LedgerEntry (Srvr)" temporary; var TmpSalesLine: Record "NPR MM Reg. Sales Buffer" temporary; var TmpPaymentLine: Record "NPR MM Reg. Sales Buffer" temporary)
    begin

        SetErrorResponse('No response.', '-1099');

        // Extract the request data
        TmpAuthorizationRequest.FindFirst();
        TmpAuthorization.TransferFields(TmpAuthorizationRequest, true);
        TmpAuthorization.Insert();

        if (TmpRegisterSalesRequest.FindSet()) then begin
            repeat
                TmpSalesLine.TransferFields(TmpRegisterSalesRequest, true);
                TmpSalesLine.Insert();
            until (TmpRegisterSalesRequest.Next() = 0);
        end;

        if (TmpRegisterPaymentRequest.FindSet()) then begin
            repeat
                TmpPaymentLine.TransferFields(TmpRegisterPaymentRequest, true);
                TmpPaymentLine.Insert();
            until (TmpRegisterPaymentRequest.Next() = 0);
        end;
    end;

    procedure GetResponse(var ResponseCodeOut: Code[10]; var ResponseMessageOut: Text; var DocumentIdOut: Text; var TmpPoints: Record "NPR MM Loy. LedgerEntry (Srvr)" temporary)
    begin

        // For test framework
        ResponseCodeOut := ResponseCode;
        ResponseMessageOut := ResponseMessage;
        DocumentIdOut := DocumentId;

        TmpPoints.TransferFields(TmpPointsResponse);
        TmpPoints."Entry No." := 1;
        TmpPoints.Insert();
    end;

    procedure SetResponse(var TmpPoints: Record "NPR MM Loy. LedgerEntry (Srvr)" temporary)
    begin

        if (not TmpPoints.FindFirst()) then begin
            SetErrorResponse('Registering the sales failed.', '-1098');
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

    procedure SetErrorResponse(ResponseMessageIn: Text; MessageId: Text)
    begin

        ResponseCode := 'ERROR';
        ResponseMessage := ResponseMessageIn;
        MessageCode := MessageId;
    end;
}

