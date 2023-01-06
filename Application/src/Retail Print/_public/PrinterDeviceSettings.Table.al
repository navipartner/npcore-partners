table 6059808 "NPR Printer Device Settings"
{
    TableType = Temporary;
    DataClassification = CustomerContent;

    fields
    {
        field(2; Name; Text[50])
        {
            DataClassification = CustomerContent;
        }
        field(4; "Data Type"; Option)
        {
            OptionMembers = Text,"Integer",Decimal,Date,Boolean,Option;
            DataClassification = CustomerContent;
        }
        field(5; Value; Text[250])
        {
            DataClassification = CustomerContent;
        }
        field(6; Options; Text[250])
        {
            DataClassification = CustomerContent;
        }
    }
}