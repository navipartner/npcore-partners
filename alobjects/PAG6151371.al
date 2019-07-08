page 6151371 "CS Setup"
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

    Caption = 'CS Setup';
    PageType = Card;
    SourceTable = "CS Setup";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Enable Capture Service";"Enable Capture Service")
                {
                }
                field("Log Communication";"Log Communication")
                {
                }
                field("Web Service Is Published";"Web Service Is Published")
                {
                }
                field("Warehouse Type";"Warehouse Type")
                {
                }
                field("Media Library";"Media Library")
                {
                }
                field("Zero Def. Qty. to Handle";"Zero Def. Qty. to Handle")
                {
                }
            }
            group(Control6014409)
            {
                Caption = 'Stock-Take';
                field("Filter Worksheets by Location";"Filter Worksheets by Location")
                {
                }
                field("Error On Invalid Barcode";"Error On Invalid Barcode")
                {
                }
                field("Aggregate Stock-Take Summarize";"Aggregate Stock-Take Summarize")
                {
                }
            }
            group(RFID)
            {
                Caption = 'RFID';
                field("Stock-Take Template";"Stock-Take Template")
                {
                }
            }
            group("Price Calculation")
            {
                Caption = 'Price Calculation';
                field("Price Calc. Customer No.";"Price Calc. Customer No.")
                {
                }
            }
            group(Search)
            {
                Caption = 'Search';
                field("Max Records In Search Result";"Max Records In Search Result")
                {
                }
            }
            group(Worksheets)
            {
                Caption = 'Worksheets';
                field("Item Reclass. Jour Temp Name";"Item Reclass. Jour Temp Name")
                {
                }
                field("Item Reclass. Jour Batch Name";"Item Reclass. Jour Batch Name")
                {
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
                RunObject = Page "CS UIs";
            }
            action(Users)
            {
                Caption = 'Users';
                Image = Employee;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "CS Users";
            }
            action("Communication Log")
            {
                Caption = 'Communication Log';
                Image = Log;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "CS Communication Log List";
            }
            action(Devices)
            {
                Caption = 'Devices';
                Image = MiniForm;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "CS Devices";
            }
            group("Stock-Take")
            {
                Caption = 'Stock-Take';
                action(Worksheet)
                {
                    Caption = 'Worksheet';
                    Image = Worksheet;
                    //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                    //PromotedCategory = Process;
                    //The property 'PromotedIsBig' can only be set if the property 'Promoted' is set to 'true'
                    //PromotedIsBig = true;
                    RunObject = Page "Stock-Take Worksheet";
                }
                action(Counting)
                {
                    Caption = 'Counting';
                    Image = Worksheet2;
                    //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                    //PromotedCategory = Process;
                    //The property 'PromotedIsBig' can only be set if the property 'Promoted' is set to 'true'
                    //PromotedIsBig = true;
                    RunObject = Page "CS Stock-Take Handling";
                }
                action(Data)
                {
                    Caption = 'Data';
                    Image = DataEntry;
                    //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                    //PromotedCategory = Process;
                    //The property 'PromotedIsBig' can only be set if the property 'Promoted' is set to 'true'
                    //PromotedIsBig = true;
                    RunObject = Page "CS Stock-Takes Data";
                }
            }
            group(Rfid)
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
                    RunObject = Page "CS Rfid Tag Models";
                }
            }
        }
    }
}

