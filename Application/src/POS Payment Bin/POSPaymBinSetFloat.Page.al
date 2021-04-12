page 6150623 "NPR POS Paym.Bin Set Float"
{
    // NPR5.51/TJ  /20190618 CASE 353761 New object

    Caption = 'POS Payment Bin Set Float';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR POS Payment Method";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field("Processing Type"; Rec."Processing Type")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Processing Type field';
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Currency Code field';
                }
                field("Include In Counting"; Rec."Include In Counting")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Include In Counting field';
                }
                field(Amount; Amount)
                {
                    ApplicationArea = All;
                    Caption = 'Amount';
                    DecimalPlaces = 2 : 2;
                    ToolTip = 'Specifies the value of the Amount field';

                    trigger OnValidate()
                    var
                        POSPaymentBinCheckpoint: Record "NPR POS Payment Bin Checkp.";
                    begin
                        case true of
                            Amount > 0:
                                begin
                                    POSPaymentBinCheckpoint.SetRange("Payment Method No.", Rec.Code);
                                    POSPaymentBinCheckpoint.SetRange("Payment Bin No.", POSPaymentBin."No.");
                                    if POSPaymentBinCheckpoint.FindLast() then
                                        if POSPaymentBinCheckpoint."Float Amount" <> 0 then
                                            Error(FloatAlreadySetErr, POSPaymentBinCheckpoint.FieldCaption("Payment Bin No."), POSPaymentBinCheckpoint."Payment Bin No.",
                                                                     Rec.FieldCaption(Code), Rec.Code);
                                    if not POSPaymentMethodTemp.Get(Rec.Code) then begin
                                        POSPaymentMethodTemp.Init();
                                        POSPaymentMethodTemp.Code := Rec.Code;
                                        POSPaymentMethodTemp."Rounding Precision" := Amount;
                                        POSPaymentMethodTemp.Insert();
                                    end else
                                        if Amount <> POSPaymentMethodTemp."Rounding Precision" then begin
                                            POSPaymentMethodTemp."Rounding Precision" := Amount;
                                            POSPaymentMethodTemp.Modify();
                                        end;
                                end;
                            Amount = 0:
                                if POSPaymentMethodTemp.Get(Rec.Code) then
                                    POSPaymentMethodTemp.Delete();
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
        if POSPaymentMethodTemp.Get(Rec.Code) then
            Amount := POSPaymentMethodTemp."Rounding Precision";
    end;

    var
        Amount: Decimal;
        POSPaymentMethodTemp: Record "NPR POS Payment Method" temporary;
        NegAmountErr: Label 'Amount can''t be set as negative.';
        POSPaymentBin: Record "NPR POS Payment Bin";
        FloatAlreadySetErr: Label 'Float is already set for %1 %2, %3 %4.';

    procedure SetPaymentBin(POSPaymentBinHere: Record "NPR POS Payment Bin")
    begin
        POSPaymentBin := POSPaymentBinHere;
    end;

    procedure GetAmounts(var POSPaymentMethodHere: Record "NPR POS Payment Method")
    begin
        if POSPaymentMethodTemp.FindSet() then
            repeat
                POSPaymentMethodHere := POSPaymentMethodTemp;
                POSPaymentMethodHere.Insert();
            until POSPaymentMethodTemp.Next() = 0;
    end;
}

