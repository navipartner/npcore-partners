table 6151371 "CS Setup"
{
    // NPR5.41/CLVA/20180313 CASE 306407 Object created - NP Capture Service
    // NPR5.43/CLVA/20180511 CASE 307239 Added field Error Invalid Barcode
    // NPR5.43/NPKNAV/20180629 CASE 304872 Transport NPR5.43 - 29 June 2018
    // NPR5.47/CLVA/20181011 CASE 307282 Added field "Max Records In Search Result"
    // NPR5.48/CLVA/20181113 CASE 335606 Added field "Warehouse Type"
    // NPR5.48/CLVA/20181214 CASE 335606 Added field Media Library
    // NPR5.49/TJ  /20190218 CASE 346066 Added field "Zero Def. Qty. to Handle"
    // NPR5.50/CLVA/20190304 CASE 332844 Added field "Stock-Take Template"
    // NPR5.50/CLVA/20190527 CASE 355694 Added field "Item Reclass. Jour Temp Name" and "Item Reclass. Jour Batch Name"
    // NPR5.51/CLVA/20190627 CASE 359375 Added field Create Worksheet after Trans. for re-creation of worksheet after Stock-Take transfer
    // NPR5.51/CLVA/20190812 CASE 362173 Added field "Phys. Inv Jour Temp Name" and "Phys. Inv Jour No. Series"
    // NPR5.52/CLVA/20190904 CASE 365967 Added field "Post with Job Queue", "Job Queue Category Code","Job Queue Priority for Post","Notify On Success","Run in User Session" and "Sum Qty. to Handle"
    // NPR5.53/CLVA/20191128 CASE 379973 Added field "Earliest Start Date/Time"
    // NPR5.54/CLVA/20202003 CASE 389224 Added field "Batch Size"

    Caption = 'CS Setup';

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
        }
        field(11; "Enable Capture Service"; Boolean)
        {
            Caption = 'Enable Capture Service';

            trigger OnValidate()
            var
                CSHelperFunctions: Codeunit "CS Helper Functions";
            begin
                CSHelperFunctions.PublishWebService(Rec."Enable Capture Service");
            end;
        }
        field(12; "Log Communication"; Boolean)
        {
            Caption = 'Log Communication';
        }
        field(13; "Web Service Is Published"; Boolean)
        {
            CalcFormula = Exist ("Web Service" WHERE("Object Type" = CONST(Codeunit),
                                                     "Service Name" = CONST('cs_service')));
            Caption = 'Web Service Is Published';
            Editable = false;
            FieldClass = FlowField;
        }
        field(14; "Filter Worksheets by Location"; Boolean)
        {
            Caption = 'Filter Worksheets by Location';
            Description = 'Filtering Worksheets by User Location';
        }
        field(15; "Error On Invalid Barcode"; Boolean)
        {
            Caption = 'Error On Invalid Barcode';
            Description = 'Show alert on IOS if barcode is invalid';
        }
        field(16; "Price Calc. Customer No."; Code[20])
        {
            Caption = 'Price Calc. Customer No.';
            TableRelation = Customer;
        }
        field(17; "Max Records In Search Result"; Integer)
        {
            Caption = 'Max Records In Search Result';
            InitValue = 100;
        }
        field(18; "Aggregate Stock-Take Summarize"; Boolean)
        {
            Caption = 'Aggregate Stock-Take Summarize';
        }
        field(19; "Warehouse Type"; Option)
        {
            Caption = 'Warehouse Type';
            OptionCaption = 'Basic,Advanced,Advanced (Bins)';
            OptionMembers = Basic," Advanced"," Advanced (Bins)";

            trigger OnValidate()
            var
                CSUIHeader: Record "CS UI Header";
            begin
                if "Warehouse Type" <> xRec."Warehouse Type" then
                    if Confirm(TXT001, true) then
                        CSUIHeader.ModifyAll("Warehouse Type", "Warehouse Type", true);
            end;
        }
        field(20; "Media Library"; Option)
        {
            Caption = 'Media Library';
            OptionCaption = 'Dynamics NAV,Magento';
            OptionMembers = "Dynamics NAV",Magento;
        }
        field(22; "Stock-Take Template"; Code[10])
        {
            Caption = 'Stock-Take Template';
            TableRelation = "Stock-Take Template";
        }
        field(23; "Zero Def. Qty. to Handle"; Boolean)
        {
            Caption = 'Zero Def. Qty. to Handle';
        }
        field(24; "Item Reclass. Jour Temp Name"; Code[10])
        {
            Caption = 'Item Reclass. Jour Temp Name';
            TableRelation = "Item Journal Template";
        }
        field(25; "Item Reclass. Jour Batch Name"; Code[10])
        {
            Caption = 'Item Reclass. Jour Batch Name';
            TableRelation = "Item Journal Batch".Name WHERE("Journal Template Name" = FIELD("Item Reclass. Jour Temp Name"));
        }
        field(26; "Create Worksheet after Trans."; Boolean)
        {
            Caption = 'Create Worksheet after Trans.';
        }
        field(27; "Phys. Inv Jour Temp Name"; Code[10])
        {
            Caption = 'Phys. Inv Jour Temp Name';
            TableRelation = "Item Journal Template";
        }
        field(28; "Phys. Inv Jour No. Series"; Code[10])
        {
            Caption = 'Phys. Inv Jour No. Series';
            TableRelation = "No. Series";
        }
        field(29; "Sum Qty. to Handle"; Boolean)
        {
            Caption = 'Sum Qty. to Handle';
        }
        field(38; "Post with Job Queue"; Boolean)
        {
            Caption = 'Post with Job Queue';
        }
        field(39; "Job Queue Category Code"; Code[10])
        {
            Caption = 'Job Queue Category Code';
            TableRelation = "Job Queue Category";
        }
        field(40; "Job Queue Priority for Post"; Integer)
        {
            Caption = 'Job Queue Priority for Post';
            ObsoleteState = Removed;
            ObsoleteReason = 'Target field Prioriti on Job Queue Entry is removed!';
        }
        field(41; "Notify On Success"; Boolean)
        {
            Caption = 'Notify On Success';
        }
        field(42; "Run in User Session"; Boolean)
        {
            Caption = 'Run in User Session';
        }
        field(43; "Earliest Start Date/Time"; DateTime)
        {
            Caption = 'Earliest Start Date/Time';
        }
        field(44; "Batch Size"; Integer)
        {
            Caption = 'Batch Size';
            MaxValue = 1000;
            MinValue = 10;
        }
    }

    keys
    {
        key(Key1; "Primary Key")
        {
        }
    }

    fieldgroups
    {
    }

    var
        DCHelperFunctions: Codeunit "CS Helper Functions";
        TXT001: Label 'Update Wharehouse Type on all UIs?';
        TXT002: Label 'Job Queue Priority must be zero or positive.';
}

