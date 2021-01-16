report 6060135 "NPR MM Member Card Owner"
{
    // MM1.25/NPKNAV/20180122  CASE 299537 Transport MM1.25 - 22 January 2018
    UsageCategory = None;
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/MM Member Card Owner.rdlc';

    Caption = 'Member Card Owner';
    ShowPrintStatus = false;

    dataset
    {
        dataitem("MM Member Card"; "NPR MM Member Card")
        {
            column(CardLast4; "MM Member Card"."External Card No. Last 4")
            {
            }
            column(PinCode; "MM Member Card"."Pin Code")
            {
            }
            column(CardValidUntil; "MM Member Card"."Valid Until")
            {
            }
            dataitem("MM Member"; "NPR MM Member")
            {
                DataItemLink = "Entry No." = FIELD("Member Entry No.");
                column(FirstName; "MM Member"."First Name")
                {
                }
                column(LastName; "MM Member"."Last Name")
                {
                }
                column(DisplayName; "MM Member"."Display Name")
                {
                }
                column(Address; "MM Member".Address)
                {
                }
                column(PostCode; "MM Member"."Post Code Code")
                {
                }
                column(City; "MM Member".City)
                {
                }
                column(CountryCode; "MM Member"."Country Code")
                {
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

    labels
    {
    }
}

