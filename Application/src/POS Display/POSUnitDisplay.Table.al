table 6014698 "NPR POS Unit Display"
{
    DataClassification = CustomerContent;
    Description = 'A table that contains device specific information, not suited for the Display Profile table (DisplaySetup)';
#IF NOT BC17
    Access = Internal;
#ENDIF
    Extensible = False;
    fields
    {
        field(1; POSUnit; Code[10])
        {
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Unit";


        }
        field(2; "Media Downloaded"; Boolean)
        {
            DataClassification = CustomerContent;
            InitValue = false;
        }
        field(3; "Screen No."; Integer)
        {
            DataClassification = CustomerContent;
            InitValue = 0;
        }
    }

    keys
    {
        key(Key1; POSUnit)
        {
            Clustered = true;
        }
    }

}