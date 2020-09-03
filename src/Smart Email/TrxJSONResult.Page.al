page 6059829 "NPR Trx JSON Result"
{
    // NPR5.38/THRO/20171018 CASE 286713 Object created
    // NPR5.55/THRO/20200511 CASE 343266 Multiple Providers

    Caption = 'Transactional JSON Result';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    ShowFilter = false;
    SourceTable = "NPR Trx JSON Result";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Name; Name)
                {
                    ApplicationArea = All;
                }
                field(Status; Status)
                {
                    ApplicationArea = All;
                }
                field(Created; Created)
                {
                    ApplicationArea = All;
                }
                field(ID; ID)
                {
                    ApplicationArea = All;
                }
                field("Entry No"; "Entry No")
                {
                    ApplicationArea = All;
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
        if IsEmpty then
            //-NPR5.55 [343266]
            TransactionalEmailMgt.GetSmartEmailList(Rec);
        //+NPR5.55 [343266]
    end;

    var
        NewCaption: Text;

    procedure LoadRecords(var ResultsToShow: Record "NPR Trx JSON Result"; UseCaption: Text)
    begin
        if ResultsToShow.FindSet then
            repeat
                Rec := ResultsToShow;
                Rec.Insert;
            until ResultsToShow.Next = 0;
        NewCaption := UseCaption;
    end;
}

