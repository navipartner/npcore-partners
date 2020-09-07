page 6059916 "NPR Person Statistics"
{
    PageType = CardPart;
    Caption = ' ';

    layout
    {
        area(Content)
        {
            group(GroupName)
            {
                Caption = ' ';
                field(age; age)
                {
                    ApplicationArea = All;
                }
                field(gender; gender)
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    var
        age: Text;
        gender: Text;

    procedure SetValues(var _age: Text; _gender: Text)
    begin
        age := _age;
        gender := _gender;
    end;

    procedure ResetValues()
    begin
        age := '';
        gender := '';
    end;
}