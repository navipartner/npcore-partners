page 6150719 "POS Menu Filter List"
{
    // NPR5.33/ANEN  /20170607 CASE 270854 Object created to support function for filtererd menu buttons in transcendance pos.

    Caption = 'POS Menu Filter List';
    CardPageID = "POS Menu Filter";
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "POS Menu Filter";
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
                }
                field("Object Id"; "Object Id")
                {
                    ApplicationArea = All;
                }
                field("Filter Code"; "Filter Code")
                {
                    ApplicationArea = All;
                }
                field("Object Name"; "Object Name")
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
    }
}

