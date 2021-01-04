page 6059916 "NPR Person Statistics"
{
    PageType = CardPart;
    UsageCategory = Administration;
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
                    ToolTip = 'Specifies the value of the age field';
                }
                field(gender; gender)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the gender field';
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