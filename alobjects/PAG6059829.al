page 6059829 "Transactional JSON Result"
{
    // NPR5.38/THRO/20171018 CASE 286713 Object created

    Caption = 'Transactional JSON Result';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    ShowFilter = false;
    SourceTable = "Transactional JSON Result";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Name;Name)
                {
                }
                field(Status;Status)
                {
                }
                field(Created;Created)
                {
                }
                field(ID;ID)
                {
                }
                field("Entry No";"Entry No")
                {
                }
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    var
        CampaignMonitorMgt: Codeunit "CampaignMonitor Mgt.";
    begin
        if IsEmpty then
          CampaignMonitorMgt.GetSmartEmailList(Rec);
    end;

    var
        NewCaption: Text;

    procedure LoadRecords(var ResultsToShow: Record "Transactional JSON Result";UseCaption: Text)
    begin
        if ResultsToShow.FindSet then
          repeat
            Rec := ResultsToShow;
            Rec.Insert;
          until ResultsToShow.Next = 0;
        NewCaption := UseCaption;
    end;
}

