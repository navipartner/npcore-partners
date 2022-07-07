xmlport 6060135 "NPR MM Get Members. Chg. Items"
{

    Caption = 'Get Membership Change Items';
    FormatEvaluate = Xml;
    UseDefaultNamespace = true;
    Encoding = UTF8;
    schema
    {
        textelement(membershipchangeitem)
        {
            MaxOccurs = Once;
            textelement(getchangemembershiplist)
            {
                MaxOccurs = Once;
                tableelement(tmpmemberinfocapture; "NPR MM Member Info Capture")
                {
                    MaxOccurs = Once;
                    MinOccurs = Zero;
                    XmlName = 'request';
                    UseTemporary = true;
                    fieldelement(membershipnumber; tmpMemberInfoCapture."External Membership No.")
                    {
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
                    tableelement(tmpmembership; "NPR MM Membership")
                    {
                        MinOccurs = Zero;
                        XmlName = 'membership';
                        UseTemporary = true;
                        fieldelement(membershipnumber; TmpMembership."External Membership No.")
                        {
                        }
                        fieldelement(membershipcode; TmpMembership."Membership Code")
                        {
                        }
                        fieldelement(issued; TmpMembership."Issued Date")
                        {
                        }
                        tableelement(tmpactivemembershipentry; "NPR MM Membership Entry")
                        {
                            XmlName = 'activesubscriptionperiod';
                            UseTemporary = true;
                            fieldelement(periodstart; TmpActiveMembershipEntry."Valid From Date")
                            {
                            }
                            fieldelement(periodend; TmpActiveMembershipEntry."Valid Until Date")
                            {
                            }
                        }
                        textelement(changeitems)
                        {
                            MaxOccurs = Once;
                            MinOccurs = Zero;
                            tableelement(tmpmembershipentry; "NPR MM Membership Entry")
                            {
                                MinOccurs = Zero;
                                XmlName = 'changeitem';
                                UseTemporary = true;

                                fieldattribute(itemno; TmpMembershipEntry."Item No.")
                                {
                                }
                                fieldattribute(type; TmpMembershipEntry.Context)
                                {
                                }
                                fieldattribute(description; TmpMembershipEntry.Description)
                                {
                                }
                                fieldattribute(targetmembershipcode; TmpMembershipEntry."Membership Code")
                                {
                                }
                                fieldattribute(periodstart; TmpMembershipEntry."Valid From Date")
                                {
                                }
                                fieldattribute(periodend; TmpMembershipEntry."Valid Until Date")
                                {
                                }
                                fieldattribute(unitprice; TmpMembershipEntry."Unit Price")
                                {
                                }
                                fieldattribute(amount; TmpMembershipEntry."Amount Incl VAT")
                                {
                                }
                                textattribute(membercardinality)
                                {

                                    trigger OnBeforePassVariable()
                                    var
                                        TargetMembershipSetup: Record "NPR MM Membership Setup";
                                    begin
                                        if (TargetMembershipSetup.Get(TmpMembershipEntry."Membership Code")) then
                                            membercardinality := Format(TargetMembershipSetup."Membership Member Cardinality");
                                    end;
                                }
                                fieldattribute(presentationorder; TmpMembershipEntry."Line No.")
                                {
                                }
                                textelement(translations)
                                {
                                    XmlName = 'translations';
                                    MinOccurs = Zero;
                                    MaxOccurs = Once;

                                    tableelement(ItemTranslation; "Item Translation")
                                    {
                                        XmlName = 'translation';
                                        MinOccurs = Zero;
                                        MaxOccurs = Unbounded;

                                        fieldattribute(LanguageCode; ItemTranslation."Language Code")
                                        {
                                            XmlName = 'languagecode';
                                            Occurrence = Required;
                                        }
                                        fieldattribute(Description; ItemTranslation.Description)
                                        {
                                            XmlName = 'description';
                                            Occurrence = Required;
                                        }

                                        trigger OnPreXmlItem()
                                        begin
                                            ItemTranslation.SetFilter("Item No.", '=%1', TmpMembershipEntry."Item No.");
                                        end;
                                    }
                                }
                            }
                        }
                    }

                    trigger OnAfterGetRecord()
                    begin
                        if (not MembershipSetup.Get(tmpMembershipResponse."Membership Code")) then
                            MembershipSetup.Init();
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
        MembershipSetup: Record "NPR MM Membership Setup";

    internal procedure ClearResponse()
    begin

        tmpMembershipResponse.DeleteAll();
    end;

    internal procedure AddResponse(MembershipEntryNo: Integer)
    var
        Membership: Record "NPR MM Membership";
        MembershipManagement: Codeunit "NPR MM Membership Mgt.";
        MembershipAlterationSetup: Record "NPR MM Members. Alter. Setup";
    begin

        errordescription := '';
        status := '1';

        if (MembershipEntryNo <= 0) then begin
            AddErrorResponse('Invalid Membership Entry No.');
            exit;
        end;
        if (tmpMembershipResponse.Insert()) then;

        Membership.Get(MembershipEntryNo);
        TmpMembership.TransferFields(Membership, true);
        TmpMembership.Insert();

        TmpActiveMembershipEntry.Init();
        MembershipManagement.GetMembershipValidDate(MembershipEntryNo, Today, TmpActiveMembershipEntry."Valid From Date", TmpActiveMembershipEntry."Valid Until Date");
        TmpActiveMembershipEntry."Entry No." := 1;
        TmpActiveMembershipEntry.Insert();

        MembershipAlterationSetup.SetFilter("From Membership Code", '=%1', Membership."Membership Code");

        MembershipAlterationSetup.SetFilter("Not Available Via Web Service", '=%1', false);

        MembershipManagement.GetMembershipChangeOptions(MembershipEntryNo, MembershipAlterationSetup, TmpMembershipEntry);
    end;

    internal procedure AddErrorResponse(ErrorMessage: Text)
    begin

        errordescription := ErrorMessage;
        status := '0';
        if (tmpMembershipResponse.Insert()) then;
    end;
}

