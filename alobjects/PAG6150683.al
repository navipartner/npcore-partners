page 6150683 "NPRE Restaurants"
{
    // NPR5.54/ALPO/20200401 CASE 382428 Kitchen Display System (KDS) for NP Restaurant

    Caption = 'Restaurants';
    CardPageID = "NPRE Restaurant Card";
    Editable = false;
    PageType = List;
    SourceTable = "NPRE Restaurant";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code";Code)
                {
                }
                field(Name;Name)
                {
                }
                field("Name 2";"Name 2")
                {
                    Visible = false;
                }
            }
        }
        area(factboxes)
        {
            systempart(Control6014406;Notes)
            {
                Visible = false;
            }
            systempart(Control6014407;Links)
            {
                Visible = false;
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group(Kitchen)
            {
                Caption = 'Kitchen';
                action(KitchenStations)
                {
                    Caption = 'Stations';
                    Image = Departments;
                    RunObject = Page "NPRE Kitchen Stations";
                    RunPageLink = "Restaurant Code"=FIELD(Code);
                }
                action(KitchenStationSelection)
                {
                    Caption = 'Station Selection Setup';
                    Image = Troubleshoot;
                    RunObject = Page "NPRE Kitchen Station Selection";
                    RunPageLink = "Restaurant Code"=FIELD(Code);
                }
            }
        }
    }
}

