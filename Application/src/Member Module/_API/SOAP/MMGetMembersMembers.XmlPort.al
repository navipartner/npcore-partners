xmlport 6060130 "NPR MM Get Members. Members"
{

    Caption = 'Get Membership Members';
    FormatEvaluate = Xml;
    UseDefaultNamespace = true;
    Encoding = UTF8;
    schema
    {
        textelement(members)
        {
            textelement(getmembers)
            {
                tableelement(TempMemberInfoRequest; "NPR MM Member Info Capture")
                {
                    MaxOccurs = Once;
                    MinOccurs = Zero;
                    XmlName = 'request';
                    UseTemporary = true;
                    textattribute(NstServiceInstanceIdIn)
                    {
                        XmlName = 'cache_instance_id';
                        Occurrence = Optional;
                    }
                    fieldelement(membershipnumber; TempMemberInfoRequest."External Membership No.")
                    {
                    }
                    fieldelement(membernumber; TempMemberInfoRequest."External Member No")
                    {
                    }
                    fieldelement(cardnumber; TempMemberInfoRequest."External Card No.")
                    {
                    }
                    textelement(IncludeMemberImageXmlText)
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                        XmlName = 'includememberimage';

                        trigger OnAfterAssignVariable()
                        begin
                            if (not Evaluate(_IncludeMemberImageBool, IncludeMemberImageXmlText)) then
                                _IncludeMemberImageBool := false;
                        end;
                    }
                }
                textelement(response)
                {
                    MaxOccurs = Once;
                    MinOccurs = Zero;
                    XmlName = 'response';
                    textattribute(NstServiceInstanceIdOut)
                    {
                        XmlName = 'cache_instance_id';
                        trigger OnBeforePassVariable()
                        begin
                            NstServiceInstanceIdOut := Format(ServiceInstanceId(), 0, 9);
                        end;
                    }
                    textelement(status)
                    {
                        MaxOccurs = Once;
                    }
                    textelement(errordescription)
                    {
                        MaxOccurs = Once;
                    }
                    tableelement(TempMemberInfoResponse; "NPR MM Member Info Capture")
                    {
                        MaxOccurs = Unbounded;
                        MinOccurs = Zero;
                        XmlName = 'member';
                        UseTemporary = true;

                        fieldattribute(contactno; TempMemberInfoResponse."Contact No.")
                        {

                        }
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
                        fieldelement(gender; TempMemberInfoResponse.Gender)
                        {
                        }
                        fieldelement(newsletter; TempMemberInfoResponse."News Letter")
                        {
                        }
                        fieldelement(phoneno; TempMemberInfoResponse."Phone No.")
                        {
                        }
                        fieldelement(email; TempMemberInfoResponse."E-Mail Address")
                        {
                        }
                        fieldelement(storecode; TempMemberInfoResponse."Store Code")
                        {
                        }
                        textelement(base64Image)
                        {
                            XmlName = 'base64Image';

                            trigger OnBeforePassVariable()
                            var
                                MemberMgt: Codeunit "NPR MM MembershipMgtInternal";
                            begin
                                base64Image := '';
                                if (_IncludeMemberImageBool) then
                                    MemberMgt.GetMemberImage(TempMemberInfoResponse."Member Entry No", base64Image);
                            end;
                        }
                        textelement(memberships)
                        {
                            MaxOccurs = Once;

                            tableelement(MemberMembership; "NPR MM Membership Role")
                            {
                                XmlName = 'membership';
                                MinOccurs = Zero;
                                MaxOccurs = Unbounded;

                                fieldelement(MembershipNumber; MemberMembership."External Membership No.")
                                {
                                    XmlName = 'membershipnumber';
                                    textattribute(MemberRoleName)
                                    {
                                        XmlName = 'role';
                                        trigger OnBeforePassVariable()
                                        begin
                                            MemberRoleName := Format(MemberMembership."Member Role");
                                        end;
                                    }

                                    textattribute(GDPR_State)
                                    {
                                        XmlName = 'gdpr_approval';

                                        trigger OnBeforePassVariable()
                                        begin
                                            MemberMembership.CalcFields("GDPR Approval");
                                            GDPR_State := Format(MemberMembership."GDPR Approval");
                                        end;
                                    }
                                }
                                fieldelement(username; MemberMembership."User Logon ID")
                                {
                                    XmlName = 'username';
                                }

                                trigger OnPreXmlItem()
                                begin
                                    MemberMembership.SetFilter("Member Entry No.", '=%1', TempMemberInfoResponse."Member Entry No");
                                    MemberMembership.SetFilter(Blocked, '=%1', false);
                                end;
                            }
                        }
                        textelement(cards)
                        {
                            tableelement(MemberCard; "NPR MM Member Card")
                            {
                                XmlName = 'card';
                                MinOccurs = Zero;
                                MaxOccurs = Unbounded;

                                fieldelement(ExtCardNumberField; MemberCard."External Card No.")
                                {
                                    XmlName = 'cardnumber';
                                    fieldattribute(ExtMembershipNumberCard; MemberCard."External Membership No.")
                                    {
                                        XmlName = 'membershipnumber';
                                    }
                                    fieldattribute(ExpiryDate; MemberCard."Valid Until")
                                    {
                                        XmlName = 'expirydate';
                                    }
                                }

                                trigger OnPreXmlItem()
                                begin
                                    if (TempMemberInfoResponse."Card Entry No." <> 0) then begin
                                        MemberCard.SetFilter("Entry No.", '=%1', TempMemberInfoResponse."Card Entry No.");
                                    end else begin
                                        MemberCard.SetFilter("Member Entry No.", '=%1', TempMemberInfoResponse."Member Entry No");
                                    end;
                                    MemberCard.SetFilter(Blocked, '=%1', false);
                                    MemberCard.SetFilter("Valid Until", '=%1|>%2', 0D, Today());
                                end;
                            }
                        }
                        textelement(approvaltext)
                        {
                            XmlName = 'gdpr_approval';

                            trigger OnBeforePassVariable()
                            var
                                MembershipRole: Record "NPR MM Membership Role";
                            begin
                                MembershipRole.Get(TempMemberInfoResponse."Membership Entry No.", TempMemberInfoResponse."Member Entry No");
                                MembershipRole.CalcFields("GDPR Approval");
                                ApprovalText := Format(MembershipRole."GDPR Approval");
                            end;
                        }
                        textelement(attributes)
                        {
                            MaxOccurs = Once;
                            MinOccurs = Zero;
                            tableelement(TempAttributeValueSet; "NPR Attribute Value Set")
                            {
                                LinkFields = "Attribute Set ID" = field("Member Entry No");
                                LinkTable = TempMemberInfoResponse;
                                MinOccurs = Zero;
                                XmlName = 'attribute';
                                UseTemporary = true;
                                fieldattribute(code; TempAttributeValueSet."Attribute Code")
                                {
                                }
                                fieldattribute(value; TempAttributeValueSet."Text Value")
                                {
                                }
                            }
                        }
                        fieldelement(notificationmethod; TempMemberInfoResponse."Notification Method")
                        {
                        }
                        textelement(RequestFieldUpdate)
                        {
                            XmlName = 'requestfieldupdate';
                            MinOccurs = Zero;
                            MaxOccurs = Once;
                            tableelement(TempRequestMemberUpdate; "NPR MM Request Member Update")
                            {
                                UseTemporary = true;
                                XmlName = 'field';
                                MinOccurs = Zero;
                                MaxOccurs = Unbounded;
                                LinkTable = TempMemberInfoResponse;
                                LinkFields = "Member Entry No." = field("Member Entry No");
                                fieldattribute(EntryNo; TempRequestMemberUpdate."Entry No.")
                                {
                                    XmlName = 'entryno';
                                }
                                fieldattribute(FieldNo; TempRequestMemberUpdate."Field No.")
                                {
                                    XmlName = 'fieldno';
                                }
                                fieldelement(FieldCaption; TempRequestMemberUpdate.Caption)
                                {
                                    XmlName = 'caption';
                                    MinOccurs = Once;
                                    MaxOccurs = Once;
                                }
                                fieldelement(CurrentValue; TempRequestMemberUpdate."Current Value")
                                {
                                    XmlName = 'currentvalue';
                                    MinOccurs = Once;
                                    MaxOccurs = Once;
                                }

                                trigger OnPreXmlItem()
                                begin
                                    TempRequestMemberUpdate.SetFilter("Member Entry No.", '=%1', TempMemberInfoResponse."Member Entry No");
                                end;
                            }

                        }
                        textelement(Wallets)
                        {
                            XmlName = 'wallets';
                            MinOccurs = Zero;
                            MaxOccurs = Once;

                            tableelement(TempWallet; "NPR MM Membership Role")
                            {
                                XmlName = 'wallet';
                                MinOccurs = Zero;
                                MaxOccurs = Unbounded;
                                LinkTable = TempMemberInfoResponse;
                                LinkFields = "Membership Entry No." = field("Membership Entry No."), "Member Entry No." = field("Member Entry No");
                                UseTemporary = true;
                                CalcFields = "Membership Code";

                                fieldattribute(MembershipNo; TempWallet."External Membership No.")
                                {
                                    XmlName = 'membershipnumber';
                                    Occurrence = Required;
                                }
                                textattribute(_available)
                                {
                                    XmlName = 'available';
                                    Occurrence = Required;
                                    trigger OnBeforePassVariable()
                                    var
                                        MembershipSetup: Record "NPR MM Membership Setup";
                                    begin
                                        _available := format(false, 0, 9);
                                        if (MembershipSetup.Get(TempWallet."Membership Code")) then
                                            _available := format(MembershipSetup."Enable NP Pass Integration", 0, 9);
                                    end;
                                }
                                textattribute(_created)
                                {
                                    XmlName = 'created';
                                    Occurrence = Required;
                                    trigger OnBeforePassVariable()
                                    begin
                                        _created := Format((TempWallet."Wallet Pass Id" <> ''), 0, 9);
                                    end;
                                }
                                textattribute(_walletId)
                                {
                                    XmlName = 'id';
                                    Occurrence = Optional;
                                    trigger OnBeforePassVariable()
                                    begin
                                        _walletId := TempWallet."Wallet Pass Id";
                                    end;
                                }
                            }
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
        _IncludeMemberImageBool: Boolean;

    internal procedure ClearResponse()
    begin

        TempMemberInfoResponse.DeleteAll();
    end;

    internal procedure AddResponse(MembershipEntryNo: Integer; MemberExternalNumber: Code[20]; MemberExternalCardNo: Code[100])
    begin

        errordescription := '';
        status := '1';

        if (MembershipEntryNo <= 0) then
            exit;

        TempMemberInfoRequest.Reset();
        TempMemberInfoRequest.FindSet();
        repeat
            // one member info request record for each member matching the requested search conditions
            BuildResultSet(TempMemberInfoRequest."External Membership No.", TempMemberInfoRequest."External Member No", TempMemberInfoRequest."External Card No.");

        until (TempMemberInfoRequest.Next() = 0);

        if (TempMemberInfoResponse.Count() = 0) then
            AddErrorResponse(NOT_FOUND);

    end;

    internal procedure GetResponse(var TmpMemberInfoResponseOut: Record "NPR MM Member Info Capture"; var TmpAttributeValueSetOut: Record "NPR Attribute Value Set"; var ResponseMessage: Text): Boolean
    begin
        TmpMemberInfoResponseOut.Copy(TempMemberInfoResponse, true);
        TmpAttributeValueSetOut.Copy(TempAttributeValueSet, true);
        ResponseMessage := errordescription;

        exit(status = '1');
    end;

    internal procedure AddErrorResponse(ErrorMessage: Text)
    begin

        errordescription := ErrorMessage;
        status := '0';
    end;


    local procedure BuildResultSet(ExtMembershipNo: Code[20]; ExtMemberNo: Code[20]; ExtCardNumber: Text[100])
    var
        Membership: Record "NPR MM Membership";
        MembershipRole: Record "NPR MM Membership Role";
        Member: Record "NPR MM Member";
        MemberCard: Record "NPR MM Member Card";
        NPRAttributeKey: Record "NPR Attribute Key";
        NPRAttributeValueSet: Record "NPR Attribute Value Set";
        RequestMemberUpdate: Record "NPR MM Request Member Update";
        MembershipEvents: Codeunit "NPR MM Membership Events";
    begin

        if (ExtMembershipNo = '') and (ExtMemberNo = '') and (ExtCardNumber = '') then
            exit;

        if (ExtMembershipNo <> '') then begin
            Membership.SetFilter("External Membership No.", '=%1', ExtMembershipNo);
            Membership.SetFilter(Blocked, '=%1', false);
            if (Membership.FindFirst()) then begin
                MembershipRole.SetFilter("Membership Entry No.", '=%1', Membership."Entry No.");
            end else begin
                exit; // An invalid membership will invalidate the result
            end;
        end;

        if (ExtMemberNo <> '') then begin
            Member.SetFilter("External Member No.", '=%1', ExtMemberNo);
            Member.SetFilter(Blocked, '=%1', false);
            if (Member.FindFirst()) then begin
                MembershipRole.SetFilter("Member Entry No.", '=%1', Member."Entry No.");
            end else begin
                exit; // An invalid member will invalidate the result
            end;
        end;

        if (ExtCardNumber <> '') then begin
            MemberCard.SetFilter("External Card No.", '=%1', UpperCase(ExtCardNumber));
            MemberCard.SetFilter(Blocked, '=%1', false);
            if (MemberCard.FindFirst()) then begin
                MembershipRole.SetFilter("Membership Entry No.", '=%1', MemberCard."Membership Entry No.");
                MembershipRole.SetFilter("Member Entry No.", '=%1', MemberCard."Member Entry No.");
            end else begin
                exit; // An invalid card will invalidate the result
            end;
        end;

        if (MembershipRole.FindSet()) then begin
            repeat

                TempMemberInfoResponse.Init();
                Member.Get(MembershipRole."Member Entry No.");
                Membership.Get(MembershipRole."Membership Entry No.");

                TempMemberInfoResponse.TransferFields(Member, true);

                TempMemberInfoResponse."User Logon ID" := MembershipRole."User Logon ID";
                TempMemberInfoResponse."External Membership No." := Membership."External Membership No.";
                TempMemberInfoResponse."External Member No" := Member."External Member No.";
                TempMemberInfoResponse."Member Entry No" := MembershipRole."Member Entry No.";
                TempMemberInfoResponse."Membership Entry No." := MembershipRole."Membership Entry No.";
                TempMemberInfoResponse."Contact No." := MembershipRole."Contact No.";

                if (ExtCardNumber <> '') then
                    TempMemberInfoResponse."Card Entry No." := MemberCard."Entry No.";

                MembershipRole.CalcFields("GDPR Approval");
                case MembershipRole."GDPR Approval" of
                    MembershipRole."GDPR Approval"::ACCEPTED:
                        TempMemberInfoResponse."GDPR Approval" := TempMemberInfoResponse."GDPR Approval"::ACCEPTED;
                    MembershipRole."GDPR Approval"::REJECTED:
                        TempMemberInfoResponse."GDPR Approval" := TempMemberInfoResponse."GDPR Approval"::REJECTED;
                    MembershipRole."GDPR Approval"::PENDING:
                        TempMemberInfoResponse."GDPR Approval" := TempMemberInfoResponse."GDPR Approval"::PENDING;
                    else
                        TempMemberInfoResponse."GDPR Approval" := TempMemberInfoResponse."GDPR Approval"::NA;
                end;

                MembershipEvents.OnGetMembershipMembers_OnBeforeTempMemberInfoResponseInsert(TempMemberInfoResponse);
                TempMemberInfoResponse."Entry No." := TempMemberInfoResponse.Count() + 1;
                TempMemberInfoResponse.Insert();

                // Pre-fill auxillary tables
                NPRAttributeKey.SetFilter("Table ID", '=%1', DATABASE::"NPR MM Member");
                NPRAttributeKey.SetFilter("MDR Code PK", '=%1', Format(Member."Entry No.", 0, '<integer>'));
                if (NPRAttributeKey.FindFirst()) then begin
                    NPRAttributeValueSet.SetFilter("Attribute Set ID", '=%1', NPRAttributeKey."Attribute Set ID");
                    if (NPRAttributeValueSet.FindSet()) then begin
                        repeat
                            TempAttributeValueSet.TransferFields(NPRAttributeValueSet, true);
                            TempAttributeValueSet."Attribute Set ID" := Member."Entry No.";
                            TempAttributeValueSet.Insert();
                        until (NPRAttributeValueSet.Next() = 0);
                    end;
                end;

                RequestMemberUpdate.SetFilter("Member Entry No.", '=%1', Member."Entry No.");
                RequestMemberUpdate.SetFilter(Handled, '=%1', false);
                if (RequestMemberUpdate.FindSet()) then begin
                    repeat
                        TempRequestMemberUpdate.TransferFields(RequestMemberUpdate, true);
                        TempRequestMemberUpdate.Insert();
                    until (RequestMemberUpdate.Next() = 0);
                end;

            until (MembershipRole.Next() = 0);
        end;

    end;

}


