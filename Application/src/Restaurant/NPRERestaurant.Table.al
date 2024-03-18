table 6150681 "NPR NPRE Restaurant"
{
    Access = Internal;
    Caption = 'Restaurant';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR NPRE Restaurants";
    LookupPageID = "NPR NPRE Restaurants";

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(10; Name; Text[50])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;
            Width = 50;
        }
        field(11; "Name 2"; Text[50])
        {
            Caption = 'Name 2';
            DataClassification = CustomerContent;
        }
        field(20; "Auto Send Kitchen Order"; Enum "NPR NPRE Auto Send Kitch.Order")
        {
            Caption = 'Auto Send Kitchen Order';
            DataClassification = CustomerContent;
        }
        field(21; "Resend All On New Lines"; Enum "NPR NPRE Send All on New Lines")
        {
            Caption = 'Resend All On New Lines';
            DataClassification = CustomerContent;
        }
        field(30; "Station Req. Handl. On Serving"; Enum "NPR NPRE Req.Handl.on Serving")
        {
            Caption = 'Station Req. Handl. On Serving';
            DataClassification = CustomerContent;
        }
        field(40; "Kitchen Printing Active"; Option)
        {
            Caption = 'Kitchen Printing Active';
            DataClassification = CustomerContent;
            OptionCaption = '<Default>,No,Yes';
            OptionMembers = Default,No,Yes;
        }
        field(45; "Print on POS Sale Cancel"; Option)
        {
            Caption = 'Print on POS Sale Cancel';
            DataClassification = CustomerContent;
            OptionCaption = '<Default>,No,Yes';
            OptionMembers = Default,No,Yes;
        }
        field(50; "KDS Active"; Option)
        {
            Caption = 'KDS Active';
            DataClassification = CustomerContent;
            OptionCaption = '<Default>,No,Yes';
            OptionMembers = Default,No,Yes;

            trigger OnValidate()
            var
                NotificationHandler: Codeunit "NPR NPRE Notification Handler";
                KitchenOrderMgt: Codeunit "NPR NPRE Kitchen Order Mgt.";
                SetupProxy: Codeunit "NPR NPRE Restaur. Setup Proxy";
                KDSActivated: Boolean;
            begin
                if IsTemporary() or ("KDS Active" = "KDS Active"::No) then
                    exit;
                Modify();
                KDSActivated := SetupProxy.KDSActivatedForAnyRestaurant();
                if KDSActivated then
                    KitchenOrderMgt.EnableKitchenOrderRetentionPolicy();
                NotificationHandler.CreateNotificationJobQueues(KDSActivated);
            end;
        }
        field(60; "Order ID Assign. Method"; Enum "NPR NPRE Ord.ID Assign. Method")
        {
            Caption = 'Order ID Assign. Method';
            DataClassification = CustomerContent;
        }
        field(70; "Service Flow Profile"; Code[20])
        {
            Caption = 'Service Flow Profile';
            DataClassification = CustomerContent;
            Description = 'NPR5.55';
            TableRelation = "NPR NPRE Serv.Flow Profile";
        }
        field(80; "Order Is Ready For Serving"; Enum "NPR NPRE Order Ready Serving")
        {
            Caption = 'Order Is Ready For Serving';
            DataClassification = CustomerContent;
        }
        field(90; "Default Number of Guests"; Enum "NPR NPRE Default No. of Guests")
        {
            Caption = 'Default Number of Guests';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Code") { }
    }
    fieldgroups
    {
        fieldgroup(Brick; Code, Name) { }
    }

    procedure ShowKitchenRequests()
    var
        KitchenRequest: Record "NPR NPRE Kitchen Request";
        KitchenRequests: Page "NPR NPRE Kitchen Req.";
    begin
        KitchenRequest.SetRange("Line Status",
          KitchenRequest."Line Status"::"Ready for Serving", KitchenRequest."Line Status"::Planned);
        KitchenRequest.SetRange("Restaurant Code", Code);

        Clear(KitchenRequests);
        KitchenRequests.SetViewMode(0);
        KitchenRequests.SetTableView(KitchenRequest);
        KitchenRequests.Run();
    end;
}
