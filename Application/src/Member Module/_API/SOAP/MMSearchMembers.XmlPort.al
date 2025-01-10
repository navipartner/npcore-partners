xmlport 6151186 "NPR MM Search Members"
{
    Caption = 'Search Members';
    FormatEvaluate = Xml;
    UseDefaultNamespace = true;
    Encoding = UTF8;
    schema
    {
        textelement(Members)
        {
            XmlName = 'members';
            MaxOccurs = Once;
            MinOccurs = Once;

            textelement(SearchMembers)
            {
                XmlName = 'searchmembers';
                MaxOccurs = Once;
                MinOccurs = Once;

                tableelement(TempMemberInfoRequest; "NPR MM Member Info Capture")
                {
                    XmlName = 'request';
                    MaxOccurs = Once;
                    MinOccurs = Once;
                    UseTemporary = true;
                    textattribute(NstServiceInstanceIdIn)
                    {
                        XmlName = 'cache_instance_id';
                        Occurrence = Optional;
                    }
                    fieldelement(FirstName; TempMemberInfoRequest."First Name")
                    {
                        XmlName = 'firstname';
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(LastName; TempMemberInfoRequest."Last Name")
                    {
                        XmlName = 'lastname';
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(PhoneNo; TempMemberInfoRequest."Phone No.")
                    {
                        XmlName = 'phonenumber';
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(EMailAddress; TempMemberInfoRequest."E-Mail Address")
                    {
                        XmlName = 'email';
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(ExternalMemberNo; TempMemberInfoRequest."External Member No")
                    {
                        XmlName = 'membernumber';
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(ExternalCardNo; TempMemberInfoRequest."External Card No.")
                    {
                        XmlName = 'cardnumber';
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(Quantity; TempMemberInfoRequest.Quantity)
                    {
                        XmlName = 'limitresultset';
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                }

                textelement(Response)
                {
                    XmlName = 'response';
                    MaxOccurs = Once;
                    MinOccurs = Zero;
                    textattribute(NstServiceInstanceIdOut)
                    {
                        XmlName = 'cache_instance_id';
                        trigger OnBeforePassVariable()
                        begin
                            NstServiceInstanceIdOut := Format(ServiceInstanceId(), 0, 9);
                        end;
                    }
                    textelement(Status)
                    {
                        XmlName = 'status';
                        MaxOccurs = Once;
                    }
                    textelement(ErrorDescription)
                    {
                        XmlName = 'errordescription';
                        MaxOccurs = Once;
                    }
                    tableelement(TempMemberInfoResponse; "NPR MM Member Info Capture")
                    {
                        MaxOccurs = Unbounded;
                        MinOccurs = Zero;
                        XmlName = 'member';
                        UseTemporary = true;

                        fieldelement(membernumber; TempMemberInfoResponse."External Member No")
                        {
                        }
                        fieldelement(firstname; TempMemberInfoResponse."First Name")
                        {
                        }
                        fieldelement(middlename; TempMemberInfoResponse."Middle Name")
                        {
                        }
                        fieldelement(lastname; TempMemberInfoResponse."Last Name")
                        {
                        }
                        fieldelement(address; TempMemberInfoResponse.Address)
                        {
                        }
                        fieldelement(postcode; TempMemberInfoResponse."Post Code Code")
                        {
                        }
                        fieldelement(city; TempMemberInfoResponse.City)
                        {
                        }
                        fieldelement(country; TempMemberInfoResponse.Country)
                        {
                            fieldattribute(countrycode; TempMemberInfoResponse."Country Code")
                            {
                                XmlName = 'code';
                            }
                        }
                        fieldelement(birthday; TempMemberInfoResponse.Birthday)
                        {
                        }
                        textelement(GenderText)
                        {
                            XmlName = 'gender';
                            fieldattribute(GenderId; TempMemberInfoResponse.Gender)
                            {
                                XmlName = 'id';
                            }

                            trigger OnBeforePassVariable()
                            begin
                                GenderText := Format(TempMemberInfoResponse.Gender);
                            end;
                        }

                        textelement(NewsLetterText)
                        {
                            XmlName = 'newsletter';
                            fieldattribute(NewsLetterId; TempMemberInfoResponse."News Letter")
                            {
                                XmlName = 'id';
                            }

                            trigger OnBeforePassVariable()
                            begin
                                NewsLetterText := Format(TempMemberInfoResponse."News Letter");
                            end;
                        }
                        fieldelement(phoneno; TempMemberInfoResponse."Phone No.")
                        {
                        }
                        fieldelement(email; TempMemberInfoResponse."E-Mail Address")
                        {
                        }
                        textelement(NotificationMethodText)
                        {
                            XmlName = 'notificationmethod';

                            fieldattribute(NotificationMethodId; TempMemberInfoResponse."Notification Method")
                            {
                                XmlName = 'id';
                            }

                            trigger OnBeforePassVariable()
                            begin
                                NotificationMethodText := Format(TempMemberInfoResponse."Notification Method");
                            end;
                        }

                        textelement(memberships)
                        {
                            MaxOccurs = Once;
                            tableelement(MembershipRole; "NPR MM Membership Role")
                            {
                                XmlName = 'membership';
                                LinkTable = TempMemberInfoResponse;
                                LinkFields = "Member Entry No." = field("Member Entry No");
                                CalcFields = "External Membership No.";

                                fieldattribute(MembershipNumber; MembershipRole."External Membership No.")
                                {
                                    XmlName = 'membershipnumber';
                                }

                                fieldattribute(ContactNumber; MembershipRole."Contact No.")
                                {
                                    XmlName = 'contactno';
                                }

                                fieldelement(MembershipCode; MembershipRole."Membership Code")
                                {
                                    XmlName = 'membershipcode';
                                }
                                textelement(MemberRoleText)
                                {
                                    XmlName = 'role';
                                    fieldattribute(MemberRoleId; MembershipRole."Member Role")
                                    {
                                        XmlName = 'id';
                                    }

                                    trigger OnBeforePassVariable()
                                    begin
                                        MemberRoleText := Format(MembershipRole."Member Role");
                                    end;
                                }

                                textelement(GdprApprovalText)
                                {
                                    XmlName = 'gdpr_approval';
                                    fieldattribute(GdprApprovalId; MembershipRole."GDPR Approval")
                                    {
                                        XmlName = 'id';
                                    }

                                    trigger OnBeforePassVariable()
                                    begin
                                        GdprApprovalText := Format(MembershipRole."GDPR Approval");
                                    end;
                                }

                                textelement(Cards)
                                {
                                    XmlName = 'cards';
                                    MaxOccurs = Once;
                                    MinOccurs = Zero;
                                    tableelement(Card; "NPR MM Member Card")
                                    {
                                        XmlName = 'card';
                                        LinkTable = MembershipRole;
                                        LinkFields = "Membership Entry No." = field("Membership Entry No."), "Member Entry No." = field("Member Entry No.");

                                        MaxOccurs = Unbounded;
                                        MinOccurs = Zero;
                                        fieldelement(CardNumber; Card."External Card No.")
                                        {
                                            XmlName = 'cardnumber';
                                        }
                                        fieldelement(ValidUntil; Card."Valid Until")
                                        {
                                            XmlName = 'expirydate';
                                        }
                                        fieldelement(Blocked; Card.Blocked)
                                        {
                                            XmlName = 'blocked';
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    procedure ClearResponse()
    begin
        TempMemberInfoResponse.DeleteAll();
    end;

    procedure AddResponse()
    var
        Member: Record "NPR MM Member";
        MemberCard: Record "NPR MM Member Card";
        NOT_FOUND: Label 'Member not found.';
    begin
        ErrorDescription := '';
        Status := '1';
        TempMemberInfoRequest.Reset();
        TempMemberInfoRequest.FindFirst();

        if (TempMemberInfoRequest.Quantity <= 0) then
            TempMemberInfoRequest.Quantity := 100;

        Member.SetFilter(Blocked, '=%1', false);

        if (TempMemberInfoRequest."External Card No." <> '') then begin
            MemberCard.SetFilter(Blocked, '=%1', false);
            MemberCard.SetFilter("External Card No.", '=%1', TempMemberInfoRequest."External Card No.");

            Member.SetFilter("Entry No.", '=%1', -1); // member entry no -1 does not exist - so an invalid member card will not find a member
            if (MemberCard.FindFirst()) then
                if (MemberCard."Member Entry No." > 0) then // Memberships can have anonymous members in which case the member entry no would be zero
                    Member.SetFilter("Entry No.", '=%1', MemberCard."Member Entry No.");
        end;

        if (TempMemberInfoRequest."External Member No" <> '') then
            Member.SetFilter("External Member No.", '=%1', TempMemberInfoRequest."External Member No");

        if (TempMemberInfoRequest."Last Name" <> '') then
            Member.SetFilter("Last Name", '%1', StrSubstNo('@%1', TempMemberInfoRequest."Last Name"));

        if (TempMemberInfoRequest."First Name" <> '') then
            Member.SetFilter("First Name", '%1', StrSubstNo('@%1', TempMemberInfoRequest."First Name"));

        if (TempMemberInfoRequest."E-Mail Address" <> '') then
            Member.SetFilter("E-Mail Address", '%1', LowerCase(TempMemberInfoRequest."E-Mail Address"));

        if (TempMemberInfoRequest."Phone No." <> '') then
            Member.SetFilter("Phone No.", '%1', TempMemberInfoRequest."Phone No.");

        if (Member.FindSet()) then begin
            repeat
                TempMemberInfoResponse.Init();
                TempMemberInfoResponse."Entry No." := Member."Entry No.";

                TempMemberInfoResponse."First Name" := Member."First Name";
                TempMemberInfoResponse."Last Name" := Member."Last Name";
                TempMemberInfoResponse."Middle Name" := Member."Middle Name";
                TempMemberInfoResponse.Address := Member.Address;
                TempMemberInfoResponse."Post Code Code" := Member."Post Code Code";
                TempMemberInfoResponse.City := Member.City;
                TempMemberInfoResponse.Country := Member.Country;
                TempMemberInfoResponse.Birthday := Member.Birthday;
                TempMemberInfoResponse.Gender := Member.Gender;
                TempMemberInfoResponse."News Letter" := Member."E-Mail News Letter";
                TempMemberInfoResponse."Phone No." := Member."Phone No.";
                TempMemberInfoResponse."E-Mail Address" := Member."E-Mail Address";

                TempMemberInfoResponse."User Logon ID" := MembershipRole."User Logon ID";
                TempMemberInfoResponse."External Member No" := Member."External Member No.";
                TempMemberInfoResponse."Member Entry No" := Member."Entry No.";
                TempMemberInfoResponse.Insert();

            until ((Member.Next() = 0) OR (TempMemberInfoResponse.Count() >= TempMemberInfoRequest.Quantity));
        end;

        if (TempMemberInfoResponse.Count() = 0) then
            AddErrorResponse(NOT_FOUND);

    end;

    procedure AddErrorResponse(ErrorMessage: Text)
    begin
        ErrorDescription := ErrorMessage;
        Status := '0';
    end;

}