xmlport 6060136 "NPR MM Anonymous Member"
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
                tableelement(tmpmemberinfocapture; "NPR MM Member Info Capture")
                {
                    MaxOccurs = Once;
                    MinOccurs = Zero;
                    XmlName = 'request';
                    UseTemporary = true;
                    fieldelement(membershipnumber; tmpMemberInfoCapture."Item No.")
                    {
                    }
                    fieldelement(addmembercount; tmpMemberInfoCapture.Quantity)
                    {
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

        tmpMember.DeleteAll();
    end;

    procedure AddResponse()
    begin

        errordescription := '';
        status := '1';

        tmpMember.Insert();
    end;

    procedure AddErrorResponse(ErrorMessage: Text)
    begin

        errordescription := ErrorMessage;
        status := '0';

        tmpMember.Insert();
    end;
}

