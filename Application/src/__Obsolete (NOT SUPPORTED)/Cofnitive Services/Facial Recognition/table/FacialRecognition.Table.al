table 6059915 "NPR Facial Recognition"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'Refractored to old code MCS Face Recognition';
    DataClassification = CustomerContent;
    Caption = 'Facial Recognition';
    fields
    {
        field(1; "Entry No."; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(2; "Contact No."; Code[20])
        {
            Caption = 'Contact ID';
            DataClassification = CustomerContent;
        }
        field(3; "Json Response"; Blob)
        {
            Caption = 'Json Response';
            DataClassification = CustomerContent;
        }
        field(4; "Person Group"; Text[1024])
        {
            Caption = 'Person Group';
            DataClassification = CustomerContent;
        }
        field(5; "Person ID"; Text[1024])
        {
            Caption = 'Person ID';
            DataClassification = CustomerContent;
        }
        field(6; "Face ID"; Text[1024])
        {
            Caption = 'Face ID';
            DataClassification = CustomerContent;
        }
        field(7; Gender; Text[1024])
        {
            Caption = 'Gender';
            DataClassification = CustomerContent;
        }
        field(8; Age; Text[1024])
        {
            Caption = 'Age';
            DataClassification = CustomerContent;
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