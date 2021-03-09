page 6059829 "NPR Trx JSON Result"
{
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
        area(content)
        {
            repeater(Group)
            {
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Name field';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Status field';
                }
                field(Created; Rec.Created)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Created field';
                }
                field(ID; Rec.ID)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the ID field';
                }
                field("Entry No"; Rec."Entry No")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Entry No field';
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

    procedure LoadRecords(var ResultsToShow: Record "NPR Trx JSON Result"; UseCaption: Text)
    begin
        if ResultsToShow.FindSet() then
            repeat
                Rec := ResultsToShow;
                Rec.Insert();
            until ResultsToShow.Next() = 0;
        NewCaption := UseCaption;
    end;
}

