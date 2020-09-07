page 6014665 "NPR Stock-Take Configs"
{
    // NPR4.16/TS/20150525 CASE 213313 Page Created
    // NPR5.29/CLVA/20161122 CASE 252352 Added button Integration

    Caption = 'Stock-Take Configurations';
    PageType = List;
    SourceTable = "NPR Stock-Take Configuration";
    UsageCategory = Tasks;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Code)
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("Location Code"; "Location Code")
                {
                    ApplicationArea = All;
                }
                field("Inventory Calc. Date"; "Inventory Calc. Date")
                {
                    ApplicationArea = All;
                }
                field("Stock-Take Template Code"; "Stock-Take Template Code")
                {
                    ApplicationArea = All;
                }
                field("Allow User Modification"; "Allow User Modification")
                {
                    ApplicationArea = All;
                }
                field("Allow Unit Cost Change"; "Allow Unit Cost Change")
                {
                    ApplicationArea = All;
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
            action("&Dimensions")
            {
                Caption = '&Dimensions';
                Image = Dimensions;
                Promoted = true;
                PromotedCategory = Process;
                RunObject = Page "Default Dimensions";
                RunPageLink = "Table ID" = CONST(6014665),
                              "No." = FIELD(Code);
                ShortCutKey = 'Shift+Ctrl+D';
                ApplicationArea=All;

                trigger OnAction()
                var
                    NPRDimMgt: Codeunit "NPR Dimension Mgt.";
                begin
                end;
            }
            action(Card)
            {
                Caption = 'Card';
                Image = Card;
                Promoted = true;
                PromotedCategory = Process;
                RunObject = Page "NPR Stock-Take Config. Card";
                RunPageLink = Code = FIELD(Code);
                ShortCutKey = 'Shift+F5';
                ApplicationArea=All;
            }
            action("&Worksheets")
            {
                Caption = '&Worksheets';
                Image = Worksheet2;
                RunObject = Page "NPR Stock-Take Worksheet";
                RunPageLink = "Stock-Take Config Code" = FIELD(Code);
                ApplicationArea=All;
            }
            action(Integration)
            {
                Caption = 'Integration';
                Image = Setup;
                Promoted = true;
                PromotedCategory = Process;
                RunObject = Page "NPR Scanner Service Setup";
                RunPageMode = View;
                ApplicationArea=All;
            }
        }
    }
}

