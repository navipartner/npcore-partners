page 6059996 "Scanner Service Setup"
{
    // NPR5.29/NPKNAV/20170127  CASE 252352 Transport NPR5.29 - 27 januar 2017
    // NPR5.48/JDH /20181109 CASE 334163 Added object caption

    Caption = 'Scanner Service Setup';
    PageType = Card;
    SourceTable = "Scanner Service Setup";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Log Request";"Log Request")
                {
                }
                field("Stock-Take Config Code";"Stock-Take Config Code")
                {
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
        }
        area(navigation)
        {
            action("Setup Webservice")
            {
                Caption = 'Setup Webservice';
                Image = Setup;
                Promoted = true;
                PromotedCategory = Process;
                RunObject = Codeunit "Scanner Service WS";
            }
        }
    }
}

