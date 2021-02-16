page 6014404 "NPR SMS Setup"
{
    Caption = 'NPR SMS Setup';
    PageType = Card;
    SourceTable = "NPR SMS Setup";
    PromotedActionCategories = 'New,Tasks,Reports,Display';
    RefreshOnActivate = true;
    UsageCategory = Administration;
    ApplicationArea = All;
    DeleteAllowed = false;
    InsertAllowed = false;

    layout
    {
        area(content)
        {

        }
    }

    trigger OnOpenPage()
    begin
        if not Rec.Get() then
            Rec.Insert();
    end;
}