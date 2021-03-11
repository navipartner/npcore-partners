xmlport 6060139 "NPR MM Get AutoRenew Product"
{

    Caption = 'Get AutoRenew Product';
    FormatEvaluate = Xml;
    UseDefaultNamespace = true;
    Encoding = UTF8;
    schema
    {
        textelement(membershipautorenew)
        {
            MaxOccurs = Once;
            textelement(getautorenewproduct)
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
                                fieldattribute(description; TmpMembershipEntry.Description)
                                {
                                }
                                fieldattribute(nextrenewaldate; TmpMembershipEntry."Valid From Date")
                                {
                                }
                                fieldattribute(unitprice; TmpMembershipEntry."Unit Price")
                                {
                                }
                            }
                        }
                    }

                    trigger OnAfterGetRecord()
                    begin

                        if (MembershipSetup.Get(tmpMembershipResponse."Membership Code")) then;
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
        AdmissionSetup: Record "NPR TM Admission";

    procedure ClearResponse()
    begin

        tmpMembershipResponse.DeleteAll();
    end;

    procedure AddResponse(MembershipEntryNo: Integer)
    var
        Member: Record "NPR MM Member";
        Membership: Record "NPR MM Membership";
        MembershipManagement: Codeunit "NPR MM Membership Mgt.";
        EntryNo: Integer;
        IsValidOption: Boolean;
        StartDate: Date;
        EndDate: Date;
        Item: Record Item;
        ResponseMessage: Text;
        MemberInfoCapture: Record "NPR MM Member Info Capture";
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

        TmpActiveMembershipEntry.Init;
        MembershipManagement.GetMembershipValidDate(MembershipEntryNo, Today, TmpActiveMembershipEntry."Valid From Date", TmpActiveMembershipEntry."Valid Until Date");
        TmpActiveMembershipEntry."Entry No." := 1;
        TmpActiveMembershipEntry.Insert();

        if (MemberInfoCapture.Get(MembershipManagement.CreateAutoRenewMemberInfoRequest(MembershipEntryNo, '', ResponseMessage))) then begin
            TmpMembershipEntry."Entry No." := 1;
            TmpMembershipEntry."Item No." := MemberInfoCapture."Item No.";
            TmpMembershipEntry.Description := MemberInfoCapture.Description;
            TmpMembershipEntry."Valid From Date" := MemberInfoCapture."Valid Until";
            TmpMembershipEntry."Unit Price" := MemberInfoCapture."Unit Price";
            TmpMembershipEntry.Insert();
            MemberInfoCapture.Delete();

        end else begin
            AddErrorResponse(ResponseMessage);

        end;
    end;

    procedure AddErrorResponse(ErrorMessage: Text)
    var
        totalTicketCardinality: Integer;
    begin

        errordescription := ErrorMessage;
        status := '0';
        if (tmpMembershipResponse.Insert()) then;
    end;
}

