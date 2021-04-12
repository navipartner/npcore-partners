xmlport 6184507 "NPR M2 Shopper Recognition"
{
    Caption = 'M2 Shopper Recognition';
    Encoding = UTF8;
    FormatEvaluate = Xml;
    UseDefaultNamespace = true;

    schema
    {
        textelement(ShopperRecognition)
        {
            tableelement(tmpshopperrecognitionrequest; "NPR EFT Shopper Recognition")
            {
                XmlName = 'Request';
                UseTemporary = true;
                textelement(Account)
                {
                    MaxOccurs = Once;
                    fieldattribute(Type; TmpShopperRecognitionRequest."Entity Type")
                    {
                    }
                    fieldattribute(Id; TmpShopperRecognitionRequest."Entity Key")
                    {
                    }
                }
                textelement(Integration)
                {
                    MaxOccurs = Once;
                    fieldattribute(Type; TmpShopperRecognitionRequest."Integration Type")
                    {
                    }
                    fieldattribute(Id; TmpShopperRecognitionRequest."Shopper Reference")
                    {
                        Occurrence = Optional;
                    }
                }
                textelement(Contract)
                {
                    MaxOccurs = Once;
                    MinOccurs = Zero;
                    fieldattribute(Type; TmpShopperRecognitionRequest."Contract Type")
                    {
                    }
                    fieldattribute(Id; TmpShopperRecognitionRequest."Contract ID")
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
                tableelement(tmpshopperrecognitionresponse; "NPR EFT Shopper Recognition")
                {
                    MaxOccurs = Once;
                    XmlName = 'ShopperRecognition';
                    UseTemporary = true;
                    textelement(accountresponse)
                    {
                        MaxOccurs = Once;
                        XmlName = 'Account';
                        textattribute(Type)
                        {

                            trigger OnBeforePassVariable()
                            begin

                                case TmpShopperRecognitionResponse."Entity Type" of
                                    TmpShopperRecognitionResponse."Entity Type"::Contact:
                                        Type := 'Contact';
                                    TmpShopperRecognitionResponse."Entity Type"::Customer:
                                        Type := 'Customer';
                                end;
                            end;
                        }
                        fieldattribute(Id; TmpShopperRecognitionResponse."Entity Key")
                        {
                        }
                    }
                    textelement(integrationresponse)
                    {
                        MaxOccurs = Once;
                        XmlName = 'Integration';
                        fieldattribute(Type; TmpShopperRecognitionResponse."Integration Type")
                        {
                        }
                        fieldattribute(Id; TmpShopperRecognitionResponse."Shopper Reference")
                        {
                            Occurrence = Optional;
                        }
                    }
                    textelement(contractresponse)
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                        XmlName = 'Contract';
                        fieldattribute(Type; TmpShopperRecognitionResponse."Contract Type")
                        {
                        }
                        fieldattribute(Id; TmpShopperRecognitionResponse."Contract ID")
                        {
                        }
                    }
                }
            }
        }
    }

    trigger OnInitXmlPort()
    begin
        StartTime := Time;
        ExecutionTime := '---';
    end;

    var
        StartTime: Time;

    procedure GetRequest(var EFTShopperRecognition: Record "NPR EFT Shopper Recognition" temporary)
    begin

        TmpShopperRecognitionRequest.FindFirst();
        EFTShopperRecognition.TransferFields(TmpShopperRecognitionRequest, true);
        EFTShopperRecognition.Insert();
    end;

    procedure SetResponse(var EFTShopperRecognition: Record "NPR EFT Shopper Recognition" temporary)
    begin

        TmpShopperRecognitionRequest.FindFirst();

        if (not EFTShopperRecognition.FindFirst()) then
            SetErrorResponse(StrSubstNo('Invalid Account %1 %2', TmpShopperRecognitionRequest."Entity Type", TmpShopperRecognitionRequest."Entity Key"));

        if (ResponseCode = 'ERROR') then
            exit;

        EFTShopperRecognition.Reset();
        EFTShopperRecognition.FindFirst();
        TmpShopperRecognitionResponse.TransferFields(EFTShopperRecognition, true);
        TmpShopperRecognitionResponse.Insert();

        ResponseCode := 'OK';
        ResponseMessage := '';
        ExecutionTime := StrSubstNo('%1 (ms)', Format((Time - StartTime), 0, 9));
    end;

    procedure SetErrorResponse(ResponseMessageIn: Text)
    begin
        ResponseCode := 'ERROR';
        ResponseMessage := ResponseMessageIn;
    end;
}