page 6059960 "NPR MCS Person Bus. Entities"
{

    Caption = 'MCS Person Business Entities';
    PageType = List;
    SourceTable = "NPR MCS Person Bus. Entit.";
    UsageCategory = Lists;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(PersonId; Rec.PersonId)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Person Id field';
                }
                field("Table Id"; Rec."Table Id")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Table Id field';
                }
                field(KeyText; KeyText)
                {
                    ApplicationArea = All;
                    ShowCaption = false;
                    ToolTip = 'Specifies the value of the KeyText field';
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        KeyText := Format(Rec.Key);
    end;

    var
        KeyText: Text;
}

