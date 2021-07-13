page 6014419 "NPR Exchange Label Setup"
{

    Caption = 'Exchange Label Setup';
    PageType = Card;
    SourceTable = "NPR Exchange Label Setup";
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;


    layout
    {
        area(content)
        {
            group(General)
            {
                field("EAN Prefix Exhange Label"; Rec."EAN Prefix Exhange Label")
                {

                    ToolTip = 'Specifies the value of the EAN Prefix Exhange Label field';
                    ApplicationArea = NPRRetail;
                }
                field("Exchange Label  No. Series"; Rec."Exchange Label  No. Series")
                {

                    ToolTip = 'Specifies the value of the Exchange Label Nos. field';
                    ApplicationArea = NPRRetail;
                }
                field("Purchace Price Code"; Rec."Purchace Price Code")
                {

                    ToolTip = 'Specifies the value of the Purchase Price Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Exchange Label Exchange Period"; Rec."Exchange Label Exchange Period")
                {

                    ToolTip = 'Specifies the value of the Exchange Label Exchange Period field';
                    ApplicationArea = NPRRetail;
                }
                field("Exchange Label Default Date"; Rec."Exchange Label Default Date")
                {

                    ToolTip = 'Specifies the value of the Exchange Label Default Date field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

}
