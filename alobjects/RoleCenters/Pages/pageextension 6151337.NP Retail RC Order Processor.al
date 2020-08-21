pageextension 6151337 "NP Retail RC Order Processor" extends "Headline RC Order Processor"
{

    layout
    {

        modify(Control2)
        {
            Visible = false;
        }
        addafter(Control2)
        {
            group(HighestPOSSales)
            {
                ShowCaption = false;
                Editable = false;
                field("'Biggest sales for today is ' + FORMAT(highestPOSSales,0,'<Precision,2><sign><Integer Thousand><Decimals,3>')+ ' !'"; 'Highest POS Sales for today is ' + Format(highestPOSSales) + ' !')
                {
                    ApplicationArea = All;
                    ShowCaption = false;
                }
            }

            group(HighestSalesInvoices)
            {
                ShowCaption = false;
                Editable = false;
                field("'Biggest sales for today is ' + FORMAT(highestSalesInv,0,'<Precision,2><sign><Integer Thousand><Decimals,3>') + ' !'"; 'Highest Sales Invoice for today is ' + Format(highestSalesInv) + ' !')
                {
                    ApplicationArea = All;
                    ShowCaption = false;
                }
            }
            group(TopSalesPerson)
            {
                ShowCaption = false;
                Editable = false;
                field("'Top Sales Person for today is ' + TopSalesPerson +' !'"; 'Top Sales Person for today is ' + TopSalesPerson + ' !')
                {
                    ApplicationArea = All;
                    ShowCaption = false;
                }
            }

            group(AverageBasket)
            {
                ShowCaption = false;
                Editable = false;
                field("'Average Basket is ' +  FORMAT(AvgBasket,0,'<Precision,2><sign><Integer Thousand><Decimals,3>') + ' !'"; 'Average Basket is ' + FORMAT(AverageBasket, 0, '<Precision,2><sign><Integer Thousand><Decimals,3>') + ' !')
                {
                    ApplicationArea = All;
                    ShowCaption = false;
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
        HeadlineManagement2: Codeunit "NP Retail Headline Management";
        BiggestSales: Text;
        TopSalesPerson: Text;
        AverageBasket: Decimal;
        highestPOSSales: Text;
        highestSalesInv: Text;

}