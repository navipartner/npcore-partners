page 6059960 "MCS Person Business Entities"
{
    // NPR5.48/JDH /20181109 CASE 334163 Added object caption

    Caption = 'MCS Person Business Entities';
    PageType = List;
    SourceTable = "MCS Person Business Entities";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(PersonId; PersonId)
                {
                    ApplicationArea = All;
                }
                field("Table Id"; "Table Id")
                {
                    ApplicationArea = All;
                }
                field(KeyText; KeyText)
                {
                    ApplicationArea = All;
                    ShowCaption = false;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        KeyText := Format(Key);
    end;

    var
        KeyText: Text;
}

