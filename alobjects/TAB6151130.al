table 6151130 "TM Seating Setup"
{
    // TM1.36/TSA/20180830  CASE 322432 Transport TM1.36 - 30 August 2018
    // TM1.39/NPKNAV/20190125  CASE 343941 Transport TM1.39 - 25 January 2019
    // TM1.45/TSA /20191113 CASE 322432 Added Template Cache

    Caption = 'Seating Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Admission Code"; Code[20])
        {
            Caption = 'Admission Code';
            DataClassification = CustomerContent;
            TableRelation = "TM Admission";
        }
        field(10; "Seat Numbering"; Option)
        {
            Caption = 'Seat Numbering';
            DataClassification = CustomerContent;
            OptionCaption = 'Left to Right,Right to Left';
            OptionMembers = LEFT_TO_RIGHT,RIGHT_TO_LEFT;
        }
        field(15; "Row Numbering"; Option)
        {
            Caption = 'Row Numbering';
            DataClassification = CustomerContent;
            OptionCaption = 'Top to Bottom,Bottom to Top';
            OptionMembers = TOP_TO_BOTTOM,BOTTOM_TO_TOP;
        }
        field(20; "Template Cache"; Option)
        {
            Caption = 'Template Cache';
            DataClassification = CustomerContent;
            OptionCaption = ' ,Admission,Admission & Schedule,Timeslot';
            OptionMembers = NO_CACHE,ADMIN,SCHEDULE,ENTRY;
        }
    }

    keys
    {
        key(Key1; "Admission Code")
        {
        }
    }

    fieldgroups
    {
    }
}

