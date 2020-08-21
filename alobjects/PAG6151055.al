page 6151055 "Distribution Group List"
{
    // NPR5.38.01/JKL /20180126  CASE 289017 Object created - Replenishment Module

    Caption = 'Distribution Groups';
    CardPageID = "Distribution Group";
    PageType = List;
    SourceTable = "Distribution Group";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Code)
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field(Type; Type)
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Distribution Setup")
            {
                Caption = 'Distribution Setup';
                Image = SetupList;
                Promoted = true;
                RunObject = Page "Distribution Setup";
                RunPageLink = "Distribution Group" = FIELD(Code);
            }
            action("Distribution Group Members")
            {
                Caption = 'Distribution Group Members';
                Image = Group;
                Promoted = true;
                RunObject = Page "Distribution Group Member List";
                RunPageLink = "Distribution Group" = FIELD(Code);
            }
        }
    }
}

