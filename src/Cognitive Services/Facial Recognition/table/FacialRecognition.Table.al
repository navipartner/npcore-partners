table 6059915 "NPR Facial Recognition"
{
    fields
    {
        field(1; "Entry No."; Integer)
        {
        }
        field(2; "Contact No."; Code[20])
        {
            Caption = 'Contact ID';
        }
        field(3; "Json Response"; Blob)
        {
            Caption = 'Json Response';
        }
        field(4; "Person Group"; Text[1024])
        {
            Caption = 'Person Group';
        }
        field(5; "Person ID"; Text[1024])
        {
            Caption = 'Person ID';
        }
        field(6; "Face ID"; Text[1024])
        {
            Caption = 'Face ID';
        }
        field(7; Gender; Text[1024])
        {
            Caption = 'Gender';
        }
        field(8; Age; Text[1024])
        {
            Caption = 'Age';
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
    }
}