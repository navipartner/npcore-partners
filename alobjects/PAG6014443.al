page 6014443 "Customer Repair List"
{
    // 
    // //-NPR3.0a ved Nikolai Pedersen
    //   afgr�nset s� kun reperationer fra egen afdeling kan ses
    // NPR5.23/TS/20160603  CASE 243207 Added Filter <> Claimed
    // NPR5.25/TS/20160711 CASE 244140 Added Customer Repair Card
    // NPR5.26/TS/20160901  CASE 248351 Removed Filter <> Claimed
    // NPR5.30/BHR /20170217 CASE 262923 Add fields "Item No" and  "handed in date"
    // NPR5.48/TS  /20181206 CASE 338656 Added Missing Picture to Action

    Caption = 'Customer Repair List';
    CardPageID = "Customer Repair Card";
    Editable = false;
    PageType = List;
    SourceTable = "Customer Repair";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Control6150614)
            {
                ShowCaption = false;
                field("No.";"No.")
                {
                }
                field(Status;Status)
                {
                }
                field("Customer No.";"Customer No.")
                {
                }
                field(Name;Name)
                {
                }
                field("Handed In Date";"Handed In Date")
                {
                }
                field("Item No.";"Item No.")
                {
                }
                field(Worranty;Worranty)
                {
                }
                field("Serial No.";"Serial No.")
                {
                }
                field(Brand;Brand)
                {
                }
                field("Global Dimension 1 Code";"Global Dimension 1 Code")
                {
                }
                field("Prices Including VAT";"Prices Including VAT")
                {
                }
                field("Expected Completion Date";"Expected Completion Date")
                {
                }
                field("Phone No.";"Phone No.")
                {
                }
                field("Price when Not Accepted";"Price when Not Accepted")
                {
                }
            }
        }
        area(factboxes)
        {
            systempart(Control6014405;Notes)
            {
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Customer Repair Card")
            {
                Caption = 'Customer Repair Card';
                Image = New;
                Promoted = true;
                RunObject = Page "Customer Repair Card";
                RunPageMode = Create;
            }
            action("Claimed List")
            {
                Caption = 'Claimed List';
                Image = List;
                Promoted = true;
                ShortCutKey = 'F5';

                trigger OnAction()
                var
                    CustomerRepair: Record "Customer Repair";
                    CustomerRepairList: Page "Customer Repair List";
                begin
                    SetFilterStatus(false);
                end;
            }
            action("All Status List")
            {
                Caption = 'All Status List';
                Image = Status;
                Promoted = true;

                trigger OnAction()
                begin
                    SetFilterStatus(true);
                end;
            }
        }
    }

    trigger OnInit()
    begin
        
        //-NPR3.0a
        /*kasseNr := retailformcode.HentKassenummer;
        kasseRec.GET(kasseNr);
        globVal := kasseRec."Shortcut Dimension 1 Code";*/
        //+NPR3.0a

    end;

    trigger OnOpenPage()
    begin
        SetFilterStatus(true);
        //-NPR3.0a
        //Rec.SETRANGE("Global Dimension 1 Code", globVal);
        //+NPR3.0a
    end;

    local procedure SetFilterStatus(AllowFilter: Boolean)
    begin
        if AllowFilter  then
          SetFilter(Status,'%1|%2|%3|%4|%5|%6|%7',Status::"At Vendor",Status::"Awaits Approval",Status::Approved,Status::"Awaits Claiming",Status::"Return No Repair",Status::"Ready No Repair",Status::"To be sent")

         else
          SetFilter(Status,'%1',Status::Claimed);
    end;
}

