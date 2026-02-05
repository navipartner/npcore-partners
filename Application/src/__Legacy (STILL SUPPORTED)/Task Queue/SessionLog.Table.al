table 6059908 "NPR Session Log"
{
    Access = Internal;
    Caption = 'Session Log';
    DataPerCompany = false;
    DataClassification = CustomerContent;
    ObsoleteState = Removed;
    ObsoleteTag = '2023-06-28';
    ObsoleteReason = 'Task Queue module removed from NP Retail. We are now using Job Queue instead.';

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(9; "Log Type"; Option)
        {
            Caption = 'Entry Type';
            OptionCaption = ',Login,Logout,,Login Tread,Error Starting Tread';
            OptionMembers = ,LoginMaster,LogoutMaster,,LoginTread,ErrorStartingTread;
            DataClassification = CustomerContent;
        }
        field(10; "Log Time"; DateTime)
        {
            Caption = 'Starting Time';
            DataClassification = CustomerContent;
        }
        field(20; "User ID"; Code[50])
        {
            Caption = 'User ID';
            DataClassification = EndUserIdentifiableInformation;

        }
        field(21; "Task Worker Group"; Code[10])
        {
            Caption = 'Task Worker Group';
            DataClassification = CustomerContent;
        }
        field(22; "Server Instance ID"; Integer)
        {
            Caption = 'Server Instance ID';
            DataClassification = CustomerContent;
        }
        field(30; "Company Name"; Text[30])
        {
            Caption = 'Company Name';
            DataClassification = CustomerContent;
        }
        field(40; "Error Message"; Text[250])
        {
            Caption = 'Error Message';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
        }
    }
}
