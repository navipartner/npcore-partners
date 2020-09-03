// TODO: CTRLUPGRADE - uses old Standard code; must be removed or refactored
page 6014529 "NPR Touch Screen: Balanc.Line"
{
    // NPR4.10/VB/20150602 CASE 213003 Support for Web Client (JavaScript) client
    // NPR4.12/VB/20150618 CASE 213944 Removed the delete and insert options from this page
    // NPRx.xx/VB/20160105  CASE 230373 Refactoring due to client-side formatting of decimal and date/time values
    // NPR5.00/NPKNAV/20160113  CASE 230373 NP Retail 2016
    // NPR5.25/TS/20160726 CASE 246066 Change Page Type from Worksheet to ListPage
    // NPR5.41/TS  /20180105 CASE 300893 Removed Caption on ActionContainer

    Caption = 'Coin types';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = List;
    SourceTable = "NPR Payment Type - Detailed";

    layout
    {
        area(content)
        {
            repeater(Control6150613)
            {
                ShowCaption = false;
                field(Weight; Weight)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = All;
                }
                field(Amount; Amount)
                {
                    ApplicationArea = All;
                }
            }
            group(Control6150621)
            {
                ShowCaption = false;
                field(Sum; Sum)
                {
                    ApplicationArea = All;
                    Caption = 'Total';
                    Editable = false;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Or set total")
            {
                Caption = 'Or set total';
                Image = Totals;
                Promoted = true;

                trigger OnAction()
                var
                    t001: Label 'Total counted amount';
                begin
                    // TODO: CTRLUPGRADE - Refactor without Marshaller
                    Error('CTRLUPGRADE');
                    /*
                    if not Marshaller.NumPad(t001, dec, false, false) then
                        exit;
                    */

                    recount;

                    if FindFirst then;

                    setAmount(dec);
                end;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        calc;
    end;

    trigger OnAfterGetRecord()
    begin
        calc;
    end;

    trigger OnOpenPage()
    var
        dec: Decimal;
        Validering: Text[30];
        cuTS: Codeunit "NPR Touch Screen - Func.";
        "sum": Decimal;
        payment: Record "NPR Payment Type POS";
        payment1: Record "NPR Payment Type POS";
    begin
        if Find('-') then;
        if not payment1.Get("Payment No.", "Register No.") then
            payment1.Get("Payment No.", '');
    end;

    var
        dec: Decimal;
        // TODO: CTRLUPGRADE - declares a removed codeunit; all dependent functionality must be refactored
        //Marshaller: Codeunit "POS Event Marshaller";
        "Sum": Decimal;
        payment: Record "NPR Payment Type POS";
        payment1: Record "NPR Payment Type POS";
        Total: Decimal;

    procedure setAmount(dec: Decimal)
    begin
        //setAmount
        if dec > 0 then
            Validate(Amount, dec);
        Modify(true);
        CurrPage.Update(false);
    end;

    procedure setQuantity(dec: Decimal)
    begin
        //setQuantity
        if dec >= 0 then
            Validate(Quantity, dec);
        Modify(true);
        CurrPage.Update(false);
    end;

    procedure recount()
    begin
        //reCount

        if FindFirst then
            repeat
                setQuantity(0);
            until Next = 0;

        CurrPage.Update(false);
    end;

    procedure calc()
    var
        payment: Record "NPR Payment Type POS";
    begin
        //calc

        payment.SetRange("No.", "Payment No.");
        payment.SetRange("Register Filter", "Register No.");
        if payment.Find('-') then
            payment.CalcFields("Balancing Total");
        Sum := payment."Balancing Total";
    end;
}
