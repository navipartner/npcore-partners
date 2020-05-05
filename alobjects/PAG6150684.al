page 6150684 "NPRE Restaurant Card"
{
    // NPR5.54/ALPO/20200401 CASE 382428 Kitchen Display System (KDS) for NP Restaurant

    Caption = 'Restaurant Card';
    PageType = Card;
    PromotedActionCategories = 'New,Process,Report,Kitchen';
    SourceTable = "NPRE Restaurant";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Code";Code)
                {
                }
                field(Name;Name)
                {
                }
                field("Name 2";"Name 2")
                {
                }
            }
            group("Kitchen Integration")
            {
                Caption = 'Kitchen Integration';
                field("Auto Send Kitchen Order";"Auto Send Kitchen Order")
                {
                }
                field("Resend All On New Lines";"Resend All On New Lines")
                {
                }
                group(Print)
                {
                    Caption = 'Print';
                    field("Kitchen Printing Active";"Kitchen Printing Active")
                    {
                    }
                }
                group(KDS)
                {
                    Caption = 'KDS';
                    Visible = ShowKDS;
                    field("KDS Active";"KDS Active")
                    {
                    }
                    field("Order ID Assign. Method";"Order ID Assign. Method")
                    {
                    }
                }
            }
        }
        area(factboxes)
        {
            systempart(Control6014412;Notes)
            {
            }
            systempart(Control6014413;Links)
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
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
                    RunObject = Page "NPRE Kitchen Stations";
                    RunPageLink = "Restaurant Code"=FIELD(Code);
                }
                action(KitchenStationSelection)
                {
                    Caption = 'Station Selection Setup';
                    Image = Troubleshoot;
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
                    RunObject = Page "NPRE Kitchen Station Selection";
                    RunPageLink = "Restaurant Code"=FIELD(Code);
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        KitchenOrderMgt: Codeunit "NPRE Kitchen Order Mgt.";
    begin
        ShowKDS := KitchenOrderMgt.KDSAvailable();
    end;

    var
        ShowKDS: Boolean;
}

