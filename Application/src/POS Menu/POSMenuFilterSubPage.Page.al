page 6150717 "NPR POS Menu Filter SubPage"
{
    AutoSplitKey = true;
    Caption = 'Filter Line';
    PageType = ListPart;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR POS Menu Filter Line";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Object Type"; "Object Type")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Object Type field';
                }
                field("Object Id"; "Object Id")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Object Id field';
                }
                field("Filter Code"; "Filter Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Filter Code field';
                }
                field("Line No."; "Line No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Line No. field';
                }
                field("Object Name"; "Object Name")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Object Name field';
                }
                field("Table No."; "Table No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Table No. field';
                }
                field("Table Name"; "Table Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Table Name field';
                }
                field("Field No."; "Field No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Field No. field';
                }
                field("Field Name"; "Field Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Field Name field';
                }
                field("Filter Value"; "Filter Value")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Filter Value field';
                }
                field("Filter Sale POS Field Id"; "Filter Sale POS Field Id")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Filter Sale POS Field Id field';
                }
                field("Filter Sale POS Field Name"; "Filter Sale POS Field Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Filter Sale POS Field Name field';
                }
                field("Filter Sale Line POS Field Id"; "Filter Sale Line POS Field Id")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Filter Sale Line POS Field Id field';
                }
                field("Filter Sale Line POS Field Nam"; "Filter Sale Line POS Field Nam")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Filter Sale Line POS Field Name field';
                }
            }
        }
    }

    actions
    {
    }

    var
        POSMenuFilterMain: Record "NPR POS Menu Filter" temporary;
}

