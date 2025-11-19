page 6185084 "NPR APIV1 PBI MembPaymMethods"
{
    Extensible = false;
    Caption = 'PowerBI Member Payment Methods';
    APIGroup = 'powerBI';
    APIPublisher = 'navipartner';
    APIVersion = 'v1.0';
    EntitySetName = 'memberPaymentMethods';
    EntityName = 'memberPaymentMethod';
    PageType = API;
    DataAccessIntent = ReadOnly;
    DelayedInsert = true;
    Editable = false;
    SourceTable = "NPR MM Member Payment Method";

    layout
    {
        area(Content)
        {
            repeater(PaymentMethodRepeater)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'Id', Locked = true;
                }
                field(entryNo; Rec."Entry No.")
                {
                    Caption = 'Entry No.', Locked = true;
                }
                field(psp; Rec.PSP)
                {
                    Caption = 'PSP', Locked = true;
                }
                field(status; Rec.Status)
                {
                    Caption = 'Status', Locked = true;
                }
                field(paymentInstrumentType; Rec."Payment Instrument Type")
                {
                    Caption = 'Payment Instrument Type', Locked = true;
                }
                field(paymentBrand; Rec."Payment Brand")
                {
                    Caption = 'Payment Brand', Locked = true;
                }
                field(maskedPAN; Rec."Masked PAN")
                {
                    Caption = 'Masked PAN', Locked = true;
                }
                field(expiryDate; Rec."Expiry Date")
                {
                    Caption = 'Expiry Date', Locked = true;
                }
                field(shopperReference; Rec."Shopper Reference")
                {
                    Caption = 'Shopper Reference', Locked = true;
                }
                field(paymentMethodAlias; Rec."Payment Method Alias")
                {
                    Caption = 'Payment Method Alias', Locked = true;
                }
                field(paymentToken; Rec."Payment Token")
                {
                    Caption = 'Payment Token', Locked = true;
                }
                field(panLast4Digits; Rec."PAN Last 4 Digits")
                {
                    Caption = 'PAN Last 4 Digits', Locked = true;
                }
#if not (BC17 or BC18 or BC19 or BC20)
                field(systemRowVersion; Rec.SystemRowVersion)
                {
                    Caption = 'System Row Version', Locked = true;
                }
#endif
            }
        }
    }
}