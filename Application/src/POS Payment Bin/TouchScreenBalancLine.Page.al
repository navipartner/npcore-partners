// TODO: CTRLUPGRADE - uses old Standard code; must be removed or refactored
page 6014529 "NPR Touch Screen: Balanc.Line"
{
    Caption = 'Coin types';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
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
                    ToolTip = 'Specifies the value of the Type field';
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Quantity field';
                }
                field(Amount; Amount)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Amount field';
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
                    ToolTip = 'Specifies the value of the Total field';
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
                PromotedCategory = Process;
                PromotedOnly = true;
                ApplicationArea = All;
                ToolTip = 'Executes the Or set total action';

                trigger OnAction()
                var
                    t001: Label 'Total counted amount';
                begin
                    // TODO: CTRLUPGRADE - Refactor without Marshaller
                    Error('CTRLUPGRADE');
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
    begin
        if Find('-') then;
    end;

    var
        dec: Decimal;
        // TODO: CTRLUPGRADE - declares a removed codeunit; all dependent functionality must be refactored
        //Marshaller: Codeunit "POS Event Marshaller";
        "Sum": Decimal;

    procedure setAmount(dec: Decimal)
    begin
        if dec > 0 then
            Validate(Amount, dec);
        Modify(true);
        CurrPage.Update(false);
    end;

    procedure setQuantity(dec: Decimal)
    begin
        if dec >= 0 then
            Validate(Quantity, dec);
        Modify(true);
        CurrPage.Update(false);
    end;

    procedure recount()
    begin
        if FindFirst then
            repeat
                setQuantity(0);
            until Next = 0;

        CurrPage.Update(false);
    end;

    procedure calc()
    begin
        Sum := 0;
    end;
}
