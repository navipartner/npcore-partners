page 6014665 "Stock-Take Configurations"
{
    // NPR4.16/TS/20150525 CASE 213313 Page Created
    // NPR5.29/CLVA/20161122 CASE 252352 Added button Integration

    Caption = 'Stock-Take Configurations';
    PageType = List;
    SourceTable = "Stock-Take Configuration";
    UsageCategory = Tasks;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code";Code)
                {
                }
                field(Description;Description)
                {
                }
                field("Location Code";"Location Code")
                {
                }
                field("Inventory Calc. Date";"Inventory Calc. Date")
                {
                }
                field("Stock-Take Template Code";"Stock-Take Template Code")
                {
                }
                field("Allow User Modification";"Allow User Modification")
                {
                }
                field("Allow Unit Cost Change";"Allow Unit Cost Change")
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
            action("&Dimensions")
            {
                Caption = '&Dimensions';
                Image = Dimensions;
                Promoted = true;
                PromotedCategory = Process;
                RunObject = Page "Default Dimensions";
                RunPageLink = "Table ID"=CONST(6014665),
                              "No."=FIELD(Code);
                ShortCutKey = 'Shift+Ctrl+D';

                trigger OnAction()
                var
                    NPRDimMgt: Codeunit NPRDimensionManagement;
                begin
                end;
            }
            action(Card)
            {
                Caption = 'Card';
                Image = Card;
                Promoted = true;
                PromotedCategory = Process;
                RunObject = Page "Stock-Take Configuration Card";
                RunPageLink = Code=FIELD(Code);
                ShortCutKey = 'Shift+F5';
            }
            action("&Worksheets")
            {
                Caption = '&Worksheets';
                Image = Worksheet2;
                RunObject = Page "Stock-Take Worksheet";
                RunPageLink = "Stock-Take Config Code"=FIELD(Code);
            }
            action(Integration)
            {
                Caption = 'Integration';
                Image = Setup;
                Promoted = true;
                PromotedCategory = Process;
                RunObject = Page "Scanner Service Setup";
                RunPageMode = View;
            }
        }
    }
}

