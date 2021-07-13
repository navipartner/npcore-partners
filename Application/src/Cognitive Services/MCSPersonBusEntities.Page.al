page 6059960 "NPR MCS Person Bus. Entities"
{

    Caption = 'MCS Person Business Entities';
    PageType = List;
    SourceTable = "NPR MCS Person Bus. Entit.";
    UsageCategory = Lists;
    ApplicationArea = NPRRetail;


    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(PersonId; Rec.PersonId)
                {

                    ToolTip = 'Specifies the value of the Person Id field';
                    ApplicationArea = NPRRetail;
                }
                field("Table Id"; Rec."Table Id")
                {

                    ToolTip = 'Specifies the value of the Table Id field';
                    ApplicationArea = NPRRetail;
                }
                field(KeyText; KeyText)
                {

                    ShowCaption = false;
                    ToolTip = 'Specifies the value of the KeyText field';
                    ApplicationArea = NPRRetail;
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

