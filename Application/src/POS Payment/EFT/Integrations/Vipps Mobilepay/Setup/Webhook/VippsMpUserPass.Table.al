table 6150780 "NPR Vipps Mp UserPass"
{
    DataClassification = CustomerContent;
    Access = Internal;
    Extensible = False;
    TableType = Temporary;

    fields
    {
        field(1; Id; Integer)
        {
            DataClassification = CustomerContent;
            AutoIncrement = True;

        }
        field(2; FriendlyNameId; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Config Name';

        }
        field(3; Username; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Username';

        }
        field(4; Password; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Password';
        }
    }
}