xmlport 6151151 "NPR M2 Reset Account Password"
{
    Caption = 'Reset Account Password';
    Encoding = UTF8;
    FormatEvaluate = Xml;
    TransactionType = UpdateNoLocks;
    UseDefaultNamespace = true;

    schema
    {
        textelement(ResetAccountPassword)
        {
            tableelement(tmponetimepasswordrequest; "NPR M2 One Time Password")
            {
                MaxOccurs = Once;
                XmlName = 'Request';
                UseTemporary = true;
                textelement(Account)
                {
                    MaxOccurs = Once;
                    fieldattribute(EMail; TmpOneTimePasswordRequest."E-Mail")
                    {
                    }
                }

                trigger OnBeforeInsertRecord()
                begin
                end;
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

    trigger OnInitXmlPort()
    begin
    end;

    var
        StartTime: Time;
        ExecutionTimeLbl: Label '%1 (ms)', Locked = true;

    internal procedure GetRequest(var TmpOneTimePassword: Record "NPR M2 One Time Password" temporary)
    begin

        StartTime := Time;
        ResponseCode := 'ERROR';
        ResponseMessage := 'No Response';

        TmpOneTimePasswordRequest.Reset();
        if (TmpOneTimePasswordRequest.FindSet()) then begin
            repeat
                TmpOneTimePassword.TransferFields(TmpOneTimePasswordRequest, true);
                TmpOneTimePassword.Insert();
            until (TmpOneTimePasswordRequest.Next() = 0);
        end;
    end;

    internal procedure SetResponse()
    begin

        ExecutionTime := StrSubstNo(ExecutionTimeLbl, Format(Time - StartTime, 0, 9));
        ResponseCode := 'OK';
        ResponseMessage := '';
    end;

    internal procedure SetErrorResponse(ReasonText: Text)
    begin
        ExecutionTime := StrSubstNo(ExecutionTimeLbl, Format(Time - StartTime, 0, 9));
        ResponseCode := 'ERROR';
        ResponseMessage := ReasonText;
    end;
}