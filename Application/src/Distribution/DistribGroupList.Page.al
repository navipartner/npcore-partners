page 6151055 "NPR Distrib. Group List"
{
    // NPR5.38.01/JKL /20180126  CASE 289017 Object created - Replenishment Module

    Caption = 'Distribution Groups';
    CardPageID = "NPR Distrib. Group";
    PageType = List;
    SourceTable = "NPR Distrib. Group";
    UsageCategory = Lists;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field(Type; Type)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Type field';
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
                RunObject = Page "NPR Distribution Setup";
                RunPageLink = "Distribution Group" = FIELD(Code);
                ApplicationArea = All;
                ToolTip = 'Executes the Distribution Setup action';
            }
            action("Distribution Group Members")
            {
                Caption = 'Distribution Group Members';
                Image = Group;
                Promoted = true;
                RunObject = Page "NPR Distrib. Group Member List";
                RunPageLink = "Distribution Group" = FIELD(Code);
                ApplicationArea = All;
                ToolTip = 'Executes the Distribution Group Members action';
            }
        }
    }
}

