page 6151371 "NPR CS Setup"
{
    // NPR5.41/CLVA/20180329 CASE 306407 Object created - NP Capture Service
    // NPR5.43/CLVA/20180511 CASE 307239 Added field Error On Invalid Barcode
    // NPR5.43/NPKNAV/20180629  CASE 304872 Transport NPR5.43 - 29 June 2018
    // NPR5.47/CLVA/20181011 CASE 307282 Added field "Max Records In Search Result"
    // NPR5.47/CLVA/20181019 CASE 318296 Added actiongroup Demo
    // NPR5.48/CLVA/20181113 CASE 335606 Added field "Warehouse Type"
    // NPR5.48/CLVA/20181214 CASE 335606 Added field Media Library
    // NPR5.49/TJ  /20190220 CASE 346066 Added field "Zero Def. Qty. to Handle"
    // NPR5.50/CLVA/20190425 CASE 352134 Deleted Action "Cleanup demo data"
    // NPR5.50/CLVA/20190304 CASE 332844 Added field "Stock-Take Template"
    //                                   Added Group RFID
    // NPR5.50/CLVA/20190515 CASE 350696 Added action "Devices" and "Stock-Take" > "Data"
    // NPR5.50/CLVA/20190527 CASE 355694 Added field "Item Reclass. Jour Temp Name" and "Item Reclass. Jour Batch Name"
    // NPR5.51/CLVA/20190610 CASE 356107 Added action "Warehouse Receipt"
    // NPR5.51/CLVA/20190627 CASE 359375 Added field Create Worksheet after Trans. for re-creation of worksheet after Stock-Take transfer
    // NPR5.51/CLVA/20190812 CASE 362173 Added Group Physical Inventory Counting
    // NPR5.51/CLVA/20190823 CASE 365967 Added action Posting Buffer and Store Users
    // NPR5.52/CLVA/20190904 CASE 365967 Added Group "Job Queue" and field "Sum Qty. to Handle"
    // NPR5.52/CLVA/20190905 CASE 365967 Added action Stores
    // NPR5.52/CLVA/20190916 CASE 368484 Added action Store Users
    // NPR5.53/CLVA/20191125 CASE 377467 Added action Schedule
    // NPR5.53/CLVA/20191128 CASE 379973 Added field "Earliest Start Date/Time"
    // NPR5.53/CLVA/20191125 CASE 377467 Added action "Counting Supervisor"
    // NPR5.54/CLVA/20202003 CASE 389224 Added field "Batch Size"
    // NPR5.55/CLVA/20200604 CASE 379709 Added Group "Ship & Receive"
    // NPR5.55/CLVA/20200608 CASE 379709 Added action "Update Item Cross. Ref."
    // NPR5.55/ALST/20200727 CASE 415521 added field Disregard Unknown RFID Tags
    // NPR5.55/ALPO/20200729 CASE 404663 Added action "Whse. Activity Type Setup"

    Caption = 'CS Setup';
    PageType = Card;
    SourceTable = "NPR CS Setup";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Enable Capture Service"; "Enable Capture Service")
                {
                    ApplicationArea = All;
                }
                field("Log Communication"; "Log Communication")
                {
                    ApplicationArea = All;
                }
                field("Web Service Is Published"; "Web Service Is Published")
                {
                    ApplicationArea = All;
                }
                field("Warehouse Type"; "Warehouse Type")
                {
                    ApplicationArea = All;
                }
                field("Media Library"; "Media Library")
                {
                    ApplicationArea = All;
                }
                field("Zero Def. Qty. to Handle"; "Zero Def. Qty. to Handle")
                {
                    ApplicationArea = All;
                }
                field("Sum Qty. to Handle"; "Sum Qty. to Handle")
                {
                    ApplicationArea = All;
                }
            }
            group("Stock-Take")
            {
                Caption = 'Stock-Take';
                field("Filter Worksheets by Location"; "Filter Worksheets by Location")
                {
                    ApplicationArea = All;
                }
                field("Error On Invalid Barcode"; "Error On Invalid Barcode")
                {
                    ApplicationArea = All;
                }
                field("Aggregate Stock-Take Summarize"; "Aggregate Stock-Take Summarize")
                {
                    ApplicationArea = All;
                }
                field("Create Worksheet after Trans."; "Create Worksheet after Trans.")
                {
                    ApplicationArea = All;
                }
            }
            group(RFID)
            {
                Caption = 'RFID';
                field("Stock-Take Template"; "Stock-Take Template")
                {
                    ApplicationArea = All;
                }
                field("Earliest Start Date/Time"; "Earliest Start Date/Time")
                {
                    ApplicationArea = All;
                }
                field("Batch Size"; "Batch Size")
                {
                    ApplicationArea = All;
                }
                field("Disregard Unknown RFID Tags"; "Disregard Unknown RFID Tags")
                {
                    ApplicationArea = All;
                }
            }
            group("Ship & Receive")
            {
                Caption = 'Ship & Receive';
                field("Import Tags to Shipping Doc."; "Import Tags to Shipping Doc.")
                {
                    ApplicationArea = All;
                }
                field("Use Whse. Receipt"; "Use Whse. Receipt")
                {
                    ApplicationArea = All;
                }
            }
            group("Price Calculation")
            {
                Caption = 'Price Calculation';
                field("Price Calc. Customer No."; "Price Calc. Customer No.")
                {
                    ApplicationArea = All;
                }
            }
            group(Search)
            {
                Caption = 'Search';
                field("Max Records In Search Result"; "Max Records In Search Result")
                {
                    ApplicationArea = All;
                }
            }
            group(Worksheets)
            {
                Caption = 'Worksheets';
                field("Item Reclass. Jour Temp Name"; "Item Reclass. Jour Temp Name")
                {
                    ApplicationArea = All;
                }
                field("Item Reclass. Jour Batch Name"; "Item Reclass. Jour Batch Name")
                {
                    ApplicationArea = All;
                }
            }
            group("Physical Inventory Counting")
            {
                Caption = 'Physical Inventory Counting';
                field("Phys. Inv Jour Temp Name"; "Phys. Inv Jour Temp Name")
                {
                    ApplicationArea = All;
                }
                field("Phys. Inv Jour No. Series"; "Phys. Inv Jour No. Series")
                {
                    ApplicationArea = All;
                }
            }
            group("Job Queue")
            {
                Caption = 'Job Queue';
                field("Post with Job Queue"; "Post with Job Queue")
                {
                    ApplicationArea = All;
                }
                field("Job Queue Category Code"; "Job Queue Category Code")
                {
                    ApplicationArea = All;
                }
                field("Notify On Success"; "Notify On Success")
                {
                    ApplicationArea = All;
                }
                field("Run in User Session"; "Run in User Session")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(UIs)
            {
                Caption = 'UIs';
                Image = MiniForm;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "NPR CS UIs";
            }
            action(Users)
            {
                Caption = 'Users';
                Image = Employee;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "NPR CS Users";
            }
            action("Communication Log")
            {
                Caption = 'Communication Log';
                Image = Log;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "NPR CS Comm. Log List";
            }
            action(Devices)
            {
                Caption = 'Devices';
                Image = MiniForm;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "NPR CS Devices";
            }
            action("Posting Buffer")
            {
                Caption = 'Posting Buffer';
                Image = PostBatch;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "NPR CS Posting Buffer";
            }
            action("Whse. Activity Type Setup")
            {
                Caption = 'Whse. Activity Type Setup';
                Image = SetupLines;
                RunObject = Page "NPR CS Wareh. Activity Setup";
            }
            group(Stores)
            {
                Caption = 'Stores';
                action(List)
                {
                    Caption = 'List';
                    Image = BusinessRelation;
                    Promoted = false;
                    //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                    //PromotedCategory = Process;
                    //The property 'PromotedIsBig' can only be set if the property 'Promoted' is set to 'true'
                    //PromotedIsBig = true;
                    RunObject = Page "NPR POS Store List";
                }
                action("Store Users")
                {
                    Caption = 'Store Users';
                    Image = Employee;
                    Promoted = false;
                    //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                    //PromotedCategory = Process;
                    //The property 'PromotedIsBig' can only be set if the property 'Promoted' is set to 'true'
                    //PromotedIsBig = true;
                    RunObject = Page "NPR CS Store Users";
                }
                action(Countings)
                {
                    Caption = 'Countings';
                    Image = Worksheet2;
                    Promoted = false;
                    //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                    //PromotedCategory = Process;
                    //The property 'PromotedIsBig' can only be set if the property 'Promoted' is set to 'true'
                    //PromotedIsBig = true;
                    RunObject = Page "NPR CS Stock-Takes List";
                }
                action(Schedule)
                {
                    Caption = 'Schedule';
                    Image = Planning;
                    //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                    //PromotedCategory = Process;
                    //The property 'PromotedIsBig' can only be set if the property 'Promoted' is set to 'true'
                    //PromotedIsBig = true;
                    RunObject = Page "NPR CS Counting Schedule";
                }
                action("Counting Supervisor")
                {
                    Caption = 'Counting Supervisor';
                    Image = Employee;
                    Promoted = false;
                    //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                    //PromotedCategory = Process;
                    //The property 'PromotedIsBig' can only be set if the property 'Promoted' is set to 'true'
                    //PromotedIsBig = true;
                    RunObject = Page "NPR CS Counting Supervisor";
                }
            }
            group(RfidActionGroup)
            {
                Caption = 'Rfid';
                action("Tag Models")
                {
                    Caption = 'Tag Models';
                    Image = ItemGroup;
                    //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                    //PromotedCategory = Process;
                    //The property 'PromotedIsBig' can only be set if the property 'Promoted' is set to 'true'
                    //PromotedIsBig = true;
                    RunObject = Page "NPR CS Rfid Tag Models";
                }
                action("Counting Data")
                {
                    Caption = 'Counting Data';
                    Image = DataEntry;
                    //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                    //PromotedCategory = Process;
                    //The property 'PromotedIsBig' can only be set if the property 'Promoted' is set to 'true'
                    //PromotedIsBig = true;
                    RunObject = Page "NPR CS Stock-Takes Data";
                }
                action("Update Item Cross. Ref.")
                {
                    Caption = 'Update Item Cross. Ref.';
                    Image = UpdateDescription;
                    //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                    //PromotedCategory = Process;

                    trigger OnAction()
                    var
                        CSHelperFunctions: Codeunit "NPR CS Helper Functions";
                    begin
                        CSHelperFunctions.UpdateItemCrossRef();
                    end;
                }
            }
        }
    }
}

