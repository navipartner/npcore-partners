table 6059928 "NPR CMOrder"
{
    Access = Internal;
    Caption = 'OTA Channel Manager Order';
    DataClassification = CustomerContent;

    fields
    {
        field(1; OrderId; Guid)
        {
            DataClassification = CustomerContent;
            Caption = 'Order Id';
            NotBlank = true;
        }

        field(5; DocumentNo; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Buy-from Order Reference';
        }

        field(10; PartnerId; Guid)
        {
            DataClassification = CustomerContent;
            Caption = 'Partner Id';
            NotBlank = true;
            TableRelation = "NPR CMPartnerSetup".PartnerId;
        }

        field(20; SellToOrderReference; Code[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Sell-to Order Reference';
        }

        field(30; SellToEmail; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Sell-to Email';
            ExtendedDatatype = EMail;
        }

        field(40; SellToName; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Sell-to Name';
        }

        field(50; SellToLanguage; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Sell-to Language';
            TableRelation = Language.Code;
        }

        field(60; PaymentReference; Code[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Payment Reference';
        }

        field(70; Status; Enum "NPR CMOrderStatus")
        {
            DataClassification = CustomerContent;
            Caption = 'Status';
            InitValue = Draft;
        }
        field(75; StatusMessage; Text[500])
        {
            DataClassification = CustomerContent;
            Caption = 'Status Message';
        }
        field(80; ReceivedAt; DateTime)
        {
            DataClassification = CustomerContent;
            Caption = 'Received At';
        }

        field(100; JobId; Code[40])
        {
            DataClassification = CustomerContent;
            Caption = 'Job Id';
            TableRelation = "NPR TM ImportTicketHeader".JobId;
        }

        field(110; ManifestId; Guid)
        {
            DataClassification = CustomerContent;
            Caption = 'Manifest Id';
        }

        field(120; ManifestUrl; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'Manifest URL';
            ExtendedDatatype = URL;
        }
    }

    keys
    {
        key(Key1; OrderId)
        {
            Clustered = true;
        }

        key(Key2; PartnerId, SellToOrderReference)
        {
            Clustered = false;
            Unique = true;
        }

        key(Key3; PartnerId, ReceivedAt)
        {
            Clustered = false;
        }

        key(Key4; ReceivedAt)
        {
            Clustered = false;
        }

        key(Key5; JobId)
        {
            Clustered = false;
        }

        key(Key6; Status, ReceivedAt)
        {
            Clustered = false;
        }

#IF NOT (BC17 or BC18 or BC19 or BC20)
        key(KeySync; SystemRowVersion)
        {
        }
#ENDIF
    }

    fieldgroups
    {
        fieldgroup(DropDown; SellToOrderReference, SellToName)
        {
        }
    }

    internal procedure GetStatusStyle() StatusStyle: Text
    begin
        case Rec.Status of
            Rec.Status::Issued:
                StatusStyle := 'Favorable';
            Rec.Status::Draft:
                StatusStyle := 'Subordinate';
            Rec.Status::Cancelled:
                StatusStyle := 'Unfavorable';
            Rec.Status::Error:
                StatusStyle := 'Unfavorable';
            Rec.Status::Processing:
                StatusStyle := 'Attention';
            else
                StatusStyle := 'Standard';
        end;
    end;
}
