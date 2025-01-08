table 6151010 "NPR SG ImageProfile"
{
    Access = Internal;
    DataClassification = CustomerContent;
    Caption = 'Image Profile Line';
    LookupPageId = "NPR SG ImageProfileList";

    fields
    {
        field(1; "Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Code';
        }

        field(10; Description; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Description';
        }
        field(11; TemporaryImageBuffer; Media)
        {
            // This field is used to store the temporary image while image processing is in progress.
            Caption = 'Temporary Image Buffer';
            DataClassification = CustomerContent;
        }

        field(20; AnonymousMemberAvatar; Media)
        {
            Caption = 'Anonymous Member Avatar';
            DataClassification = CustomerContent;
        }

        field(30; ReadyImage; Media)
        {
            Caption = 'Ready Image';
            DataClassification = CustomerContent;
        }
        field(40; SuccessImage; Media)
        {
            Caption = 'Success Image';
            DataClassification = CustomerContent;
        }
        field(41; TicketSuccessImage; Media)
        {
            Caption = 'Ticket Success Image';
            DataClassification = CustomerContent;
        }
        field(42; MemberCardSuccessImage; Media)
        {
            Caption = 'Member Card Success Image';
            DataClassification = CustomerContent;
        }
        field(43; WalletSuccessImage; Media)
        {
            Caption = 'Wallet Success Image';
            DataClassification = CustomerContent;
        }
        field(44; CityCardSuccessImage; Media)
        {
            Caption = 'City Card Success Image';
            DataClassification = CustomerContent;
        }
        field(50; ErrorImage; Media)
        {
            Caption = 'Error Image';
            DataClassification = CustomerContent;
        }

        field(60; SuccessTimeout; Integer)
        {
            Caption = 'Success Timeout (ms)';
            DataClassification = CustomerContent;
            Initvalue = 3000;
        }
        field(70; ErrorTimeout; Integer)
        {
            Caption = 'Error Timeout (ms)';
            DataClassification = CustomerContent;
            Initvalue = 5000;
        }
    }


    keys
    {
        key(Key1; Code)
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        fieldgroup(Main; Code, Description)
        {
            Caption = 'Image Profiles for Speedgate';
        }
    }

}