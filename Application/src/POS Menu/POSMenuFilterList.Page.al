page 6150719 "NPR POS Menu Filter List"
{
    Caption = 'POS Menu Filter List';
    CardPageID = "NPR POS Menu Filter";
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "NPR POS Menu Filter";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Object Type"; "Object Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Object Type field';
                }
                field("Object Id"; "Object Id")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Object Id field';
                }
                field("Filter Code"; "Filter Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Filter Code field';
                }
                field("Object Name"; "Object Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Object Name field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
            }
        }
    }

    actions
    {
    }
}

