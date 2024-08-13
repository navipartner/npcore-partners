page 6184729 "NPR RS EI Paym. Method Step"
{
    Caption = 'Payment Method Mapping';
    Extensible = false;
    PageType = ListPart;
    SourceTable = "NPR RS EI Payment Method Mapp.";
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            repeater(PaymentMethodMappingLines)
            {
                field("Payment Method Code"; Rec."Payment Method Code")
                {
                    ApplicationArea = NPRRSEInvoice;
                    ToolTip = 'Specifies the value of the Payment Method Code field.';
                }
                field("RS EI Payment Means"; Rec."RS EI Payment Means")
                {
                    ApplicationArea = NPRRSEInvoice;
                    ToolTip = 'Specifies the value of the RS EI Payment Means field.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action("Init")
            {
                ApplicationArea = NPRRSEInvoice;
                Caption = 'Init Payment Methods';
                Image = Start;
                ToolTip = 'Initialize RS E-Invoice Payment Method Mapping with non existing Payment Methods';
                trigger OnAction()
                var
                    RSEIPaymentMethodMapping: Record "NPR RS EI Payment Method Mapp.";
                    PaymentMethod: Record "Payment Method";
                begin
                    if PaymentMethod.IsEmpty() then
                        exit;
                    PaymentMethod.FindSet();
                    repeat
                        if not RSEIPaymentMethodMapping.Get(PaymentMethod.Code) then begin
                            RSEIPaymentMethodMapping.Init();
                            RSEIPaymentMethodMapping."Payment Method Code" := PaymentMethod.Code;
                            RSEIPaymentMethodMapping.Insert();
                        end;
                    until PaymentMethod.Next() = 0;
                end;
            }
        }
    }
    internal procedure CopyRealToTemp()
    begin
        if not RSEIPaymentMethodMapp.FindSet() then
            exit;
        repeat
            Rec.TransferFields(RSEIPaymentMethodMapp);
            if not Rec.Insert() then
                Rec.Modify();
        until RSEIPaymentMethodMapp.Next() = 0;
    end;

    internal procedure RSEIPaymentMethodMappingDataToCreate(): Boolean
    begin
        exit(CheckIsDataSet());
    end;

    internal procedure CreateRSEIPaymentMethodMappingData()
    begin
        if not Rec.FindSet() then
            exit;
        repeat
            RSEIPaymentMethodMapp.TransferFields(Rec);
            if not RSEIPaymentMethodMapp.Insert() then
                RSEIPaymentMethodMapp.Modify();
        until Rec.Next() = 0;
    end;

    local procedure CheckIsDataSet(): Boolean
    begin
        if not Rec.FindSet() then
            exit(false);
        repeat
            if (Rec."Payment Method Code" <> '') then
                exit(true);
        until Rec.Next() = 0;
    end;

    var
        RSEIPaymentMethodMapp: Record "NPR RS EI Payment Method Mapp.";
}