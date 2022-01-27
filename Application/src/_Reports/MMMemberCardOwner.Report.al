report 6060135 "NPR MM Member Card Owner"
{
    #IF NOT BC17 
    Extensible = False; 
    #ENDIF
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/MM Member Card Owner.rdlc';
    Caption = 'Member Card Owner';
    ShowPrintStatus = false;
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = NPRRetail;
    DataAccessIntent = ReadOnly;

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
        SaveValues = true;
    }
}

