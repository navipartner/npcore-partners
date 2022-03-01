tableextension 6014407 "NPR Sales Cr.Memo Header" extends "Sales Cr.Memo Header"
{
    fields
    {
        field(6151405; "NPR External Order No."; Code[20])
        {
            Caption = 'External Order No.';
            Description = 'MAG2.12';
            DataClassification = CustomerContent;
        }

        field(6151420; "NPR Magento Coupon"; Text[20])
        {
            Caption = 'Magento Coupon';
            DataClassification = CustomerContent;
        }
    }
}