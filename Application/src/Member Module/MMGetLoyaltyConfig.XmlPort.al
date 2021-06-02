xmlport 6151160 "NPR MM Get Loyalty Config."
{

    Caption = 'Get Loyalty Configuration';
    FormatEvaluate = Xml;
    UseDefaultNamespace = true;
    Encoding = UTF8;
    schema
    {
        textelement(GetLoyaltyConfiguration)
        {
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
                }
            }
            textelement(Response)
            {
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
                textelement(Configurations)
                {
                    MaxOccurs = Once;
                    MinOccurs = Zero;
                    tableelement(tmployaltysetupresponse; "NPR MM Loyalty Setup")
                    {
                        MinOccurs = Zero;
                        XmlName = 'Configuration';
                        UseTemporary = true;
                        fieldattribute(Code; TmpLoyaltySetupResponse.Code)
                        {
                        }
                        fieldelement(EarnRatio; TmpLoyaltySetupResponse."Amount Factor")
                        {
                        }
                        fieldelement(BurnRatio; TmpLoyaltySetupResponse."Point Rate")
                        {
                        }
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

    var
        DocumentId: Text;
        StartTime: Time;
        ExecutionTimeLbl: Label '%1 (ms)', Locked = true;

    procedure SetDocumentId(var DocumentIdIn: Text)
    begin

        // For test framework
        DocumentId := DocumentIdIn;
    end;

    procedure GetRequest(var TmpAuthorization: Record "NPR MM Loy. LedgerEntry (Srvr)" temporary)
    begin

        SetErrorResponse('No response.', '-1099');

        // Extract the request data
        TmpAuthorizationRequest.FindFirst();
        TmpAuthorization.TransferFields(TmpAuthorizationRequest, true);
        TmpAuthorization.Insert();
    end;

    procedure GetResponse(var ResponseCodeOut: Code[10]; var ResponseMessageOut: Text; var DocumentIdOut: Text; var TmpLoyaltySetup: Record "NPR MM Loyalty Setup" temporary)
    begin

        // For test framework
        ResponseCodeOut := ResponseCode;
        ResponseMessageOut := ResponseMessage;
        DocumentIdOut := DocumentId;

        TmpLoyaltySetup.TransferFields(TmpLoyaltySetupResponse, true);
        TmpLoyaltySetup.Insert();
    end;

    procedure SetResponse(var TmpLoyaltySetup: Record "NPR MM Loyalty Setup" temporary)
    begin

        if (not TmpLoyaltySetup.FindFirst()) then begin
            SetErrorResponse('Loyalty Setup not found.', '-1098');
            exit;
        end;

        TmpLoyaltySetupResponse.TransferFields(TmpLoyaltySetup, true);
        TmpLoyaltySetupResponse.Insert();

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

