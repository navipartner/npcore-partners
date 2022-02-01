page 6014693 "NPR APIV1 - Vend. Post. Groups"
{

    APIGroup = 'core';
    APIPublisher = 'navipartner';
    APIVersion = 'v1.0';
    Caption = 'Vendor Posting Groups';
    DelayedInsert = true;
    EntityName = 'vendorPostGroup';
    EntitySetName = 'vendorPostGroups';
    Extensible = false;
    ODataKeyFields = SystemId;
    PageType = API;
    SourceTable = "Vendor Posting Group";

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'SystemId', Locked = true;
                }
                field("code"; Rec."Code")
                {
                    Caption = 'Code', Locked = true;
                }
                field(description; Rec.Description)
                {
                    Caption = 'Description', Locked = true;
                }
                field(payablesAccount; Rec."Payables Account")
                {
                    Caption = 'Payables Account', Locked = true;
                }
                field(debitCurrApplnRndgAcc; Rec."Debit Curr. Appln. Rndg. Acc.")
                {
                    Caption = 'Debit Curr. Appln. Rndg. Acc.', Locked = true;
                }
                field(debitRoundingAccount; Rec."Debit Rounding Account")
                {
                    Caption = 'Debit Rounding Account', Locked = true;
                }
                field(creditCurrApplnRndgAcc; Rec."Credit Curr. Appln. Rndg. Acc.")
                {
                    Caption = 'Credit Curr. Appln. Rndg. Acc.', Locked = true;
                }
                field(creditRoundingAccount; Rec."Credit Rounding Account")
                {
                    Caption = 'Credit Rounding Account', Locked = true;
                }
                field(invoiceRoundingAccount; Rec."Invoice Rounding Account")
                {
                    Caption = 'Invoice Rounding Account', Locked = true;
                }
                field(paymentDiscCreditAcc; Rec."Payment Disc. Credit Acc.")
                {
                    Caption = 'Payment Disc. Credit Acc.', Locked = true;
                }
                field(paymentDiscDebitAcc; Rec."Payment Disc. Debit Acc.")
                {
                    Caption = 'Payment Disc. Debit Acc.', Locked = true;
                }
                field(paymentToleranceCreditAcc; Rec."Payment Tolerance Credit Acc.")
                {
                    Caption = 'Payment Tolerance Credit Acc.', Locked = true;
                }
                field(paymentToleranceDebitAcc; Rec."Payment Tolerance Debit Acc.")
                {
                    Caption = 'Payment Tolerance Debit Acc.', Locked = true;
                }
                field(serviceChargeAcc; Rec."Service Charge Acc.")
                {
                    Caption = 'Service Charge Acc.', Locked = true;
                }
                field(viewAllAccountsOnLookup; Rec."View All Accounts on Lookup")
                {
                    Caption = 'View All Accounts on Lookup', Locked = true;
                }

                field(systemModifiedAt; Rec.SystemModifiedAt)
                {
                    Caption = 'systemModifiedAt', Locked = true;
                }

                field(replicationCounter; Rec."NPR Replication Counter")
                {
                    Caption = 'replicationCounter', Locked = true;
                }
            }
        }
    }

    trigger OnInit()
    begin
        CurrentTransactionType := TransactionType::Update;
    end;

}
