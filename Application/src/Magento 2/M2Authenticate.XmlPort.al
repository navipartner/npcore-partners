xmlport 6151150 "NPR M2 Authenticate"
{
    Caption = 'Authenticate';
    Encoding = UTF8;
    FormatEvaluate = Xml;
    TransactionType = UpdateNoLocks;
    UseDefaultNamespace = true;

    schema
    {
        textelement(Authenticate)
        {
            tableelement(tmponetimepasswordrequest; "NPR M2 One Time Password")
            {
                MaxOccurs = Once;
                XmlName = 'Request';
                UseTemporary = true;
                textelement(Account)
                {
                    MaxOccurs = Once;
                    fieldattribute(Email; TmpOneTimePasswordRequest."E-Mail")
                    {
                    }
                    fieldattribute(PasswordHash; TmpOneTimePasswordRequest."Password (Hash)")
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
                        fieldattribute(CorporateId; TmpContactResponse."Company No.")
                        {
                            Occurrence = Optional;

                            trigger OnBeforePassField()
                            begin
                                if (TmpContactResponse.Type = TmpContactResponse.Type::Company) then
                                    TmpContactResponse."Company No." := '';
                            end;
                        }
                        textattribute(isaffiliated)
                        {
                            XmlName = 'Affiliated';
                        }
                        fieldelement(Name; TmpContactResponse.Name)
                        {
                        }
                        textelement(personresponse)
                        {
                            MaxOccurs = Once;
                            MinOccurs = Zero;
                            XmlName = 'Person';
                            fieldelement(FirstName; TmpContactResponse."First Name")
                            {
                                MinOccurs = Zero;
                            }
                            fieldelement(LastName; TmpContactResponse.Surname)
                            {
                                MinOccurs = Zero;
                            }
                        }
                        fieldelement(CompanyName; TmpContactResponse."Company Name")
                        {
                        }
                        fieldelement(Email; TmpContactResponse."E-Mail")
                        {
                        }
                        textelement(accountstatus)
                        {
                            XmlName = 'Status';

                            trigger OnBeforePassVariable()
                            begin

                                case TmpContactResponse."NPR Magento Account Status" of
                                    TmpContactResponse."NPR Magento Account Status"::ACTIVE:
                                        AccountStatus := 'active';
                                    TmpContactResponse."NPR Magento Account Status"::BLOCKED:
                                        AccountStatus := 'blocked';
                                    TmpContactResponse."NPR Magento Account Status"::CHECKOUT_BLOCKED:
                                        AccountStatus := 'checkout_blocked';
                                end;
                            end;
                        }
                        textelement(pricevisibility)
                        {
                            XmlName = 'PriceVisibility';

                            trigger OnBeforePassVariable()
                            begin

                                case TmpContactResponse."NPR Magento Price Visibility" of
                                    TmpContactResponse."NPR Magento Price Visibility"::VISIBLE:
                                        PriceVisibility := 'visible';
                                    TmpContactResponse."NPR Magento Price Visibility"::HIDDEN:
                                        PriceVisibility := 'hidden';
                                end;
                            end;
                        }
                        textelement(storecode)
                        {
                            XmlName = 'StoreCode';

                            trigger OnBeforePassVariable()
                            begin
                                StoreCode := Customer."NPR Magento Store Code";
                            end;
                        }
                        tableelement(tmpmembershiproleresponse; "NPR MM Membership Role")
                        {
                            LinkFields = "Contact No." = FIELD("No.");
                            LinkTable = TmpContactResponse;
                            MinOccurs = Zero;
                            XmlName = 'Membership';
                            UseTemporary = true;
                            fieldelement(MembershipCode; TmpMembershipRoleResponse."Membership Code")
                            {
                            }
                            fieldelement(ExternalMembershipNumber; TmpMembershipRoleResponse."External Membership No.")
                            {
                            }
                            fieldelement(ExternalMemberNumber; TmpMembershipRoleResponse."External Member No.")
                            {
                            }
                            fieldelement(DisplayName; TmpMembershipRoleResponse."Member Display Name")
                            {
                            }
                        }
                        tableelement(tmpcontactbusinessrelationresp; "Contact Business Relation")
                        {
                            LinkFields = "Contact No." = FIELD("No.");
                            LinkTable = TmpContactResponse;
                            MaxOccurs = Once;
                            MinOccurs = Zero;
                            XmlName = 'SellTo';
                            UseTemporary = true;
                            fieldattribute(Id; TmpContactBusinessRelationResp."No.")
                            {
                            }
                            textelement(customersearchname)
                            {
                                XmlName = 'SearchName';
                            }
                            textelement(salesperson)
                            {
                                XmlName = 'Salesperson';
                                textattribute(salespersoncode)
                                {
                                    XmlName = 'Code';
                                }
                            }

                            trigger OnAfterGetRecord()
                            var
                                SalespersonPurchaser: Record "Salesperson/Purchaser";
                            begin
                                if (not Customer.Get(TmpContactBusinessRelationResp."No.")) then
                                    Clear(Customer);

                                CustomerSearchName := Customer."Search Name";

                                if (Customer."Salesperson Code" <> '') then begin
                                    if (SalespersonPurchaser.Get(Customer."Salesperson Code")) then
                                        Salesperson := SalespersonPurchaser.Name;
                                    SalespersonCode := Customer."Salesperson Code";
                                end;
                            end;
                        }

                        trigger OnAfterGetRecord()
                        var
                            ContactBusinessRelation: Record "Contact Business Relation";
                            MarketingSetup: Record "Marketing Setup";
                        begin
                            if (TmpContactResponse."Company No." = '') then
                                TmpContactResponse."Company No." := TmpContactResponse."No.";

                            if (MarketingSetup.Get()) then
                                if (ContactBusinessRelation.Get(TmpContactResponse."Company No.", MarketingSetup."Bus. Rel. Code for Customers")) then
                                    if (not Customer.Get(ContactBusinessRelation."No.")) then
                                        Clear(Customer);
                            IsAffiliated := Format((TmpOneTimePasswordRequest."E-Mail" <> TmpContactResponse."E-Mail"), 0, 9);
                        end;
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
        Customer: Record Customer;

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
    var
        MembershipRole: Record "NPR MM Membership Role";
        ContactBusinessRelation: Record "Contact Business Relation";
    begin
        TmpContact.Reset();

        AppendAffiliatedContacts(TmpContact);

        if (TmpContact.FindSet()) then begin
            repeat
                TmpContactResponse.TransferFields(TmpContact, true);
                TmpContactResponse.Insert();
                if (not MembershipRole.SetCurrentKey("Contact No.")) then;
                MembershipRole.SetFilter("Contact No.", '=%1', TmpContact."No.");
                MembershipRole.SetFilter(Blocked, '=%1', false);
                if (MembershipRole.FindFirst()) then begin
                    MembershipRole.CalcFields("External Member No.", "External Membership No.", "Member Display Name", "Membership Code");
                    TmpMembershipRoleResponse.TransferFields(MembershipRole, true);
                    TmpMembershipRoleResponse.Insert();
                end;

                ContactBusinessRelation.SetFilter("Link to Table", '=%1', ContactBusinessRelation."Link to Table"::Customer);
                ContactBusinessRelation.SetFilter("Contact No.", '=%1', TmpContact."Company No.");
                if (ContactBusinessRelation.FindFirst()) then begin
                    TmpContactBusinessRelationResp.TransferFields(ContactBusinessRelation, true);
                    TmpContactBusinessRelationResp."Contact No." := TmpContact."No.";
                    if (not TmpContactBusinessRelationResp.Insert()) then;
                end;

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

    local procedure AppendAffiliatedContacts(var TmpContact: Record Contact temporary)
    var
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        PrimaryContact: Record Contact;
        ContactBusinessRelation: Record "Contact Business Relation";
    begin
        if (TmpContact.FindSet()) then begin
            TmpOneTimePasswordRequest.Reset();
            TmpOneTimePasswordRequest.FindFirst();

            SalespersonPurchaser.SetFilter("E-Mail", '=%1', TmpOneTimePasswordRequest."E-Mail");
            if (SalespersonPurchaser.FindSet()) then begin
                repeat
                    Customer.SetFilter("Salesperson Code", '=%1', SalespersonPurchaser.Code);
                    if (Customer.FindSet()) then begin
                        repeat
                            ContactBusinessRelation.SetFilter("Link to Table", '=%1', ContactBusinessRelation."Link to Table"::Customer);
                            ContactBusinessRelation.SetFilter("No.", '=%1', Customer."No.");
                            if (ContactBusinessRelation.FindFirst()) then begin
                                if (PrimaryContact.Get(ContactBusinessRelation."Contact No.")) then begin
                                    TmpContact.TransferFields(PrimaryContact, true);
                                    TmpContact."Company No." := TmpContact."No.";
                                    if (TmpContact."NPR Magento Contact") then
                                        if (not TmpContact.Insert()) then;
                                end;
                            end;
                        until (Customer.Next() = 0);
                    end;
                until (SalespersonPurchaser.Next() = 0);
            end;
        end;
    end;
}