xmlport 6151144 "NPR M2 Get Extended Account"
{
    Caption = 'Get Account';
    Encoding = UTF8;
    FormatEvaluate = Xml;
    UseDefaultNamespace = true;

    schema
    {
        textelement(ExtendedAccountDetails)
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
                tableelement(tmpcontactresponse; Contact)
                {
                    MinOccurs = Zero;
                    XmlName = 'Account';
                    UseTemporary = true;
                    textattribute(Type)
                    {

                        trigger OnBeforePassVariable()
                        begin
                            case TmpContactResponse.Type of
                                TmpContactResponse.Type::Company:
                                    Type := 'company';
                                TmpContactResponse.Type::Person:
                                    Type := 'person';
                            end;
                        end;
                    }
                    fieldattribute(Id; TmpContactResponse."No.")
                    {
                    }
                    textelement(accountextendeddetails)
                    {
                        XmlName = 'ExtendedDetails';
                        fieldelement(Fax; TmpContactResponse."Fax No.")
                        {
                        }
                    }
                    tableelement(tmpselltocustomer; Customer)
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                        XmlName = 'SellToCustomer';
                        UseTemporary = true;
                        fieldattribute(Id; TmpSellToCustomer."No.")
                        {
                        }
                        textelement(selltoextendeddetails)
                        {
                            XmlName = 'ExtendedDetails';
                            textelement(selltoean)
                            {
                                XmlName = 'Ean';

                                trigger OnBeforePassVariable()
                                begin
                                    TryGetEanNo(SellToEan);
                                end;
                            }
                        }
                    }
                    tableelement(tmpbilltocustomer; Customer)
                    {
                        MinOccurs = Zero;
                        XmlName = 'BillToCustomer';
                        UseTemporary = true;
                        fieldattribute(Id; TmpBillToCustomer."No.")
                        {
                        }
                        textelement(billtoextendeddetails)
                        {
                            XmlName = 'ExtendedDetails';
                            textelement(billtoean)
                            {
                                XmlName = 'Ean';

                                trigger OnBeforePassVariable()
                                begin
                                    TryGetEanNo(BillToEan);
                                end;
                            }
                        }
                    }
                }
            }
        }
    }

    var
        StartTime: Time;

    procedure GetRequest() ContactNumber: Code[20]
    begin

        StartTime := Time;
        ResponseCode := 'ERROR';
        ResponseMessage := 'No result.';

        if (not TmpContactRequest.FindFirst()) then;
        exit(TmpContactRequest."No.");
    end;

    procedure SetResponse(var TmpContactIn: Record Contact temporary; var TmpSellToCustomerIn: Record Customer temporary; var TmpBillToCustomerIn: Record Customer temporary)
    begin

        ResponseMessage := 'Contact Id is unknown.';

        if (TmpContactIn.FindFirst()) then begin
            TmpContactResponse.TransferFields(TmpContactIn, true);
            TmpContactResponse.Insert();

            if (TmpSellToCustomerIn.FindFirst()) then begin
                TmpSellToCustomer.TransferFields(TmpSellToCustomerIn, true);
                TmpSellToCustomer.Insert();
            end;

            if (TmpBillToCustomerIn.FindFirst()) then begin
                TmpBillToCustomer.TransferFields(TmpBillToCustomerIn, true);
                TmpBillToCustomer.Insert();
            end;

            ResponseCode := 'OK';
            ResponseMessage := ''; //STRSUBSTNO ('%1 %2', TmpBillToCustomer.COUNT, TmpSellToCustomer.Count());
        end;

        ExecutionTime := StrSubstNo('%1 (ms)', Format(Time - StartTime, 0, 9));
    end;

    procedure SetErrorResponse(ReasonText: Text)
    begin

        ExecutionTime := StrSubstNo('%1 (ms)', Format(Time - StartTime, 0, 9));
        ResponseCode := 'ERROR';
        ResponseMessage := ReasonText;
    end;

    [TryFunction]
    local procedure TryGetEanNo(var EanNo: Text)
    begin
        EanNo := 'NOT IN W1';
    end;
}