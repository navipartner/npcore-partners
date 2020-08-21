page 6150623 "POS Payment Bin Set Float"
{
    // NPR5.51/TJ  /20190618 CASE 353761 New object

    Caption = 'POS Payment Bin Set Float';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = List;
    SourceTable = "POS Payment Method";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Code)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Processing Type"; "Processing Type")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Currency Code"; "Currency Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Include In Counting"; "Include In Counting")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Amount; Amount)
                {
                    ApplicationArea = All;
                    Caption = 'Amount';
                    DecimalPlaces = 2 : 2;

                    trigger OnValidate()
                    var
                        POSPaymentBinCheckpoint: Record "POS Payment Bin Checkpoint";
                    begin
                        case true of
                            Amount > 0:
                                begin
                                    POSPaymentBinCheckpoint.SetRange("Payment Method No.", Code);
                                    POSPaymentBinCheckpoint.SetRange("Payment Bin No.", POSPaymentBin."No.");
                                    if POSPaymentBinCheckpoint.FindLast then
                                        if POSPaymentBinCheckpoint."Float Amount" <> 0 then
                                            Error(FloatAlreadySetErr, POSPaymentBinCheckpoint.FieldCaption("Payment Bin No."), POSPaymentBinCheckpoint."Payment Bin No.",
                                                                     FieldCaption(Code), Code);
                                    if not POSPaymentMethodTemp.Get(Code) then begin
                                        POSPaymentMethodTemp.Init;
                                        POSPaymentMethodTemp.Code := Code;
                                        POSPaymentMethodTemp."Rounding Precision" := Amount;
                                        POSPaymentMethodTemp.Insert;
                                    end else
                                        if Amount <> POSPaymentMethodTemp."Rounding Precision" then begin
                                            POSPaymentMethodTemp."Rounding Precision" := Amount;
                                            POSPaymentMethodTemp.Modify;
                                        end;
                                end;
                            Amount = 0:
                                if POSPaymentMethodTemp.Get(Code) then
                                    POSPaymentMethodTemp.Delete;
                            Amount < 0:
                                Error(NegAmountErr);
                        end;
                    end;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        Amount := 0;
        if POSPaymentMethodTemp.Get(Code) then
            Amount := POSPaymentMethodTemp."Rounding Precision";
    end;

    var
        Amount: Decimal;
        POSPaymentMethodTemp: Record "POS Payment Method" temporary;
        NegAmountErr: Label 'Amount can''t be set as negative.';
        POSPaymentBin: Record "POS Payment Bin";
        FloatAlreadySetErr: Label 'Float is already set for %1 %2, %3 %4.';

    procedure SetPaymentBin(POSPaymentBinHere: Record "POS Payment Bin")
    begin
        POSPaymentBin := POSPaymentBinHere;
    end;

    procedure GetAmounts(var POSPaymentMethodHere: Record "POS Payment Method")
    begin
        if POSPaymentMethodTemp.FindSet then
            repeat
                POSPaymentMethodHere := POSPaymentMethodTemp;
                POSPaymentMethodHere.Insert;
            until POSPaymentMethodTemp.Next = 0;
    end;
}

