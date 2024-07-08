query 6060136 "NPR MM Member Card Notific."
{
    Access = Internal;

    Caption = 'MM Member Card Notification';

    elements
    {
        dataitem(MemberCard; "NPR MM Member Card")
        {
            column(External_Card_No; "External Card No.")
            {
            }
            column(Valid_Until; "Valid Until")
            {
            }
            column(Card_Is_Temporary; "Card Is Temporary")
            {
            }
            dataitem(MembershipRoles; "NPR MM Membership Role")
            {
                DataItemLink = "Membership Entry No." = MemberCard."Membership Entry No.", "Member Entry No." = MemberCard."Member Entry No.";
                SqlJoinType = InnerJoin;
                DataItemTableFilter = Blocked = CONST(false);
                dataitem(Membership; "NPR MM Membership")
                {
                    DataItemLink = "Entry No." = MembershipRoles."Membership Entry No.";
                    DataItemTableFilter = Blocked = CONST(false);
                    column(Membership_Code; "Membership Code")
                    {
                    }
                    dataitem(MembershipSetup; "NPR MM Membership Setup")
                    {
                        DataItemLink = Code = Membership."Membership Code";
                        column(Membership_Code_Description; Description)
                        {
                        }
                        dataitem(MembershipEntry; "NPR MM Membership Entry")
                        {
                            DataItemLink = "Membership Entry No." = Membership."Entry No.";
                            column(Valid_From_Date; "Valid From Date")
                            {
                            }
                            column(Valid_Until_Date; "Valid Until Date")
                            {
                            }
                            dataitem(Member; "NPR MM Member")
                            {
                                DataItemLink = "Entry No." = MemberCard."Member Entry No.";
                                SqlJoinType = InnerJoin;
                                DataItemTableFilter = Blocked = CONST(false);
                                column(First_Name; "First Name")
                                {
                                }
                                column(Middle_Name; "Middle Name")
                                {
                                }
                                column(Last_Name; "Last Name")
                                {
                                }
                                column(Display_Name; "Display Name")
                                {
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

