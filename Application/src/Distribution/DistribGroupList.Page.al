page 6151055 "NPR Distrib. Group List"
{
    Extensible = False;
    // NPR5.38.01/JKL /20180126  CASE 289017 Object created - Replenishment Module

    Caption = 'Distribution Groups';
    CardPageID = "NPR Distrib. Group";
    PageType = List;
    SourceTable = "NPR Distrib. Group";
    UsageCategory = Lists;
    ApplicationArea = NPRRetail;


    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {

                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field(Type; Rec.Type)
                {

                    ToolTip = 'Specifies the value of the Type field';
                    ApplicationArea = NPRRetail;
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
                PromotedCategory = Process;
                PromotedOnly = true;
                RunObject = Page "NPR Distribution Setup";
                RunPageLink = "Distribution Group" = FIELD(Code);

                ToolTip = 'Executes the Distribution Setup action';
                ApplicationArea = NPRRetail;
            }
            action("Distribution Group Members")
            {
                Caption = 'Distribution Group Members';
                Image = Group;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                RunObject = Page "NPR Distrib. Group Member List";
                RunPageLink = "Distribution Group" = FIELD(Code);

                ToolTip = 'Executes the Distribution Group Members action';
                ApplicationArea = NPRRetail;
            }
        }
    }
}

