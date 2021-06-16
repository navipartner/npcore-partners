table 6150681 "NPR NPRE Restaurant"
{
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
        field(20; "Auto Send Kitchen Order"; Option)
        {
            Caption = 'Auto Send Kitchen Order';
            DataClassification = CustomerContent;
            OptionCaption = 'Default,No,Yes,Ask';
            OptionMembers = Default,No,Yes,Ask;
        }
        field(21; "Resend All On New Lines"; Option)
        {
            Caption = 'Resend All On New Lines';
            DataClassification = CustomerContent;
            OptionCaption = 'Default,No,Yes,Ask';
            OptionMembers = Default,No,Yes,Ask;
        }
        field(30; "Station Req. Handl. On Serving"; Option)
        {
            Caption = 'Station Req. Handl. On Serving';
            DataClassification = CustomerContent;
            OptionCaption = 'Default,Do Nothing,Finish Started,Finish All,Finish Started/Cancel Not Started,Cancel All Unfinished';
            OptionMembers = Default,"Do Nothing","Finish Started","Finish All","Finish Started/Cancel Not Started","Cancel All Unfinished";
        }
        field(40; "Kitchen Printing Active"; Option)
        {
            Caption = 'Kitchen Printing Active';
            DataClassification = CustomerContent;
            OptionCaption = 'Default,No,Yes';
            OptionMembers = Default,No,Yes;
        }
        field(50; "KDS Active"; Option)
        {
            Caption = 'KDS Active';
            DataClassification = CustomerContent;
            OptionCaption = 'Default,No,Yes';
            OptionMembers = Default,No,Yes;
        }
        field(60; "Order ID Assign. Method"; Option)
        {
            Caption = 'Order ID Assign. Method';
            DataClassification = CustomerContent;
            OptionCaption = 'Default,Same for Source Document,New Each Time';
            OptionMembers = Default,"Same for Source Document","New Each Time";
        }
        field(70; "Service Flow Profile"; Code[20])
        {
            Caption = 'Service Flow Profile';
            DataClassification = CustomerContent;
            Description = 'NPR5.55';
            TableRelation = "NPR NPRE Serv.Flow Profile";
        }
    }

    keys
    {
        key(Key1; "Code")
        {
        }
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
