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
                    Caption = 'Id', Locked = true;
                    Editable = false;
                }
                field("code"; Rec.Code)
                {
                    Caption = 'Code', Locked = true;
                    ShowMandatory = true;
                }
                field(displayName; Rec.Description)
                {
                    Caption = 'Description', Locked = true;
                }

                field(lastDateModified; Rec."Last Date Modified")
                {
                    Caption = 'Last Date Modified', Locked = true;
                }

                field(lastDateAdjusted; Rec."Last Date Adjusted")
                {
                    Caption = 'Last Date Adjusted', Locked = true;
                }

                field(symbol; Rec.Symbol)
                {
                    Caption = 'Symbol', Locked = true;

                }

                field(isoCode; Rec."ISO Code")
                {
                    Caption = 'ISO Code', Locked = true;
                }

                field(isoNumericCode; Rec."ISO Numeric Code")
                {
                    Caption = 'ISO Numeric Code', Locked = true;
                }

                field(unrealizedGainsAcc; Rec."Unrealized Gains Acc.")
                {
                    Caption = 'Unrealized Gains Acc.', Locked = true;
                }

                field(realizedGainsAcc; Rec."Realized Gains Acc.")
                {
                    Caption = 'Realized Gains Acc.', Locked = true;
                }

                field(unrealizedLossesAcc; Rec."Unrealized Losses Acc.")
                {
                    Caption = 'Unrealized Losses Acc.', Locked = true;
                }

                field(realizedLossesAcc; Rec."Realized Losses Acc.")
                {
                    Caption = 'Realized Losses Acc.', Locked = true;
                }

                field(invoiceRoundingPrecision; Rec."Invoice Rounding Precision")
                {
                    Caption = 'Invoice Rounding Precision', Locked = true;
                }

                field(invoiceRoundingType; Rec."Invoice Rounding Type")
                {
                    Caption = 'Invoice Rounding Type', Locked = true;
                }

                field(amountRoundingPrecision; Rec."Amount Rounding Precision")
                {
                    Caption = 'Amount Rounding Precision', Locked = true;
                }

                field(unitAmountRoundingPrecision; Rec."Unit-Amount Rounding Precision")
                {
                    Caption = 'IUnit-Amount Rounding Precision', Locked = true;
                }

                field(amountDecimalPlaces; Rec."Amount Decimal Places")
                {
                    Caption = 'Amount Decimal Places', Locked = true;
                }

                field(unitAmountDecimalPlaces; Rec."Unit-Amount Decimal Places")
                {
                    Caption = 'Unit-Amount Decimal Places', Locked = true;
                }

                field(realizedGLGainsAccount; Rec."Realized G/L Gains Account")
                {
                    Caption = 'Realized G/L Gains Account', Locked = true;
                }

                field(realizedGLLossesAccount; Rec."Realized G/L Losses Account")
                {
                    Caption = 'Realized G/L Losses Account', Locked = true;
                }

                field(applnRoundingPrecision; Rec."Appln. Rounding Precision")
                {
                    Caption = 'Appln. Rounding Precision', Locked = true;
                }

                field(emuCurrency; Rec."EMU Currency")
                {
                    Caption = 'EMU Currency', Locked = true;
                }

                field(currencyFactor; Rec."Currency Factor")
                {
                    Caption = 'Currency Factor', Locked = true;
                }

                field(residualGainsAccount; Rec."Residual Gains Account")
                {
                    Caption = 'Residual Gains Account', Locked = true;
                }

                field(residualLossesAccount; Rec."Residual Losses Account")
                {
                    Caption = 'Residual Losses Account', Locked = true;
                }

                field(convLcyRndgDebitAcc; Rec."Conv. LCY Rndg. Debit Acc.")
                {
                    Caption = 'Conv. LCY Rndg. Debit Acc.', Locked = true;
                }

                field(convLcyRndgCreditAcc; Rec."Conv. LCY Rndg. Credit Acc.")
                {
                    Caption = 'Conv. LCY Rndg. Credit Acc.', Locked = true;
                }

                field(maxVatDifferenceAllowed; Rec."Max. VAT Difference Allowed")
                {
                    Caption = 'Max. VAT Difference Allowed', Locked = true;
                }

                field(vatRoundingType; Rec."VAT Rounding Type")
                {
                    Caption = 'VAT Rounding Type', Locked = true;
                }

                field(paymentTolerancePercent; Rec."Payment Tolerance %")
                {
                    Caption = 'Payment Tolerance %', Locked = true;
                }

                field(maxPaymentToleranceAmount; Rec."Max. Payment Tolerance Amount")
                {
                    Caption = 'Max. Payment Tolerance Amount', Locked = true;
                }

                field(lastModifiedDateTime; Rec.SystemModifiedAt)
                {
                    Caption = 'Last Modified Date', Locked = true;
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





