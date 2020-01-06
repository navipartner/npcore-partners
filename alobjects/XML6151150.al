xmlport 6151150 "M2 Authenticate"
{
    // NPR5.49/TSA /20181211 CASE 320425 Initial Version
    // NPR5.49/TSA /20190307 CASE 347894 Changed PasswordMD5 to PasswordHash
    // NPR5.51/TSA /20190812 CASE 364644 Added Person section
    // MAG2.23/TSA /20191015 CASE 373151 Changed cardinality for person section

    Caption = 'Authenticate';
    Encoding = UTF8;
    FormatEvaluate = Xml;
    TransactionType = UpdateNoLocks;
    UseDefaultNamespace = true;

    schema
    {
        textelement(Authenticate)
        {
            tableelement(tmponetimepasswordrequest;"M2 One Time Password")
            {
                MaxOccurs = Once;
                XmlName = 'Request';
                UseTemporary = true;
                textelement(Account)
                {
                    MaxOccurs = Once;
                    fieldattribute(Email;TmpOneTimePasswordRequest."E-Mail")
                    {
                    }
                    fieldattribute(PasswordHash;TmpOneTimePasswordRequest."Password (Hash)")
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
                    tableelement(tmpcontactresponse;Contact)
                    {
                        MinOccurs = Zero;
                        XmlName = 'Account';
                        UseTemporary = true;
                        textattribute(Type)
                        {

                            trigger OnBeforePassVariable()
                            begin
                                case TmpContactResponse.Type of
                                  TmpContactResponse.Type::Company : Type := 'company';
                                  TmpContactResponse.Type::Person : Type := 'person';
                                end;
                            end;
                        }
                        fieldattribute(Id;TmpContactResponse."No.")
                        {
                        }
                        fieldattribute(CorporateId;TmpContactResponse."Company No.")
                        {
                            Occurrence = Optional;

                            trigger OnBeforePassField()
                            begin
                                if (TmpContactResponse.Type = TmpContactResponse.Type::Company) then
                                  TmpContactResponse."Company No." := '';
                            end;
                        }
                        fieldelement(Name;TmpContactResponse.Name)
                        {
                        }
                        textelement(personresponse)
                        {
                            MaxOccurs = Once;
                            MinOccurs = Zero;
                            XmlName = 'Person';
                            fieldelement(FirstName;TmpContactResponse."First Name")
                            {
                                MinOccurs = Zero;
                            }
                            fieldelement(LastName;TmpContactResponse.Surname)
                            {
                                MinOccurs = Zero;
                            }
                        }
                        fieldelement(CompanyName;TmpContactResponse."Company Name")
                        {
                        }
                        fieldelement(Email;TmpContactResponse."E-Mail")
                        {
                        }
                        textelement(accountstatus)
                        {
                            XmlName = 'Status';

                            trigger OnBeforePassVariable()
                            begin

                                case TmpContactResponse."Magento Account Status" of
                                  TmpContactResponse."Magento Account Status"::ACTIVE : AccountStatus := 'active';
                                  TmpContactResponse."Magento Account Status"::BLOCKED : AccountStatus := 'blocked';
                                  TmpContactResponse."Magento Account Status"::CHECKOUT_BLOCKED : AccountStatus := 'checkout_blocked';
                                end;
                            end;
                        }
                        textelement(pricevisibility)
                        {
                            XmlName = 'PriceVisibility';

                            trigger OnBeforePassVariable()
                            begin

                                case TmpContactResponse."Magento Price Visibility" of
                                  TmpContactResponse."Magento Price Visibility"::VISIBLE : PriceVisibility := 'visible';
                                  TmpContactResponse."Magento Price Visibility"::HIDDEN : PriceVisibility := 'hidden';
                                end;
                            end;
                        }
                        tableelement(tmpmembershiproleresponse;"MM Membership Role")
                        {
                            LinkFields = "Contact No."=FIELD("No.");
                            LinkTable = TmpContactResponse;
                            MinOccurs = Zero;
                            XmlName = 'Membership';
                            UseTemporary = true;
                            fieldelement(MembershipCode;TmpMembershipRoleResponse."Membership Code")
                            {
                            }
                            fieldelement(ExternalMembershipNumber;TmpMembershipRoleResponse."External Membership No.")
                            {
                            }
                            fieldelement(ExternalMemberNumber;TmpMembershipRoleResponse."External Member No.")
                            {
                            }
                            fieldelement(DisplayName;TmpMembershipRoleResponse."Member Display Name")
                            {
                            }
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

    procedure SetResponse(var TmpContact: Record Contact temporary)
    begin

        TmpContact.Reset ();
        if (TmpContact.FindSet ()) then begin
          repeat
            TmpContactResponse.TransferFields (TmpContact, true);
            TmpContactResponse.Insert ();

          until (TmpContact.Next () = 0);
        end;

        ExecutionTime := StrSubstNo ('%1 (ms)', Format (Time - StartTime, 0, 9));
        ResponseCode := 'OK';
        ResponseMessage := '';

        if (TmpContact.IsEmpty ()) then
          SetErrorResponse ('Invalid E-Mail, Password combination.');
    end;

    procedure SetErrorResponse(ReasonText: Text)
    begin
        ExecutionTime := StrSubstNo ('%1 (ms)', Format (Time - StartTime, 0, 9));
        ResponseCode := 'ERROR';
        ResponseMessage := ReasonText;
    end;
}

