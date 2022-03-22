page 6014623 "NPR MM Member FactBox"
{
    Extensible = False;
    Caption = 'Member FactBox';
    PageType = CardPart;
    SourceTable = "NPR MM Member";
    UsageCategory = None;
    Editable = false;

    layout
    {
        area(Content)
        {
            group(GroupOne)
            {
                Caption = 'General';
                field("External Member No."; Rec."External Member No.")
                {
                    ToolTip = 'Specifies the value of the External Member No. field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Display Name"; Rec."Display Name")
                {
                    ToolTip = 'Specifies the value of the Display Name field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
            }
            group(groupTwo)
            {
                Caption = 'Details';
                field("First Name"; Rec."First Name")
                {
                    ToolTip = 'Specifies the value of the First Name field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Middle Name"; Rec."Middle Name")
                {
                    ToolTip = 'Specifies the value of the Middle Name field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Last Name"; Rec."Last Name")
                {
                    ToolTip = 'Specifies the value of the Last Name field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field(Address; Rec.Address)
                {
                    ToolTip = 'Specifies the value of the Address field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Post Code Code"; Rec."Post Code Code")
                {
                    ToolTip = 'Specifies the value of the ZIP Code field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field(City; Rec.City)
                {
                    ToolTip = 'Specifies the value of the City field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field(Country; Rec.Country)
                {
                    ToolTip = 'Specifies the value of the Country field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Country Code"; Rec."Country Code")
                {
                    ToolTip = 'Specifies the value of the Country Code field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }

                field(Birthday; Rec.Birthday)
                {
                    ToolTip = 'Specifies the value of the Birthday field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field(Gender; Rec.Gender)
                {
                    ToolTip = 'Specifies the value of the Gender field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Social Security No."; Rec."Social Security No.")
                {
                    ToolTip = 'Specifies the value of the Social Security No. field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
            }
            Group(GroupThree)
            {
                Caption = 'Communication';
                field("E-Mail News Letter"; Rec."E-Mail News Letter")
                {
                    ToolTip = 'Specifies the value of the E-Mail News Letter field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("E-Mail Address"; Rec."E-Mail Address")
                {
                    ToolTip = 'Specifies the value of the E-Mail Address field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Notification Method"; Rec."Notification Method")
                {
                    ToolTip = 'Specifies the value of the Notification Method field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Phone No."; Rec."Phone No.")
                {
                    ToolTip = 'Specifies the value of the Phone No. field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }

                field("Store Code"; Rec."Store Code")
                {
                    ToolTip = 'Specifies the value of the Store Code field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }

                group(groupFour)
                {
                    Caption = 'System';
                    field(Blocked; Rec.Blocked)
                    {
                        ToolTip = 'Specifies the value of the Blocked field';
                        ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    }
                    field("Block Reason"; Rec."Block Reason")
                    {
                        ToolTip = 'Specifies the value of the Block Reason field';
                        ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    }
                    field("Blocked At"; Rec."Blocked At")
                    {
                        ToolTip = 'Specifies the value of the Blocked At field';
                        ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    }
                    field("Blocked By"; Rec."Blocked By")
                    {
                        ToolTip = 'Specifies the value of the Blocked By field';
                        ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    }
                    field(SystemCreatedAt; Rec.SystemCreatedAt)
                    {
                        ToolTip = 'Specifies the value of the SystemCreatedAt field';
                        ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    }
                    field(SystemModifiedAt; Rec.SystemModifiedAt)
                    {
                        ToolTip = 'Specifies the value of the SystemModifiedAt field';
                        ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    }
                }
            }
        }
    }
}
