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
    ApplicationArea = All;

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
                    ToolTip = 'Specifies the value of the No. field';
                }
                field(Status; Status)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Status field';
                }
                field("Customer No."; "Customer No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Customer No. field';
                }
                field(Name; Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Name field';
                }
                field("Handed In Date"; "Handed In Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Handed In Date field';
                }
                field("Item No."; "Item No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Item No. field';
                }
                field(Worranty; Worranty)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Guarantee field';
                }
                field("Serial No."; "Serial No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Serial No. field';
                }
                field(Brand; Brand)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Brand field';
                }
                field("Global Dimension 1 Code"; "Global Dimension 1 Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Global Dimension 1 Code field';
                }
                field("Prices Including VAT"; "Prices Including VAT")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Prices Including VAT field';
                }
                field("Expected Completion Date"; "Expected Completion Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Expected Completion Date field';
                }
                field("Phone No."; "Phone No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Phone No. field';
                }
                field("Price when Not Accepted"; "Price when Not Accepted")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Price when Not Accepted field';
                }
            }
        }
        area(factboxes)
        {
            systempart(Control6014405; Notes)
            {
                ApplicationArea = All;
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

