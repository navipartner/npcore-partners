xmlport 6060127 "NPR MM Create Membership"
{

    Caption = 'Create Membership';
    FormatEvaluate = Xml;
    UseDefaultNamespace = true;
    Encoding = UTF8;
    schema
    {
        textelement(memberships)
        {
            textelement(createmembership)
            {
                MaxOccurs = Once;
                tableelement(tmpmemberinfocapture; "NPR MM Member Info Capture")
                {
                    MaxOccurs = Once;
                    MinOccurs = Zero;
                    XmlName = 'request';
                    UseTemporary = true;
                    fieldelement(membershipsalesitem; tmpMemberInfoCapture."Item No.")
                    {
                    }
                    fieldelement(activationdate; tmpMemberInfoCapture."Document Date")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(companyname; tmpMemberInfoCapture."Company Name")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(preassigned_customer_number; tmpMemberInfoCapture."Customer No.")
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
                }
                tableelement(tmpmembershipresponse; "NPR MM Membership")
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
                    textelement(membership)
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                        fieldelement(communitycode; tmpMembershipResponse."Community Code")
                        {
                        }
                        fieldelement(membershipcode; tmpMembershipResponse."Membership Code")
                        {
                        }
                        fieldelement(membershipnumber; tmpMembershipResponse."External Membership No.")
                        {
                        }
                        fieldelement(customer_number; tmpMembershipResponse."Customer No.")
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
                        fieldelement(documentid; tmpMembershipResponse."Document ID")
                        {
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
        Caption = 'MM Create Membership';

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

        tmpMembershipResponse.DeleteAll();
    end;

    procedure AddResponse(MembershipEntryNo: Integer)
    var
        Membership: Record "NPR MM Membership";
    begin

        errordescription := '';
        status := '1';

        Membership.Get(MembershipEntryNo);

        tmpMembershipResponse.TransferFields(Membership);
        tmpMembershipResponse.Insert();
    end;

    procedure GetResponse(var MembershipEntryNo: Integer; var ResponseMessage: Text): Boolean
    begin
        tmpmembershipresponse.FindFirst();
        MembershipEntryNo := tmpmembershipresponse."Entry No.";
        ResponseMessage := errordescription;
        exit(status = '1');
    end;

    procedure AddErrorResponse(ErrorMessage: Text)
    begin

        errordescription := ErrorMessage;
        status := '0';

        tmpMembershipResponse.Insert();
    end;
}

