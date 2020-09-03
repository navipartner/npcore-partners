xmlport 6060127 "NPR MM Create Membership"
{
    // MM1.00/TSA/20151217  CASE 229684 NaviPartner Member Management Module
    // MM1.05/TSA/20160121  CASE 232494 Added the membership valid from/until date implementation
    // MM1.06/TSA/20160127  CASE 232910 - Enchanced error handling when there is a runtime error processing the request
    // MM1.08/TSA/20160225  CASE 235204 Transport MM1.08 - 16 February 2016
    // MM1.17/TSA/20161209  CASE 259671 Added activationdate as optional field
    // MM1.18/TSA/20170207  CASE Changed to XML format
    // MM1.26/TSA /20180219 CASE 305631 Added element DocumentID
    // MM1.40/TSA /20190827 CASE 360242 Adding support for attributes
    // MM1.41/TSA /20191001 CASE 359703 Added the optional field company name
    // MM1.43/TSA /20200130 CASE 386080 Added preassigned_customer_number

    Caption = 'Create Membership';
    FormatEvaluate = Xml;
    UseDefaultNamespace = true;

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

    procedure AddErrorResponse(ErrorMessage: Text)
    begin

        errordescription := ErrorMessage;
        status := '0';

        tmpMembershipResponse.Insert();
    end;
}

