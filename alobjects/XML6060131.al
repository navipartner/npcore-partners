xmlport 6060131 "MM Update Member"
{
    // MM80.1.02/TSA/20151228  CASE 229684 Touch-up and enchancements
    // MM1.03/TSA/20160104  CASE 230647 - Added NewsLetter CRM option
    // MM1.06/TSA/20160127  CASE 232910 - Enchanced error handling when there is a runtime error processing the request
    // MM1.18/NPKNAV/20170309  CASE 265562 Transport MM1.18 - 8 March 2017
    // MM1.24/TSA /20171120 CASE 276832 - Added guardian section
    // MM1.40/TSA /20190827 CASE 360242 - Added Attributes
    // MM1.42/TSA /20191205 CASE 381222 Added notification method

    Caption = 'Update Member';
    FormatEvaluate = Xml;
    UseDefaultNamespace = true;

    schema
    {
        textelement(members)
        {
            MaxOccurs = Once;
            textelement(updatemember)
            {
                tableelement(tmpmemberinfocapture;"MM Member Info Capture")
                {
                    MaxOccurs = Once;
                    MinOccurs = Zero;
                    XmlName = 'request';
                    UseTemporary = true;
                    fieldelement(membernumber;tmpMemberInfoCapture."Item No.")
                    {
                    }
                    fieldelement(firstname;tmpMemberInfoCapture."First Name")
                    {
                    }
                    fieldelement(middlename;tmpMemberInfoCapture."Middle Name")
                    {
                    }
                    fieldelement(lastname;tmpMemberInfoCapture."Last Name")
                    {
                    }
                    fieldelement(address;tmpMemberInfoCapture.Address)
                    {
                    }
                    fieldelement(postcode;tmpMemberInfoCapture."Post Code Code")
                    {
                    }
                    fieldelement(city;tmpMemberInfoCapture.City)
                    {
                    }
                    fieldelement(country;tmpMemberInfoCapture.Country)
                    {
                    }
                    fieldelement(phoneno;tmpMemberInfoCapture."Phone No.")
                    {
                    }
                    fieldelement(email;tmpMemberInfoCapture."E-Mail Address")
                    {
                    }
                    fieldelement(birthday;tmpMemberInfoCapture.Birthday)
                    {
                    }
                    fieldelement(gender;tmpMemberInfoCapture.Gender)
                    {
                    }
                    fieldelement(newsletter;tmpMemberInfoCapture."News Letter")
                    {
                    }
                    textelement(guardian)
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                        fieldelement(membernumber;tmpMemberInfoCapture."Guardian External Member No.")
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
                        tableelement(tmpattributevalueset;"NPR Attribute Value Set")
                        {
                            MinOccurs = Zero;
                            XmlName = 'attribute';
                            UseTemporary = true;
                            fieldattribute(code;TmpAttributeValueSet."Attribute Code")
                            {
                            }
                            fieldattribute(value;TmpAttributeValueSet."Text Value")
                            {
                            }
                        }
                    }
                    fieldelement(notificationmethod;tmpMemberInfoCapture."Notification Method")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                }
                tableelement(tmpmember;"MM Member")
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
                        fieldelement(membernumber;tmpMember."External Member No.")
                        {
                        }
                        fieldelement(email;tmpMember."E-Mail Address")
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

    var
        OutStr: OutStream;
        EntryNo: Integer;

    procedure ClearResponse()
    begin

        tmpMember.DeleteAll ();
    end;

    procedure AddResponse(MemberEntryNo: Integer)
    var
        Member: Record "MM Member";
    begin

        errordescription := '';
        status := '1';

        Member.Get (MemberEntryNo);

        tmpMember.TransferFields (Member, true);
        tmpMember.Insert ();
    end;

    procedure AddErrorResponse(ErrorMessage: Text)
    begin

        errordescription := ErrorMessage;
        status := '0';

        tmpMember.Insert ();
    end;
}

