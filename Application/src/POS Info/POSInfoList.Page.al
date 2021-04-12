page 6150642 "NPR POS Info List"
{
    // NPR5.26/OSFI/20160810 CASE 246167 Object Created
    // NPR5.51/ALPO/20190826 CASE 364558 Define inheritable pos info codes (will be copied from Sales POS header to new lines)

    Caption = 'POS Info List';
    CardPageID = "NPR POS Info Card";
    Editable = false;
    PageType = List;
    SourceTable = "NPR POS Info";
    UsageCategory = Tasks;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                Caption = 'Group';
                field("Code"; Rec.Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Message"; Rec.Message)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Message field';
                }
                field(Type; Rec.Type)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Type field';
                }
                field("Input Type"; Rec."Input Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Input Type field';
                }
                field("Input Mandatory"; Rec."Input Mandatory")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Input Mandatory field';
                }
                field("Copy from Header"; Rec."Copy from Header")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Copy from Header field';
                }
            }
        }
    }

    actions
    {
    }
}

