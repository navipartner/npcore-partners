xmlport 6150905 "NPR HC Generic Request"
{
    // NPR5.38/TSA /20171205 CASE 297946 Initial Version
    // NPR5.38/NPKNAV/20180126  CASE 297859 Transport NPR5.38 - 26 January 2018

    Caption = 'HC Generic Request';
    Encoding = UTF8;
    FormatEvaluate = Xml;
    UseDefaultNamespace = true;

    schema
    {
        textelement(generichqrequest)
        {
            textelement(request)
            {
                MaxOccurs = Once;
                tableelement(tmpgenericwebrequest; "NPR HC Generic Web Request")
                {
                    MaxOccurs = Once;
                    XmlName = 'requestline';
                    UseTemporary = true;
                    fieldattribute(number; TmpGenericWebRequest."External Entry No.")
                    {
                        Occurrence = Optional;
                    }
                    fieldattribute(requestcode; TmpGenericWebRequest."Request Code")
                    {
                        Occurrence = Optional;
                    }
                    fieldelement(parameter1; TmpGenericWebRequest."Parameter 1")
                    {
                    }
                    fieldelement(parameter2; TmpGenericWebRequest."Parameter 2")
                    {
                    }
                    fieldelement(parameter3; TmpGenericWebRequest."Parameter 3")
                    {
                    }
                    fieldelement(parameter4; TmpGenericWebRequest."Parameter 4")
                    {
                    }
                    fieldelement(parameter5; TmpGenericWebRequest."Parameter 5")
                    {
                    }
                    fieldelement(parameter6; TmpGenericWebRequest."Parameter 6")
                    {
                    }
                    fieldelement(requestdate; TmpGenericWebRequest."Request Date")
                    {
                    }
                    fieldelement(requestuserid; TmpGenericWebRequest."Request User ID")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }

                    trigger OnBeforeInsertRecord()
                    begin
                        TmpGenericWebRequest."Entry No." := 0;
                    end;
                }
            }
            textelement(requestresponse)
            {
                MaxOccurs = Once;
                MinOccurs = Zero;
                textelement(responseStatus)
                {
                    MaxOccurs = Once;
                    textelement(responseCode)
                    {
                        MaxOccurs = Once;
                    }
                    textelement(responseDescription)
                    {
                        MaxOccurs = Once;
                    }
                }
                tableelement(tmpresponse; "NPR HC Generic Web Request")
                {
                    MaxOccurs = Once;
                    MinOccurs = Zero;
                    XmlName = 'responeseline';
                    UseTemporary = true;
                    fieldattribute(number; TmpResponse."External Entry No.")
                    {
                        Occurrence = Optional;
                    }
                    fieldelement(response1; TmpResponse."Response 1")
                    {
                    }
                    fieldelement(response2; TmpResponse."Response 2")
                    {
                    }
                    fieldelement(response3; TmpResponse."Response 3")
                    {
                    }
                    fieldelement(response4; TmpResponse."Response 4")
                    {
                    }
                    fieldelement(responsedate; TmpResponse."Response Date")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(responseuserid; TmpResponse."Response User ID")
                    {
                        MinOccurs = Zero;
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
        LineNo: Integer;

    procedure GetRequest(var TmpHCGenericWebRequest: Record "NPR HC Generic Web Request" temporary)
    begin
        TmpHCGenericWebRequest.TransferFields(TmpGenericWebRequest, true);
        TmpHCGenericWebRequest.Insert();

        responseCode := 'ERROR';
        responseDescription := 'No Response';
    end;

    procedure SetResponse(var TmpHCGenericWebRequest: Record "NPR HC Generic Web Request" temporary)
    begin
        TmpResponse.TransferFields(TmpHCGenericWebRequest, true);

        TmpResponse."Response User ID" := UserId;
        TmpResponse."Response Date" := CurrentDateTime;
        TmpResponse.Insert();

        responseCode := 'OK';
        responseDescription := '';
    end;

    procedure SetErrorResponse(ErrorDescription: Text)
    begin

        responseCode := 'ERROR';
        responseDescription := ErrorDescription;
    end;
}

