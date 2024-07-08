page 6150642 "NPR POS Info List"
{
    Extensible = False;
    // NPR5.26/OSFI/20160810 CASE 246167 Object Created
    // NPR5.51/ALPO/20190826 CASE 364558 Define inheritable pos info codes (will be copied from Sales POS header to new lines)

    Caption = 'POS Info List';
    ContextSensitiveHelpPage = 'docs/retail/pos_processes/how-to/pos_info_setup/';
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
                    ToolTip = 'Specifies the code of the POS info';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the description of the POS info';
                    ApplicationArea = NPRRetail;
                }
                field("Message"; Rec.Message)
                {
                    ToolTip = 'Specifies the message of the POS info';
                    ApplicationArea = NPRRetail;
                }
                field(Type; Rec.Type)
                {
                    ToolTip = 'Specifies the type of the POS info';
                    ApplicationArea = NPRRetail;
                }
                field("Input Type"; Rec."Input Type")
                {
                    ToolTip = 'Specifies the input type for the POS info';
                    ApplicationArea = NPRRetail;
                }
                field("Input Mandatory"; Rec."Input Mandatory")
                {
                    ToolTip = 'Specifies whether the input is mandatory for the POS.';
                    ApplicationArea = NPRRetail;
                }
                field("Copy from Header"; Rec."Copy from Header")
                {
                    ToolTip = 'Specifies whether the information from the header should be copied to the POS Info Card.';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
    }
}

