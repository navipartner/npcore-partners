page 6150719 "NPR POS Menu Filter List"
{
    Caption = 'POS Menu Filter List';
    CardPageID = "NPR POS Menu Filter";
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "NPR POS Menu Filter";
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;


    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Object Type"; Rec."Object Type")
                {

                    ToolTip = 'Specifies the value of the Object Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Object Id"; Rec."Object Id")
                {

                    ToolTip = 'Specifies the value of the Object Id field';
                    ApplicationArea = NPRRetail;
                }
                field("Filter Code"; Rec."Filter Code")
                {

                    ToolTip = 'Specifies the value of the Filter Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Object Name"; Rec."Object Name")
                {

                    ToolTip = 'Specifies the value of the Object Name field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
    }
}

