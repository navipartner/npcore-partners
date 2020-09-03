xmlport 6060128 "NPR MM Add Member"
{
    // MM1.00/TSA/20151217  CASE 229684 - NaviPartner Member Management Module
    // MM1.03/TSA/20160104  CASE 230647 - Added NewsLetter CRM option
    // MM1.06/TSA/20160127  CASE 232910 - Enchanced error handling when there is a runtime error processing the request
    // MM1.18/TSA/20170309  CASE 265562 - Transport MM1.18 - 8 March 2017
    // MM1.21/TSA/20170719 CASE 284560 - Added optional field membercardnumber
    // MM1.22/TSA /20170911 CASE 284560 - Added is_temporary option to create temp cards and control their usage
    // MM1.22/TSA /20170911 CASE 284560 - Added attribute is_temporary to Member Card Number
    // MM1.24/TSA /20171031 CASE 276832 - Added optional element guardianmembernumber
    // MM1.24/TSA /20171031 CASE 276832 - Refactored membercard section to elements instead of attributes
    // MM1.29/TSA /20180516 CASE 313795 - Added GDPR Approval status
    // MM1.40/TSA /20190827 CASE 360242 - Added Attributes
    // MM1.42/TSA /20191205 CASE 381222 - Added notification method
    // MM1.43/TSA /20200130 CASE 386080 - Added preassigned_contact_number

    Caption = 'Add Member';
    FormatEvaluate = Xml;
    UseDefaultNamespace = true;

    schema
    {
        textelement(members)
        {
            MaxOccurs = Once;
            textelement(addmember)
            {
                tableelement(tmpmemberinfocapture; "NPR MM Member Info Capture")
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
        OutStr: OutStream;
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

        MemberCard.SetFilter("Member Entry No.", '=%1', MemberEntryNo);
        MemberCard.SetFilter(Blocked, '=%1', false);
        if (MemberCard.FindFirst()) then begin
            tmpMemberCard.TransferFields(MemberCard, true);
            tmpMemberCard.Insert();
        end;
    end;

    procedure AddErrorResponse(ErrorMessage: Text)
    begin

        errordescription := ErrorMessage;
        status := '0';

        tmpMember.Insert();
    end;
}

