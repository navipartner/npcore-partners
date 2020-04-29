page 6060077 "MM Recurring Payment Setup"
{
    // #334163/JDH /20181109 CASE 334163 Added Caption to Object
    // MM1.36/NPKNAV/20190125  CASE 343948 Transport MM1.36 - 25 January 2019

    Caption = 'Recurring Payment Setup';
    PageType = Card;
    SourceTable = "MM Recurring Payment Setup";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Code";Code)
                {
                }
                field("Payment Service Provider Code";"Payment Service Provider Code")
                {
                }
                field("PSP Recurring Plan ID";"PSP Recurring Plan ID")
                {
                }
                field("Period Alignment";"Period Alignment")
                {
                }
                field("Period Size";"Period Size")
                {
                }
            }
            group(Posting)
            {
                field("Gen. Journal Template Name";"Gen. Journal Template Name")
                {
                }
                field("Document No. Series";"Document No. Series")
                {
                }
                field("Payment Terms Code";"Payment Terms Code")
                {
                }
                field("Revenue Account";"Revenue Account")
                {
                }
            }
        }
    }

    actions
    {
    }
}

