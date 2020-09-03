page 6150717 "NPR POS Menu Filter SubPage"
{
    // NPR5.32/NPKNAV/20170526  CASE 270854 Transport NPR5.32 - 26 May 2017

    AutoSplitKey = true;
    Caption = 'Filter Line';
    PageType = ListPart;
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
                }
                field("Object Id"; "Object Id")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Filter Code"; "Filter Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Line No."; "Line No.")
                {
                    ApplicationArea = All;
                }
                field("Object Name"; "Object Name")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Table No."; "Table No.")
                {
                    ApplicationArea = All;
                }
                field("Table Name"; "Table Name")
                {
                    ApplicationArea = All;
                }
                field("Field No."; "Field No.")
                {
                    ApplicationArea = All;
                }
                field("Field Name"; "Field Name")
                {
                    ApplicationArea = All;
                }
                field("Filter Value"; "Filter Value")
                {
                    ApplicationArea = All;
                }
                field("Filter Sale POS Field Id"; "Filter Sale POS Field Id")
                {
                    ApplicationArea = All;
                }
                field("Filter Sale POS Field Name"; "Filter Sale POS Field Name")
                {
                    ApplicationArea = All;
                }
                field("Filter Sale Line POS Field Id"; "Filter Sale Line POS Field Id")
                {
                    ApplicationArea = All;
                }
                field("Filter Sale Line POS Field Nam"; "Filter Sale Line POS Field Nam")
                {
                    ApplicationArea = All;
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

