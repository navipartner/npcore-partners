xmlport 6151185 "NPR MM AddReplaceCard"
{
    Caption = 'Add Replace Card';
    FormatEvaluate = Xml;
    UseDefaultNamespace = true;
    Encoding = UTF8;
    schema
    {
        textelement(Members)
        {
            XmlName = 'members';
            MaxOccurs = Once;
            textelement(AddReplaceCard)
            {
                XmlName = 'addreplacecard';
                MaxOccurs = Once;

                tableelement(TmpMemberInfoRequest; "NPR MM Member Info Capture")
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
                    textelement(AddCard)
                    {
                        XmlName = 'add_card';
                        MaxOccurs = Once;
                        MinOccurs = Zero;

                        fieldattribute(MembershipNumber; TmpMemberInfoRequest."External Membership No.")
                        {
                            XmlName = 'membershipnumber';
                            Occurrence = Required;
                        }
                        fieldattribute(MemberNumber; TmpMemberInfoRequest."External Member No")
                        {
                            XmlName = 'membernumber';
                            Occurrence = Required;
                        }
                        fieldattribute(NewCardNumber; TmpMemberInfoRequest."External Card No.")
                        {
                            XmlName = 'new_cardnumber';
                            Occurrence = Optional;
                        }
                    }
                    textelement(ReplaceCard)
                    {
                        XmlName = 'replace_card';
                        MaxOccurs = Once;
                        MinOccurs = Zero;

                        fieldattribute(OldCardNumber; TmpMemberInfoRequest."Replace External Card No.")
                        {
                            XmlName = 'old_cardnumber';
                            Occurrence = Required;
                        }

                        fieldattribute(NewCardNumber; TmpMemberInfoRequest."External Card No.")
                        {
                            XmlName = 'new_cardnumber';
                            Occurrence = Optional;
                        }
                    }
                }

                textelement(Response)
                {
                    XmlName = 'response';
                    MinOccurs = Zero;
                    MaxOccurs = Once;
                    textattribute(NstServiceInstanceIdOut)
                    {
                        XmlName = 'cache_instance_id';
                        Occurrence = Optional;
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
                    tableelement(TmpMemberInfoResponse; "NPR MM Member Info Capture")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                        XmlName = 'member';
                        UseTemporary = true;

                        fieldelement(MembernNumber; TmpMemberInfoResponse."External Member No")
                        {
                            XmlName = 'membernumber';
                        }
                        fieldelement(FirstName; TmpMemberInfoResponse."First Name")
                        {
                            XmlName = 'firstname';
                        }
                        fieldelement(MiddleName; TmpMemberInfoResponse."Middle Name")
                        {
                            XmlName = 'middlename';
                        }
                        fieldelement(LastName; TmpMemberInfoResponse."Last Name")
                        {
                            XmlName = 'lastname';
                        }

                        textelement(cards)
                        {
                            tableelement(TmpMemberCard; "NPR MM Member Card")
                            {
                                MaxOccurs = Once;
                                MinOccurs = Zero;
                                XmlName = 'card';
                                UseTemporary = true;

                                fieldelement(CardNumber; TmpMemberCard."External Card No.")
                                {
                                    XmlName = 'cardnumber';
                                }
                                fieldelement(CardSuffix; TmpMemberCard."External Card No. Last 4")
                                {
                                    XmlName = 'cardsuffix';
                                }
                                fieldelement(ValidUntil; TmpMemberCard."Valid Until")
                                {
                                    XmlName = 'validuntil';
                                }
                                fieldelement(IsTemporaryCard; TmpMemberCard."Card Is Temporary")
                                {
                                    XmlName = 'istemporary';
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    var
        NOT_FOUND: Label 'Filter combination removed all results.', Locked = true;

    internal procedure ClearResponse();
    begin
        TmpMemberInfoResponse.DeleteAll();
    end;

    internal procedure AddResponse(MembershipEntryNo: Integer; MemberEntryNo: Integer; MemberCardEntryNo: Integer);
    var
        Membership: Record "NPR MM Membership";
        Member: Record "NPR MM Member";
        MemberCard: Record "NPR MM Member Card";
    begin

        AddErrorResponse(NOT_FOUND);

        if (MembershipEntryNo <= 0) then
            exit;

        ErrorDescription := '';
        Status := 'OK';

        Membership.Get(MembershipEntryNo);
        Member.Get(MemberEntryNo);
        MemberCard.Get(MemberCardEntryNo);

        TmpMemberInfoResponse.TransferFields(Member, true);
        TmpMemberInfoResponse."External Membership No." := Membership."External Membership No.";
        TmpMemberInfoResponse."External Member No" := Member."External Member No.";
        TmpMemberInfoResponse."Member Entry No" := MemberEntryNo;
        TmpMemberInfoResponse."Membership Entry No." := MembershipEntryNo;

        TmpMemberCard.TransferFields(MemberCard, true);
        TmpMemberCard.Insert();

        if (not Member.Blocked) then
            if (TmpMemberInfoResponse.Insert()) then;

        if (TmpMemberInfoResponse.Count() = 0) then begin
            AddErrorResponse(NOT_FOUND);
            if (TmpMemberCard.IsTemporary()) then
                TmpMemberCard.DeleteAll();
        end;
    end;

    internal procedure GetResponse(var MemberCardEntryNo: Integer; var ResponseMessage: Text): Boolean
    begin
        if (TmpMemberCard.FindFirst()) then
            MemberCardEntryNo := TmpMemberCard."Entry No.";
        ResponseMessage := ErrorDescription;
        exit(Status = 'OK');
    end;

    internal procedure AddErrorResponse(ErrorMessage: Text);
    begin
        ErrorDescription := ErrorMessage;
        Status := 'ERROR';
    end;


}