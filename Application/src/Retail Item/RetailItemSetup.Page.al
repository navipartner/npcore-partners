page 6014408 "NPR Retail Item Setup"
{

    Caption = 'Retail Item Setup';
    PageType = Card;
    SourceTable = "NPR Retail Item Setup";
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Item Group on Creation"; Rec."Item Group on Creation")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Item Group On Creation field';
                }
                field("Item Description at 1 star"; Rec."Item Description at 1 star")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Item Description At * field';
                }
                field("EAN No. at 1 star"; Rec."EAN No. at 1 star")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the EAN No. At * field';
                }
                field("Transfer SeO Item Entry"; Rec."Transfer SeO Item Entry")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Transfer Seo To Item Entry field';
                }
                field("EAN-No. at Item Create"; Rec."EAN-No. at Item Create")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the EAN-No. At Item Create field';
                }
                field("Autocreate EAN-Number"; Rec."Autocreate EAN-Number")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Autocreate EAN-Number field';
                }
                field("Itemgroup Pre No. Serie"; Rec."Itemgroup Pre No. Serie")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Itemgroup Pre No. Serie field';
                }
                field("Itemgroup No. Serie StartNo."; Rec."Itemgroup No. Serie StartNo.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Itemgroup No. Serie StartNo. field';
                }
                field("Itemgroup No. Serie EndNo."; Rec."Itemgroup No. Serie EndNo.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Itemgroup No. Serie EndNo. field';
                }
                field("Itemgroup No. Serie Warning"; Rec."Itemgroup No. Serie Warning")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Itemgroup No. Serie Warning field';
                }
                field("Reason for Return Mandatory"; Rec."Reason for Return Mandatory")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Reason For Return Mandatory field';
                }
                field("Description Control"; Rec."Description Control")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description Control field';
                }
                field("Not use Dim filter SerialNo"; Rec."Not use Dim filter SerialNo")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Dont Use Dim Filter Serial No. field';
                }
            }
        }
    }

}
