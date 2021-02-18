page 6014419 "NPR Exchange Label Setup"
{

    Caption = 'Exchange Label Setup';
    PageType = Card;
    SourceTable = "NPR Exchange Label Setup";
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            group(General)
            {
                field("EAN Prefix Exhange Label"; Rec."EAN Prefix Exhange Label")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the EAN Prefix Exhange Label field';
                }
                field("Exchange Label  No. Series"; Rec."Exchange Label  No. Series")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Exchange Label Nos. field';
                }
                field("Purchace Price Code"; Rec."Purchace Price Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Purchase Price Code field';
                }
                field("Exchange Label Exchange Period"; Rec."Exchange Label Exchange Period")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Exchange Label Exchange Period field';
                }
                field("Exchange Label Default Date"; Rec."Exchange Label Default Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Exchange Label Default Date field';
                }
            }
        }
    }

}
