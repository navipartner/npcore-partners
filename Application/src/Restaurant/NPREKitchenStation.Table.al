table 6150682 "NPR NPRE Kitchen Station"
{
    Caption = 'Kitchen Station';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR NPRE Kitchen Stations";
    LookupPageID = "NPR NPRE Kitchen Stations";

    fields
    {
        field(1; "Restaurant Code"; Code[20])
        {
            Caption = 'Restaurant Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR NPRE Restaurant";
        }
        field(2; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(10; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(11; "Description 2"; Text[50])
        {
            Caption = 'Description 2';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Restaurant Code", "Code")
        {
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "Code", Description, "Description 2", "Restaurant Code")
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
        KitchenRequest.SetRange("Production Status",
          KitchenRequest."Production Status"::"Not Started", KitchenRequest."Production Status"::"On Hold");
        KitchenRequest.SetRange("Production Restaurant Filter", "Restaurant Code");
        KitchenRequest.SetRange("Kitchen Station Filter", Code);
        KitchenRequest.SetRange("Applicable for Kitchen Station", true);

        Clear(KitchenRequests);
        KitchenRequests.SetViewMode(1);
        KitchenRequests.SetTableView(KitchenRequest);
        KitchenRequests.Run;
    end;
}