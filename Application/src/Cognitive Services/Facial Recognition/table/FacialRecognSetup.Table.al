table 6059916 "NPR Facial Recogn. Setup"
{
    DataClassification = CustomerContent;
    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(2; BaseURL; Text[1024])
        {
            Caption = 'Base URL';
            DataClassification = CustomerContent;
        }
        field(3; APIKey; Text[1024])
        {
            Caption = 'API Key';
            DataClassification = CustomerContent;
        }
        field(4; PersonGroupURI; Text[1024])
        {
            Caption = 'Person Group URI';
            DataClassification = CustomerContent;
        }
        field(5; PersonURI; Text[1024])
        {
            Caption = 'Person URI';
            DataClassification = CustomerContent;
        }
        field(6; DetectFaceURI; Text[1024])
        {
            Caption = 'Detect Face URI';
            DataClassification = CustomerContent;
        }
        field(7; PersonFaceURI; Text[1024])
        {
            Caption = 'Add Person Face URI';
            DataClassification = CustomerContent;
        }
        field(8; TrainPersonGroupURI; Text[1024])
        {
            Caption = 'Train Person Group URI';
            DataClassification = CustomerContent;
        }
        field(9; IdentifyPersonURI; Text[1024])
        {
            Caption = 'Identify Person URI';
            DataClassification = CustomerContent;
        }
        field(10; Active; Boolean)
        {
            Caption = 'Activate';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; Code)
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    begin
        CreateDefaultValues();
    end;

    local procedure CreateDefaultValues()
    begin
        Code := 'Facial Recognition';
        BaseURL := 'https://northeurope.api.cognitive.microsoft.com/face/v1.0';
        APIKey := '8bbe2f04fa3e4160b76d60220e6d01a6';
        PersonGroupURI := '/persongroups/';
        PersonURI := '/persons/';
        DetectFaceURI := '/detect/';
        PersonFaceURI := '/persistedFaces/';
        TrainPersonGroupURI := '/train/';
        IdentifyPersonURI := '/identify/';
    end;
}