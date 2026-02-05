page 6059829 "NPR Trx JSON Result"
{
    ObsoleteState = Pending;
    ObsoleteTag = '2026-01-29';
    ObsoleteReason = 'This module is no longer being maintained';
    Extensible = false;
    Caption = 'Transactional JSON Result';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    ShowFilter = false;
    SourceTable = "NPR Trx JSON Result";
    SourceTableTemporary = true;
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(Name; Rec.Name)
                {

                    ToolTip = 'Specifies the value of the Name field';
                    ApplicationArea = NPRRetail;
                }
                field(Status; Rec.Status)
                {

                    ToolTip = 'Specifies the value of the Status field';
                    ApplicationArea = NPRRetail;
                }
                field(Created; Rec.Created)
                {

                    ToolTip = 'Specifies the value of the Created field';
                    ApplicationArea = NPRRetail;
                }
                field(ID; Rec.ID)
                {

                    ToolTip = 'Specifies the value of the ID field';
                    ApplicationArea = NPRRetail;
                }
                field("Entry No"; Rec."Entry No")
                {

                    ToolTip = 'Specifies the value of the Entry No field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    var
        TransactionalEmailMgt: Codeunit "NPR Transactional Email Mgt.";
    begin
        if Rec.IsEmpty() then
            TransactionalEmailMgt.GetSmartEmailList(Rec);
    end;

    var
        NewCaption: Text;

    internal procedure LoadRecords(var ResultsToShow: Record "NPR Trx JSON Result"; UseCaption: Text)
    begin
        if ResultsToShow.FindSet() then
            repeat
                Rec := ResultsToShow;
                Rec.Insert();
            until ResultsToShow.Next() = 0;
        NewCaption := UseCaption;
    end;
}

