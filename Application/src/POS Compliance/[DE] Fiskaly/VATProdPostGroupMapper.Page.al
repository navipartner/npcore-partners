page 6014434 "NPR VAT Prod Post Group Mapper"
{

    ApplicationArea = All;
    Caption = 'VAT Prod Post Group Mapper List';
    PageType = List;
    SourceTable = "NPR VAT Posting Group Mapper";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("VAT Prod. Pos. Group"; Rec."VAT Prod. Pos. Group")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the VAT Prod. Pos. Group field';
                }
                field("VAT Bus. Posting Group"; Rec."VAT Bus. Posting Group")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the VAT Bus. Posting Group field';
                }
                field("VAT Identifier"; Rec."VAT Identifier")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the VAT Identifier field';
                }
                field("Fiscal Name"; Rec."Fiscal Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Fiscal Name field';
                }
            }
        }
    }
}