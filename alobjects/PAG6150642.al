page 6150642 "POS Info List"
{
    // NPR5.26/OSFI/20160810 CASE 246167 Object Created
    // NPR5.51/ALPO/20190826 CASE 364558 Define inheritable pos info codes (will be copied from Sales POS header to new lines)

    Caption = 'POS Info List';
    CardPageID = "POS Info Card";
    Editable = false;
    PageType = List;
    SourceTable = "POS Info";
    UsageCategory = Tasks;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                Caption = 'Group';
                field("Code"; Code)
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field(Message; Message)
                {
                    ApplicationArea = All;
                }
                field(Type; Type)
                {
                    ApplicationArea = All;
                }
                field("Input Type"; "Input Type")
                {
                    ApplicationArea = All;
                }
                field("Input Mandatory"; "Input Mandatory")
                {
                    ApplicationArea = All;
                }
                field("Copy from Header"; "Copy from Header")
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

