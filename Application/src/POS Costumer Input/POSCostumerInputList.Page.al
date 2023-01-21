page 6150775 "NPR POS Costumer Input List"
{
    PageType = List;
    ApplicationArea = NPRRetail;
    UsageCategory = Administration;
    SourceTable = "NPR POS Costumer Input";
    CardPageId = "NPR POS Costumer Input";
    Extensible = false;
    Editable = false;
    Caption = 'Customer Input List';
#IF NOT BC17
    AboutTitle = 'Customer Input List';
    AboutText = 'Shows the list of customer inputs and context they belong too.';
#ENDIF

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(Id; Rec."POS Entry No.")
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'POS Entry No.';
                    ToolTip = 'Specifies the POS Entry that the input relates to.';
                    Editable = false;
#IF NOT BC17
                    AboutTitle = 'POS Entry No.';
                    AboutText = 'Specifies the POS Entry that the input relates to.';
#ENDIF
                }
                field("Date"; Rec."Date & Time")
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Customer Input Date & Time';
                    ToolTip = 'The date and time for collection of input.';
                    Editable = false;
#IF NOT BC17
                    AboutTitle = 'Customer Input Date & Time';
                    AboutText = 'The date and time for collection of input.';
#ENDIF
                }
                field("Context Type"; Rec.Context)
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Customer Input Context';
                    ToolTip = 'Describes the context in which the input was gathered.';
#IF NOT BC17
                    AboutTitle = 'Customer Input Context';
                    AboutText = 'Describes the context in which the input was gathered.';
#ENDIF

                }
                field("Phone Number"; Rec."Phone Number")
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Customer Phone Number';
                    ToolTip = 'The phone number given by the customer';
#IF NOT BC17
                    AboutTitle = 'Customer Phone Number';
                    AboutText = 'The phone number given by the customer';
#ENDIF

                }
            }
        }
    }
}