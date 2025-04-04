xmlport 6151189 "NPR MM Loyalty Delete Coupont"
{
    Caption = 'Loyalty Delete Coupon';
    FormatEvaluate = Xml;
    UseDefaultNamespace = true;
    Encoding = UTF8;
    schema
    {
        textelement(loyalty)
        {
            MaxOccurs = Once;
            textelement(deletecoupon)
            {
                MaxOccurs = Once;
                tableelement(tmpmemberinfocapture; "NPR MM Member Info Capture")
                {
                    MaxOccurs = Once;
                    XmlName = 'request';
                    UseTemporary = true;
                    textelement(ExternalMembershipNumber)
                    {
                        MinOccurs = Once;
                        MaxOccurs = Once;
                        XmlName = 'membershipnumber';
                    }

                    textelement(CouponReference)
                    {
                        MinOccurs = Once;
                        MaxOccurs = Once;
                        XmlName = 'couponreference';
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
                }
            }
        }
    }

    internal procedure GetRequest(var ExternalMembershipNumberOut: Code[20]; var CouponReferenceOut: Text[30]);
    begin
        ExternalMembershipNumberOut := ExternalMembershipNumber;
        CouponReferenceOut := CouponReference;
    end;

    internal procedure ClearResponse();
    begin
        tmpMembershipResponse.DeleteALL();
    end;

    internal procedure AddResponse(ResponseMessageIn: Text);
    begin
        responsemessage := ResponseMessageIn;
        responsecode := 'OK';
        tmpMemberInfoCapture.FindFirst();
        if (tmpMembershipResponse.Insert()) then;
    end;

    internal procedure AddErrorResponse(ErrorMessage: Text);
    begin
        responsemessage := ErrorMessage;
        responsecode := 'ERROR';
        if (tmpMembershipResponse.Insert()) then;
    end;

}