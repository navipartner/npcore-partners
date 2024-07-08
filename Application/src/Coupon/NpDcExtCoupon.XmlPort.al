xmlport 6151591 "NPR NpDc Ext. Coupon"
{
    Caption = 'NpDc Coupon';
    DefaultNamespace = 'urn:microsoft-dynamics-nav/xmlports/discount_coupon';
    Encoding = UTF8;
    FormatEvaluate = Xml;
    PreserveWhiteSpace = true;
    UseDefaultNamespace = true;

    schema
    {
        textelement(coupons)
        {
            MaxOccurs = Once;
            tableelement(tempnpdcextcouponbuffer; "NPR NpDc Ext. Coupon Buffer")
            {
                XmlName = 'coupon';
                UseTemporary = true;
                fieldattribute(document_no; TempNpDcExtCouponBuffer."Document No.")
                {
                }
                fieldattribute(reference_no; TempNpDcExtCouponBuffer."Reference No.")
                {
                }
                fieldelement(coupon_type; TempNpDcExtCouponBuffer."Coupon Type")
                {
                    MinOccurs = Zero;
                }
                fieldelement(description; TempNpDcExtCouponBuffer.Description)
                {
                    MinOccurs = Zero;
                }
                fieldelement(starting_date; TempNpDcExtCouponBuffer."Starting Date")
                {
                    MinOccurs = Zero;
                }
                fieldelement(ending_date; TempNpDcExtCouponBuffer."Ending Date")
                {
                    MinOccurs = Zero;
                }
                fieldelement(open; TempNpDcExtCouponBuffer.Open)
                {
                    MinOccurs = Zero;
                }
                fieldelement(remaining_quantity; TempNpDcExtCouponBuffer."Remaining Quantity")
                {
                    MinOccurs = Zero;
                }
                fieldelement(in_use_quantity; TempNpDcExtCouponBuffer."In-use Quantity")
                {
                    MaxOccurs = Once;
                    MinOccurs = Zero;
                }

                trigger OnAfterInitRecord()
                begin
                    LineNo += 1000;
                    TempNpDcExtCouponBuffer."Line No." := LineNo;
                end;
            }
        }
    }

    var
        LineNo: Integer;

    internal procedure GetCoupons(var TempNpDcExtCouponBuffer2: Record "NPR NpDc Ext. Coupon Buffer" temporary)
    begin
        TempNpDcExtCouponBuffer2.Copy(TempNpDcExtCouponBuffer, true);
    end;

    internal procedure SetCoupons(var TempNpDcExtCouponBuffer2: Record "NPR NpDc Ext. Coupon Buffer" temporary)
    begin
        TempNpDcExtCouponBuffer.Copy(TempNpDcExtCouponBuffer2, true);
    end;
}

