page 6059960 "NPR MCS Person Bus. Entities"
{
    // NPR5.48/JDH /20181109 CASE 334163 Added object caption

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
                field(PersonId; PersonId)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Person Id field';
                }
                field("Table Id"; "Table Id")
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

