xmlport 6060140 "MM Confirm AutoRenew Payment"
{
    // 
    // MM1.28/TSA /20180418 CASE 303635 Initial version

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
                tableelement(tmpmemberinfocapture;"MM Member Info Capture")
                {
                    MaxOccurs = Once;
                    MinOccurs = Zero;
                    XmlName = 'request';
                    UseTemporary = true;
                    fieldelement(membershipnumber;tmpMemberInfoCapture."External Membership No.")
                    {
                    }
                    fieldelement(externaldocumentnumber;tmpMemberInfoCapture."Document No.")
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
                            fieldelement(documentid;TmpActiveMembershipEntry."Import Entry Document ID")
                            {
                            }
                            fieldelement(nextrenewaldate;TmpActiveMembershipEntry."Valid Until Date")
                            {
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

    procedure AddResponse(RequestMemberInfoCapture: Record "MM Member Info Capture")
    var
        Member: Record "MM Member";
        Membership: Record "MM Membership";
        MembershipManagement: Codeunit "MM Membership Management";
        MembershipAutoRenew: Codeunit "MM Membership Auto Renew";
        MembershipAlterationSetup: Record "MM Membership Alteration Setup";
        EntryNo: Integer;
        IsValidOption: Boolean;
        StartDate: Date;
        EndDate: Date;
        UnitPrice: Decimal;
        Item: Record Item;
        ResponseMessage: Text;
        MemberInfoCapture: Record "MM Member Info Capture";
        TmpMembershipAutoRenew: Record "MM Membership Auto Renew" temporary;
        InfoEntryNo: Integer;
        MembershipEntry: Record "MM Membership Entry";
    begin

        errordescription := '';
        status := '1';

        if (RequestMemberInfoCapture."Membership Entry No." <= 0) then begin
          AddErrorResponse ('Invalid Membership Entry No.');
          exit;
        end;
        if (tmpMembershipResponse.Insert ()) then ;

        Membership.Get (RequestMemberInfoCapture."Membership Entry No.");
        TmpMembership.TransferFields (Membership, true);
        TmpMembership.Insert ();

        InfoEntryNo := MembershipManagement.CreateAutoRenewMemberInfoRequest (RequestMemberInfoCapture."Membership Entry No.", '', ResponseMessage);
        if (not MemberInfoCapture.Get (InfoEntryNo)) then begin
          AddErrorResponse (ResponseMessage);
          exit;
        end;

        //IF (MemberInfoCapture."Response Status" = MemberInfoCapture."Response Status"::READY)
        MemberInfoCapture."Import Entry Document ID" := RequestMemberInfoCapture."Import Entry Document ID";
        MemberInfoCapture."Document No." := RequestMemberInfoCapture."Document No.";
        if (MemberInfoCapture."Document No." = '') then
          MemberInfoCapture."Document No." := Membership."External Membership No.";

        if (not MembershipManagement.AutoRenewMembership (MemberInfoCapture, true, StartDate, EndDate, UnitPrice)) then begin
          AddErrorResponse (ResponseMessage);
          exit;
        end;

        MembershipEntry.SetFilter ("Membership Entry No.", '=%1', RequestMemberInfoCapture."Membership Entry No.");
        MembershipEntry.FindLast ();
        TmpActiveMembershipEntry.TransferFields (MembershipEntry);
        TmpActiveMembershipEntry."Valid Until Date" := CalcDate ('<+1D>', TmpActiveMembershipEntry."Valid Until Date");
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

