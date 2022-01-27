page 6150623 "NPR POS Paym.Bin Set Float"
{
    Extensible = False;
    // NPR5.51/TJ  /20190618 CASE 353761 New object

    Caption = 'POS Payment Bin Set Float';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR POS Payment Method";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Processing Type"; Rec."Processing Type")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Processing Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Currency Code"; Rec."Currency Code")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Currency Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Include In Counting"; Rec."Include In Counting")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Include In Counting field';
                    ApplicationArea = NPRRetail;
                }
                field(Amount; Amount)
                {

                    Caption = 'Amount';
                    DecimalPlaces = 2 : 2;
                    ToolTip = 'Specifies the value of the Amount field';
                    ApplicationArea = NPRRetail;

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
                                    if not TempPOSPaymentMethod.Get(Rec.Code) then begin
                                        TempPOSPaymentMethod.Init();
                                        TempPOSPaymentMethod.Code := Rec.Code;
                                        TempPOSPaymentMethod."Rounding Precision" := Amount;
                                        TempPOSPaymentMethod.Insert();
                                    end else
                                        if Amount <> TempPOSPaymentMethod."Rounding Precision" then begin
                                            TempPOSPaymentMethod."Rounding Precision" := Amount;
                                            TempPOSPaymentMethod.Modify();
                                        end;
                                end;
                            Amount = 0:
                                if TempPOSPaymentMethod.Get(Rec.Code) then
                                    TempPOSPaymentMethod.Delete();
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
        if TempPOSPaymentMethod.Get(Rec.Code) then
            Amount := TempPOSPaymentMethod."Rounding Precision";
    end;

    var
        POSPaymentBin: Record "NPR POS Payment Bin";
        TempPOSPaymentMethod: Record "NPR POS Payment Method" temporary;
        Amount: Decimal;
        NegAmountErr: Label 'Amount can''t be set as negative.';
        FloatAlreadySetErr: Label 'Float is already set for %1 %2, %3 %4.';

    procedure SetPaymentBin(POSPaymentBinHere: Record "NPR POS Payment Bin")
    begin
        POSPaymentBin := POSPaymentBinHere;
    end;

    procedure GetAmounts(var POSPaymentMethodHere: Record "NPR POS Payment Method")
    begin
        if TempPOSPaymentMethod.FindSet() then
            repeat
                POSPaymentMethodHere := TempPOSPaymentMethod;
                POSPaymentMethodHere.Insert();
            until TempPOSPaymentMethod.Next() = 0;
    end;
}

