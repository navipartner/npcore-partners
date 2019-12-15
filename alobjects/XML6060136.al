xmlport 6060136 "MM Anonymous Member"
{
    // MM1.22/TSA /20170817 CASE 287080 Initial version

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
                tableelement(tmpmemberinfocapture;"MM Member Info Capture")
                {
                    MaxOccurs = Once;
                    MinOccurs = Zero;
                    XmlName = 'request';
                    UseTemporary = true;
                    fieldelement(membershipnumber;tmpMemberInfoCapture."Item No.")
                    {
                    }
                    fieldelement(addmembercount;tmpMemberInfoCapture.Quantity)
                    {
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

    procedure ClearResponse()
    begin

        tmpMember.DeleteAll ();
    end;

    procedure AddResponse()
    begin

        errordescription := '';
        status := '1';

        tmpMember.Insert ();
    end;

    procedure AddErrorResponse(ErrorMessage: Text)
    begin

        errordescription := ErrorMessage;
        status := '0';

        tmpMember.Insert ();
    end;
}

