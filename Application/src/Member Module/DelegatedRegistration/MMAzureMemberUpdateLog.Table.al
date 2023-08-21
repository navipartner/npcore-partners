table 6060015 "NPR MM AzureMemberUpdateLog"
{
    DataClassification = CustomerContent;
    Access = Internal;

    fields
    {
        field(1; EntryNo; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
            AutoIncrement = true;
        }
        field(10; SetupCode; Code[10])
        {
            Caption = 'Setup Code';
            DataClassification = CustomerContent;
        }
        field(15; DataSubjectId; Text[64])
        {
            Caption = 'Data Subject Id';
            DataClassification = CustomerContent;
        }
        field(20; NotificationAddress; Text[100])
        {
            Caption = 'Notification Address';
            DataClassification = CustomerContent;
        }
        field(30; RequestCreated; DateTime)
        {
            Caption = 'Request Created';
            DataClassification = CustomerContent;
        }
        field(35; ResponseReceived; DateTime)
        {
            Caption = 'Response Received';
            DataClassification = CustomerContent;
        }
        field(40; RegistrationMethod; Enum "NPR MM AzureRegistrationMethod")
        {
            Caption = 'Registration Method';
            DataClassification = CustomerContent;
        }
        field(45; Token; Text[100])
        {
            Caption = 'Token';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; EntryNo)
        {
            Clustered = true;
        }
        key(Key2; DataSubjectId)
        {
        }
        key(Key3; NotificationAddress)
        {
        }
        key(Key4; RegistrationMethod, Token)
        {
        }
    }
}