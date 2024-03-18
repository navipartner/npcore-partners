table 6150792 "NPR NPRE Notification Setup"
{
    Access = Internal;
    Caption = 'Restaurant Notification Setup';
    DataClassification = CustomerContent;
    LookupPageId = "NPR NPRE Notification Setup";
    DrillDownPageId = "NPR NPRE Notification Setup";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(10; "Notification Trigger"; Enum "NPR NPRE Notification Trigger")
        {
            Caption = 'Notification Trigger';
            DataClassification = CustomerContent;
        }
        field(20; "Restaurant Code"; Code[20])
        {
            Caption = 'Restaurant Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR NPRE Restaurant";
        }
        field(30; "Production Restaurant Code"; Code[20])
        {
            Caption = 'Production Restaurant Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR NPRE Restaurant";

            trigger OnValidate()
            var
                KitchenStation: Record "NPR NPRE Kitchen Station";
            begin
                if ("Production Restaurant Code" <> xRec."Production Restaurant Code") and ("Kitchen Station" <> '') then
                    if not KitchenStation.Get("Production Restaurant Code", "Kitchen Station") then
                        Validate("Kitchen Station", '');
            end;
        }
        field(40; "Kitchen Station"; Code[20])
        {
            Caption = 'Kitchen Station';
            DataClassification = CustomerContent;
            TableRelation = "NPR NPRE Kitchen Station".Code WHERE("Restaurant Code" = FIELD("Production Restaurant Code"));
        }
        field(100; "E-Mail Notification"; Boolean)
        {
            Caption = 'E-Mail Notification';
            DataClassification = CustomerContent;
        }
        field(110; "E-Mail Notif. Template"; Code[20])
        {
            Caption = 'E-Mail Notif. Template';
            DataClassification = CustomerContent;
            TableRelation = "NPR E-mail Template Header".Code where("Table No." = const(6150793));
        }
        field(120; "Sms Notification"; Boolean)
        {
            Caption = 'Sms Notification';
            DataClassification = CustomerContent;
        }
        field(130; "Sms Notif. Template"; Code[10])
        {
            Caption = 'Sms Notif. Template';
            DataClassification = CustomerContent;
            TableRelation = "NPR SMS Template Header".Code where("Table No." = const(6150793));
        }
        field(140; Recipient; Enum "NPR NPRE Notif. Recipient")
        {
            Caption = 'Recipient';
            DataClassification = CustomerContent;
        }
        field(150; "User ID (Recipient)"; Code[50])
        {
            Caption = 'User ID (Recipient)';
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = User."User Name";
            ValidateTableRelation = false;

            trigger OnValidate()
            var
                UserSelection: Codeunit "User Selection";
            begin
                UserSelection.ValidateUserName("User ID (Recipient)");
            end;
        }
        field(160; "Notification Expires in (sec.)"; Integer)
        {
            Caption = 'Notification Expires in (sec.)';
            DataClassification = CustomerContent;
            MinValue = 0;
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(Key2; "Notification Trigger", "Restaurant Code", "Production Restaurant Code", "Kitchen Station") { }
    }
}