report 6060134 "NPR MM Member Info"
{
    // MM1.25/BHR/20171120 CASE 296024 Report to show member details
    UsageCategory = None;
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/MM Member Info.rdlc';

    Caption = 'Member Info';

    dataset
    {
        dataitem("MM Membership Entry"; "NPR MM Membership Entry")
        {
            RequestFilterFields = "Valid From Date", "Valid Until Date";
            column(ValidFromDate_MMMembershipEntry; "MM Membership Entry"."Valid From Date")
            {
                IncludeCaption = true;
            }
            column(MembershipEntryNo_MMMembershipEntry; "MM Membership Entry"."Membership Entry No.")
            {
                IncludeCaption = true;
            }
            column(ValidUntilDate_MMMembershipEntry; "MM Membership Entry"."Valid Until Date")
            {
                IncludeCaption = true;
            }
            dataitem("MM Membership"; "NPR MM Membership")
            {
                DataItemLink = "Entry No." = FIELD("Membership Entry No.");
                column(IssuedDate_MMMembership; "MM Membership"."Issued Date")
                {
                    IncludeCaption = true;
                }
                column(ExternalMembershipNo_MMMembership; "MM Membership"."External Membership No.")
                {
                    IncludeCaption = true;
                }
                dataitem("MM Membership Role"; "NPR MM Membership Role")
                {
                    DataItemLink = "Membership Entry No." = FIELD("Entry No.");
                    dataitem("MM Member"; "NPR MM Member")
                    {
                        DataItemLink = "Entry No." = FIELD("Member Entry No.");
                        column(ExternalMemberNo_MMMember; "MM Member"."External Member No.")
                        {
                            IncludeCaption = true;
                        }
                        column(DisplayName_MMMember; "MM Member"."Display Name")
                        {
                            IncludeCaption = true;
                        }
                        column(FirstName_MMMember; "MM Member"."First Name")
                        {
                            IncludeCaption = true;
                        }
                        column(LastName_MMMember; "MM Member"."Last Name")
                        {
                            IncludeCaption = true;
                        }
                        column(Birthday_MMMember; "MM Member".Birthday)
                        {
                            IncludeCaption = true;
                        }
                        column(PhoneNo_MMMember; "MM Member"."Phone No.")
                        {
                            IncludeCaption = true;
                        }
                        column(Address_MMMember; "MM Member".Address)
                        {
                            IncludeCaption = true;
                        }
                        column(PostCodeCode_MMMember; "MM Member"."Post Code Code")
                        {
                            IncludeCaption = true;
                        }
                        column(City_MMMember; "MM Member".City)
                        {
                            IncludeCaption = true;
                        }
                        column(CountryCode_MMMember; "MM Member"."Country Code")
                        {
                            IncludeCaption = true;
                        }
                        column(Country_MMMember; "MM Member".Country)
                        {
                            IncludeCaption = true;
                        }
                        column(EMailAddress_MMMember; "MM Member"."E-Mail Address")
                        {
                            IncludeCaption = true;
                        }
                    }
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
        TxtCount = 'Membership Change Count';
    }
}

