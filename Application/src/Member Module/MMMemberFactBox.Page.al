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
                    ApplicationArea = NPRRetail;
                }
                field("Display Name"; Rec."Display Name")
                {
                    ToolTip = 'Specifies the value of the Display Name field';
                    ApplicationArea = NPRRetail;
                }
            }
            group(groupTwo)
            {
                Caption = 'Details';
                field("First Name"; Rec."First Name")
                {
                    ToolTip = 'Specifies the value of the First Name field';
                    ApplicationArea = NPRRetail;
                }
                field("Middle Name"; Rec."Middle Name")
                {
                    ToolTip = 'Specifies the value of the Middle Name field';
                    ApplicationArea = NPRRetail;
                }
                field("Last Name"; Rec."Last Name")
                {
                    ToolTip = 'Specifies the value of the Last Name field';
                    ApplicationArea = NPRRetail;
                }
                field(Address; Rec.Address)
                {
                    ToolTip = 'Specifies the value of the Address field';
                    ApplicationArea = NPRRetail;
                }
                field("Post Code Code"; Rec."Post Code Code")
                {
                    ToolTip = 'Specifies the value of the ZIP Code field';
                    ApplicationArea = NPRRetail;
                }
                field(City; Rec.City)
                {
                    ToolTip = 'Specifies the value of the City field';
                    ApplicationArea = NPRRetail;
                }
                field(Country; Rec.Country)
                {
                    ToolTip = 'Specifies the value of the Country field';
                    ApplicationArea = NPRRetail;
                }
                field("Country Code"; Rec."Country Code")
                {
                    ToolTip = 'Specifies the value of the Country Code field';
                    ApplicationArea = NPRRetail;
                }

                field(Birthday; Rec.Birthday)
                {
                    ToolTip = 'Specifies the value of the Birthday field';
                    ApplicationArea = NPRRetail;
                }
                field(Gender; Rec.Gender)
                {
                    ToolTip = 'Specifies the value of the Gender field';
                    ApplicationArea = NPRRetail;
                }
                field("Social Security No."; Rec."Social Security No.")
                {
                    ToolTip = 'Specifies the value of the Social Security No. field';
                    ApplicationArea = NPRRetail;
                }
            }
            Group(GroupThree)
            {
                Caption = 'Communication';
                field("E-Mail News Letter"; Rec."E-Mail News Letter")
                {
                    ToolTip = 'Specifies the value of the E-Mail News Letter field';
                    ApplicationArea = NPRRetail;
                }
                field("E-Mail Address"; Rec."E-Mail Address")
                {
                    ToolTip = 'Specifies the value of the E-Mail Address field';
                    ApplicationArea = NPRRetail;
                }
                field("Notification Method"; Rec."Notification Method")
                {
                    ToolTip = 'Specifies the value of the Notification Method field';
                    ApplicationArea = NPRRetail;
                }
                field("Phone No."; Rec."Phone No.")
                {
                    ToolTip = 'Specifies the value of the Phone No. field';
                    ApplicationArea = NPRRetail;
                }

                field("Store Code"; Rec."Store Code")
                {
                    ToolTip = 'Specifies the value of the Store Code field';
                    ApplicationArea = NPRRetail;
                }

                group(groupFour)
                {
                    Caption = 'System';
                    field(Blocked; Rec.Blocked)
                    {
                        ToolTip = 'Specifies the value of the Blocked field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Block Reason"; Rec."Block Reason")
                    {
                        ToolTip = 'Specifies the value of the Block Reason field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Blocked At"; Rec."Blocked At")
                    {
                        ToolTip = 'Specifies the value of the Blocked At field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Blocked By"; Rec."Blocked By")
                    {
                        ToolTip = 'Specifies the value of the Blocked By field';
                        ApplicationArea = NPRRetail;
                    }
                    field(SystemCreatedAt; Rec.SystemCreatedAt)
                    {
                        ToolTip = 'Specifies the value of the SystemCreatedAt field';
                        ApplicationArea = NPRRetail;
                    }
                    field(SystemModifiedAt; Rec.SystemModifiedAt)
                    {
                        ToolTip = 'Specifies the value of the SystemModifiedAt field';
                        ApplicationArea = NPRRetail;
                    }
                }
            }
        }
    }
}
