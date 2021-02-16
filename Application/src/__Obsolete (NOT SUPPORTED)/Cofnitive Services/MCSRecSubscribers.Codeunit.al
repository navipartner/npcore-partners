codeunit 6060088 "NPR MCS Rec. Subscribers"
{
    // NPR5.32/BR  /20170523 CASE 252646 Object Created
    ObsoleteState = Pending;
    ObsoleteReason = 'On February 15, 2018, “Recommendations API is no longer under active development”';

    trigger OnRun()
    begin
    end;

    [EventSubscriber(ObjectType::Page, 42, 'OnAfterActionEvent', 'NPR SelectRecommendedItem', false, false)]
    local procedure P42OnActionSelectRecommendedItem(var Rec: Record "Sales Header")
    var
        MCSSelectRecomforSales: Codeunit "NPR MCS Select Recom. Sales";
    begin
        MCSSelectRecomforSales.SelectRecommendedItem(Rec);
    end;
}

