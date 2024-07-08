xmlport 6060131 "NPR MM Update Member"
{

    Caption = 'Update Member';
    FormatEvaluate = Xml;
    UseDefaultNamespace = true;
    Encoding = UTF8;
    schema
    {
        textelement(members)
        {
            MaxOccurs = Once;
            textelement(updatemember)
            {
                tableelement(tmpmemberinfocapture; "NPR MM Member Info Capture")
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
                    fieldelement(membernumber; tmpMemberInfoCapture."Item No.")
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
                    fieldelement(store_code; tmpMemberInfoCapture."Store Code")
                    {
                        MinOccurs = Zero;
                        MaxOccurs = Once;
                        XmlName = 'store_code';
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
                        }
                    }
                    fieldelement(notificationmethod; tmpMemberInfoCapture."Notification Method")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(preferred_language; tmpMemberInfoCapture.PreferredLanguageCode)
                    {
                        MinOccurs = Zero;
                        XmlName = 'preferred_language';
                    }
                }
                tableelement(tmpmember; "NPR MM Member")
                {
                    MaxOccurs = Once;
                    MinOccurs = Zero;
                    XmlName = 'response';
                    UseTemporary = true;
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
                    }
                }
            }
        }
    }

    requestpage
    {
        Caption = 'MM Update Member';

        layout
        {
        }

        actions
        {
        }
    }


    internal procedure ClearResponse()
    begin

        tmpMember.DeleteAll();
    end;

    internal procedure AddResponse(MemberEntryNo: Integer)
    var
        Member: Record "NPR MM Member";
    begin

        errordescription := '';
        status := '1';

        Member.Get(MemberEntryNo);

        tmpMember.TransferFields(Member, true);
        tmpMember.Insert();
    end;

    internal procedure GetResponse(var ResponseMessage: Text): Boolean
    begin
        ResponseMessage := errordescription;
        exit(status = '1');
    end;

    internal procedure AddErrorResponse(ErrorMessage: Text)
    begin

        errordescription := ErrorMessage;
        status := '0';

        tmpMember.Insert();
    end;
}

