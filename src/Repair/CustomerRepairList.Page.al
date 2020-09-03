page 6014443 "NPR Customer Repair List"
{
    // 
    // //-NPR3.0a ved Nikolai Pedersen
    //   afgrænset så kun reperationer fra egen afdeling kan ses
    // NPR5.23/TS/20160603  CASE 243207 Added Filter <> Claimed
    // NPR5.25/TS/20160711 CASE 244140 Added Customer Repair Card
    // NPR5.26/TS/20160901  CASE 248351 Removed Filter <> Claimed
    // NPR5.30/BHR /20170217 CASE 262923 Add fields "Item No" and  "handed in date"
    // NPR5.48/TS  /20181206 CASE 338656 Added Missing Picture to Action
    // NPR5.55/YAHA/20200615 CASE 409873 Removed Customer Repair Card,Claimed list and all status list from new

    Caption = 'Customer Repair List';
    CardPageID = "NPR Customer Repair Card";
    Editable = false;
    PageType = List;
    SourceTable = "NPR Customer Repair";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Control6150614)
            {
                ShowCaption = false;
                field("No."; "No.")
                {
                    ApplicationArea = All;
                }
                field(Status; Status)
                {
                    ApplicationArea = All;
                }
                field("Customer No."; "Customer No.")
                {
                    ApplicationArea = All;
                }
                field(Name; Name)
                {
                    ApplicationArea = All;
                }
                field("Handed In Date"; "Handed In Date")
                {
                    ApplicationArea = All;
                }
                field("Item No."; "Item No.")
                {
                    ApplicationArea = All;
                }
                field(Worranty; Worranty)
                {
                    ApplicationArea = All;
                }
                field("Serial No."; "Serial No.")
                {
                    ApplicationArea = All;
                }
                field(Brand; Brand)
                {
                    ApplicationArea = All;
                }
                field("Global Dimension 1 Code"; "Global Dimension 1 Code")
                {
                    ApplicationArea = All;
                }
                field("Prices Including VAT"; "Prices Including VAT")
                {
                    ApplicationArea = All;
                }
                field("Expected Completion Date"; "Expected Completion Date")
                {
                    ApplicationArea = All;
                }
                field("Phone No."; "Phone No.")
                {
                    ApplicationArea = All;
                }
                field("Price when Not Accepted"; "Price when Not Accepted")
                {
                    ApplicationArea = All;
                }
            }
        }
        area(factboxes)
        {
            systempart(Control6014405; Notes)
            {
            }
        }
    }

    actions
    {
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
        if AllowFilter then
            SetFilter(Status, '%1|%2|%3|%4|%5|%6|%7', Status::"At Vendor", Status::"Awaits Approval", Status::Approved, Status::"Awaits Claiming", Status::"Return No Repair", Status::"Ready No Repair", Status::"To be sent")

        else
            SetFilter(Status, '%1', Status::Claimed);
    end;
}

