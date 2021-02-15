xmlport 6151149 "NPR M2 Change Account Password"
{
    Caption = 'Change Account Password';
    Encoding = UTF8;
    FormatEvaluate = Xml;
    TransactionType = UpdateNoLocks;
    UseDefaultNamespace = true;

    schema
    {
        textelement(ChangeAccountPassword)
        {
            tableelement(tmponetimepasswordrequest; "NPR M2 One Time Password")
            {
                MaxOccurs = Once;
                XmlName = 'Request';
                UseTemporary = true;
                textelement(Account)
                {
                    fieldattribute(EMail; TmpOneTimePasswordRequest."E-Mail")
                    {
                    }
                    fieldattribute(PasswordHash; TmpOneTimePasswordRequest."Password (Hash)")
                    {
                    }
                    fieldattribute(NewPasswordHash; TmpOneTimePasswordRequest."Password2 (Hash)")
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
                textelement(Accounts)
                {
                    MaxOccurs = Once;
                    MinOccurs = Zero;
                    tableelement(tmpcontactresponse; Contact)
                    {
                        MinOccurs = Zero;
                        XmlName = 'Account';
                        UseTemporary = true;
                        fieldattribute(Id; TmpContactResponse."No.")
                        {
                        }
                        fieldelement(Name; TmpContactResponse.Name)
                        {
                        }
                        fieldelement(Name2; TmpContactResponse."Name 2")
                        {
                        }
                        fieldelement(Email; TmpContactResponse."E-Mail")
                        {
                        }
                    }
                }
            }
        }
    }

    trigger OnInitXmlPort()
    begin
        RequestEntryCount := 0;
    end;

    var
        RequestEntryCount: Integer;
        StartTime: Time;

    procedure GetRequest(var TmpOneTimePassword: Record "NPR M2 One Time Password" temporary)
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

    procedure SetResponse(var TmpContact: Record Contact temporary)
    begin

        TmpContact.Reset();
        if (TmpContact.FindSet()) then begin
            repeat
                TmpContactResponse.TransferFields(TmpContact, true);
                TmpContactResponse.Insert();
            until (TmpContact.Next() = 0);
        end;

        ExecutionTime := StrSubstNo('%1 (ms)', Format(Time - StartTime, 0, 9));
        ResponseCode := 'OK';
        ResponseMessage := '';

        if (TmpContact.IsEmpty()) then
            SetErrorResponse('Invalid E-Mail, Password combination.');
    end;

    procedure SetErrorResponse(ReasonText: Text)
    begin
        ExecutionTime := StrSubstNo('%1 (ms)', Format(Time - StartTime, 0, 9));
        ResponseCode := 'ERROR';
        ResponseMessage := ReasonText;
    end;
}