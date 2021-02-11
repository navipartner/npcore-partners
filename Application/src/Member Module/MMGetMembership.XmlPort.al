xmlport 6060129 "NPR MM Get Membership"
{

    Caption = 'Get Membership';
    FormatEvaluate = Xml;
    UseDefaultNamespace = true;

    schema
    {
        textelement(memberships)
        {
            MaxOccurs = Once;
            textelement(getmembership)
            {
                MaxOccurs = Once;
                tableelement(tmpmemberinfocapture; "NPR MM Member Info Capture")
                {
                    MaxOccurs = Once;
                    MinOccurs = Zero;
                    XmlName = 'request';
                    UseTemporary = true;
                    fieldelement(membernumber; tmpMemberInfoCapture."External Member No")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(cardnumber; tmpMemberInfoCapture."External Card No.")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(membershipnumber; tmpMemberInfoCapture."External Membership No.")
                    {
                    }
                    fieldelement(username; tmpMemberInfoCapture."User Logon ID")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(password; tmpMemberInfoCapture."Password SHA1")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(customernumber; tmpMemberInfoCapture."Document No.")
                    {
                        MinOccurs = Zero;
                    }
                }
                tableelement(tmpmembershipresponse; "NPR MM Membership")
                {
                    MaxOccurs = Unbounded;
                    MinOccurs = Zero;
                    XmlName = 'response';
                    UseTemporary = true;
                    textelement(status)
                    {
                        MaxOccurs = Once;
                    }
                    textelement(errordescription)
                    {
                        MaxOccurs = Once;
                    }
                    textelement(membership)
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                        fieldelement(communitycode; tmpMembershipResponse."Community Code")
                        {
                            textattribute(communityname)
                            {
                                XmlName = 'name';
                            }
                        }
                        fieldelement(membershipcode; tmpMembershipResponse."Membership Code")
                        {
                            textattribute(membershipname)
                            {
                                XmlName = 'name';
                            }
                        }
                        textelement(loyaltycode)
                        {
                            MaxOccurs = Once;
                            XmlName = 'loyaltyprogram';
                            textattribute(loyaltyname)
                            {
                                XmlName = 'name';
                            }
                        }
                        fieldelement(membershipnumber; tmpMembershipResponse."External Membership No.")
                        {
                        }
                        fieldelement(issuedate; tmpMembershipResponse."Issued Date")
                        {
                        }
                        textelement(validfromdate)
                        {
                            MaxOccurs = Once;
                            XmlName = 'validfromdate';
                        }
                        textelement(validuntildate)
                        {
                            MaxOccurs = Once;
                            XmlName = 'validuntildate';
                        }
                        textelement(membercardinality)
                        {
                            XmlName = 'membercardinality';
                        }
                        textelement(totalmembercounttext)
                        {
                            XmlName = 'membercount';
                            textattribute(namedmembercounttext)
                            {
                                XmlName = 'named';
                            }
                            textattribute(anonmembercounttext)
                            {
                                XmlName = 'anonymous';
                            }
                        }
                        textelement(attributes)
                        {
                            MaxOccurs = Once;
                            MinOccurs = Zero;
                            tableelement(tmpattributevalueset; "NPR Attribute Value Set")
                            {
                                MinOccurs = Zero;
                                XmlName = 'attribute';
                                UseTemporary = true;
                                fieldattribute(code; TmpAttributeValueSet."Attribute Code")
                                {
                                }
                                textattribute(attributename)
                                {
                                    XmlName = 'name';

                                    trigger OnBeforePassVariable()
                                    var
                                        NPRAttribute: Record "NPR Attribute";
                                    begin

                                        AttributeName := '';
                                        if (NPRAttribute.Get(TmpAttributeValueSet."Attribute Code")) then
                                            AttributeName := NPRAttribute.Name;

                                    end;
                                }
                                fieldattribute(value; TmpAttributeValueSet."Text Value")
                                {
                                }
                            }
                        }
                        tableelement(tmpmembershipentry; "NPR MM Membership Entry")
                        {
                            MinOccurs = Zero;
                            XmlName = 'membershipperiods';
                            UseTemporary = true;
                            fieldelement(validfromdate; TmpMembershipEntry."Valid From Date")
                            {
                            }
                            fieldelement(validuntildate; TmpMembershipEntry."Valid Until Date")
                            {
                            }
                            fieldelement(createdat; TmpMembershipEntry."Created At")
                            {
                            }
                            fieldelement(context; TmpMembershipEntry.Context)
                            {
                                textattribute(contextname)
                                {
                                    XmlName = 'name';

                                    trigger OnBeforePassVariable()
                                    begin

                                        case TmpMembershipEntry.Context of
                                            TmpMembershipEntry.Context::NEW:
                                                ContextName := 'New';
                                            TmpMembershipEntry.Context::AUTORENEW:
                                                ContextName := 'Auto-Renew';
                                            TmpMembershipEntry.Context::CANCEL:
                                                ContextName := 'Cancel';
                                            TmpMembershipEntry.Context::EXTEND:
                                                ContextName := 'Extend';
                                            TmpMembershipEntry.Context::FOREIGN:
                                                ContextName := 'Foreign Membership';
                                            TmpMembershipEntry.Context::REGRET:
                                                ContextName := 'Regret';
                                            TmpMembershipEntry.Context::RENEW:
                                                ContextName := 'Renew';
                                            TmpMembershipEntry.Context::UPGRADE:
                                                ContextName := 'Upgrade';
                                        end;

                                    end;
                                }
                            }
                            fieldelement(blocked; TmpMembershipEntry.Blocked)
                            {
                            }
                            fieldelement(activateonfirstuse; TmpMembershipEntry."Activate On First Use")
                            {
                            }
                            fieldelement(productid; TmpMembershipEntry."Item No.")
                            {
                            }
                            fieldelement(documentid; TmpMembershipEntry."Import Entry Document ID")
                            {
                            }
                        }
                    }

                    trigger OnAfterGetRecord()
                    var
                        MembershipManagement: Codeunit "NPR MM Membership Mgt.";
                        DateValidFromDate: Date;
                        DateValidUntilDate: Date;
                    begin
                        MembershipManagement.GetMembershipValidDate(tmpMembershipResponse."Entry No.", Today, DateValidFromDate, DateValidUntilDate);
                        ValidFromDate := Format(DateValidFromDate, 0, 9);
                        ValidUntilDate := Format(DateValidUntilDate, 0, 9);
                    end;
                }
            }
        }
    }

    requestpage
    {
        Caption = 'MM Get Membership';

        layout
        {
        }

        actions
        {
        }
    }

    var
        TotalCount: Integer;

    procedure ClearResponse()
    begin

        tmpMembershipResponse.DeleteAll();
    end;

    procedure AddResponse(MembershipEntryNo: Integer)
    var
        Membership: Record "NPR MM Membership";
        MembershipSetup: Record "NPR MM Membership Setup";
        Member: Record "NPR MM Member";
        MembershipRole: Record "NPR MM Membership Role";
        MembershipEntry: Record "NPR MM Membership Entry";
        NPRAttributeKey: Record "NPR Attribute Key";
        NPRAttributeValueSet: Record "NPR Attribute Value Set";
        MemberCommunity: Record "NPR MM Member Community";
        LoyaltySetup: Record "NPR MM Loyalty Setup";
        MembershipManagement: Codeunit "NPR MM Membership Mgt.";
        AdminMemberCount: Integer;
        NamedMemberCount: Integer;
        AnonMemberCount: Integer;
    begin

        errordescription := '';
        status := '1';

        if (MembershipEntryNo <= 0) then
            exit;

        Membership.Get(MembershipEntryNo);
        tmpMembershipResponse.TransferFields(Membership, true);
        if (tmpMembershipResponse.Insert()) then;

        MembershipSetup.Get(Membership."Membership Code");
        MemberCardinality := Format(MembershipSetup."Membership Member Cardinality");

        MemberCommunity.Get(Membership."Community Code");
        CommunityName := MemberCommunity.Description;
        MembershipName := MembershipSetup.Description;

        if (MemberCommunity."Activate Loyalty Program") then begin
            if (LoyaltySetup.Get(MembershipSetup."Loyalty Code")) then begin
                LoyaltyCode := LoyaltySetup.Code;
                LoyaltyName := LoyaltySetup.Description;
            end;
        end;

        // MembershipRole.SetFilter ("Membership Entry No.", '=%1', MembershipEntryNo);
        // MembershipRole.SetFilter (Blocked, '=%1', FALSE);
        // MemberCount := FORMAT (MembershipRole.COUNT ());

        MembershipManagement.GetMemberCount(MembershipEntryNo, AdminMemberCount, NamedMemberCount, AnonMemberCount);
        NamedMemberCountText := Format(AdminMemberCount + NamedMemberCount, 0, 9);
        AnonMemberCountText := Format(AnonMemberCount, 0, 9);
        TotalMemberCountText := Format(AdminMemberCount + NamedMemberCount + AnonMemberCount, 0, 9);

        MembershipEntry.SetFilter("Membership Entry No.", '=%1', MembershipEntryNo);
        if (MembershipEntry.FindSet()) then begin
            repeat
                TmpMembershipEntry.TransferFields(MembershipEntry, true);
                TmpMembershipEntry.Insert();
            until (MembershipEntry.Next() = 0);
        end;

        TmpAttributeValueSet.DeleteAll();
        NPRAttributeKey.SetFilter("Table ID", '=%1', DATABASE::"NPR MM Membership");
        NPRAttributeKey.SetFilter("MDR Code PK", '=%1', Format(MembershipEntryNo, 0, '<integer>'));
        if (NPRAttributeKey.FindFirst()) then begin
            NPRAttributeValueSet.SetFilter("Attribute Set ID", '=%1', NPRAttributeKey."Attribute Set ID");
            if (NPRAttributeValueSet.FindSet()) then begin
                repeat
                    TmpAttributeValueSet.TransferFields(NPRAttributeValueSet, true);
                    TmpAttributeValueSet.Insert();
                until (NPRAttributeValueSet.Next() = 0);
            end;
        end;

    end;

    procedure GetResponse(var TmpMembershipOut: Record "NPR MM Membership" temporary; var TmpMembershipEntryOut: Record "NPR MM Membership Entry" temporary; var TmpAttributeValueSetOut: Record "NPR Attribute Value Set" temporary; var ResponseMessage: Text): Boolean
    begin
        TmpMembershipOut.Copy(tmpMembershipResponse, true);
        TmpMembershipEntryOut.Copy(TmpMembershipEntry, true);
        TmpAttributeValueSetOut.Copy(TmpAttributeValueSet, true);
        ResponseMessage := errordescription;
        exit(status = '1');
    end;

    procedure AddErrorResponse(ErrorMessage: Text)
    begin

        errordescription := ErrorMessage;
        status := '0';
        if (tmpMembershipResponse.Insert()) then;
    end;
}

