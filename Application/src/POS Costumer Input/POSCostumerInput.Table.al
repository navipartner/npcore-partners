table 6059810 "NPR POS Costumer Input"
{
    DataClassification = CustomerContent;
    Access = Internal;
    Extensible = False;
    LookupPageId = "NPR POS Costumer Input";
    DrillDownPageId = "NPR POS Costumer Input";

    fields
    {
        field(1; Context; Enum "NPR POS Costumer Input Context")
        {
            DataClassification = CustomerContent;
        }
        //This field is a JS 2 dimension array in string representation.
        //First level is the index of which line is being drawn.
        //Second level is the points of that line that is beeing drawn.
        //[0]->[(x_1,y_1), ... , (x_n,y_n)]
        //[1]->[(x_1,y_2), ... , (x_k,y_k)]
        field(2; Signature; Blob)
        {
            DataClassification = CustomerContent;
        }
        field(3; "Phone Number"; Text[50])
        {
            DataClassification = CustomerContent;
        }
        field(4; "Date & Time"; DateTime)
        {
            DataClassification = CustomerContent;
        }
        field(5; "POS Entry No."; Integer)
        {
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Entry";
        }

    }
    keys
    {
        key(Key1; "POS Entry No.")
        {

        }
    }
}