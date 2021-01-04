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
                    ToolTip = 'Specifies the value of the Code field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Location Code"; "Location Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Location Code field';
                }
                field("Inventory Calc. Date"; "Inventory Calc. Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Stock-Take Calc. Date field';
                }
                field("Stock-Take Template Code"; "Stock-Take Template Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Stock-Take Template Code field';
                }
                field("Allow User Modification"; "Allow User Modification")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Allow User Modification field';
                }
                field("Allow Unit Cost Change"; "Allow Unit Cost Change")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Allow Unit Cost Change field';
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
                ApplicationArea = All;
                ToolTip = 'Executes the &Dimensions action';

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
                ApplicationArea = All;
                ToolTip = 'Executes the Card action';
            }
            action("&Worksheets")
            {
                Caption = '&Worksheets';
                Image = Worksheet2;
                RunObject = Page "NPR Stock-Take Worksheet";
                RunPageLink = "Stock-Take Config Code" = FIELD(Code);
                ApplicationArea = All;
                ToolTip = 'Executes the &Worksheets action';
            }
            action(Integration)
            {
                Caption = 'Integration';
                Image = Setup;
                Promoted = true;
                PromotedCategory = Process;
                RunObject = Page "NPR Scanner Service Setup";
                RunPageMode = View;
                ApplicationArea = All;
                ToolTip = 'Executes the Integration action';
            }
        }
    }
}

