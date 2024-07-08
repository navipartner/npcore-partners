page 6150717 "NPR POS Menu Filter SubPage"
{
    Extensible = False;
    AutoSplitKey = true;
    Caption = 'Filter Line';
    PageType = ListPart;
    UsageCategory = None;
    SourceTable = "NPR POS Menu Filter Line";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Object Type"; Rec."Object Type")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Object Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Object Id"; Rec."Object Id")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Object Id field';
                    ApplicationArea = NPRRetail;
                }
                field("Filter Code"; Rec."Filter Code")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Filter Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Line No."; Rec."Line No.")
                {

                    ToolTip = 'Specifies the value of the Line No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Object Name"; Rec."Object Name")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Object Name field';
                    ApplicationArea = NPRRetail;
                }
                field("Table No."; Rec."Table No.")
                {

                    ToolTip = 'Specifies the value of the Table No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Table Name"; Rec."Table Name")
                {

                    ToolTip = 'Specifies the value of the Table Name field';
                    ApplicationArea = NPRRetail;
                }
                field("Field No."; Rec."Field No.")
                {

                    ToolTip = 'Specifies the value of the Field No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Field Name"; Rec."Field Name")
                {

                    ToolTip = 'Specifies the value of the Field Name field';
                    ApplicationArea = NPRRetail;
                }
                field("Filter Value"; Rec."Filter Value")
                {

                    ToolTip = 'Specifies the value of the Filter Value field';
                    ApplicationArea = NPRRetail;
                }
                field("Filter Sale POS Field Id"; Rec."Filter Sale POS Field Id")
                {

                    ToolTip = 'Specifies the value of the Filter Sale POS Field Id field';
                    ApplicationArea = NPRRetail;
                }
                field("Filter Sale POS Field Name"; Rec."Filter Sale POS Field Name")
                {

                    ToolTip = 'Specifies the value of the Filter Sale POS Field Name field';
                    ApplicationArea = NPRRetail;
                }
                field("Filter Sale Line POS Field Id"; Rec."Filter Sale Line POS Field Id")
                {

                    ToolTip = 'Specifies the value of the Filter Sale Line POS Field Id field';
                    ApplicationArea = NPRRetail;
                }
                field("Filter Sale Line POS Field Nam"; Rec."Filter Sale Line POS Field Nam")
                {

                    ToolTip = 'Specifies the value of the Filter Sale Line POS Field Name field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
    }

}

