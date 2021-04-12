page 6150719 "NPR POS Menu Filter List"
{
    Caption = 'POS Menu Filter List';
    CardPageID = "NPR POS Menu Filter";
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "NPR POS Menu Filter";
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Object Type"; Rec."Object Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Object Type field';
                }
                field("Object Id"; Rec."Object Id")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Object Id field';
                }
                field("Filter Code"; Rec."Filter Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Filter Code field';
                }
                field("Object Name"; Rec."Object Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Object Name field';
                }
                field(Description; Rec.Description)
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

