xmlport 6151158 "NPR M2 Delete Account"
{
    // NPR5.48/TSA /20181213 CASE 320424 Initial Version

    Caption = 'Delete Account';
    Encoding = UTF8;
    FormatEvaluate = Xml;
    UseDefaultNamespace = true;

    schema
    {
        textelement(DeleteAccount)
        {
            tableelement(tmpcontactrequest; Contact)
            {
                MaxOccurs = Once;
                XmlName = 'Request';
                UseTemporary = true;
                textelement(Account)
                {
                    MaxOccurs = Once;
                    fieldattribute(Id; TmpContactRequest."No.")
                    {
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
        NPRDocLocalizationProxy: Codeunit "NPR Doc. Localization Proxy";
        StartTime: Time;

    procedure GetRequest() ContactNumber: Code[20]
    begin

        StartTime := Time;
        ResponseCode := 'ERROR';
        ResponseMessage := 'No result.';

        if (not TmpContactRequest.FindFirst()) then;
        exit(TmpContactRequest."No.");
    end;

    procedure SetResponse()
    begin

        ResponseCode := 'OK';
        ResponseMessage := '';
        ExecutionTime := StrSubstNo('%1 (ms)', Format(Time - StartTime, 0, 9));
    end;

    procedure SetErrorResponse(ReasonText: Text)
    begin

        ExecutionTime := StrSubstNo('%1 (ms)', Format(Time - StartTime, 0, 9));
        ResponseCode := 'ERROR';
        ResponseMessage := ReasonText;
    end;

    [TryFunction]
    local procedure TryGetEanNo(Customer: Record Customer temporary; var EanNo: Text)
    var
        TmpEan: Variant;
    begin

        //NPRDocLocalizationProxy.T18_GetFieldValue (Customer, 'Ean No.', TmpEan);
        EanNo := 'NOT IN W1';
    end;
}

