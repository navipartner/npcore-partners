xmlport 6060135 "MM Get Membership Change Items"
{
    // MM1.11/TSA/20160428  CASE 239025 Online membership change management
    // MM1.11/TSA/20160502  CASE 239052 Transport MM1.11 - 29 April 2016
    // MM1.14/TSA/20160603  CASE 240871 Transport MM1.13 - 1 June 2016
    // MM1.17/TSA /20161025  CASE 256152 Conform to OMA Guidelines
    // MM1.18/TSA/20170216  CASE 265729 Added membercardinality attribute
    // MM1.23/TSA /20170918 CASE 276869 Added filter on "Not Available Via Web Service"

    Caption = 'Get Membership Change Items';
    FormatEvaluate = Xml;
    UseDefaultNamespace = true;

    schema
    {
        textelement(membershipchangeitem)
        {
            MaxOccurs = Once;
            textelement(getchangemembershiplist)
            {
                MaxOccurs = Once;
                tableelement(tmpmemberinfocapture;"MM Member Info Capture")
                {
                    MaxOccurs = Once;
                    MinOccurs = Zero;
                    XmlName = 'request';
                    UseTemporary = true;
                    fieldelement(membershipnumber;tmpMemberInfoCapture."External Membership No.")
                    {
                    }
                }
                tableelement(tmpmembershipresponse;"MM Membership")
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
                    tableelement(tmpmembership;"MM Membership")
                    {
                        MinOccurs = Zero;
                        XmlName = 'membership';
                        UseTemporary = true;
                        fieldelement(membershipnumber;TmpMembership."External Membership No.")
                        {
                        }
                        fieldelement(membershipcode;TmpMembership."Membership Code")
                        {
                        }
                        fieldelement(issued;TmpMembership."Issued Date")
                        {
                        }
                        tableelement(tmpactivemembershipentry;"MM Membership Entry")
                        {
                            XmlName = 'activesubscriptionperiod';
                            UseTemporary = true;
                            fieldelement(periodstart;TmpActiveMembershipEntry."Valid From Date")
                            {
                            }
                            fieldelement(periodend;TmpActiveMembershipEntry."Valid Until Date")
                            {
                            }
                        }
                        textelement(changeitems)
                        {
                            MaxOccurs = Once;
                            MinOccurs = Zero;
                            tableelement(tmpmembershipentry;"MM Membership Entry")
                            {
                                MinOccurs = Zero;
                                XmlName = 'changeitem';
                                UseTemporary = true;
                                fieldattribute(itemno;TmpMembershipEntry."Item No.")
                                {
                                }
                                fieldattribute(type;TmpMembershipEntry.Context)
                                {
                                }
                                fieldattribute(description;TmpMembershipEntry.Description)
                                {
                                }
                                fieldattribute(periodstart;TmpMembershipEntry."Valid From Date")
                                {
                                }
                                fieldattribute(periodend;TmpMembershipEntry."Valid Until Date")
                                {
                                }
                                fieldattribute(unitprice;TmpMembershipEntry."Unit Price")
                                {
                                }
                                fieldattribute(amount;TmpMembershipEntry."Amount Incl VAT")
                                {
                                }
                                textattribute(membercardinality)
                                {

                                    trigger OnBeforePassVariable()
                                    var
                                        TargetMembershipSetup: Record "MM Membership Setup";
                                    begin
                                        if (TargetMembershipSetup.Get (TmpMembershipEntry."Membership Code")) then
                                          membercardinality := Format (TargetMembershipSetup."Membership Member Cardinality");
                                    end;
                                }
                            }
                        }
                    }

                    trigger OnAfterGetRecord()
                    begin

                        if (MembershipSetup.Get (tmpMembershipResponse."Membership Code")) then ;
                    end;
                }
            }
        }
    }

    requestpage
    {
        Caption = 'MM Get Membership Change Items';

        layout
        {
        }

        actions
        {
        }
    }

    var
        MembershipSetup: Record "MM Membership Setup";
        AdmissionSetup: Record "TM Admission";

    procedure ClearResponse()
    begin

        tmpMembershipResponse.DeleteAll ();
    end;

    procedure AddResponse(MembershipEntryNo: Integer)
    var
        Member: Record "MM Member";
        Membership: Record "MM Membership";
        MembershipManagement: Codeunit "MM Membership Management";
        MembershipAlterationSetup: Record "MM Membership Alteration Setup";
        EntryNo: Integer;
        IsValidOption: Boolean;
        StartDate: Date;
        EndDate: Date;
        Item: Record Item;
    begin

        errordescription := '';
        status := '1';

        if (MembershipEntryNo <= 0) then begin
          AddErrorResponse ('Invalid Membership Entry No.');
          exit;
        end;
        if (tmpMembershipResponse.Insert ()) then ;

        Membership.Get (MembershipEntryNo);
        TmpMembership.TransferFields (Membership, true);
        TmpMembership.Insert ();

        TmpActiveMembershipEntry.Init;
        MembershipManagement.GetMembershipValidDate (MembershipEntryNo, Today, TmpActiveMembershipEntry."Valid From Date", TmpActiveMembershipEntry."Valid Until Date");
        TmpActiveMembershipEntry."Entry No." := 1;
        TmpActiveMembershipEntry.Insert ();

        MembershipAlterationSetup.SetFilter ("From Membership Code", '=%1', Membership."Membership Code");

        //-MM1.23 [276869]
        MembershipAlterationSetup.SetFilter ("Not Available Via Web Service", '=%1', false);
        //+MM1.23 [276869]

        MembershipManagement.GetMembershipChangeOptions (MembershipEntryNo, MembershipAlterationSetup, TmpMembershipEntry);
    end;

    procedure AddErrorResponse(ErrorMessage: Text)
    var
        totalTicketCardinality: Integer;
    begin

        errordescription := ErrorMessage;
        status := '0';
        if (tmpMembershipResponse.Insert ()) then ;
    end;
}

