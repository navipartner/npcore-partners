xmlport 6060140 "NPR MM Confirm AutoRenew Pay."
{
    // 

    Caption = 'Confirm AutoRenew Payment';
    FormatEvaluate = Xml;
    UseDefaultNamespace = true;

    schema
    {
        textelement(membershipautorenew)
        {
            MaxOccurs = Once;
            textelement(confirmautorenewpayment)
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
                    fieldelement(externaldocumentnumber; tmpMemberInfoCapture."Document No.")
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
                            fieldelement(documentid; TmpActiveMembershipEntry."Import Entry Document ID")
                            {
                            }
                            fieldelement(nextrenewaldate; TmpActiveMembershipEntry."Valid Until Date")
                            {
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

    procedure AddResponse(RequestMemberInfoCapture: Record "NPR MM Member Info Capture")
    var
        Member: Record "NPR MM Member";
        Membership: Record "NPR MM Membership";
        MembershipManagement: Codeunit "NPR MM Membership Mgt.";
        MembershipAutoRenew: Codeunit "NPR MM Membership Auto Renew";
        MembershipAlterationSetup: Record "NPR MM Members. Alter. Setup";
        EntryNo: Integer;
        IsValidOption: Boolean;
        StartDate: Date;
        EndDate: Date;
        UnitPrice: Decimal;
        Item: Record Item;
        ResponseMessage: Text;
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        TmpMembershipAutoRenew: Record "NPR MM Membership Auto Renew" temporary;
        InfoEntryNo: Integer;
        MembershipEntry: Record "NPR MM Membership Entry";
    begin

        errordescription := '';
        status := '1';

        if (RequestMemberInfoCapture."Membership Entry No." <= 0) then begin
            AddErrorResponse('Invalid Membership Entry No.');
            exit;
        end;
        if (tmpMembershipResponse.Insert()) then;

        Membership.Get(RequestMemberInfoCapture."Membership Entry No.");
        TmpMembership.TransferFields(Membership, true);
        TmpMembership.Insert();

        InfoEntryNo := MembershipManagement.CreateAutoRenewMemberInfoRequest(RequestMemberInfoCapture."Membership Entry No.", '', ResponseMessage);
        if (not MemberInfoCapture.Get(InfoEntryNo)) then begin
            AddErrorResponse(ResponseMessage);
            exit;
        end;

        //IF (MemberInfoCapture."Response Status" = MemberInfoCapture."Response Status"::READY)
        MemberInfoCapture."Import Entry Document ID" := RequestMemberInfoCapture."Import Entry Document ID";
        MemberInfoCapture."Document No." := RequestMemberInfoCapture."Document No.";
        if (MemberInfoCapture."Document No." = '') then
            MemberInfoCapture."Document No." := Membership."External Membership No.";

        if (not MembershipManagement.AutoRenewMembership(MemberInfoCapture, true, StartDate, EndDate, UnitPrice)) then begin
            AddErrorResponse(ResponseMessage);
            exit;
        end;

        MembershipEntry.SetFilter("Membership Entry No.", '=%1', RequestMemberInfoCapture."Membership Entry No.");
        MembershipEntry.FindLast();
        TmpActiveMembershipEntry.TransferFields(MembershipEntry);
        TmpActiveMembershipEntry."Valid Until Date" := CalcDate('<+1D>', TmpActiveMembershipEntry."Valid Until Date");
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

