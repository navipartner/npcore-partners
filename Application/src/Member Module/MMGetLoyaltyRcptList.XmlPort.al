xmlport 6060149 "NPR MM Get Loyalty Rcpt. List"
{

    Caption = 'Get Loyalty Receipt List';
    FormatEvaluate = Xml;
    UseDefaultNamespace = true;
    Encoding = UTF8;
    schema
    {
        textelement(loyalty)
        {
            MaxOccurs = Once;
            textelement(getreceiptlist)
            {
                MaxOccurs = Once;
                tableelement(tmpmemberinfocapture; "NPR MM Member Info Capture")
                {
                    MaxOccurs = Once;
                    XmlName = 'request';
                    UseTemporary = true;
                    fieldelement(membershipnumber; tmpMemberInfoCapture."External Membership No.")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(cardnumber; tmpMemberInfoCapture."External Card No.")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(customernumber; tmpMemberInfoCapture."Document No.")
                    {
                        MinOccurs = Zero;
                    }

                    trigger OnBeforeInsertRecord()
                    begin

                        tmpMemberInfoCapture."Document Date" := Today();
                    end;
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
                        textelement(responsecode)
                        {
                            MaxOccurs = Once;
                        }
                        textelement(responsemessage)
                        {
                            MaxOccurs = Once;
                        }
                    }
                    textelement(membership)
                    {
                        MaxOccurs = Once;
                        fieldelement(communitycode; tmpMembershipResponse."Community Code")
                        {
                        }
                        fieldelement(membershipcode; tmpMembershipResponse."Membership Code")
                        {
                        }
                        fieldelement(membershipnumber; tmpMembershipResponse."External Membership No.")
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
                        textelement(accumulated)
                        {
                            MaxOccurs = Once;
                            textattribute(untildate)
                            {

                                trigger OnBeforePassVariable()
                                begin

                                    untildate := Format(CalcDate('<-1D>', tmpMemberInfoCapture."Document Date"), 0, 9);
                                end;
                            }
                            textelement(awarded)
                            {
                                MaxOccurs = Once;
                                fieldelement(sales; tmpMembershipResponse."Awarded Points (Sale)")
                                {
                                }
                                fieldelement(refund; tmpMembershipResponse."Awarded Points (Refund)")
                                {
                                }
                            }
                            textelement(redeemed)
                            {
                                MaxOccurs = Once;
                                fieldelement(withdrawl; tmpMembershipResponse."Redeemed Points (Withdrawl)")
                                {
                                }
                                fieldelement(deposit; tmpMembershipResponse."Redeemed Points (Deposit)")
                                {
                                }
                            }
                            fieldelement(expired; tmpMembershipResponse."Expired Points")
                            {
                            }
                            fieldelement(remaining; tmpMembershipResponse."Remaining Points")
                            {
                            }
                        }
                    }
                    textelement(receipts)
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                        tableelement(tmpposentryresponse; "NPR POS Entry")
                        {
                            MinOccurs = Zero;
                            XmlName = 'receipt';
                            UseTemporary = true;
                            fieldattribute(entryno; tmpPosEntryResponse."Entry No.")
                            {
                            }
                            tableelement(posstore; "NPR POS Store")
                            {
                                LinkFields = Code = FIELD("POS Store Code");
                                LinkTable = tmpPosEntryResponse;
                                XmlName = 'storeaddress';
                                fieldattribute(storecode; tmpPosEntryResponse."POS Store Code")
                                {
                                }
                                fieldelement(name; PosStore.Name)
                                {
                                }
                                fieldelement(name2; PosStore."Name 2")
                                {
                                }
                                fieldelement(address; PosStore.Address)
                                {
                                }
                                fieldelement(address2; PosStore."Address 2")
                                {
                                }
                                fieldelement(postcode; PosStore."Post Code")
                                {
                                }
                                fieldelement(city; PosStore.City)
                                {
                                }
                                fieldelement(contact; PosStore.Contact)
                                {
                                }
                                fieldelement(county; PosStore.County)
                                {
                                }
                                fieldelement(country; PosStore."Country/Region Code")
                                {
                                }
                                fieldelement(vatregistrationno; PosStore."VAT Registration No.")
                                {
                                }
                                fieldelement(registrationno; PosStore."Registration No.")
                                {
                                }
                            }
                            fieldelement(posunit; tmpPosEntryResponse."POS Unit No.")
                            {
                            }
                            fieldelement(receiptnumber; tmpPosEntryResponse."Document No.")
                            {
                            }
                            textelement(salestype)
                            {
                                fieldattribute(type; tmpPosEntryResponse."Entry Type")
                                {
                                }

                                trigger OnBeforePassVariable()
                                begin
                                    salestype := Format(tmpPosEntryResponse."Entry Type");
                                end;
                            }
                            fieldelement(date; tmpPosEntryResponse."Entry Date")
                            {
                            }
                            fieldelement(time; tmpPosEntryResponse."Ending Time")
                            {
                            }
                            fieldelement(amountinclvat; tmpPosEntryResponse."Amount Incl. Tax")
                            {
                                textattribute(currencycode)
                                {
                                }
                                fieldattribute(vatamount; tmpPosEntryResponse."Tax Amount")
                                {
                                }
                            }
                        }
                    }

                    trigger OnAfterGetRecord()
                    var
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

        layout
        {
        }

        actions
        {
        }
    }

    var
        MembershipManagement: Codeunit "NPR MM Membership Mgt.";

    procedure GetRequest(var TmpMemberInfoCaptureOut: Record "NPR MM Member Info Capture" temporary)
    begin

        tmpMemberInfoCapture.FindFirst();
        TmpMemberInfoCaptureOut.TransferFields(tmpMemberInfoCapture, true);
        TmpMemberInfoCaptureOut.Insert();
    end;

    procedure ClearResponse()
    begin

        tmpMembershipResponse.DeleteAll();
    end;

    procedure AddResponse(MembershipEntryNo: Integer; ResponseMessageIn: Text)
    var
        Membership: Record "NPR MM Membership";
        POSEntry: Record "NPR POS Entry";
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin

        if (MembershipEntryNo <= 0) then begin
            AddErrorResponse('Invalid membership entry no.');
            exit;
        end;

        if (not Membership.Get(MembershipEntryNo)) then begin
            AddErrorResponse('Invalid membership entry no.');
            exit;
        end;

        responsemessage := '';
        responsecode := 'OK';
        tmpMemberInfoCapture.FindFirst();

        tmpMembershipResponse.TransferFields(Membership, true);
        tmpMembershipResponse.SetFilter("Date Filter", '..%1', tmpMemberInfoCapture."Document Date");
        tmpMembershipResponse.CalcFields("Awarded Points (Sale)", "Awarded Points (Refund)", "Redeemed Points (Withdrawl)", "Redeemed Points (Deposit)", "Expired Points", "Remaining Points");
        if (tmpMembershipResponse.Insert()) then;

        if (Membership."Customer No." <> '') then begin
            POSEntry.SetFilter("Customer No.", '=%1', Membership."Customer No.");
            if (POSEntry.FindSet()) then begin
                repeat
                    tmpPosEntryResponse.TransferFields(POSEntry, true);
                    tmpPosEntryResponse.Insert();
                until (POSEntry.Next() = 0);
            end;
        end;

        GeneralLedgerSetup.Get();
        currencycode := GeneralLedgerSetup."LCY Code";

    end;

    procedure AddErrorResponse(ErrorMessage: Text)
    begin

        responsemessage := ErrorMessage;
        responsecode := 'ERROR';
        if (tmpMembershipResponse.Insert()) then;
    end;
}

