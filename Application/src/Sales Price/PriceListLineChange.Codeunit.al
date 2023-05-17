codeunit 6150950 "NPR Price List Line Change"
{
    Access = Internal;

    local procedure FindPriceChange(Rec: Record "Price List Line")
    var
        PriceChangeHistory: Record "NPR Price Change History";
    begin
        if Rec.Status <> Rec.Status::Active then
            exit;
#IF BC17 OR BC18 OR BC19 OR BC20
        PriceChangeHistory.SetRange("Product No.", Rec."Asset No.");
#ELSE
        PriceChangeHistory.SetRange("Product No.", Rec."Product No.");
#ENDIF
        PriceChangeHistory.SetRange("Asset Type", PriceChangeHistory."Asset Type"::Item);
        PriceChangeHistory.SetRange("Unit of Measure Code", Rec."Unit of Measure Code");
        PriceChangeHistory.SetRange("Variant Code", Rec."Variant Code");
        PriceChangeHistory.SetRange("Price List Code", Rec."Price List Code");

        if PriceChangeHistory.FindLast() then;

        if PriceChangeHistory."Unit Price" = Rec."Unit Price" then
            exit;

        PriceChangeHistory.Init();
        PriceChangeHistory.TransferFields(Rec);
        PriceChangeHistory."Price Change Date" := CurrentDateTime();
        PriceChangeHistory."Entry No." := 0;
        PriceChangeHistory.Insert();
    end;

    [EventSubscriber(ObjectType::Table, Database::"Price List Line", 'OnAfterModifyEvent', '', false, false)]
    local procedure PriceListLineOnAfterModify(var Rec: Record "Price List Line")
    begin
        FindPriceChange(Rec);
    end;
}