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
    ApplicationArea = NPRRetail;


    layout
    {
        area(content)
        {
            repeater(Group)
            {
                Caption = 'Group';
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
                field("Message"; Rec.Message)
                {

                    ToolTip = 'Specifies the value of the Message field';
                    ApplicationArea = NPRRetail;
                }
                field(Type; Rec.Type)
                {

                    ToolTip = 'Specifies the value of the Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Input Type"; Rec."Input Type")
                {

                    ToolTip = 'Specifies the value of the Input Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Input Mandatory"; Rec."Input Mandatory")
                {

                    ToolTip = 'Specifies the value of the Input Mandatory field';
                    ApplicationArea = NPRRetail;
                }
                field("Copy from Header"; Rec."Copy from Header")
                {

                    ToolTip = 'Specifies the value of the Copy from Header field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
    }
}

