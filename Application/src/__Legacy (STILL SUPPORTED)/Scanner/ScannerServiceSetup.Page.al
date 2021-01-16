page 6059996 "NPR Scanner Service Setup"
{
    // NPR5.29/NPKNAV/20170127  CASE 252352 Transport NPR5.29 - 27 januar 2017
    // NPR5.48/JDH /20181109 CASE 334163 Added object caption

    Caption = 'Scanner Service Setup';
    PageType = Card;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR Scanner Service Setup";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Log Request"; "Log Request")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Log Request field';
                }
                field("Stock-Take Config Code"; "Stock-Take Config Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Stock-Take Conf. Code field';
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
                RunObject = Codeunit "NPR Scanner Service WS";
                ApplicationArea = All;
                ToolTip = 'Executes the Setup Webservice action';
            }
        }
    }
}

