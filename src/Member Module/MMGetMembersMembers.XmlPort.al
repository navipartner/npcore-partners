xmlport 6060130 "NPR MM Get Members. Members"
{

    Caption = 'Get Membership Members';
    FormatEvaluate = Xml;
    UseDefaultNamespace = true;

    schema
    {
        textelement(members)
        {
            textelement(getmembers)
            {
                tableelement(tmpmemberinforequest; "NPR MM Member Info Capture")
                {
                    MaxOccurs = Once;
                    MinOccurs = Zero;
                    XmlName = 'request';
                    UseTemporary = true;
                    fieldelement(membershipnumber; tmpMemberInfoRequest."External Membership No.")
                    {
                    }
                    fieldelement(membernumber; tmpMemberInfoRequest."External Member No")
                    {
                    }
                    fieldelement(cardnumber; tmpMemberInfoRequest."External Card No.")
                    {
                    }
                }
                textelement(response)
                {
                    MaxOccurs = Once;
                    MinOccurs = Zero;
                    textelement(status)
                    {
                        MaxOccurs = Once;
                    }
                    textelement(errordescription)
                    {
                        MaxOccurs = Once;
                    }
                    tableelement(tmpmemberinforesponse; "NPR MM Member Info Capture")
                    {
                        MaxOccurs = Unbounded;
                        MinOccurs = Zero;
                        XmlName = 'member';
                        UseTemporary = true;
                        textattribute(memberrole)
                        {
                            XmlName = 'role';

                            trigger OnBeforePassVariable()
                            var
                                MembershipRole: Record "NPR MM Membership Role";
                            begin
                                MembershipRole.SetFilter("Membership Entry No.", '=%1', tmpMemberInfoResponse."Membership Entry No.");
                                MembershipRole.SetFilter("Member Entry No.", '=%1', tmpMemberInfoResponse."Member Entry No");
                                if (MembershipRole.FindFirst()) then
                                    MemberRole := Format(MembershipRole."Member Role");
                            end;
                        }
                        fieldelement(membernumber; tmpMemberInfoResponse."External Member No")
                        {
                        }
                        fieldelement(firstname; tmpMemberInfoResponse."First Name")
                        {
                        }
                        fieldelement(middlename; tmpMemberInfoResponse."Middle Name")
                        {
                        }
                        fieldelement(lastname; tmpMemberInfoResponse."Last Name")
                        {
                        }
                        fieldelement(address; tmpMemberInfoResponse.Address)
                        {
                        }
                        fieldelement(postcode; tmpMemberInfoResponse."Post Code Code")
                        {
                        }
                        fieldelement(city; tmpMemberInfoResponse.City)
                        {
                        }
                        fieldelement(country; tmpMemberInfoResponse.Country)
                        {
                        }
                        fieldelement(birthday; tmpMemberInfoResponse.Birthday)
                        {
                        }
                        fieldelement(gender; tmpMemberInfoResponse.Gender)
                        {
                        }
                        fieldelement(newsletter; tmpMemberInfoResponse."News Letter")
                        {
                        }
                        fieldelement(phoneno; tmpMemberInfoResponse."Phone No.")
                        {
                        }
                        fieldelement(email; tmpMemberInfoResponse."E-Mail Address")
                        {
                        }
                        textelement(memberships)
                        {
                            MaxOccurs = Once;
                            textelement(membership)
                            {
                                fieldelement(membershipnumber; tmpMemberInfoResponse."External Membership No.")
                                {
                                }
                                fieldelement(username; tmpMemberInfoResponse."User Logon ID")
                                {
                                }
                            }
                        }
                        textelement(cards)
                        {
                            textelement(card)
                            {
                                fieldelement(cardnumber; tmpMemberInfoResponse."External Card No.")
                                {
                                }
                            }
                        }
                        textelement(approvaltext)
                        {
                            XmlName = 'gdpr_approval';

                            trigger OnBeforePassVariable()
                            var
                                MembershipRole: Record "NPR MM Membership Role";
                            begin
                                MembershipRole.Get(tmpMemberInfoResponse."Membership Entry No.", tmpMemberInfoResponse."Member Entry No");
                                MembershipRole.CalcFields("GDPR Approval");
                                ApprovalText := Format(MembershipRole."GDPR Approval");
                            end;
                        }
                        textelement(attributes)
                        {
                            MaxOccurs = Once;
                            MinOccurs = Zero;
                            tableelement(tmpattributevalueset; "NPR Attribute Value Set")
                            {
                                LinkFields = "Attribute Set ID" = FIELD("Member Entry No");
                                LinkTable = tmpMemberInfoResponse;
                                MinOccurs = Zero;
                                XmlName = 'attribute';
                                UseTemporary = true;
                                fieldattribute(code; TmpAttributeValueSet."Attribute Code")
                                {
                                }
                                fieldattribute(value; TmpAttributeValueSet."Text Value")
                                {
                                }
                            }
                        }
                        fieldelement(notificationmethod; tmpMemberInfoResponse."Notification Method")
                        {
                        }
                    }
                }
            }
        }
    }

    requestpage
    {
        Caption = 'MM Get Membership Members';

        layout
        {
        }

        actions
        {
        }
    }

    var
        NOT_FOUND: Label 'Filter combination removed all results.';

    procedure ClearResponse()
    begin

        tmpMemberInfoResponse.DeleteAll();
    end;

    procedure AddResponse(MembershipEntryNo: Integer; MemberExternalNumber: Code[20]; MemberExternalCardNo: Code[50])
    var
        Membership: Record "NPR MM Membership";
        MembershipRole: Record "NPR MM Membership Role";
        Member: Record "NPR MM Member";
        MemberCard: Record "NPR MM Member Card";
        NPRAttributeKey: Record "NPR Attribute Key";
        NPRAttributeValueSet: Record "NPR Attribute Value Set";
    begin

        errordescription := '';
        status := '1';

        if (MembershipEntryNo <= 0) then
            exit;

        Membership.Get(MembershipEntryNo);

        MembershipRole.SetFilter("Membership Entry No.", '=%1', MembershipEntryNo);
        MembershipRole.SetFilter(Blocked, '=%1', false);

        MembershipRole.SetFilter("Member Role", '<>%1&<>%2', MembershipRole."Member Role"::ANONYMOUS, MembershipRole."Member Role"::GUARDIAN);

        if (MembershipRole.FindSet()) then begin
            repeat
                tmpMemberInfoResponse.Init;
                Member.Get(MembershipRole."Member Entry No.");

                tmpMemberInfoResponse.TransferFields(Member, true);

                MemberCard.SetFilter("Member Entry No.", '=%1', Member."Entry No.");

                //MemberCard.SetFilter ("Valid Until", '>=%1', TODAY);
                MemberCard.SetFilter("Valid Until", '>=%1|=%2', Today, 0D);

                MemberCard.SetFilter(Blocked, '=%1', false);
                if (MemberCard.FindFirst()) then begin
                    tmpMemberInfoResponse."External Card No." := MemberCard."External Card No.";
                    tmpMemberInfoResponse."Valid Until" := MemberCard."Valid Until";
                end;

                tmpMemberInfoResponse."User Logon ID" := MembershipRole."User Logon ID";
                tmpMemberInfoResponse."External Membership No." := Membership."External Membership No.";
                tmpMemberInfoResponse."External Member No" := Member."External Member No.";
                tmpMemberInfoResponse."Member Entry No" := Member."Entry No.";
                tmpMemberInfoResponse."Membership Entry No." := MembershipRole."Membership Entry No.";

                MembershipRole.CalcFields("GDPR Approval");
                case MembershipRole."GDPR Approval" of
                    MembershipRole."GDPR Approval"::ACCEPTED:
                        tmpMemberInfoResponse."GDPR Approval" := tmpMemberInfoResponse."GDPR Approval"::ACCEPTED;
                    MembershipRole."GDPR Approval"::REJECTED:
                        tmpMemberInfoResponse."GDPR Approval" := tmpMemberInfoResponse."GDPR Approval"::REJECTED;
                    MembershipRole."GDPR Approval"::PENDING:
                        tmpMemberInfoResponse."GDPR Approval" := tmpMemberInfoResponse."GDPR Approval"::PENDING;
                    else
                        tmpMemberInfoRequest."GDPR Approval" := tmpMemberInfoRequest."GDPR Approval"::NA;
                end;

                NPRAttributeKey.SetFilter("Table ID", '=%1', DATABASE::"NPR MM Member");
                NPRAttributeKey.SetFilter("MDR Code PK", '=%1', Format(Member."Entry No.", 0, '<integer>'));
                if (NPRAttributeKey.FindFirst()) then begin
                    NPRAttributeValueSet.SetFilter("Attribute Set ID", '=%1', NPRAttributeKey."Attribute Set ID");
                    if (NPRAttributeValueSet.FindSet()) then begin
                        repeat
                            TmpAttributeValueSet.TransferFields(NPRAttributeValueSet, true);
                            TmpAttributeValueSet."Attribute Set ID" := Member."Entry No.";
                            TmpAttributeValueSet.Insert();
                        until (NPRAttributeValueSet.Next() = 0);
                    end;
                end;

                if (not Member.Blocked) then
                    if (tmpMemberInfoResponse.Insert()) then;

                if ((MemberExternalNumber <> '') and (MemberExternalNumber <> Member."External Member No.")) then
                    if (tmpMemberInfoResponse.Delete()) then;

                if ((MemberExternalCardNo <> '') and (MemberExternalCardNo <> tmpMemberInfoResponse."External Card No.")) then
                    if (tmpMemberInfoResponse.Delete()) then;

            until (MembershipRole.Next() = 0);
        end;

        if (tmpMemberInfoResponse.Count() = 0) then
            AddErrorResponse(NOT_FOUND);
    end;

    procedure AddErrorResponse(ErrorMessage: Text)
    begin

        errordescription := ErrorMessage;
        status := '0';
    end;
}

