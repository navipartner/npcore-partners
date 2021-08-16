xmlport 6060128 "NPR MM Add Member"
{
    Caption = 'Add Member';
    FormatEvaluate = Xml;
    UseDefaultNamespace = true;
    Encoding = UTF8;

    schema
    {
        textelement(members)
        {
            MaxOccurs = Once;
            textelement(addmember)
            {
                tableelement(tmpMemberInfoCapture; "NPR MM Member Info Capture")
                {
                    MaxOccurs = Once;
                    MinOccurs = Zero;
                    XmlName = 'request';
                    UseTemporary = true;
                    fieldelement(membershipnumber; tmpMemberInfoCapture."Item No.")
                    {
                    }
                    fieldelement(firstname; tmpMemberInfoCapture."First Name")
                    {
                    }
                    fieldelement(middlename; tmpMemberInfoCapture."Middle Name")
                    {
                    }
                    fieldelement(lastname; tmpMemberInfoCapture."Last Name")
                    {
                    }
                    fieldelement(address; tmpMemberInfoCapture.Address)
                    {
                    }
                    fieldelement(postcode; tmpMemberInfoCapture."Post Code Code")
                    {
                    }
                    fieldelement(city; tmpMemberInfoCapture.City)
                    {
                    }
                    fieldelement(country; tmpMemberInfoCapture.Country)
                    {
                    }
                    fieldelement(phoneno; tmpMemberInfoCapture."Phone No.")
                    {
                    }
                    fieldelement(email; tmpMemberInfoCapture."E-Mail Address")
                    {
                    }
                    fieldelement(birthday; tmpMemberInfoCapture.Birthday)
                    {
                    }
                    fieldelement(gender; tmpMemberInfoCapture.Gender)
                    {
                    }
                    fieldelement(newsletter; tmpMemberInfoCapture."News Letter")
                    {
                    }
                    fieldelement(username; tmpMemberInfoCapture."User Logon ID")
                    {
                    }
                    fieldelement(password; tmpMemberInfoCapture."Password SHA1")
                    {
                    }
                    fieldelement(store_code; tmpMemberInfoCapture."Store Code")
                    {
                        MinOccurs = Zero;
                        MaxOccurs = Once;
                        XmlName = 'store_code';
                    }
                    textelement(membercard)
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                        fieldelement(cardnumber; tmpMemberInfoCapture."External Card No.")
                        {
                        }
                        fieldelement(is_permanent; tmpMemberInfoCapture."Temporary Member Card")
                        {
                        }
                        fieldelement(valid_until; tmpMemberInfoCapture."Valid Until")
                        {
                        }
                    }
                    textelement(guardian)
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                        fieldelement(membernumber; tmpMemberInfoCapture."Guardian External Member No.")
                        {
                        }
                        textelement(guardianemail)
                        {
                            XmlName = 'email';
                        }
                    }
                    fieldelement(gdpr_approval; tmpMemberInfoCapture."GDPR Approval")
                    {
                        MinOccurs = Zero;
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
                            fieldattribute(value; TmpAttributeValueSet."Text Value")
                            {
                            }

                            trigger OnBeforeInsertRecord()
                            begin
                                EntryNo += 1;
                                TmpAttributeValueSet."Attribute Set ID" := EntryNo;
                            end;
                        }
                    }
                    fieldelement(notificationmethod; tmpMemberInfoCapture."Notification Method")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(preassigned_contact_number; tmpMemberInfoCapture."Contact No.")
                    {
                        MinOccurs = Zero;
                    }
                }
                tableelement(tmpmember; "NPR MM Member")
                {
                    MaxOccurs = Once;
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
                    textelement(member)
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                        fieldelement(membernumber; tmpMember."External Member No.")
                        {
                        }
                        fieldelement(email; tmpMember."E-Mail Address")
                        {
                        }
                        tableelement(tmpmembercard; "NPR MM Member Card")
                        {
                            MaxOccurs = Once;
                            MinOccurs = Zero;
                            XmlName = 'card';
                            UseTemporary = true;
                            fieldelement(cardnumber; tmpMemberCard."External Card No.")
                            {
                            }
                            fieldelement(expirydate; tmpMemberCard."Valid Until")
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
        Caption = 'MM Add Member';

        layout
        {
        }

        actions
        {
        }
    }

    var
        EntryNo: Integer;

    procedure ClearResponse()
    begin

        tmpMember.DeleteAll();
    end;

    procedure AddResponse(MemberEntryNo: Integer)
    var
        Member: Record "NPR MM Member";
        MemberCard: Record "NPR MM Member Card";
    begin

        errordescription := '';
        status := '1';

        Member.Get(MemberEntryNo);

        tmpMember.TransferFields(Member, true);
        tmpMember.Insert();

        MemberCard.SetCurrentKey("Member Entry No.");
        MemberCard.SetFilter("Member Entry No.", '=%1', MemberEntryNo);
        MemberCard.SetFilter(Blocked, '=%1', false);
        if (MemberCard.FindFirst()) then begin
            tmpMemberCard.TransferFields(MemberCard, true);
            tmpMemberCard.Insert();
        end;
    end;

    procedure GetResponse(var MemberEntryNo: Integer; var ResponseMessage: Text): Boolean
    begin
        tmpMember.FindFirst();
        MemberEntryNo := tmpMember."Entry No.";
        ResponseMessage := errordescription;
        exit(status = '1');
    end;

    procedure AddErrorResponse(ErrorMessage: Text)
    begin

        errordescription := ErrorMessage;
        status := '0';

        tmpMember.Insert();
    end;
}

