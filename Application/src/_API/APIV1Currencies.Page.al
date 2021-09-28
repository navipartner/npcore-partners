page 6014663 "NPR APIV1 - Currencies"
{
    APIGroup = 'core';
    APIPublisher = 'navipartner';
    APIVersion = 'v1.0';
    Caption = 'Currencies';
    DelayedInsert = true;
    EntityName = 'currency';
    EntitySetName = 'currencies';
    Extensible = false;
    ODataKeyFields = SystemId;
    PageType = API;
    SourceTable = Currency;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'Id';
                    Editable = false;
                }
                field("code"; Rec.Code)
                {
                    Caption = 'Code';
                    ShowMandatory = true;
                }
                field(displayName; Rec.Description)
                {
                    Caption = 'Description';
                }

                field(lastDateModified; Rec."Last Date Modified")
                {
                    Caption = 'Last Date Modified';
                }

                field(lastDateAdjusted; Rec."Last Date Adjusted")
                {
                    Caption = 'Last Date Adjusted';
                }

                field(symbol; Rec.Symbol)
                {
                    Caption = 'Symbol';

                }

                field(isoCode; Rec."ISO Code")
                {
                    Caption = 'ISO Code';
                }

                field(isoNumericCode; Rec."ISO Numeric Code")
                {
                    Caption = 'ISO Numeric Code';
                }

                field(unrealizedGainsAcc; Rec."Unrealized Gains Acc.")
                {
                    Caption = 'Unrealized Gains Acc.';
                }

                field(realizedGainsAcc; Rec."Realized Gains Acc.")
                {
                    Caption = 'Realized Gains Acc.';
                }

                field(unrealizedLossesAcc; Rec."Unrealized Losses Acc.")
                {
                    Caption = 'Unrealized Losses Acc.';
                }

                field(realizedLossesAcc; Rec."Realized Losses Acc.")
                {
                    Caption = 'Realized Losses Acc.';
                }

                field(invoiceRoundingPrecision; Rec."Invoice Rounding Precision")
                {
                    Caption = 'Invoice Rounding Precision';
                }

                field(invoiceRoundingType; Rec."Invoice Rounding Type")
                {
                    Caption = 'Invoice Rounding Type';
                }

                field(amountRoundingPrecision; Rec."Amount Rounding Precision")
                {
                    Caption = 'Amount Rounding Precision';
                }

                field(unitAmountRoundingPrecision; Rec."Unit-Amount Rounding Precision")
                {
                    Caption = 'IUnit-Amount Rounding Precision';
                }

                field(amountDecimalPlaces; Rec."Amount Decimal Places")
                {
                    Caption = 'Amount Decimal Places';
                }

                field(unitAmountDecimalPlaces; Rec."Unit-Amount Decimal Places")
                {
                    Caption = 'Unit-Amount Decimal Places';
                }

                field(realizedGLGainsAccount; Rec."Realized G/L Gains Account")
                {
                    Caption = 'Realized G/L Gains Account';
                }

                field(realizedGLLossesAccount; Rec."Realized G/L Losses Account")
                {
                    Caption = 'Realized G/L Losses Account';
                }

                field(applnRoundingPrecision; Rec."Appln. Rounding Precision")
                {
                    Caption = 'Appln. Rounding Precision';
                }

                field(emuCurrency; Rec."EMU Currency")
                {
                    Caption = 'EMU Currency';
                }

                field(currencyFactor; Rec."Currency Factor")
                {
                    Caption = 'Currency Factor';
                }

                field(residualGainsAccount; Rec."Residual Gains Account")
                {
                    Caption = 'Residual Gains Account';
                }

                field(residualLossesAccount; Rec."Residual Losses Account")
                {
                    Caption = 'Residual Losses Account';
                }

                field(convLcyRndgDebitAcc; Rec."Conv. LCY Rndg. Debit Acc.")
                {
                    Caption = 'Conv. LCY Rndg. Debit Acc.';
                }

                field(convLcyRndgCreditAcc; Rec."Conv. LCY Rndg. Credit Acc.")
                {
                    Caption = 'Conv. LCY Rndg. Credit Acc.';
                }

                field(maxVatDifferenceAllowed; Rec."Max. VAT Difference Allowed")
                {
                    Caption = 'Max. VAT Difference Allowed';
                }

                field(vatRoundingType; Rec."VAT Rounding Type")
                {
                    Caption = 'VAT Rounding Type';
                }

                field(paymentTolerancePercent; Rec."Payment Tolerance %")
                {
                    Caption = 'Payment Tolerance %';
                }

                field(maxPaymentToleranceAmount; Rec."Max. Payment Tolerance Amount")
                {
                    Caption = 'Max. Payment Tolerance Amount';
                }

                field(lastModifiedDateTime; Rec.SystemModifiedAt)
                {
                    Caption = 'Last Modified Date';
                }

                field(replicationCounter; Rec."NPR Replication Counter")
                {
                    Caption = 'replicationCounter', Locked = true;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnInit()
    begin
        CurrentTransactionType := TransactionType::Update;
    end;

}





