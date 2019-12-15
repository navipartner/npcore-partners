xmlport 6060129 "MM Get Membership"
{
    // MM1.00/TSA/20151217  CASE 229684 NaviPartner Member Management Module
    // MM1.06/TSA/20160127  CASE 232910 - Enchanced error handling when there is a runtime error processing the request
    // MM1.08/TSA/20160219  CASE 234298 - Added valid to from contents
    // MM1.14/TSA/20160524  CASE 239052 - Added customernumber as a search parameter
    // MM1.18/TSA/20170207  CASE 265562 - Changed to XML format
    // MM1.18/TSA/20170216  CASE 265729 - Added membercardinality and membercount
    // MM1.22/TSA /20170818 CASE 287080 - Added details to member count attribute named and anonymous
    // MM1.29/TSA /20180502 CASE 306121 - Added membership entry details to output
    // MM1.40/TSA /20190827 CASE 360242 - Added support for Attributes

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
                tableelement(tmpmemberinfocapture;"MM Member Info Capture")
                {
                    MaxOccurs = Once;
                    MinOccurs = Zero;
                    XmlName = 'request';
                    UseTemporary = true;
                    fieldelement(membernumber;tmpMemberInfoCapture."External Member No")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(cardnumber;tmpMemberInfoCapture."External Card No.")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(membershipnumber;tmpMemberInfoCapture."External Membership No.")
                    {
                    }
                    fieldelement(username;tmpMemberInfoCapture."User Logon ID")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(password;tmpMemberInfoCapture."Password SHA1")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(customernumber;tmpMemberInfoCapture."Document No.")
                    {
                        MinOccurs = Zero;
                    }
                }
                tableelement(tmpmembershipresponse;"MM Membership")
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
                        fieldelement(communitycode;tmpMembershipResponse."Community Code")
                        {
                        }
                        fieldelement(membershipcode;tmpMembershipResponse."Membership Code")
                        {
                        }
                        fieldelement(membershipnumber;tmpMembershipResponse."External Membership No.")
                        {
                        }
                        fieldelement(issuedate;tmpMembershipResponse."Issued Date")
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
                        tableelement(tmpmembershipentry;"MM Membership Entry")
                        {
                            MinOccurs = Zero;
                            XmlName = 'membershipperiods';
                            UseTemporary = true;
                            fieldelement(validfromdate;TmpMembershipEntry."Valid From Date")
                            {
                            }
                            fieldelement(validuntildate;TmpMembershipEntry."Valid Until Date")
                            {
                            }
                            fieldelement(createdat;TmpMembershipEntry."Created At")
                            {
                            }
                            fieldelement(context;TmpMembershipEntry.Context)
                            {
                            }
                            fieldelement(blocked;TmpMembershipEntry.Blocked)
                            {
                            }
                            fieldelement(activateonfirstuse;TmpMembershipEntry."Activate On First Use")
                            {
                            }
                            fieldelement(productid;TmpMembershipEntry."Item No.")
                            {
                            }
                            fieldelement(documentid;TmpMembershipEntry."Import Entry Document ID")
                            {
                            }
                        }
                    }

                    trigger OnAfterGetRecord()
                    var
                        MembershipManagement: Codeunit "MM Membership Management";
                        DateValidFromDate: Date;
                        DateValidUntilDate: Date;
                    begin
                        MembershipManagement.GetMembershipValidDate (tmpMembershipResponse."Entry No.", Today, DateValidFromDate, DateValidUntilDate);
                        ValidFromDate := Format (DateValidFromDate,0,9);
                        ValidUntilDate := Format (DateValidUntilDate,0,9);
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

        tmpMembershipResponse.DeleteAll ();
    end;

    procedure AddResponse(MembershipEntryNo: Integer)
    var
        Membership: Record "MM Membership";
        MembershipSetup: Record "MM Membership Setup";
        Member: Record "MM Member";
        MembershipRole: Record "MM Membership Role";
        MembershipEntry: Record "MM Membership Entry";
        NPRAttributeKey: Record "NPR Attribute Key";
        NPRAttributeValueSet: Record "NPR Attribute Value Set";
        MembershipManagement: Codeunit "MM Membership Management";
        AdminMemberCount: Integer;
        NamedMemberCount: Integer;
        AnonMemberCount: Integer;
    begin

        errordescription := '';
        status := '1';

        if (MembershipEntryNo <= 0) then
          exit;

        Membership.Get (MembershipEntryNo);
        tmpMembershipResponse.TransferFields (Membership, true);
        if (tmpMembershipResponse.Insert ()) then ;

        MembershipSetup.Get (Membership."Membership Code");
        MemberCardinality := Format (MembershipSetup."Membership Member Cardinality");

        //-MM1.22 [287080]
        // MembershipRole.SETFILTER ("Membership Entry No.", '=%1', MembershipEntryNo);
        // MembershipRole.SETFILTER (Blocked, '=%1', FALSE);
        // MemberCount := FORMAT (MembershipRole.COUNT ());

        MembershipManagement.GetMemberCount (MembershipEntryNo, AdminMemberCount, NamedMemberCount, AnonMemberCount);
        NamedMemberCountText := Format (AdminMemberCount+NamedMemberCount, 0, 9);
        AnonMemberCountText  := Format (AnonMemberCount, 0, 9);
        TotalMemberCountText := Format (AdminMemberCount+NamedMemberCount+AnonMemberCount, 0, 9);
        //+MM1.22 [287080]

        //-MM1.29 [306121]
        MembershipEntry.SetFilter ("Membership Entry No.", '=%1', MembershipEntryNo);
        if (MembershipEntry.FindSet ()) then begin
          repeat
            TmpMembershipEntry.TransferFields (MembershipEntry, true);
            TmpMembershipEntry.Insert ();
          until (MembershipEntry.Next () = 0);
        end;
        //+MM1.29 [306121]

        //-MM1.40 [360242]
        TmpAttributeValueSet.DeleteAll ();
        NPRAttributeKey.SetFilter ("Table ID", '=%1', DATABASE::"MM Membership");
        NPRAttributeKey.SetFilter ("MDR Code PK", '=%1', Format (MembershipEntryNo, 0, '<integer>'));
        if (NPRAttributeKey.FindFirst ()) then begin
          NPRAttributeValueSet.SetFilter ("Attribute Set ID", '=%1', NPRAttributeKey."Attribute Set ID");
          if (NPRAttributeValueSet.FindSet ()) then begin
            repeat
              TmpAttributeValueSet.TransferFields (NPRAttributeValueSet, true);
              TmpAttributeValueSet.Insert ();
            until (NPRAttributeValueSet.Next () = 0);
          end;
        end;
        //+MM1.40 [360242]
    end;

    procedure AddErrorResponse(ErrorMessage: Text)
    begin

        errordescription := ErrorMessage;
        status := '0';
        if (tmpMembershipResponse.Insert ()) then ;
    end;
}

