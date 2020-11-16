page 6151371 "NPR CS Setup"
{
    Caption = 'CS Setup';
    PageType = Card;
    UsageCategory = Administration;
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
                field("Exclude Invt. Posting Groups"; "Exclude Invt. Posting Groups")
                {
                    ApplicationArea = All;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        exit(LookupInventoryPostingGroups(Text));
                    end;
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
                ApplicationArea = All;
            }
            action(Users)
            {
                Caption = 'Users';
                Image = Employee;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "NPR CS Users";
                ApplicationArea = All;
            }
            action("Communication Log")
            {
                Caption = 'Communication Log';
                Image = Log;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "NPR CS Comm. Log List";
                ApplicationArea = All;
            }
            action(Devices)
            {
                Caption = 'Devices';
                Image = MiniForm;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "NPR CS Devices";
                ApplicationArea = All;
            }
            action("Posting Buffer")
            {
                Caption = 'Posting Buffer';
                Image = PostBatch;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "NPR CS Posting Buffer";
                ApplicationArea = All;
            }
            action("Whse. Activity Type Setup")
            {
                Caption = 'Whse. Activity Type Setup';
                Image = SetupLines;
                RunObject = Page "NPR CS Wareh. Activity Setup";
                ApplicationArea = All;
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
                    ApplicationArea = All;
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
                    ApplicationArea = All;
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
                    ApplicationArea = All;
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
                    ApplicationArea = All;
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
                    ApplicationArea = All;
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
                    ApplicationArea = All;
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
                    ApplicationArea = All;
                }
                action("Update Item Cross. Ref.")
                {
                    Caption = 'Update Item Cross. Ref.';
                    Image = UpdateDescription;
                    ApplicationArea = All;
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

