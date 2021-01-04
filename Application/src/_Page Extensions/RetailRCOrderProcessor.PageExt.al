pageextension 6151337 "NPR Retail RC Order Processor" extends "Headline RC Order Processor"
{

    layout
    {

        modify(Control2)
        {
            Visible = false;
        }
        addafter(Control2)
        {
            group("NPR HighestPOSSales")
            {
                ShowCaption = false;
                Editable = false;
                field("NPRHighestPOSSales"; 'Highest POS Sales for today is ' + Format(highestPOSSales) + ' !')
                {
                    ApplicationArea = All;
                    ShowCaption = false;
                    ToolTip = 'Specifies the value of the ''Highest POS Sales for today is '' + Format(highestPOSSales) + '' !'' field';
                }
            }

            group("NPR HighestSalesInvoices")
            {
                ShowCaption = false;
                Editable = false;
                field("NPRHighestSalesInvoice"; 'Highest Sales Invoice for today is ' + Format(highestSalesInv) + ' !')
                {
                    ApplicationArea = All;
                    ShowCaption = false;
                    ToolTip = 'Specifies the value of the ''Highest Sales Invoice for today is '' + Format(highestSalesInv) + '' !'' field';
                }
            }
            group("NPR TopSalesPerson")
            {
                ShowCaption = false;
                Editable = false;
                field("NPRTopSalesPerson"; 'Top Sales Person for today is ' + TopSalesPerson + ' !')
                {
                    ApplicationArea = All;
                    ShowCaption = false;
                    ToolTip = 'Specifies the value of the ''Top Sales Person for today is '' + TopSalesPerson + '' !'' field';
                }
            }

            group("NPR AverageBasket")
            {
                ShowCaption = false;
                Editable = false;
                field("NPRAverageBasket"; 'Average Basket is ' + FORMAT(AverageBasket, 0, '<Precision,2><sign><Integer Thousand><Decimals,3>') + ' !')
                {
                    ApplicationArea = All;
                    ShowCaption = false;
                    ToolTip = 'Specifies the value of the ''Average Basket is '' + FORMAT(AverageBasket, 0, ''<Precision,2><sign><Integer Thousand><Decimals,3>'') + '' !'' field';
                }
            }
        }
    }
    trigger OnOpenPage()
    var
        Uninitialized: Boolean;
    begin

        HeadlineManagement2.GetHighestPOSSalesText(highestPOSSales);
        HeadlineManagement2.GetHighestSalesInvText(highestSalesInv);
        HeadlineManagement2.GetTopSalesPersonText(TopSalesPerson);
        HeadlineManagement2.GetAverageBasket(AverageBasket);
    end;

    var
        HeadlineManagement2: Codeunit "NPR NP Retail Headline Mgt.";
        BiggestSales: Text;
        TopSalesPerson: Text;
        AverageBasket: Decimal;
        highestPOSSales: Text;
        highestSalesInv: Text;

}