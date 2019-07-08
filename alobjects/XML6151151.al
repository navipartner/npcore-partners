xmlport 6151151 "M2 Reset Account Password"
{
    // NPR5.48/TSA /20181211 CASE 320425 Initial Version

    Caption = 'Reset Account Password';
    Encoding = UTF8;
    FormatEvaluate = Xml;
    TransactionType = UpdateNoLocks;
    UseDefaultNamespace = true;

    schema
    {
        textelement(ResetAccountPassword)
        {
            tableelement(tmponetimepasswordrequest;"M2 One Time Password")
            {
                MaxOccurs = Once;
                XmlName = 'Request';
                UseTemporary = true;
                textelement(Account)
                {
                    MaxOccurs = Once;
                    fieldattribute(EMail;TmpOneTimePasswordRequest."E-Mail")
                    {
                    }
                }

                trigger OnBeforeInsertRecord()
                begin
                    RequestEntryCount += 1;
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
        RequestEntryCount := 0;
    end;

    var
        RequestEntryCount: Integer;
        StartTime: Time;

    procedure GetRequest(var TmpOneTimePassword: Record "M2 One Time Password" temporary)
    begin

        StartTime := Time;
        ResponseCode := 'ERROR';
        ResponseMessage := 'No Response';

        TmpOneTimePasswordRequest.Reset ();
        if (TmpOneTimePasswordRequest.FindSet ()) then begin
          repeat
            TmpOneTimePassword.TransferFields (TmpOneTimePasswordRequest, true);
            TmpOneTimePassword.Insert ();
          until (TmpOneTimePasswordRequest.Next () = 0);
        end;
    end;

    procedure SetResponse()
    begin

        ExecutionTime := StrSubstNo ('%1 (ms)', Format (Time - StartTime, 0, 9));
        ResponseCode := 'OK';
        ResponseMessage := '';
    end;

    procedure SetErrorResponse(ReasonText: Text)
    begin
        ExecutionTime := StrSubstNo ('%1 (ms)', Format (Time - StartTime, 0, 9));
        ResponseCode := 'ERROR';
        ResponseMessage := ReasonText;
    end;
}

